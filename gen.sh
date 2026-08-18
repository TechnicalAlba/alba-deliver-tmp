#!/bin/bash
# DedeBIZ static regen, one PHP process per item (MakeHtml exits). Env: DOMAIN STYLE DB DBU DBP
set +e
D=/home/u133275855/domains/$DOMAIN/public_html
L=$D/_gen.txt; : > "$L"
rm -f "$D/default.php"
mkdir -p "$D/data/tplcache" && chmod 777 "$D/data/tplcache"
touch "$D/.htaccess"
grep -q "DirectoryIndex index.html" "$D/.htaccess" || sed -i '1i DirectoryIndex index.html index.php' "$D/.htaccess"
export D_ROOT="$D" DOMAIN STYLE
echo "$(date +%T) GEN $DOMAIN style=$STYLE" >>"$L"

BOOT='$D=getenv("D_ROOT");
$_SERVER["HTTP_HOST"]=getenv("DOMAIN");$_SERVER["SERVER_NAME"]=getenv("DOMAIN");
$_SERVER["REQUEST_URI"]="/";$_SERVER["SCRIPT_NAME"]="/index.php";$_SERVER["REMOTE_ADDR"]="127.0.0.1";$_SERVER["HTTP_USER_AGENT"]="cli";
chdir($D); require $D."/system/common.inc.php"; $GLOBALS["cfg_basedir"]=$D;'

# homepage
php -d display_errors=1 -r "$BOOT"'
$row=$dsql->GetOne("SELECT * FROM `#@__homepageset`");
$tpl=str_replace("{style}",$GLOBALS["cfg_df_style"],$row["templet"]);
$pv=new PartView(); $GLOBALS["_arclistEnv"]="index";
$pv->SetTemplet($GLOBALS["cfg_basedir"].$GLOBALS["cfg_templets_dir"]."/".$tpl);
$pv->SaveToHtml($GLOBALS["cfg_basedir"]."/index.html");
' >>"$L" 2>&1
echo "$(date +%T) home: $([ -f "$D/index.html" ] && wc -c <"$D/index.html")b" >>"$L"

TIDS=$(mysql -N -h localhost -u "$DBU" -p"$DBP" "$DB" -e "SELECT id FROM biz_arctype" 2>>"$L")
for t in $TIDS; do
  DEDE_TID="$t" php -d display_errors=1 -r "$BOOT"'
  $lv=new ListView((int)getenv("DEDE_TID")); $lv->MakeHtml(1,0);' >>"$L" 2>&1
done
echo "$(date +%T) lists done ($(echo $TIDS|wc -w))" >>"$L"

AIDS=$(mysql -N -h localhost -u "$DBU" -p"$DBP" "$DB" -e "SELECT id FROM biz_archives" 2>>"$L")
n=0
for a in $AIDS; do
  DEDE_AID="$a" php -d display_errors=1 -r "$BOOT"'
  $arc=new Archives((int)getenv("DEDE_AID")); if(!$arc->IsError) $arc->MakeHtml(0);' >>"$L" 2>&1
  n=$((n+1))
done
echo "$(date +%T) articles done ($n)" >>"$L"

# serve static homepage: neutralize dynamic index.php
[ -f "$D/index.html" ] && [ -f "$D/index.php" ] && mv "$D/index.php" "$D/index.php.bak"
cp "$D/.htaccess" "$D/_htaccess.txt" 2>/dev/null
echo "$(date +%T) GEN done; index=$([ -f "$D/index.html" ] && wc -c <"$D/index.html")b idxphp=$([ -f "$D/index.php" ] && echo present || echo moved)" >>"$L"
