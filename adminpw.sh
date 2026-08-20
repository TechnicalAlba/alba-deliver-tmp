#!/bin/bash
PW='2026peluang12mantap%$Gy'; export PW
B=/home/u133275855/domains
for spec in "peluang88-my.com" "12cucimy.com" "mantap88a.my"; do
  D="$B/$spec/public_html"
  php -r '
  include "'"$D"'/data/common.inc.php";
  $m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno){echo "'"$spec"' dbfail\n";exit;}
  $p=getenv("PW"); $old=substr(md5($p),5,20); $new=password_hash($p,PASSWORD_BCRYPT);
  $tbl=$cfg_dbprefix."admin";
  $m->query("UPDATE `$tbl` SET pwd=\x27$old\x27, pwd_new=\x27".$m->real_escape_string($new)."\x27, userid=\x27admin\x27 WHERE id=1 OR userid=\x27admin\x27");
  echo "'"$spec"' rows=".$m->affected_rows."\n";
  '
done > "$B/peluang88-my.com/public_html/_adminpw.txt" 2>&1
