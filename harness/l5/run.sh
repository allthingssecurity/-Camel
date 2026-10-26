#!/bin/bash
# [MODE=real] run.sh <label> <level E|C> <family|all> <seed> <count>: generate cases with the L5 oracle, run them on Camel at the pin
# (endpoint creation and the catalog's URI tools), keep the summary, mismatches, UNSPECIFIED log and rule hits under
# runs/<label>/ (the case file is deleted after the run). JVM niced, -Xmx512m. File names are L5-specific (.l5summary,
# .l5hits, L5-ORACLE-BUILD-INFO) so that tools/status.py (L2 runs) does not read them.
set -euo pipefail
S=$(cd "$(dirname "$0")/../.." && pwd)
P=$(grep '^commit' $S/PIN | awk '{print $2}')
B=$S/build/camel-$P
K=$S/build/catalog-$P
H=$S/build/harness-l5
J=~/homebrew/opt/openjdk@21/bin
O=$S/runs/$1; mkdir -p $O $H
CP=$B/classes:$K/classes:$(cat $B/deps.cp)
if [ ! -f $H/L5Run.class ] || [ $S/harness/l5/L5Run.java -nt $H/L5Run.class ]; then
  $J/javac -nowarn -d $H -cp $CP $S/harness/l5/L5Run.java
fi
cp $S/oracle/l5/BUILD-INFO $O/L5-ORACLE-BUILD-INFO
T=${MODE:-doc}-$2-$3-$4
$S/oracle/l5/driver $2 $3 $4 $5 $O/$T.l5hits > $O/$T.tsv
nice $J/java -Xmx512m -XX:-OmitStackTraceInFastThrow -cp $H:$CP L5Run $O/$T.tsv $O/$T 2>$O/$T.stderr 
grep -v 'SLF4J' $O/$T.stderr | head -20 || true
rm -f $O/$T.tsv
[ -s $O/$T.stderr ] || rm -f $O/$T.stderr
