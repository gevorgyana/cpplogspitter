#!/bin/sh

(./scr.sh < sample.cpp) > out
diff out_sealed out > diffs

if [ -s diffs ]
then
    echo "wrong"
else
    echo "correct"
fi

rm out
