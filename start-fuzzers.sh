set -x -e

base=$(realpath "$PWD")
tmp=${TMPDIR:-/tmp}/form-fuzz

rm -rf "$tmp"
mkdir -p "$tmp"
cp -a "afl/afl-fuzz" "$tmp/"
cp -a "seeds" "$tmp/seeds"

fuzz() {
    tag=$1
    env_args=$2
    fuzz_args=$3
    exe=$4
    exe_args=$5
    subdir=$tmp/$tag
    mkdir -p "$subdir"
    cp -a "bin/$exe" "$subdir/"
    env -C "$subdir" \
        "AFL_TESTCACHE_SIZE=100MB" \
        $env_args \
        "$tmp/afl-fuzz" -a text -i "$tmp/seeds" -o "$tmp/out" -x $base/form.dict -t 5000 \
        $fuzz_args \
        -- \
        "$subdir/$exe" $exe_args >"$subdir/log.stdout" 2>"$subdir/log.stderr" &
}

fuzz  "main"     "AFL_FINAL_SYNC=1"  "-M main"         "form"          "-"  
fuzz  "ASAN"     ""                  "-S ASAN"     "form.ASAN"     "-"  
fuzz  "CFISAN"   ""                  "-S CFISAN"   "form.CFISAN"   "-"  
fuzz  "LSAN"     ""                  "-S LSAN"     "form.LSAN"     "-"  
fuzz  "MSAN"     ""                  "-S MSAN"     "form.MSAN"     "-"  
fuzz  "UBSAN"    ""                  "-S UBSAN"    "form.UBSAN"    "-"  
#fuzz  "tASAN"    ""                  "-S ASAN"     "tform.ASAN"    "-w2 -"
#fuzz  "tCFISAN"  ""                  "-S tCFISAN"  "tform.CFISAN"  "-w2 -"
#fuzz  "tLSAN"    ""                  "-S tLSAN"    "tform.LSAN"    "-w2 -"
#fuzz  "tMSAN"    ""                  "-S tMSAN"    "tform.MSAN"    "-w2 -"
#fuzz  "tUBSAN"   ""                  "-S tUBSAN"   "tform.UBSAN"   "-w2 -"
#fuzz  "tTSAN"    ""                  "-S tTSAN"    "tform.TSAN"    "-w2 -"

atexit() {
    kill $(jobs -p)
}

trap "atexit" EXIT 

wait
