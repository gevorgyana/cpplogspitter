#!/bin/sh
awk -F "" '
BEGIN {kwd=0; multiline_comment=0; singleline_comment=0;
       ident_wanted = 0; ident = ""; ident_len = 0;
       terminate_ctor = 0; terminate_ctor_left_paren = 0;
       terminate_paren_right_paren = 0;}
{
for (i=1;i<=NF;i++)
{
	# comments processing block
	if (i == 1) {singleline_comment = 0}
	if ($i$(i+1) == "//") {singleline_comment=1;}
	if ($i$(i+1) == "/*") {multiline_comment=1;}
	if ($i$(i+1) == "*/") {multiline_comment=0; i++; printf "*/"; continue;}
	if (multiline_comment == 1 || singleline_comment == 1) {printf "%s", $i; continue;}

	# keywords processing
	if ($i$(i+1)$(i+2)$(i+3)$(i+4) == "class")
	{
		printf "%s", $i$(i+1)$(i+2)$(i+3)$(i+4);
		kwd=1; i = i + 4;

 	       	j = i + 1;
		while ($j == " " && j < NF)
		{
			printf " ";
			j++;
		}

		# todo check that it parses any identifier,
		# but seems legit
	       	while ($(j) != " " && $(j) != "{" && $(j) != ";" && j < NF)
		{
			ident = ident$j;
			j++;
			ident_len++;
		}

		printf "%s", ident

		# so that next cycle starts from
		# the ; or { or [[:blank:]]
		i = j - 1;

		continue;
	}
	if ($i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)$(i+6)$(i+7)$(i+8) == "namespace")
	{
		printf "%s", $i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)$(i+6)$(i+7)$(i+8);
		kwd=1; i = i + 8;
		continue;
	}

	if (ident_wanted == 1)
	{
		needle = "";
		for (j = i; j < NF && j < ident_len; j++)
		{
			needle = needle$(j);
		}
		if (needle == ident)
		{
			# todo maybe indexing error?
			j = i + ident_len - 1;
		       	ident_wanted = 0;
		       	ident = "";
		       	ident_len = 0;

			# transition point
			terminate_ctor_left_par = 1;
		}
		printf "%s", $i;
		continue;
	}

	if (terminate_ctor_left_par)
	{
		if ($i == "(")
		{
			terminate_ctor_left_par = 0;
			terminate_ctor_right_par = 1;
		}
		printf "%s", $i;
		continue;
	}

	if (terminate_ctor_right_par)
	{
		if ($i == ")")
		{
			terminate_ctor_right_par = 0;
			terminate_ctor = 1;
		}
		printf "%s", $i;
		continue;
	}

	# final step of ctor logging
	if (terminate_ctor == 1)
	{
	       	if ($i == "{") {$i="{ PROCESSED;"; terminate_ctor = 0;}
		printf "%s", $i;
		continue;
	}

	# either dealing with declaration or with
	# the beginning of definition; silently handle
	# this case and continue with next characters;
	if (($i == ";" || $i == "{") && kwd == 1)
	{
		if ($i == "{") {count++; ident_wanted = 1;}
		kwd=0
		printf "%s", $i
		continue
	}

	# if we reached these lines, we can safely filter
	# brackets, it means application logic has been
	# satisfied
	if ($i == "}" && count > 0) count--
	if ($i == "{" ) if (count++ == 0) $i="{ PROCESSED;"
	printf "%s", $i
}
printf "%s", ORS
}
'
