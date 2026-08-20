#!/bin/bash
D=/home/u133275855/domains/mantap88a.my/public_html
php -r '
include "'"$D"'/data/common.inc.php";
$m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno){echo "dbfail\n";exit;}
$t=$cfg_dbprefix."admin";
$r=$m->query("SELECT * FROM `$t`");
if(!$r){echo "queryerr: ".$m->error."\n"; exit;}
echo "rows=".$r->num_rows."\n";
while($a=$r->fetch_assoc()){ echo "id=".$a["id"]." userid=".$a["userid"]."\n"; }
' > "$D/_admincheck.txt" 2>&1
