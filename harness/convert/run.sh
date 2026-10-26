#!/bin/bash
# Differential run of the type-conversion rules: oracle cases -> real Camel (aa63c0a4cb94). Light (one JVM, -Xmx512m).
# Keeps only the summary (harness/convert/last-summary.txt) and the non-OK lines (harness/convert/last-disagreements.tsv).
set -e
R=$(cd "$(dirname "$0")/../.." && pwd)
B=$R/build/camel-aa63c0a4cb94
J=~/homebrew/opt/openjdk@21/bin
CP=$B/classes:$(cat $B/deps.cp)
OUT=$R/build/harness-convert
mkdir -p $OUT
bash $R/oracle/convert/build.sh
$R/oracle/convert/driver > $OUT/cases.tsv
$J/javac -nowarn -d $OUT -cp $CP $R/harness/convert/ConvertRun.java
nice $J/java -Xmx512m -cp $OUT:$CP ConvertRun $OUT/cases.tsv $OUT/results.tsv 2>$OUT/stderr.txt | tee $R/harness/convert/last-summary.txt
awk -F"\t" '$7!="OK" && $7!="POK" && $7!="UNS"' $OUT/results.tsv > $R/harness/convert/last-disagreements.tsv
wc -l < $R/harness/convert/last-disagreements.tsv
# keep the summaries only (disk): the full case and result files are rebuilt by this script
rm -f $OUT/cases.tsv $OUT/results.tsv $R/oracle/convert/driver
