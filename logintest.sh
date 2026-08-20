#!/bin/bash
# probe DedeBIZ admin login over loopback for all 3 sites; report response
PW='2026peluang12mantap%$Gy'
B=/home/u133275855/domains
OUT=$B/mantap88a.my/public_html/_logintest.txt; : > "$OUT"
for d in peluang88-my.com 12cucimy.com mantap88a.my; do
  CJ=/tmp/lj_$d.txt; rm -f "$CJ"
  # seed cookie
  curl -s -H "Host: $d" -c "$CJ" "http://127.0.0.1/admin/login.php" -o /dev/null
  # find admin dir login action; post
  R=$(curl -s -H "Host: $d" -b "$CJ" -c "$CJ" -e "http://127.0.0.1/admin/login.php" \
      --data-urlencode "dopost=login" --data-urlencode "userid=admin" \
      --data-urlencode "pwd=$PW" --data-urlencode "validate=" --data-urlencode "gotopage=" \
      "http://127.0.0.1/admin/login.php")
  msg=$(echo "$R" | grep -oiE "密码错误|用户名不存在|验证码|成功|请到|登录成功|success|error[^<]*|校验|安全" | head -3 | tr '\n' '|')
  # follow: check if index accessible now
  IDX=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $d" -b "$CJ" "http://127.0.0.1/admin/index.php")
  echo "$d :: resp_snip=[$msg] admin_index_after=$IDX resp_bytes=${#R}" >> "$OUT"
done
