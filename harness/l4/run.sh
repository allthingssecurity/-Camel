#!/bin/bash
# [MODE=real] run.sh <label> <family> <seed> <count>: generate L4 lifecycle cases with the oracle, run them on Camel at
# the pin, keep the summary, mismatches, UNSPECIFIED log and rule hits under runs/<label>/ (the case file is deleted
# after the run). One JVM, niced, -Xmx512m. File names are L4-specific (.l4summary, .l4hits, L4-ORACLE-BUILD-INFO) so
# that tools/status.py (L2 runs) does not read them.
set -euo pipefail
S=$(cd "$(dirname "$0")/../.." && pwd)
B=$S/build/camel-$(grep '^commit' $S/PIN | awk '{print $2}')
H=$S/build/harness-l4
J=~/homebrew/opt/openjdk@21/bin
O=$S/runs/$1; mkdir -p $O $H
CP=$B/classes:$(cat $B/deps.cp)
if [ ! -f $H/LifecycleRun.class ] || [ $S/harness/l4/LifecycleRun.java -nt $H/LifecycleRun.class ]; then
  $J/javac -nowarn -d $H -cp $CP $S/harness/l4/LifecycleRun.java
fi
cp $S/oracle/l4/BUILD-INFO $O/L4-ORACLE-BUILD-INFO
echo "${MODE:-doc}" > $O/MODE
T=${MODE:-doc}-$2-$3
$S/oracle/l4/driver $2 $3 $4 $O/$T.l4hits > $O/$T.tsv
nice $J/java -Xmx512m -XX:-OmitStackTraceInFastThrow -cp $H:$CP LifecycleRun $O/$T.tsv $O/$T > $O/$T.l4summary 2>$O/$T.stderr || true
rm -f $O/$T.tsv
grep -v 'SLF4J' $O/$T.stderr > $O/$T.stderr.f || true
mv $O/$T.stderr.f $O/$T.stderr
[ -s $O/$T.stderr ] || rm -f $O/$T.stderr
cat $O/$T.l4summary
