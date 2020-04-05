#!/bin/sh
awk -F "" '
BEGIN {kwd=0; multiline_comment=0; singleline_comment=0;}
{
for (i=1;i<=NF;i++)
{
	if (i == 1) {singleline_comment = 0}
	if ($i$(i+1) == "//") {singleline_comment=1;}
	if ($i$(i+1) == "/*") {multiline_comment=1;}
	if ($i$(i+1) == "*/") {multiline_comment=0; i++; printf "*/"; continue;}
	if (multiline_comment == 1 || singleline_comment == 1) {printf "%s", $i; continue;}
	if ($i$(i+1)$(i+2)$(i+3)$(i+4) == "class") {kwd=1}
	if ($i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)$(i+6)$(i+7)$(i+8) == "namespace") { kwd=1}
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
