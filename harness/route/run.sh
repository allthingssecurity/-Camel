#!/bin/bash
# run.sh <label> <family> <seed> <count>: generate cases with the oracle, run them on Camel at the pin, keep the
# mismatches and the UNSPECIFIED sample under runs/<label>/ (case files are deleted after the run).
set -euo pipefail
S=$(cd "$(dirname "$0")/../.." && pwd)
B=$S/build/camel-$(grep '^commit' $S/PIN | awk '{print $2}')
H=$S/build/harness-route
J=~/homebrew/opt/openjdk@21/bin
O=$S/runs/$1; mkdir -p $O
mkdir -p $H
if [ ! -f $H/RouteRun.class ] || [ $S/harness/route/RouteRun.java -nt $H/RouteRun.class ]; then
  $J/javac -nowarn -d $H -cp $B/classes:$(cat $B/deps.cp) $S/harness/route/RouteRun.java
fi
cp $S/oracle/route/BUILD-INFO $O/ORACLE-BUILD-INFO
echo "${MODE:-doc}${DSL:+-$DSL}" > $O/MODE
C=$O/$2-$3.tsv
$S/oracle/route/driver $2 $3 $4 $O/$2-$3.hits > $C
YCP=""; if [ "${DSL:-}" = yaml ]; then YCP=":$(cat $B/yaml.cp)"; fi
nice $J/java -Xmx512m -XX:-OmitStackTraceInFastThrow ${DSL:+-Ddsl=$DSL} -cp $H:$B/classes:$(cat $B/deps.cp)$YCP RouteRun $C $O/$2-$3 2>&1 \
  | grep -v 'SLF4J' | tee $O/$2-$3.summary
rm -f $C
