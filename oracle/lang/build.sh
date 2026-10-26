#!/bin/bash
# Build the L1 lang/placeholder oracle: compile the spec (make extracts langspec.ml), then the driver. Light.
set -e
R=$(cd "$(dirname "$0")/../.." && pwd)
cd $R
# only this track's files (and what they import), so another track's broken file does not block the oracle
for f in theories/L1/Placeholder.v theories/L1/Lang.v; do rocq compile -Q theories CamelSpec $f; done
rocq compile -Q theories CamelSpec theories/L1/LangExtract.v 2>&1 | grep -v "extraction-default-directory\|Setting extraction\|Use \"Set Extraction\|to set a different\|^\"/Users\|^File \"./theories/L1/LangExtract.v\"\|^\[extraction" || true
cd $R/oracle/lang
ocamlfind ocamlopt -package zarith -linkpkg langspec.mli langspec.ml driver.ml -o driver 2>&1 | grep -v "ld.conf" || true
(cd $R && shasum -a 256 theories/L1/Placeholder.v theories/L1/Lang.v oracle/lang/langspec.ml oracle/lang/driver.ml) > BUILD-INFO
