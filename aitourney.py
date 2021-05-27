import glob
from datetime import datetime
import itertools
import subprocess
import os
import sys
import time

def get_now():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

HOME=os.getenv('HOME')
YGOSHARP_HOME = f"{HOME}/workspace/ygo/ygosharp"
WINDBOW_HOME = f"{HOME}/workspace/ygo/windbot"
LOG_DIR = f"{WINDBOW_HOME}/tourney"
fls = glob.glob(f"{WINDBOW_HOME}/Decks/*.ydk")

os.chdir(WINDBOW_HOME)

# fls=fls[:2]
fls = [x.split('/')[-1].replace(".ydk","").replace("AI_","") for x in fls]

for i, (deck1,deck2) in enumerate(itertools.combinations(fls, 2)):

    result_file = f"{LOG_DIR}/duel.log"
    deck2_log = f"{LOG_DIR}/{deck2}_vs_{deck1}.log"
    deck1_log = f"{LOG_DIR}/{deck1}_vs_{deck2}.log"

    with (
        open(deck1_log,'a') as deck1_log_f,
        open(deck2_log,'a') as deck2_log_f,
        ):

        p_serv = subprocess.Popen(f"{YGOSHARP_HOME}/YGOSharp/bin/Debug/YGOSharp.exe NoShuffleDeck=True ClientVersion=4946".split()
                ,stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,cwd=YGOSHARP_HOME)

        cmd = f"{WINDBOW_HOME}/bin/Debug/WindBot.exe Name={deck1}  Port=7911 Deck={deck1} Debug=True"
        pdeck1 = subprocess.Popen(cmd.split(), stdout=deck1_log_f,cwd=WINDBOW_HOME)

        cmd = f"{WINDBOW_HOME}/bin/Debug/WindBot.exe Name={deck2}  Port=7911 Deck={deck2} Debug=True"
        pdeck2 = subprocess.Popen(cmd.split(), stdout=deck2_log_f, stderr=subprocess.STDOUT, cwd=WINDBOW_HOME)

        pdeck1.wait()
        pdeck2.wait()
        p_serv.wait()
        if pdeck1.returncode != 0 or pdeck2.returncode != 0:
            print(deck1, deck2)
            import pdb;pdb.set_trace()
            print("wtf a process broke!!")
            sys.exit()

    with open(deck1_log) as f:
        output = f.read()
        if 'result: Win' in output:
            winner = deck1
        else:
            winner = deck2

    now = get_now()
    # always same order for easy query in pandas
    decks = ','.join(sorted([deck1,deck2]))
    line = f"{i},{now},{decks},{winner}\n"

    with open(result_file, 'a') as f:
        print(line)
        f.write(line)
