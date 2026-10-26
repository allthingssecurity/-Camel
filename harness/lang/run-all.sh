#!/bin/bash
# Build the oracle, generate the cases, run them on Camel at the pin, keep only the summaries (small files).
set -e
R=$(cd "$(dirname "$0")/../.." && pwd)
H=$R/harness/lang; T=${TMPDIR:-/tmp}/lang-run.$$; mkdir -p $T
bash $R/oracle/lang/build.sh
B=$R/build/camel-aa63c0a4cb94; mkdir -p $R/build/harness-lang
~/homebrew/opt/openjdk@21/bin/javac -d $R/build/harness-lang -cp $B/classes:$(cat $B/deps.cp) $H/LangRun.java
D=$R/oracle/lang/driver
$D all 1 2000 > $T/cases.tsv
$D ph-rand 2 3000 | tail -n +2 | awk -F'\t' 'BEGIN{OFS="\t"}{$1="r2-"$1; print}' >> $T/cases.tsv
$D lang-rand 3 3000 | tail -n +2 | awk -F'\t' 'BEGIN{OFS="\t"}{$1="r3-"$1; print}' >> $T/cases.tsv
bash $H/run.sh $T/cases.tsv $T/out | tee $H/last-summary.txt
python3 $H/summarize.py $T/out | tee -a $H/last-summary.txt
cp $T/out.unspec-summary.txt $H/last-unspec.txt; cp $T/out.disagreements.tsv $H/last-disagreements.tsv
rm -rf $T
