#!/usr/bin/env bash
 
set -ex

wdir=$(dirname $(readlink -f "$0"))
: ${WORKSPACE:=$(realpath ${wdir}/../../)}

export INSTALLDIR=${WORKSPACE}/install-gcc-gcov
rm -rf "${INSTALLDIR}"

# Code hardening is not compatible with building on Debug
export NIX_HARDENING_ENABLE=0

cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_ENABLE_GCOV=ON -DCMAKE_INSTALL_PREFIX=${INSTALLDIR}
ninja -k 100
ninja install

export LD_LIBRARY_PATH="$(ls -d ${INSTALLDIR}/lib*/):${LD_LIBRARY_PATH}"
ctest --no-compress-output --output-on-failure -T Test -E "memcheck.+"
 
# TODO nix-provided boost headers contain #line directives that
# confuse gcov. The following symlink will help gcov find the headers.
ln -sf $(nix-build -A boost.dev)/include

rc="--rc lcov_branch_coverage=1 --rc lcov_function_coverage=0"
output="${WORKSPACE}/coverage.info"

# TODO Use LCOV to generate the HTML code coverage report because
# gcovr is not properly reporting coverage for code in C++ headers.
lcov --directory . --base-directory . --capture --output-file ${output} ${rc}
lcov --remove ${output} \
    '/nix/*' '/run/*' '*/include/boost/*' '*/tests/*' '*/build-*/*' '*/liblbfgs/*' '*/pybind11/*' \
    --output-file ${output} ${rc}
lcov --list ${output} ${rc}
genhtml ${rc} --output lcovhtml ${output}

rm -f lcov_cobertura.py*
# download lcov_cobertura.py
python lcov_cobertura.py "${output}" --base-dir "${WORKSPACE}" --output "${WORKSPACE}/coverage_gcc.xml"
