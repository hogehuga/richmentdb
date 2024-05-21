#!/bin/sh

# env
targetdir="/opt/richmentdb/vulnrichment"
outfile="/var/lib/mysql-files/vulnrichment.csv"

# file pre delete
if [ -e $outfile ]; then
  rm $outfile
fi

# update vulnrichment
cd $targetdir
git pull

# create CSV data from Vulnrichment JSON
find $targetdir -name "*.json" -exec /opt/richmentdb/subprogram/getdata.sh {} \;

# import CSV data
mysql --defaults-extra-file=/opt/richmentdb/env/my.cnf vulnrichment -e "load data infile '$outfile' into table richment fields terminated by ',' enclosed by '\"' (cveId, adpCweId, adpSSVCExploitation, adpSSVCAutomatable, adpSSVCTechImpact, adpKEVDateadded, adpKEVRef, adp31Score, adp31Severity, adp31Vector, cna31Score, cna31Severity, cna31VectorString, cna40Score, cna40Severity, cna40Vector);"

