ifdef V
VERBOSE = --verbose
else
Q = @
QUIET = --quiet
endif

SUBDIRS = inc src test
INCDIRS = -Iinc -Isrc
SOURCES = $(wildcard */*.c*)
HEADERS = $(wildcard */*.h*)
DOXYGEN = $(SOURCES) $(HEADERS) $(wildcard *.md) Doxyfile
RUNTEST = cd bin && ./test ; cd -
CPPCHECK = $(Q)cppcheck --enable=all --inconclusive --std=posix $(QUIET) $(INCDIRS) $(SUBDIRS)
MAKE = make -f GNUMakefile
AM = $(Q)$(MAKE) Q=$(Q) MAKE="$(MAKE)"

all        : build

init       : GNUMakefile      ## Initialize auto tools (aclocal, autoconf, automake, configure)

GNUMakefile: configure.ac GNUMakefile.am
	$(Q)libtoolize $(QUIET) $(VERBOSE)
	$(Q)autoreconf --install --force $(VERBOSE)
	$(Q)./configure $(QUIET) AR_FLAGS="cr"

reconf     : clean-conf init  ## Reconfigure auto tools (autoreconf, configure)

clean-all  : clean-conf clean ## Remove all generated files

clean-conf :                  ## Remove generated autotools files
	$(Q)rm -rf autom4te.cache
	$(Q)rm -rf build-aux
	$(Q)rm -rf m4
	$(Q)rm -f aclocal.m4
	$(Q)rm -f configure config.log config.status
	$(Q)rm -f GNUMakefile.in GNUMakefile
	$(Q)rm -f libtool *-libtool ltmain.sh
	$(Q)for dir in . $(SUBDIRS); \
	do \
		rm -fr $$dir/.deps; \
	done;

clean      :                  ## Remove generated files (object files and binaries)
	$(Q)for dir in . $(SUBDIRS); \
	do \
		rm -f $$dir/*.o; \
		rm -f $$dir/*.lo; \
		rm -f $$dir/.dirstamp; \
		rm -fr $$dir/.libs; \
		rm -f $$dir/*.gcda $$dir/*.gcno; \
	done;
	$(Q)rm -rf bin lib install
	$(Q)rm -rf doxygen
	$(Q)rm -rf test-suite.log
	$(Q)rm -rf coverage coverage.info

build      : GNUMakefile      ## Build
	$(AM) $(FLAGS)

coverage   : FLAGS=CPPFLAGS="-g -O0 --coverage" LDFLAGS="-lgcov --coverage"
coverage   : build
coverage   : coverage.info    ## Code coverage (gcov + lcov)
coverage.info : bin/test
	$(value RUNTEST) && \
	rm -rf coverage && \
	lcov --directory . --capture --output-file coverage.info && \
	lcov --remove coverage.info '/usr/*' --output-file coverage.info && \
	lcov --list coverage.info && \
	genhtml --output-directory coverage coverage.info

rebuild    : clean-all build  ## Remove all generated files and build again

install    : build            ## Install (e.g. make install DESTDIR=$PWD/install)
	$(AM) install

check      : build            ## Run check (automake TESTS)
	$(AM) check

run-tests  : build            ## Run tests (bin/test executable)
	$(Q)$(value RUNTEST)

docker     :                  ## Build and run tests in Docker container
	docker build .

doxygen    : $(DOXYGEN)       ## Generate Doxygen documentation
	doxygen

cppcheck   :                  ## Run cppcheck
	$(CPPCHECK)

help       :                  ## Show this help
	@echo Goals:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -r 's/(.*):.*##(.*)/   \1 -\2/'
	@echo
	@echo Additional options:
	@echo "   V           - Verbosity, e.g. make V=1"
