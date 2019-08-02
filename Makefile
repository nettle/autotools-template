# Verbosity flags
ifdef V
VERBOSE = --verbose
else
Q = @
QUIET = --quiet
endif

# Project settings
SUBDIRS = inc src test
INCDIRS = -Iinc -Isrc
SOURCES = $(wildcard */*.c*)
HEADERS = $(wildcard */*.h*)
DOXYSRC = $(SOURCES) $(HEADERS) $(wildcard *.md) Doxyfile
DOXYGEN = doxygen
RUNTEST = cd bin && ./test ; cd -
DOCKER  = docker build .
CPPCHECK = cppcheck --enable=all --inconclusive --std=posix $(QUIET) $(INCDIRS) $(SUBDIRS)
COVFLAGS = CPPFLAGS="-g -O0 --coverage" LDFLAGS="-lgcov --coverage"
COVFILES = bin/test
COVERAGE = $(RUNTEST) && \
	rm -rf coverage && \
	lcov $(QUIET) --directory . --capture --output-file coverage.info && \
	lcov $(QUIET) --remove coverage.info '/usr/*' --output-file coverage.info && \
	lcov $(QUIET) --list coverage.info && \
	genhtml $(QUIET) --output-directory coverage coverage.info

# Automake macros
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

rebuild    : clean-all build  ## Remove all generated files and build again

install    : build            ## Install (e.g. make install DESTDIR=$PWD/install)
	$(AM) install

check      : build            ## Run check (automake TESTS)
	$(AM) check

run-tests  : build            ## Run tests (bin/test executable)
	$(Q)$(RUNTEST)

docker     :                  ## Build and run tests in Docker container
	$(Q)$(DOCKER)

doxygen    : $(DOXYSRC)       ## Generate Doxygen documentation
	$(Q)$(DOXYGEN)

cppcheck   :                  ## Run cppcheck
	$(Q)$(CPPCHECK)

coverage   : FLAGS=$(COVFLAGS)
coverage   : build
coverage   : coverage.info    ## Code coverage (lcov) NOTE: run make clean first!
coverage.info : $(COVFILES)
	$(Q)$(COVERAGE)

help       :                  ## Show this help
	@echo Goals:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -r 's/(.*):.*##(.*)/   \1 -\2/'
	@echo
	@echo Additional options:
	@echo "   V           - Verbosity, e.g. make V=1"
