import os
import glob
import re

tokens = set(" ;,=():?^+*/[]{}`'.<>+-")
for fn in glob.glob("seeds/*"):
    #print(fn)
    with open(fn, "r") as f:
        text = f.read()
    tokens.update(re.split(r"[\n\t ;,=():?^+*/\[\]{}`'.<>+-]", text))
with open("form.dict", "w") as f:
    for t in tokens:
        f.write(f'1="{t}"\n')
