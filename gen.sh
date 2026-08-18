#!/bin/bash
# DedeBIZ static regen via admin over loopback. Env: DOMAIN STYLE DB DBU DBP
set +e
D=/home/u133275855/domains/$DOMAIN/public_html
L=$D/_gen.txt; : > "$L"
B=http://127.0.0.1
CJ=/tmp/cj_$STYLE.txt
say(){ echo "$(date +%T) $*" >>"$L"; }
rm -f "$D/default.php"
say "GEN start $DOMAIN style=$STYLE"

# login (seed cookie then post)
curl -s -H "Host: $DOMAIN" -c "$CJ" "$B/admin/login.php" -o /dev/null
curl -s -H "Host: $DOMAIN" -b "$CJ" -c "$CJ" -e "$B/admin/login.php" \
  --data-urlencode "dopost=login" --data-urlencode "adminstyle=newDedeBIZ" \
  --data-urlencode "userid=admin" --data-urlencode "pwd=Admin#2026" --data-urlencode "validate=" \
  "$B/admin/login.php" -o /tmp/login_$STYLE.html
say "login http done; $(grep -oE '密码错误|验证码|成功|dede_login|success' /tmp/login_$STYLE.html | head -1)"

# homepage
curl -s -H "Host: $DOMAIN" -b "$CJ" -e "$B/admin/" \
  --data "dopost=make&templet=$STYLE/index.htm&position=../index.html&showmod=1&saveset=1" \
  "$B/admin/makehtml_homepage.php" -o /tmp/hp_$STYLE.html
say "homepage posted ($(wc -c </tmp/hp_$STYLE.html) b)"

# lists per real typeid
TIDS=$(mysql -N -h localhost -u "$DBU" -p"$DBP" "$DB" -e "SELECT id FROM biz_arctype" 2>>"$L")
say "typeids: $(echo $TIDS | tr '\n' ' ')"
for t in $TIDS; do
  curl -s -H "Host: $DOMAIN" -b "$CJ" "$B/admin/makehtml_list_action.php?typeid=$t&upnext=0&maxpagesize=50" -o /dev/null
done
say "lists done"

# articles
curl -s -H "Host: $DOMAIN" -b "$CJ" "$B/admin/makehtml_archives_action.php?gotype=all" -o /dev/null
say "archives done"

# caches
curl -s -H "Host: $DOMAIN" -b "$CJ" "$B/admin/catalog_do.php?dopost=upcatcache" -o /dev/null
curl -s -H "Host: $DOMAIN" -b "$CJ" "$B/admin/sys_cache_up.php?dopost=upcache" -o /dev/null

# report
IDX=$([ -f "$D/index.html" ] && wc -c <"$D/index.html" || echo 0)
say "index.html bytes: $IDX"
say "GEN done"
