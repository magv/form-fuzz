set -x -e

base=$(realpath "$PWD")
tmp=${TMPDIR:-/tmp}/fuzz

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
fuzz  "ASAN"     ""                  "-S sub_ASAN"     "form.ASAN"     "-"  
fuzz  "CFISAN"   ""                  "-S sub_CFISAN"   "form.CFISAN"   "-"  
fuzz  "LSAN"     ""                  "-S sub_LSAN"     "form.LSAN"     "-"  
fuzz  "MSAN"     ""                  "-S sub_MSAN"     "form.MSAN"     "-"  
fuzz  "UBSAN"    ""                  "-S sub_UBSAN"    "form.UBSAN"    "-"  
#fuzz  "tASAN"    ""                  "-S sub_ASAN"     "tform.ASAN"    "-w2 -"
#fuzz  "tCFISAN"  ""                  "-S sub_tCFISAN"  "tform.CFISAN"  "-w2 -"
#fuzz  "tLSAN"    ""                  "-S sub_tLSAN"    "tform.LSAN"    "-w2 -"
#fuzz  "tMSAN"    ""                  "-S sub_tMSAN"    "tform.MSAN"    "-w2 -"
#fuzz  "tUBSAN"   ""                  "-S sub_tUBSAN"   "tform.UBSAN"   "-w2 -"
#fuzz  "tTSAN"    ""                  "-S sub_tTSAN"    "tform.TSAN"    "-w2 -"

atexit() {
    kill $(jobs -p)
}

trap "atexit" EXIT 

wait
