Autotools template for C/C++
============================

Relatively simple and somewhat convenient C/C++ project template
based on GNU Autoconf and Automake with the possibility to extend it
with some additional features, e.g. Doxygen, Docker etc.

Features
--------

* Template for static and shared lib, CLI app and test
* Separate directory structure (inc, src, test)
* Simple make command wrapper
* Autoconf + automake
* Automake TESTS (make check)
* Simplest Doxygen config
* Code coverage report with lcov
* Docker build (checks build only)

Requirements
------------

* make, ld, ar etc
* gcc and g++
* autoconf automake libtool

In Ubuntu can be installed with:

    sudo apt-get install build-essential
    sudo apt-get install gcc g++
    sudo apt-get install autoconf automake libtool

### Optional:

* Code coverage (`sudo apt-get install lcov`)
* Cppcheck (`sudo apt-get install cppcheck`)
* Doxygen (`sudo apt-get install doxygen`)
* Docker ([install](https://docs.docker.com/install/))

How to build
------------

    make

How to test
-----------

    make check

Other commands
--------------

See all commands:

    make help

Clean all:

    make clean-all

Run make with verbose output:

    make V=1

Run Cppcheck:

    make cppcheck

Generate code coverage report:

    make clean
    make coverage

Generate Doxygen files

    make doxygen
