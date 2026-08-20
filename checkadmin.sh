#!/bin/bash
D=/home/u133275855/domains/mantap88a.my/public_html
php -r '
include "'"$D"'/data/common.inc.php";
$m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno){echo "dbfail\n";exit;}
$t=$cfg_dbprefix."admin";
echo "prefix=$cfg_dbprefix table=$t\n";
$r=$m->query("SELECT id,userid,LENGTH(pwd) pl,LENGTH(pwd_new) pnl,uarank FROM `$t`");
if(!$r){echo "queryerr: ".$m->error."\n"; exit;}
while($a=$r->fetch_assoc()){ echo "id=".$a["id"]." userid=".$a["userid"]." pwd_len=".$a["pl"]." pwdnew_len=".$a["pnl"]." rank=".$a["uarank"]."\n"; }
' > "$D/_admincheck.txt" 2>&1
