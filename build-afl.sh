set -x -e

sudo apt install \
    build-essential python3-dev automake cmake git flex bison libglib2.0-dev libpixman-1-dev python3-setuptools cargo libgtk-3-dev \
    lld llvm llvm-dev clang \
    gcc-14-plugin-dev libstdc++-14-dev \
    cpio libcapstone-dev

git clone https://github.com/AFLplusplus/AFLplusplus afl
make -C afl source-only PERFORMANCE=1 NO_NYX=1 -j6
