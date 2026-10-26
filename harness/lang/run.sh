#!/bin/bash
# run.sh <cases.tsv> <out-prefix>: differential run of oracle/lang cases against Camel at the pin.
# Sets exactly the OS environment the oracle assumes (#ENV line of the case file; the driver's the_env).
R=$(cd "$(dirname "$0")/../.." && pwd)
B=$R/build/camel-aa63c0a4cb94
exec env CSPEC_A=alpha CSPEC_B=beta CSPEC_D_X=dash 'CSPEC_N={{a}}' FOO_SERVICE_HOST=myserver FOO_SERVICE_PORT=8888 \
  BAR_SERVICE_HOST=barhost cspec_lc=lower \
  nice ~/homebrew/opt/openjdk@21/bin/java -Xmx512m -XX:-OmitStackTraceInFastThrow \
  -cp $R/build/harness-lang:$B/classes:$(cat $B/deps.cp) LangRun "$1" "$2" 2>&1 | grep -v SLF4J
