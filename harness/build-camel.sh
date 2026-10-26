#!/bin/bash
# build-camel.sh: compile the Camel core modules under test at the pin (PIN file) into build/camel-<pin>/classes.
# Sources come from `git archive` of ../camel (no network). The local 4.24.0-SNAPSHOT jars stay behind the
# overlay on the run classpath only for modules not compiled here (camel-util-json) and third-party deps.
# Heavy-ish (javac over ~2 200 files, ~1-2 min): niced, -J-Xmx2g.
set -euo pipefail
S=$(cd "$(dirname "$0")/.." && pwd)
C=$S/../camel
P=$(grep '^commit' $S/PIN | awk '{print $2}')
B=$S/build/camel-$P
M2=~/.m2/repository
JAVA_HOME=~/homebrew/opt/openjdk@21
MODS="camel-api camel-util camel-support camel-base camel-base-engine camel-core-processor camel-core-reifier
camel-core-model camel-core-languages camel-core-engine camel-management-api camel-xml-jaxp-util camel-cluster camel-health
camel-xml-io camel-xml-io-util"
# components used by the harness as documented test endpoints (each depends on core only)
COMPS="camel-direct camel-mock camel-seda camel-log camel-timer camel-bean camel-controlbus"
# DSL modules (L6)
DSLS="camel-xml-io-dsl camel-dsl-support"

rm -rf $B; mkdir -p $B/src $B/classes
paths=""
for m in $MODS; do for d in src/main src/generated; do
  git -C $C cat-file -e $P:core/$m/$d 2>/dev/null && paths="$paths core/$m/$d"
done; done
for m in $COMPS; do for d in src/main src/generated; do
  git -C $C cat-file -e $P:components/$m/$d 2>/dev/null && paths="$paths components/$m/$d"
done; done
for m in $DSLS; do for d in src/main src/generated; do
  git -C $C cat-file -e $P:dsl/$m/$d 2>/dev/null && paths="$paths dsl/$m/$d"
done; done
git -C $C archive $P $paths | tar -x -C $B/src

# third-party deps + the one Camel module not compiled here
DEPS="$M2/org/slf4j/slf4j-api/2.0.20/slf4j-api-2.0.20.jar
$M2/org/jspecify/jspecify/1.0.1/jspecify-1.0.1.jar
$M2/jakarta/xml/bind/jakarta.xml.bind-api/4.0.5/jakarta.xml.bind-api-4.0.5.jar
$M2/org/apache/commons/commons-lang3/3.21.0/commons-lang3-3.21.0.jar
$M2/org/apache/camel/camel-util-json/4.24.0-SNAPSHOT/camel-util-json-4.24.0-SNAPSHOT.jar"
CP=$(echo $DEPS | tr ' ' ':')
for j in $DEPS; do test -f $j || { echo "missing $j"; exit 1; }; done
echo "$CP" > $B/deps.cp

find $B/src \( -path '*/src/main/java/*' -o -path '*/src/generated/java/*' \) -name '*.java' > $B/srcs.txt
nice $JAVA_HOME/bin/javac -J-Xmx2g --release 21 -g -nowarn -proc:none -encoding UTF-8 -cp "$CP" \
  -d $B/classes @$B/srcs.txt 2>&1 | { grep -v '^Note:' || true; } | tail -30
# resources (META-INF/services etc.), main then generated
for m in $MODS; do for d in src/main/resources src/generated/resources; do
  if [ -d $B/src/core/$m/$d ]; then cp -R $B/src/core/$m/$d/. $B/classes/; fi
done; done
for m in $COMPS; do for d in src/main/resources src/generated/resources; do
  if [ -d $B/src/components/$m/$d ]; then cp -R $B/src/components/$m/$d/. $B/classes/; fi
done; done
for m in $DSLS; do for d in src/main/resources src/generated/resources; do
  if [ -d $B/src/dsl/$m/$d ]; then cp -R $B/src/dsl/$m/$d/. $B/classes/; fi
done; done
echo "built $(find $B/classes -name '*.class' | wc -l) classes for $P into $B/classes"
