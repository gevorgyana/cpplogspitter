#!/bin/sh

#fxme identifier surned by spaces!needle
#fxme unsafe lookahed may find comments - actually safe
#fxme nf index?

awk -F "" '
BEGIN {kwd=0; multiline_comment=0; singleline_comment=0;
       ident_wanted = 0; ident = ""; ident_len = 0;
       terminate_ctor = 0; terminate_ctor_left_paren = 0;
       terminate_paren_right_paren = 0; internal_counter=0;
       ns_kwd = 0; parse_ident = 0;}
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
		kwd=1; i = i + 4; ns_kwd = 0; parse_ident = 1;
		continue;
	}

	if (parse_ident == 1)
	{
 	       	j = i;
		while ($j == " " && j <= NF)
		{
			printf " ";
			j++;
		}

	       	while ($(j) != " " && $(j) != "{" && $(j) != ";" && j <= NF)
		{
			ident = ident$j;
			j++;
			ident_len++;
		}

		printf "%s", ident
		if (ident != "" && ident_len > 0) {parse_ident = 0;}

		# so that next cycle starts from
		# the ; or { or [[:blank:]]
		i = j - 1;

		continue;
	}

	if ($i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)$(i+6)$(i+7)$(i+8) == "namespace")
	{
		printf "%s", $i$(i+1)$(i+2)$(i+3)$(i+4)$(i+5)$(i+6)$(i+7)$(i+8);
		kwd=1; i = i + 8;
		ns_kwd = 1;
		continue;
	}

	#this part does not havetogiveidentifiertheremaybenone
	if (ident_wanted == 1)
	{
		# printf "[want %s]", ident;

		needle = "";
		for (j = i; j <= NF && j < i + ident_len; j++)
		{
			needle = needle$j;
		}

		# printf "/NEEDlE_%s_", needle;

		if (needle == ident)
		{
			# todo maybe indexing error?
			j = i + ident_len - 1;

		       	ident = "";
		       	ident_len = 0;

		       	ident_wanted = 0;
			terminate_ctor_left_par = 1;
		}

		if ($i == "{") {internal_counter++;}
		if ($i == "}") {internal_counter--;}

		printf "%s", $i;
		# printf "%sIW", $i;
		# printf "%d", count;

		if (internal_counter == 0)
		{
			ident_wanted = 0;
			count = 0;
		       	ident = "";
		       	ident_len = 0;
		}

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
		# printf "%sLP", $i;
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
		# printf "%sRP", $i;
		continue;
	}

	# final step of ctor logging
	if (terminate_ctor == 1)
	{
	       	if ($i == "{") {$i="{ PROCESSED CTOR;"; terminate_ctor = 0;}
		if ($i == ";") {terminate_ctor = 0;}
		printf "%s", $i;
		# printf "%sTT", $i;
		continue;
	}

	# either dealing with declaration or with
	# the beginning of definition; silently handle
	# this case and continue with next characters;
	if (($i == ";" || $i == "{") && kwd == 1)
	{
		if ($i == "{" && ns_kwd == 0) {count++; ident_wanted = 1; internal_counter = 1;}
		kwd=0
		printf "%s", $i
		# printf "%sCM", $i
		continue
	}

	# printf "!!%d", count

	# if we reached these lines, we can safely filter
	# brackets, it means application logic has been
	# satisfied
	if ($i == "}" && count > 0) {count--}
	if ($i == "{" ) if (count++ == 0) {$i="{ PROCESSED;"}
	printf "%s", $i
}
printf "%s", ORS
}
'
