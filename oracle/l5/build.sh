#!/bin/bash
# Compile the L5 rules, extract them, build the L5 oracle driver. Light (GenCatalog.v: ~6 s, ~570 MB); no lock needed.
set -e
R=$(cd "$(dirname "$0")/../.." && pwd)
O=$R/oracle/l5
cd $R; rm -f $O/driver
{ [ theories/L5/GenCatalog.v -nt docs/component-json/catalog-components.tar.xz ] && [ theories/L5/GenCatalog.v -nt tools/gen_l5.py ]; } || python3 -I tools/gen_l5.py
for f in theories/Common/Text.v theories/L0/Value.v theories/L0/Convert.v theories/L0/Exchange.v; do
  [ "${f%.v}.vo" -nt "$f" ] || rocq compile -Q theories CamelSpec $f
done
for f in theories/L5/Model.v theories/L5/GenCatalog.v theories/L5/Uri.v theories/L5/Catalog.v; do
  rocq compile -Q theories CamelSpec $f
done
rocq compile -Q theories CamelSpec theories/L5/UriExtract.v 2>&1 | grep -v "extraction-default-directory\|Setting extraction\|Use \"Set Extraction\|to set a different\|^File \"./theories/L5/UriExtract.v\"" || true
cd $O
rm -f driver
ocamlfind ocamlopt -package zarith -linkpkg -w -a l5spec.mli l5spec.ml driver.ml -o driver 2>&1 | grep -v "ld.conf" || true
rm -f *.cmi *.cmx *.o
test -x driver || { echo "oracle build FAILED"; exit 1; }
(cd $R && shasum -a 256 theories/L5/Uri.v theories/L5/GenCatalog.v theories/L0/Convert.v oracle/l5/l5spec.ml oracle/l5/driver.ml) > BUILD-INFO
echo "oracle built: $O/driver"
