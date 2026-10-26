#!/bin/bash
# build-catalog.sh: compile Camel's catalog URI tools at the pin (camel-catalog's DefaultCamelCatalog, core/camel-core-catalog's
# AbstractCamelCatalog, tooling/camel-tooling-model) with javac against the core classes of harness/build-camel.sh, plus
# the catalog's component JSONs as resources (14 MB). Sources come from `git archive` of ../camel (no network).
set -euo pipefail
S=$(cd "$(dirname "$0")/../.." && pwd)
C=$S/../camel
P=$(grep '^commit' $S/PIN | awk '{print $2}')
B=$S/build/catalog-$P
CORE=$S/build/camel-$P
JAVA_HOME=~/homebrew/opt/openjdk@21
R=catalog/camel-catalog/src/generated/resources/org/apache/camel/catalog
rm -rf $B; mkdir -p $B/src $B/classes
git -C $C archive $P catalog/camel-catalog/src/main core/camel-core-catalog/src/main tooling/camel-tooling-model/src/main \
  $R/components $R/components.properties | tar -x -C $B/src
find $B/src -path '*/src/main/java/*' -name '*.java' > $B/srcs.txt
nice $JAVA_HOME/bin/javac -J-Xmx1g --release 21 -g -nowarn -proc:none -encoding UTF-8 \
  -cp "$CORE/classes:$(cat $CORE/deps.cp)" -d $B/classes @$B/srcs.txt 2>&1 | { grep -v '^Note:' || true; } | tail -30
for d in catalog/camel-catalog/src/main/resources core/camel-core-catalog/src/main/resources; do
  [ -d $B/src/$d ] && cp -R $B/src/$d/. $B/classes/
done
mkdir -p $B/classes/org/apache/camel/catalog
cp -R $B/src/$R/components $B/src/$R/components.properties $B/classes/org/apache/camel/catalog/
echo "built $(find $B/classes -name '*.class' | wc -l) classes into $B/classes"
