YGOSHARP_HOME="$HOME/workspace/ygo/ygosharp"
WINDBOW_HOME="$HOME/workspace/ygo/windbot"


cd "$WINDBOW_HOME" || exit
mkdir -p tourney

i=0
for deck1 in "$WINDBOW_HOME"/Decks/*.ydk; do
    deck1="$(basename $deck1 .ydk | sed -e 's/AI_//')"

    #deck1=Dragun
    for deck2 in "$WINDBOW_HOME"/Decks/*.ydk; do
        deck2="$(basename $deck2 .ydk | sed -e 's/AI_//')"

        # ignore mirror match
        if [[ "$deck1" != "$deck2" ]]; then
            "$YGOSHARP_HOME"/YGOSharp/bin/Debug/YGOSharp.exe  > /dev/null 2>&1 &

            #"$WINDBOW_HOME"/bin/Debug/WindBot.exe Name="$deck2" Host=127.0.0.1 Port=7911 Deck="$deck2" Debug=True > /dev/null 2>&1 &
            "$WINDBOW_HOME"/bin/Debug/WindBot.exe Name="$deck2" Host=127.0.0.1 Port=7911 Deck="$deck2" Debug=True > duel2.log &
            "$WINDBOW_HOME"/bin/Debug/WindBot.exe Name="$deck1" Host=127.0.0.1 Port=7911 Deck="$deck1" Debug=True > duel.log

            D1_WINS="$(grep 'result: Win' duel.log)"
            cp duel.log tourney/"$deck1"_vs_"$deck2".log
            cp duel2.log tourney/"$deck1"_vs_"$deck2"_2.log
        else
            IS_WINNER="$deck2"
        fi

        if [[ -z "$D1_WINS" ]];then
            WINNER="$deck2"
        else
            WINNER="$deck1"
        fi
        NOW=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$i,$NOW,$deck1,$deck2,$WINNER"
        ((i+=1))
    done
done
