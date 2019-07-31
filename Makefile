all: build

SUBDIRS = inc src test
SOURCES = $(wildcard */*.c*)
HEADERS = $(wildcard */*.h*)
DOXYGEN = $(SOURCES) $(HEADERS) $(wildcard *.md) Doxyfile
MAKE = make -f GNUMakefile

init       : GNUMakefile      ## Initialize auto tools (aclocal, autoconf, automake, configure)

GNUMakefile: configure.ac GNUMakefile.am
	libtoolize
	autoreconf --install --force --verbose
	./configure

reconf     : clean-conf init  ## Reconfigure auto tools (autoreconf, configure)

clean-all  : clean-conf clean ## Remove all generated files

clean-conf :                  ## Remove generated autotools files
	rm -rf autom4te.cache
	rm -rf build-aux
	rm -rf m4
	rm -f aclocal.m4
	rm -f configure config.log config.status
	rm -f GNUMakefile.in GNUMakefile
	rm -f libtool *-libtool ltmain.sh
	for dir in . $(SUBDIRS); \
	do \
		rm -fr $$dir/.deps; \
	done;

clean      :                  ## Remove generated files (object files and binaries)
	for dir in . $(SUBDIRS); \
	do \
		rm -f $$dir/*.o; \
		rm -f $$dir/*.lo; \
		rm -f $$dir/.dirstamp; \
		rm -fr $$dir/.libs; \
	done;
	rm -rf bin lib install
	rm -rf doxygen
	rm -rf test-suite.log

build      : GNUMakefile      ## Build
	$(MAKE)

rebuild    : clean-all build  ## Remove all generated files and build again

install    : build            ## Install (e.g. make install DESTDIR=$PWD/install)
	$(MAKE) install MAKE="$(MAKE)"

check      : build            ## Run check (automake TESTS)
	$(MAKE) check MAKE="$(MAKE)"

run-tests  : build            ## Run tests (bin/test executable)
	cd bin && ./test ; cd -

docker     :                  ## Build and run tests in Docker container
	docker build .

doxygen    : $(DOXYGEN)       ## Generate Doxygen documentation
	doxygen

help       :                  ## Show this help
	@echo Goals:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -r 's/(.*):.*##(.*)/   \1 -\2/'
