#!/bin/bash
# DedeBIZ static regen via PHP CLI with faked HTTP env. Env: DOMAIN STYLE DB DBU DBP
set +e
D=/home/u133275855/domains/$DOMAIN/public_html
L=$D/_gen.txt; : > "$L"
rm -f "$D/default.php"
echo "$(date +%T) GEN(cli) $DOMAIN style=$STYLE" >>"$L"
export D_ROOT="$D" DOMAIN STYLE

php -d display_errors=1 -d error_reporting=E_ALL -r '
$D=getenv("D_ROOT"); $STYLE=getenv("STYLE");
$_SERVER["HTTP_HOST"]=getenv("DOMAIN");
$_SERVER["SERVER_NAME"]=getenv("DOMAIN");
$_SERVER["REQUEST_URI"]="/";
$_SERVER["SCRIPT_NAME"]="/index.php";
$_SERVER["REMOTE_ADDR"]="127.0.0.1";
$_SERVER["HTTP_USER_AGENT"]="cli";
chdir($D);
require $D."/system/common.inc.php";
echo "BOOT ok; DEDEINC=".(defined("DEDEINC")?DEDEINC:"NONE")." basehost=".$GLOBALS["cfg_basehost"]." style=".$GLOBALS["cfg_df_style"]."\n";
// homepage
require_once DEDEINC."/archive/partview.class.php";
$row=$dsql->GetOne("SELECT * FROM `#@__homepageset`");
$tpl=str_replace("{style}",$GLOBALS["cfg_df_style"],$row["templet"]);
$pv=new PartView(); $GLOBALS["_arclistEnv"]="index";
$pv->SetTemplet($GLOBALS["cfg_basedir"].$GLOBALS["cfg_templets_dir"]."/".$tpl);
$pv->SaveToHtml($GLOBALS["cfg_basedir"]."/index.html");
echo "homepage -> ".(file_exists($D."/index.html")?filesize($D."/index.html")." b":"MISSING")."\n";
// categories
require_once DEDEINC."/archive/listview.class.php";
$ids=array(); $dsql->Execute("ct","SELECT id FROM `#@__arctype`"); while($a=$dsql->GetArray("ct")) $ids[]=$a["id"];
foreach($ids as $tid){ $lv=new ListView((int)$tid); $lv->MakeHtml(1,0); echo "cat $tid ok\n"; }
// articles
require_once DEDEINC."/archive/archives.class.php";
$aids=array(); $dsql->Execute("ar","SELECT id FROM `#@__archives`"); while($a=$dsql->GetArray("ar")) $aids[]=$a["id"];
foreach($aids as $aid){ $arc=new Archives((int)$aid); if(!$arc->IsError){ $arc->MakeHtml(0); } }
echo "articles: ".count($aids)."\n";
' >>"$L" 2>&1

IDX=$([ -f "$D/index.html" ] && wc -c <"$D/index.html" || echo 0)
echo "$(date +%T) index.html bytes: $IDX ; GEN done" >>"$L"
