#!/bin/bash
# Generic DedeBIZ new-site deploy. Params via env: DOMAIN STYLE DB DBU DBP BASEHOST SQLURL THEMEURL THEMEDIR
set +e
BASE=/home/u133275855/domains
SRC=$BASE/mantap88.click/public_html
D=$BASE/$DOMAIN/public_html
L=$D/_log.txt
G=$D/.deploy_done
say(){ echo "$(date +%T) $*" | tee -a "$L"; }
[ -f "$G" ] && { echo "already done"; exit 0; }
mkdir -p "$D"; : > "$L"
say "START $DOMAIN style=$STYLE db=$DB"

# 1. core clone (prefix-agnostic DedeBIZ core; skip content/theme/caches)
for it in system admin apps user install static index.php; do
  [ -e "$SRC/$it" ] && cp -a "$SRC/$it" "$D/" 2>>"$L"
done
# data dir: copy then strip source caches/sessions/backups
cp -a "$SRC/data" "$D/" 2>>"$L"
rm -rf "$D/data/backupdata" "$D/data"/sessions_* "$D/data/tplcache" 2>>"$L"
rm -f "$D/data/config.cache.inc.php" "$D/data/config.cache.bak.inc.php" 2>>"$L"
say "core copied: $(ls "$D" | tr '\n' ' ')"

# 2. fresh common.inc.php (biz_ prefix, new DB)
cat > "$D/data/common.inc.php" <<PHP
<?php
\$cfg_dbhost = 'localhost';
\$cfg_dbname = '$DB';
\$cfg_dbuser = '$DBU';
\$cfg_dbpwd = '$DBP';
\$cfg_dbprefix = 'biz_';
\$cfg_db_language = 'utf8mb4';
PHP
php -l "$D/data/common.inc.php" >>"$L" 2>&1

# 3. import full SQL dump
curl -fsSL "$SQLURL" -o /tmp/${STYLE}.sql 2>>"$L"
say "sql bytes: $(wc -c </tmp/${STYLE}.sql)"
mysql -h localhost -u "$DBU" -p"$DBP" "$DB" < /tmp/${STYLE}.sql 2>>"$L" && say "sql imported OK" || say "sql import ERR"
TC=$(mysql -N -h localhost -u "$DBU" -p"$DBP" "$DB" -e "SELECT COUNT(*) FROM biz_sysconfig" 2>>"$L")
say "biz_sysconfig rows: $TC"

# 4. set production basehost + style
mysql -h localhost -u "$DBU" -p"$DBP" "$DB" 2>>"$L" <<SQL
UPDATE biz_sysconfig SET value='$BASEHOST' WHERE varname='cfg_basehost';
UPDATE biz_sysconfig SET value='$STYLE' WHERE varname='cfg_df_style';
SQL

# 5. theme
mkdir -p "$D/theme"
curl -fsSL "$THEMEURL" -o /tmp/${STYLE}_theme.tgz 2>>"$L"
tar xzf /tmp/${STYLE}_theme.tgz -C /tmp 2>>"$L"
rm -rf "$D/theme/$STYLE"
mv "/tmp/$THEMEDIR" "$D/theme/$STYLE" 2>>"$L"
[ -f "$D/theme/$STYLE/favicon.ico" ] && cp "$D/theme/$STYLE/favicon.ico" "$D/favicon.ico"
say "theme: $(ls "$D/theme/$STYLE" | tr '\n' ' ')"

# 6. rebuild data/config.cache.inc.php from biz_sysconfig (DedeBIZ format: one $cfg_ per line)
php -r '
$c=include "'"$D"'/data/common.inc.php";
$m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno){fwrite(STDERR,"db fail\n");exit;}
$m->set_charset("utf8mb4");
$o="<"."?php\n";
$r=$m->query("SELECT varname,value,type FROM biz_sysconfig");
while($x=$r->fetch_assoc()){ $v=$x["value"]; if($x["type"]=="number"&&$v!==""){$o.="\$".$x["varname"]." = ".$v.";\n";} else {$o.="\$".$x["varname"]." = \x27".str_replace("\x27","\\\x27",$v)."\x27;\n";} }
file_put_contents("'"$D"'/data/config.cache.inc.php",$o);
echo "config.cache rebuilt: ".strlen($o)." bytes\n";
' >>"$L" 2>&1

# 7. admin password dual-hash -> admin/Admin#2026
php -r '
include "'"$D"'/data/common.inc.php";
$m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno)exit;
$pw="Admin#2026"; $old=substr(md5($pw),5,20); $new=password_hash($pw,PASSWORD_BCRYPT);
$m->query("UPDATE biz_admin SET pwd=\x27$old\x27, pwd_new=\x27".$m->real_escape_string($new)."\x27, userid=\x27admin\x27 WHERE id=1 OR userid=\x27admin\x27 LIMIT 1");
echo "admin pw set rows=".$m->affected_rows."\n";
' >>"$L" 2>&1

# 8. scrub .htaccess of any source-brand redirect rules
[ -f "$D/.htaccess" ] && sed -i -E '/mrpokies\.online|mantap88\.click|ong777|365cuci/d' "$D/.htaccess"

# 9. generate static HTML via DedeBIZ CLI (homepage, all categories, all articles)
cd "$D"
php -r '
define("DEDEADMIN","'"$D"'/admin");
require "'"$D"'/system/common.inc.php";
require_once DEDEINC."/archive/partview.class.php";
$row=$dsql->GetOne("SELECT * FROM `#@__homepageset`");
$tpl=str_replace("{style}",$GLOBALS["cfg_df_style"],$row["templet"]);
$pv=new PartView(); $GLOBALS["_arclistEnv"]="index";
$pv->SetTemplet($cfg_basedir.$cfg_templets_dir."/".$tpl);
$pv->SaveToHtml($cfg_basedir."/index.html");
echo "homepage generated\n";
' >>"$L" 2>&1

php -r '
require "'"$D"'/system/common.inc.php";
require_once DEDEINC."/archive/listview.class.php";
$r=$dsql->Execute2("SELECT id FROM `#@__arctype` WHERE ispart=0 OR ispart IS NULL");
$ids=array(); $q=$dsql->Query("SELECT id FROM `#@__arctype`"); while($a=$dsql->GetArray()) $ids[]=$a["id"];
foreach($ids as $tid){ $lv=new ListView((int)$tid); $lv->MakeHtml(1,0); echo "cat $tid\n"; }
' >>"$L" 2>&1

php -r '
require "'"$D"'/system/common.inc.php";
require_once DEDEINC."/archive/archives.class.php";
$dsql->Execute("SELECT id FROM `#@__archives`"); $ids=array(); while($a=$dsql->GetArray()) $ids[]=$a["id"];
foreach($ids as $aid){ $arc=new Archives((int)$aid); if(!$arc->IsError){ $arc->MakeHtml(0); } echo "art $aid\n"; }
' >>"$L" 2>&1

say "DONE $DOMAIN"
touch "$G"
