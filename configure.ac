AC_INIT([autotools-template],[0.6])

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_SILENT_RULES([yes])
LT_INIT

AC_PROG_CC
AC_PROG_CXX
AC_PROG_INSTALL

AC_CHECK_PROGS([DOXYGEN],  [doxygen],  [yes])
AC_CHECK_PROGS([LCOV],     [lcov],     [yes])
AC_CHECK_PROGS([CPPCHECK], [cppcheck], [yes])

AC_CONFIG_FILES(GNUMakefile)
AC_OUTPUT
