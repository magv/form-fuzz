set -x -e

sudo apt install \
    libgmp-dev libmpfr-dev libz-dev libflint-dev

base=$(realpath $PWD)
mkdir -p bin
git clone https://github.com/form-dev/form
cd form
patch -p0 < ../patch.diff
autoreconf -i
./configure \
    --enable-threaded=yes \
    --enable-parform=no \
    --enable-debug=yes \
    --with-gmp \
    --with-mpfr \
    --with-zlib \
    --with-flint \
    CFLAGS="-O3 -fno-omit-frame-pointer" \
    CXXFLAGS="-O3 -fno-omit-frame-pointer" \
    CC=$base/afl/afl-clang-fast \
    CXX=$base/afl/afl-clang-fast++
build() {
    suffix=$1
    env_args=$2
    make clean
    env $env_args make -j6
    cp -a sources/form ../bin/form$suffix
    cp -a sources/vorm ../bin/vorm$suffix
    cp -a sources/tform ../bin/tform$suffix
    cp -a sources/tvorm ../bin/tvorm$suffix
}
build "" ""
build ".ASAN" "AFL_USE_ASAN=1" 
build ".CFISAN" "AFL_USE_CFISAN=1" 
build ".LSAN" "AFL_USE_LSAN=1" 
build ".MSAN" "AFL_USE_MSAN=1" 
build ".TSAN" "AFL_USE_TSAN=1" 
build ".COMPCOV" "AFL_LLVM_LAF_ALL=1" 
build ".CMPLOG" "AFL_LLVM_CMPLOG=1"
