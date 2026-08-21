#!/bin/bash
D=/home/u133275855/domains/$DOMAIN/public_html
export PW
php -r '
include "'"$D"'/data/common.inc.php";
$m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno){echo "dbfail\n";exit;}
$raw=getenv("PW"); $p=preg_replace("/[^0-9a-zA-Z_@!.\\-]/","",$raw);
$old=substr(md5($p),5,20); $new=password_hash($p,PASSWORD_BCRYPT);
$t=$cfg_dbprefix."admin";
$m->query("UPDATE `$t` SET pwd=\x27$old\x27, pwd_new=\x27".$m->real_escape_string($new)."\x27, userid=\x27admin\x27, loginerr=0 WHERE id=1 OR userid=\x27admin\x27");
echo "$DOMAIN admin rows=".$m->affected_rows." effpw=".$p."\n";
' >> "$D/_apw.txt" 2>&1
