#!/bin/bash
# Clone mantap88.click -> mantap88a.my (files + DB), scrub old domain. Env: DBU DBP DB
set +e
BASE=/home/u133275855/domains
SRC=$BASE/mantap88.click/public_html
D=$BASE/mantap88a.my/public_html
G=$D/.clone_done
[ -f "$G" ] && { echo "clone already done"; exit 0; }
mkdir -p "$D"
L=$D/_clone.txt; : > "$L"
say(){ echo "$(date +%T) $*" >>"$L"; }
say "CLONE start -> mantap88a.my"

# source DB creds from its common.inc.php (cron runs as account user, can read)
eval "$(php -r 'include "'"$SRC"'/data/common.inc.php"; echo "SH=\"$cfg_dbhost\" SN=\"$cfg_dbname\" SU=\"$cfg_dbuser\" SP=\"$cfg_dbpwd\" SX=\"$cfg_dbprefix\"";')"
say "src db=$SN prefix=$SX host=$SH"

# dump source DB -> load into new DB
mysqldump -h "$SH" -u "$SU" -p"$SP" --no-tablespaces "$SN" > /tmp/m88.sql 2>>"$L"
say "dump bytes: $(wc -c </tmp/m88.sql)"
mysql -h localhost -u "$DBU" -p"$DBP" "$DB" < /tmp/m88.sql 2>>"$L" && say "db loaded" || say "db load ERR"

# copy all files (generated HTML included)
cp -a "$SRC/." "$D/" 2>/dev/null
: > "$L"; say "files copied: $(ls "$D" | wc -l) entries"

# fresh common.inc.php (same prefix, new DB)
cat > "$D/data/common.inc.php" <<PHP
<?php
\$cfg_dbhost = 'localhost';
\$cfg_dbname = '$DB';
\$cfg_dbuser = '$DBU';
\$cfg_dbpwd = '$DBP';
\$cfg_dbprefix = '$SX';
\$cfg_db_language = 'utf8mb4';
PHP

# DB scrub: old domain -> new, set basehost
mysql -h localhost -u "$DBU" -p"$DBP" "$DB" 2>>"$L" <<SQL
UPDATE ${SX}sysconfig SET value=REPLACE(value,'mantap88.click','mantap88a.my');
UPDATE ${SX}sysconfig SET value='https://mantap88a.my' WHERE varname='cfg_basehost';
UPDATE ${SX}archives SET title=REPLACE(title,'mantap88.click','mantap88a.my'), keywords=REPLACE(keywords,'mantap88.click','mantap88a.my'), description=REPLACE(description,'mantap88.click','mantap88a.my');
UPDATE ${SX}addonarticle SET body=REPLACE(body,'mantap88.click','mantap88a.my');
SQL
say "db scrub done"

# static file scrub: replace old domain string everywhere
grep -rlZ 'mantap88\.click' "$D" 2>/dev/null | xargs -0 -r sed -i 's/mantap88\.click/mantap88a.my/g'
CNT=$(grep -rl 'mantap88\.click' "$D" 2>/dev/null | wc -l)
say "remaining files with old domain: $CNT"

# remove source GSC token, backups, old logs
rm -f "$D"/google*.html "$D"/dedebizcompile*.zip "$D"/_log.txt "$D"/_gen.txt "$D"/favicon.ico.orig 2>/dev/null
rm -rf "$D/data/backupdata" "$D/data"/sessions_* 2>/dev/null

# serve static homepage + DirectoryIndex
touch "$D/.htaccess"
grep -q "DirectoryIndex index.html" "$D/.htaccess" || sed -i '1i DirectoryIndex index.html index.php' "$D/.htaccess"
[ -f "$D/index.html" ] && [ -f "$D/index.php" ] && mv "$D/index.php" "$D/index.php.bak"

# report
IDX=$([ -f "$D/index.html" ] && wc -c <"$D/index.html" || echo 0)
say "index.html bytes: $IDX ; remaining-oldmarks: $CNT ; CLONE done"
touch "$G"
