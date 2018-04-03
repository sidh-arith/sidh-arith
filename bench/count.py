#!/usr/bin/python

import sys
import re

class Fun():
    def __init__(self, name):
        self.name = name
        self.adds = 0
        self.muls = 0
        self.movs = 0
        self.other = 0

def main():
    file = sys.argv[1]
    print(file)
    fh = open(file)
    funs = []
    funs.append(Fun("orphaned"))
    for line in fh:
        line = line.strip()

        # filter out comments
        m = re.match("^(.*?)//.*$", line)
        if m is not None:
            m = m.group(1)
            m.strip()
            if m == "":
                continue
            line = m

        m = re.match("^\s*/\*.*\*/\s*$", line)
        if m is not None:
            continue

        # and preprocessor instructions
        m = re.match("^\s*#.*$", line)
        if m is not None:
            continue

        # and my debugging macros
        m = re.match("^\s*SHOW.*$", line)
        if m is not None:
            continue

        # and the end of macro definitions
        m = re.match("^\s*.end.*$", line)
        if m is not None:
            continue

        # split functions
        m = re.match("^\s*(\S+):\s*", line)
        if m is not None:
            funname = m.group(1)
            if funname not in ["stuff", "epilogue", "prologue", "actualcode", "zero"]:
                funs.append(Fun(funname))
            continue

        m = re.match("^\s*\.macro (\S+)\s*", line)
        if m is not None:
            funname = m.group(1)
            if funname not in ["stuff", "epilogue", "prologue", "actualcode", "zero"]:
                funs.append(Fun(funname))
            continue

        m = re.match("^\s*mul\s+\S+\s*$", line)
        if m is not None:
            funs[-1].muls += 1
            continue

        m = re.match("^\s*mulx.*$", line)
        if m is not None:
            funs[-1].muls += 1
            continue

        m = re.match("^\s*add\s.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*adc\s.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*adcx\s.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*adox\s.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*adcq\s.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*sbb\s+.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*sub\s+.*,.*$", line)
        if m is not None:
            funs[-1].adds += 1
            continue

        m = re.match("^\s*pop\s+r.\s*.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*push\s+r.\s*.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*mov\s+.*,.*$", line)
        if m is not None:
            funs[-1].movs += 1
            continue

        m = re.match("^\s*movq\s+.*,.*$", line)
        if m is not None:
            funs[-1].movs += 1
            continue

        m = re.match("^\s*movabsq\s+.*,.*$", line)
        if m is not None:
            funs[-1].movs += 1
            continue

        m = re.match("^\s*shr\s+.*,.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*shl\s+.*,.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*shld.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*shrd.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*and\s+.*,.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*xor\s+.*,.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*dec.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*jnz.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*jmp.*$", line)
        if m is not None:
            funs[-1].other += 1
            continue

        m = re.match("^\s*call.*$", line)
        if m is not None:
            continue

        m = re.match("^\s*$", line)
        if m is not None:
            continue

        m = re.match("^.global\s.*$", line)
        if m is not None:
            continue

        m = re.match("^ret.*$", line)
        if m is not None:
            continue

        m = re.match("^#define.*$", line)
        if m is not None:
            continue

        m = re.match("^\.intel_syntax.*$", line)
        if m is not None:
            continue

        m = re.match("^\.text.*$", line)
        if m is not None:
            continue

        m = re.match("^\.data.*$", line)
        if m is not None:
            continue

        print("unknown line:")
        print("\"{}\"".format(line))

    print("Function\tMuls\tAdds\tOther\tMovs")
    for fun in funs:
        if fun.muls + fun.adds + fun.other + fun.movs > 0:
            print(fun.name + (" " * max(0, 8-len(fun.name))) + "\t" + str(fun.muls) + "\t" + str(fun.adds) +
                  "\t" + str(fun.other) + "\t" + str(fun.movs))



main()
