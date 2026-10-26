#!/bin/bash
# Compile the L4 lifecycle rules, extract them, build the L4 oracle driver. Light (seconds); no lock needed.
set -e
R=$(cd "$(dirname "$0")/../.." && pwd)
O=$R/oracle/l4
cd $R
[ theories/Common/Text.vo -nt theories/Common/Text.v ] || rocq compile -Q theories CamelSpec theories/Common/Text.v
rocq compile -Q theories CamelSpec theories/L4/Lifecycle.v
rocq compile -Q theories CamelSpec theories/L4/LifecycleExtract.v 2>&1 | grep -v "extraction-default-directory\|Setting extraction\|Use \"Set Extraction\|to set a different\|^File \"./theories/L4/LifecycleExtract.v\"\|^\"/Users" || true
cd $O
rm -f driver
ocamlfind ocamlopt -package zarith -linkpkg -w -a lifecyclespec.mli lifecyclespec.ml driver.ml -o driver 2>&1 | grep -v "ld.conf" || true
rm -f *.cmi *.cmx *.o
test -x driver || { echo "oracle build FAILED"; exit 1; }
(cd $R && shasum -a 256 theories/L4/Lifecycle.v oracle/l4/lifecyclespec.ml oracle/l4/driver.ml) > BUILD-INFO
echo "oracle built: $O/driver"
