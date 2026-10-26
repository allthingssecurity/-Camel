#!/bin/bash
# Compile the spec, extract it, build the route oracle driver. Light (seconds); no lock needed.
set -e
S=$(cd "$(dirname "$0")/.." && pwd)
cd $S && make Makefile.rocq > /dev/null && make -f Makefile.rocq theories/L2/RouteExtract.vo > /dev/null
cd $S/oracle/route
rm -f driver
ocamlfind ocamlopt -package zarith -linkpkg -w -a routespec.mli routespec.ml driver.ml -o driver 2>&1 | grep -v "ld.conf" || true
test -x driver || { echo "oracle build FAILED"; exit 1; }
(cd $S && shasum -a 256 theories/L2/Route.v theories/L1/Simple.v theories/L0/Exchange.v oracle/route/routespec.ml oracle/route/driver.ml) > BUILD-INFO
echo "oracle built: $S/oracle/route/driver"
