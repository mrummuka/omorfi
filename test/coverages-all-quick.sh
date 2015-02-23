#!/bin/bash
if test -z $srcdir ; then
    echo Use make check or define srcdir
    exit 1
fi
if test ! -r $srcdir/coverage-fast-alls.freqs ; then
    echo Missing $srcdir/coverage-fast-alls.freqs
    exit 77
fi
if test ! -r ../src/generated/omorfi-omor.analyse.hfst ; then
    echo Missing ../src/generated/omorfi-omor.analyse.hfst
    exit 77
fi
PYTHON=python3
if type python3 ; then
    PYTHON=python3
elif type python ; then
    if python -V | fgrep 3. ; then
        PYTHON=python
    else
        echo $(which python) not python3
        exit 77
    fi
else
    echo Missing python3
    exit 77
fi
if ! $PYTHON $srcdir/coverage.py -f ../src/generated/omorfi-ftb3.analyse.hfst -i coverage-fast-alls.freqs -c 1000 -o coverage-short.log ; then
    echo We missed the target of 99 % coverage
    exit 1
fi
exit 0
