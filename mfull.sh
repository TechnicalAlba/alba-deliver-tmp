#!/bin/bash
export DOMAIN=8mhdmy.com STYLE=8mohd DB=u133275855_8mohddb DBU=u133275855_8mohddb DBP=8Mohd_Db2026x BASEHOST=https://8mhdmy.com
export SQLURL=https://raw.githubusercontent.com/TechnicalAlba/alba-deliver-tmp/main/m88_final.sql THEMEURL=https://raw.githubusercontent.com/TechnicalAlba/alba-deliver-tmp/main/m88_theme.tgz THEMEDIR=8mohd-theme
A="Accept: application/vnd.github.raw"
curl -fsSL -H "$A" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/setup.sh" | bash
curl -fsSL -H "$A" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/gen.sh" | bash
DOMAIN=8mhdmy.com PW='2026abrmmhmm925' bash -c "$(curl -fsSL -H "$A" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/apw.sh")"
