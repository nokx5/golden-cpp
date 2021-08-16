#!/usr/bin/env bash
 
set -ex

wdir=$(dirname $(readlink -f "$0"))
: ${WORKSPACE:=$(realpath ${wdir}/../../)}

export INSTALLDIR=${WORKSPACE}/install-gcc-asan
rm -rf "${INSTALLDIR}"

# More robust stack unwinding for ASAN
export ASAN_OPTIONS=fast_unwind_on_malloc=0

# Suppresions for LeakSanitizer
export LSAN_OPTIONS=suppressions=${wdir}/lsan.suppressions

# Code hardening is not compatible with building on Debug
export NIX_HARDENING_ENABLE=0

cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_ENABLE_ASAN=ON -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}
ninja -k 100
ninja install
ctest --no-compress-output --output-on-failure -T Test -E "pytest.+|memcheck.+" -j 4

