#!/usr/bin/env sh

# Should be root project dir, we will output to files relative to project
#SELFPATH=$(dirname $(realpath $0))
#SUMMARY_ORG=$SELFPATH/src/SUMMARY.org

#echo "* Summary"

cat TOC.tpl | while read line; do
    ITEM=$(echo $line | tr ':' '\n');
    ITEM_LEN=$[$(echo $line | sed 's/:/\n/g' | wc -l)-1];
    PAGENAME=$(echo $line | sed 's/:/\n/g' | tail -n1);

    PAGEPATH_ORG="$(echo $line | sed 's/:/\//g').org";

    if [ -f "src/$PAGEPATH_ORG" ]; then
        TODO=""
    else
        TODO=" [TODO]"
    fi

    FORMATTED="[[file:$PAGEPATH_ORG][$PAGENAME$TODO]]"

    INDENT=$(for i in $(seq 1 $ITEM_LEN); do echo -n -e "\t"; done)
    echo "$INDENT- $FORMATTED";
done
