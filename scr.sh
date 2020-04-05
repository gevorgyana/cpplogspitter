#!/bin/sh
awk -F "" '
BEGIN {kwd=0}
{
for (i=1;i<=NF;i++)
{
	if ($i == "c" && $(i+1) == "l" && $(i+2) == "a" && $(i +3) == "s" && $(i+4) == "s") kwd=1

	if (($i == ";" || $i == "{") && kwd == 1)
	{
		if ($i == "{") count++
		kwd=0
		printf "%s", $i
		continue
	}

	if ($i == "}" && count > 0) count--
	if ($i == "{" ) if (count++ == 0) $i="{ PROCESSED;"
	printf "%s", $i
}
printf "%s", ORS
}
'
