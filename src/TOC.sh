#!/usr/bin/env sh

cat TOC.tpl | while read line; do
    ITEM=$(echo $line | tr ':' '\n');
    ITEM_LEN=$[$(echo $line | sed 's/:/\n/g' | wc -l)-1];
    PAGENAME=$(echo $line | sed 's/:/\n/g' | tail -n1);
    PAGEPATH="$(echo $line | sed 's/:/\//g').md";
    echo "$(for i in $(seq 1 $ITEM_LEN); do echo -n -e "\t"; done)- [$PAGENAME]($PAGEPATH)";
done
