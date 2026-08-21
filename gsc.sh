#!/bin/bash
B=/home/u133275855/domains
C='google-site-verification: google4bc240365f294b0a.html'
for d in peluang88-my.com 12cucimy.com mantap88a.my; do
  printf '%s' "$C" > "$B/$d/public_html/google4bc240365f294b0a.html"
done
ls -la "$B"/peluang88-my.com/public_html/google4bc240365f294b0a.html "$B"/12cucimy.com/public_html/google4bc240365f294b0a.html "$B"/mantap88a.my/public_html/google4bc240365f294b0a.html > "$B/peluang88-my.com/public_html/_gsc.txt" 2>&1
