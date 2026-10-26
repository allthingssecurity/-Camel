#!/bin/bash
# build-yaml.sh: compile the YAML DSL modules (camel-yaml-dsl-common, -deserializers, camel-yaml-dsl) at the pin into
# build/camel-<pin>/yaml-classes, against the core classes of build-camel.sh (which must have run). L6.
set -euo pipefail
S=$(cd "$(dirname "$0")/.." && pwd)
C=$S/../camel
P=$(grep '^commit' $S/PIN | awk '{print $2}')
B=$S/build/camel-$P
J=~/homebrew/opt/openjdk@21/bin
YAMLJAR=~/.m2/repository/org/snakeyaml/snakeyaml-engine/3.2/snakeyaml-engine-3.2.jar
test -f $YAMLJAR
MODS="camel-yaml-dsl-common camel-yaml-dsl-deserializers camel-yaml-dsl"
rm -rf $B/yaml-src $B/yaml-classes; mkdir -p $B/yaml-src $B/yaml-classes
paths=""
for m in $MODS; do for d in src/main src/generated; do
  git -C $C cat-file -e $P:dsl/camel-yaml-dsl/$m/$d 2>/dev/null && paths="$paths dsl/camel-yaml-dsl/$m/$d"
done; done
git -C $C archive $P $paths | tar -x -C $B/yaml-src
find $B/yaml-src \( -path '*/src/main/java/*' -o -path '*/src/generated/java/*' \) -name '*.java' > $B/yaml-srcs.txt
nice $J/javac -J-Xmx2g --release 21 -nowarn -proc:none -encoding UTF-8 -cp "$B/classes:$(cat $B/deps.cp):$YAMLJAR" \
  -d $B/yaml-classes @$B/yaml-srcs.txt 2>&1 | { grep -v '^Note:' || true; } | tail -20
for m in $MODS; do for d in src/main/resources src/generated/resources; do
  if [ -d $B/yaml-src/dsl/camel-yaml-dsl/$m/$d ]; then cp -R $B/yaml-src/dsl/camel-yaml-dsl/$m/$d/. $B/yaml-classes/; fi
done; done
echo "$B/yaml-classes:$YAMLJAR" > $B/yaml.cp
echo "built $(find $B/yaml-classes -name '*.class' | wc -l) YAML DSL classes"
