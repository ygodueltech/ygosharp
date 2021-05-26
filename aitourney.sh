YGOSHARP_HOME="$HOME/workspace/ygo/ygosharp"
WINDBOW_HOME="$HOME/workspace/ygo/windbot"



cd "$WINDBOW_HOME" || exit

i=0
for deck1 in "$WINDBOW_HOME"/Decks/*.ydk; do

    deck1="$(basename $deck1 .ydk | sed -e 's/AI_//')"
    for deck2 in "$WINDBOW_HOME"/Decks/*.ydk; do


        deck2="$(basename $deck2 .ydk | sed -e 's/AI_//')"

        # ignore mirror match
        if [[ "$deck1" != "$deck2" ]]; then
            "$YGOSHARP_HOME"/YGOSharp/bin/Debug/YGOSharp.exe  > /dev/null 2>&1 &

            "$WINDBOW_HOME"/bin/Debug/WindBot.exe Host=127.0.0.1 Port=7911 Deck="$deck1" > /dev/null 2>&1 &
            "$WINDBOW_HOME"/bin/Debug/WindBot.exe Host=127.0.0.1 Port=7911 Debug=True Deck="$deck2" > duel.log

            IS_WINNER="$(grep 'result: Win' duel.log)"
        else
            IS_WINNER="$deck2"
        fi

        if [[ -z "$IS_WINNER" ]];then
            WINNER="$deck2"
        else
            WINNER="$deck1"
        fi
        NOW=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$i,$NOW,$deck1,$deck2,$WINNER"
        ((i+=1))
    done
done
