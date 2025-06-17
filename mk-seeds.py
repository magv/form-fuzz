import os
import glob
import re

os.system("mkdir -p seeds0")
for fn in glob.glob("form/check/*.frm", recursive=True):
    print(fn)
    basename = os.path.basename(fn).removesuffix(".frm")
    filename = None
    filetext = []
    def save():
        global filename
        global filetext
        if filename is not None and len(filetext) > 0:
            minn = min(
                len(re.match("^( *)[^ ]", line).group(1))
                for line in filetext
            )
            with open(filename, "w") as f:
                for line in filetext:
                    f.write(line[minn:])
        filename = None
        filetext = []
    with open(fn, "r") as f:
        for line in f:
            if line.startswith("*--#["):
                save()
                name = line.removeprefix("*--#[").strip(" :\n")
                print(f"seeds0/{basename}_{name}.frm")
                filename = f"seeds0/{basename}_{name}.frm"
                filetext = []
            elif line.startswith("*--#]"):
                save()
            else:
                if not line.strip().startswith("*"):
                    filetext.append(line)
                if line.strip().startswith(".end"):
                    save()
        save()
os.system("rm -rf seeds")
os.system("./afl/afl-cmin -i seeds0 -o seeds -- ./bin/form -")
