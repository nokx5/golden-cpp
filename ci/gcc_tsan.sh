#!/usr/bin/env bash
 
set -ex

wdir=$(dirname $(readlink -f "$0"))
: ${WORKSPACE:=$(realpath ${wdir}/../../)}

export INSTALLDIR=${WORKSPACE}/install-gcc-tsan
rm -rf "${INSTALLDIR}"

# Code hardening is not compatible with building on Debug
export NIX_HARDENING_ENABLE=0

# Suppresions for ThreadSanitizer
export TSAN_OPTIONS=suppressions=${wdir}/tsan.suppressions

cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_ENABLE_TSAN=ON -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}
ninja -k 100
ninja install
ctest --no-compress-output --output-on-failure -T Test -E "memcheck.+" -j 4
