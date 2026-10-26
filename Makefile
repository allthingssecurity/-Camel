# make: compile the spec (light, seconds). make oracle: extract + build the OCaml oracle. make camel: compile Camel at the pin.
all: Makefile.rocq
	$(MAKE) -f Makefile.rocq
Makefile.rocq: _RocqProject
	rocq makefile -f _RocqProject -o Makefile.rocq
oracle: all
	bash oracle/build.sh
	bash oracle/l4/build.sh
camel:
	bash harness/build-camel.sh
status:
	python3 tools/status.py > STATUS.md
clean:
	$(MAKE) -f Makefile.rocq clean
.PHONY: all oracle camel status clean
