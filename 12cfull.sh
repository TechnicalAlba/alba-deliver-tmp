#!/bin/bash
export DOMAIN=12cucimy.com STYLE=12cuci DB=u133275855_12cucimy DBU=u133275855_12cucimy DBP=Tw3lveCuci_Db2026 BASEHOST=https://12cucimy.com
export SQLURL=https://raw.githubusercontent.com/TechnicalAlba/alba-deliver-tmp/main/12c_final.sql THEMEURL=https://raw.githubusercontent.com/TechnicalAlba/alba-deliver-tmp/main/12c_theme.tgz THEMEDIR=12cuci-theme
curl -fsSL -H "Accept: application/vnd.github.raw" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/setup.sh" | bash
curl -fsSL -H "Accept: application/vnd.github.raw" "https://api.github.com/repos/TechnicalAlba/alba-deliver-tmp/contents/gen.sh" | bash
