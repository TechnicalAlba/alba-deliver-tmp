#!/bin/bash
B=/home/u133275855/domains
for d in peluang88-my.com 12cucimy.com mantap88a.my; do
  rm -f "$B/$d/public_html"/_adminpw.txt "$B/$d/public_html"/_admincheck.txt "$B/$d/public_html"/_logintest.txt "$B/$d/public_html"/_gen.txt "$B/$d/public_html"/_clone.txt "$B/$d/public_html"/_cleanup.txt "$B/$d/public_html"/_htaccess.txt "$B/$d/public_html"/index.php.bak 2>/dev/null
done
echo "cleaned $(date)" > "$B/peluang88-my.com/public_html/_ok.txt"
