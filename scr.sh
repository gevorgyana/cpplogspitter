#!/bin/sh
awk -F "" '
BEGIN {kwd=0; multiline_comment=0; singleline_comment=0}
{
for (i=1;i<=NF;i++)
{
	if (i == 1) {singleline_comment = 0}
	if ($i == "/" && $(i+1) == "/") {singleline_comment=1;}
	if ($i == "/" && $(i+1) == "*") {multiline_comment=1;}
	if ($i == "*" && $(i+1) == "/") {multiline_comment=0; i++; printf "*/"; continue;}

	if (multiline_comment == 1 || singleline_comment == 1) {printf "%s", $i; continue;}

	if ($i == "c" && $(i+1) == "l" && $(i+2) == "a" && $(i+3) == "s" && $(i+4) == "s") {kwd=1}
	if ($i == "n" && $(i+1) == "a" && $(i+2) == "m" && $(i+3) == "e" && $(i+4) == "s" && $(i+5) == "p" && $(i+6) == "a" && $(i+7) == "c" && $(i+8) == "e") { kwd=1}

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
