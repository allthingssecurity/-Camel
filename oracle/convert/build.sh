#!/bin/bash
# Compile Convert.v, extract it, build the conversion oracle driver. Light (seconds); no lock needed.
set -e
R=$(cd "$(dirname "$0")/../.." && pwd)
O=$R/oracle/convert
cd $R
rocq compile -Q theories CamelSpec theories/Common/Text.v
rocq compile -Q theories CamelSpec theories/L0/Value.v
rocq compile -Q theories CamelSpec theories/L0/Convert.v
rocq compile -Q theories CamelSpec theories/L0/ConvertExtract.v 2>&1 | grep -v "extraction-default-directory\|Setting extraction\|Use \"Set Extraction\|to set a different\|^File \"./theories/L0/ConvertExtract.v\"" || true
cd $O
ocamlfind ocamlopt -package zarith -linkpkg convert.mli convert.ml driver.ml -o driver 2>&1 | grep -v "ld.conf" || true
rm -f *.cmi *.cmx *.o
shasum -a 256 $R/theories/L0/Convert.v convert.ml driver.ml > BUILD-INFO
# the driver binary is a build output (not to be committed); run.sh rebuilds it
