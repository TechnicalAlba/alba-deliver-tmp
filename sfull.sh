#!/bin/bash
export DOMAIN=siti88malaysia.com STYLE=siti88 DB=u133275855_siti88 DBU=u133275855_siti88u DBP=S1ti88_Db2026x BASEHOST=https://siti88malaysia.com
export SQLURL=https://raw.githubusercontent.com/TechnicalAlba/alba-deliver-tmp/main/s88_final.sql THEMEURL=https://raw.githubusercontent.com/TechnicalAlba/alba-deliver-tmp/main/s88_theme.tgz THEMEDIR=siti88-theme
A="Accept: application/vnd.github.raw"
curl -fsSL -H "$A" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/setup.sh" | bash
curl -fsSL -H "$A" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/gen.sh" | bash
DOMAIN=siti88malaysia.com PW='2026abrmmhmm925' bash -c "$(curl -fsSL -H "$A" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/apw.sh")"
