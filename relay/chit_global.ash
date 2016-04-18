// Global variables and functions which need to be defined for imported files as well as the main program.

string [string] chitSource;
string [string] chitBricks;
string [string] chitPickers;
string [string] chitTools;
static string [string] chitEffectsMap;
location lastLoc;
boolean isCompact = false;
boolean inValhalla = false;
string imagePath = "/images/relayimages/chit/";

record buff {
	effect eff;
	string effectName;
	string effectHTML;
	string effectImage;
	string effectType;
	int effectTurns;
	boolean isIntrinsic;
};

/*****************************************************
	Script functions
*****************************************************/

// '"/KoLmafia/sideCommand?cmd=' + cmd + '&pwd=' + my_hash() + '"'
string sideCommand(string cmd) {
	buffer c;
	c.append('/KoLmafia/sideCommand?cmd=');
	c.append(url_encode(cmd));
	c.append('&pwd=');
	c.append(my_hash());
	return c;
}

void bakeUpdate(string thisver, string prefix, string newver) {
	buffer result;
	result.append('<table id="chit_update" class="chit_brick nospace">');
	result.append('<thead><tr><th colspan="2">Character Info Toolbox</th></tr>');
	result.append('</thead><tbody><tr><td class="info">');
	result.append('<p>(');
	result.append(prefix);
	result.append(thisver);
	result.append(')</p>');
	result.append('<p>');
	result.append(prefix);
	result.append(newver);
	result.append(' is now available');
	result.append('<br>Click <a href="');
	if(svn_exists("mafiachit")) {
		result.append(sideCommand('svn update mafiachit; set _chitSVNatHead = true;'));
		result.append('" title="SVN Update">here</a> to upgrade from SVN</p>');
	} else {
		result.append(sideCommand('svn checkout https://svn.code.sf.net/p/mafiachit/code/'));
		result.append('" title="SVN Installation">here</a> to install current version from SVN</p>');
	}
	result.append('</td></tr></tbody></table>');
	chitBricks["update"] = result.to_string();		
}

/*****************************************************
	String functions
*****************************************************/

string formatInt(int n) {
	return to_string(n, "%,d");
}

string formatInt(float f) {
	return to_string(f, "%,.0f");
}

string formatModifier(int n) {
	return to_string(n, "%+,d");
}

// Round off to p decimals
string formatModifier(float f, int p) {
	if(p<1) return to_string(round(f), "%+,d%%");
	return replace_all(create_matcher("(?<!\\.)0+$", to_string(f, "%+,."+p+"f") ), "")+"%";
}

string formatModifier(float f) {
	return formatModifier(f, 2);
}

string formatStats(stat s) {
	int buffed = my_buffedstat(s);
	int unbuffed = my_basestat(s);
	if(buffed > unbuffed)
		return '<span style="color:blue">' + formatInt(buffed) + '</span>&nbsp;&nbsp;(' + unbuffed + ')';
	else if(buffed < unbuffed)
		return '<span style="color:red">' + formatInt(buffed) + '</span>&nbsp;&nbsp;(' + unbuffed + ')';
	return to_string(buffed);
}

stat findSub(stat s) {
	if(s == $stat[muscle]) return $stat[submuscle];
	else if(s == $stat[mysticality]) return $stat[submysticality];
	return $stat[submoxie];
}

string progressSubStats(stat s) {
	int statval = my_basestat(s);
	
	int lower = statval**2;
	int range = (statval + 1)**2 - lower;
	int current = my_basestat(findSub(s)) - lower;
	int needed = range - current;
	float progress = (current * 100.0) / range;
	return '<div class="progressbox" title="' + current + ' / ' + range + ' (' + needed + ' needed)"><div class="progressbar" style="width:' + progress + '%"></div></div>';
}

string progressCustom(int current, int limit, string hover, int severity, boolean active) {

	string color = "";
	string title = "";
	string border = "";
	
	switch (severity) {
		case -1	: color = "#D0D0D0"; 	break;		//disabled
		case 0	: color = "blue"; 		break;		//neutral
		case 1	: color = "green"; 		break;		//good
		case 2	: color = "orange"; 	break;		//bad
		case 3	: color = "red"; 		break;		//ugly
		case 4	: color = "#707070"; 	break;		//full
		case 5	: color = "black"; 		break;		//busted
		case 6	: color = "black"; 		break;		//super-busted
		default	: color = "blue";
	}
	string title() { return current + ' / ' + limit; }
	switch (hover) {
		case "" : title = ""; break;
		case "auto": title = ' title="' + title() + '"'; break;
		default: title = ' title="' + hover +' ('+ title() +')"';
	}
	if (active) border = ' style="border-color:#707070"';
	if (limit == 0) limit = 1;
	
	float progress = (min(current, limit) * 100.0) / limit;
	buffer result;
	result.append('<div class="progressbox"' + title + border + '>');
	result.append('<div class="progressbar" style="width:' + progress + '%;background-color:' + color + '"></div>');
	result.append('</div>');
	return result.to_string();
}
string progressCustom(int current, int limit, int severity, boolean active) {
	return progressCustom(current, limit, current + ' / ' + limit, severity, active);
}

/*****************************************************
	Picker functions
*****************************************************/

void pickerStart(buffer picker, string rel, string message) {
	picker.append('<div id="chit_picker');	
	picker.append(rel);	
	picker.append('" class="chit_skeleton" style="display:none"><table class="chit_picker"><tr><th colspan="3">');
	picker.append(message);
	picker.append('</th></tr>');
}
void pickerStart(buffer picker, string rel, string message, string image) {
	picker.pickerStart(picker, rel, '<img src="' + imagePath + image + '.png">' + message);
}

void addLoader(buffer picker, string message, string subloader) {
	picker.append('<tr class="pickloader');
	picker.append(subloader);
	picker.append('" style="display:none"><td class="info">');
	picker.append(message);
	picker.append('</td><td class="icon"><img src="/images/itemimages/karma.gif"></td></tr>');
}

void addLoader(buffer picker, string message) {
	addLoader(picker,message,"");
}

void addSadFace(buffer picker, string message) {
	picker.append('<tr class="picknone"><td class="info" colspan="3">');
	picker.append(message);
	picker.append('</td></tr>');
}

/*****************************************************
	Modifier parsing functions
*****************************************************/

//ckb: function for effect descriptions to make them short and pretty, called by chit.effects.describe
string parseMods(string evm, boolean span) {
	buffer enew;  // This is used for rebuilding evm with append_replacement()
	
	// Standardize capitalization
	matcher uncap = create_matcher("\\b[a-z]", evm);
	while(uncap.find())
		uncap.append_replacement(enew, to_upper_case(uncap.group(0)));
	uncap.append_tail(enew);
	evm = enew;
	
	// Move parenthesis to the beginning of the modifier
	enew.set_length(0);
	matcher paren = create_matcher("(, ?|^)([^,]*?)\\((.+?)\\)", evm);
	while(paren.find()) {
		paren.append_replacement(enew, paren.group(1));
		enew.append(paren.group(3));
		enew.append(" ");
		enew.append(paren.group(2));
	}
	paren.append_tail(enew);
	evm = enew;
	
	// Anything that applies the same modifier to all stats or all elements can be combined
	record {
		boolean [string] original;
		string val;
	} [string] modsort;
	string [int,int] modparse = group_string(evm, "(?:,|^)\\s*([^,:]*?)(Muscle|Mysticality|Moxie|Hot|Cold|Spooky|Stench|Sleaze)([^:]*):\\s*([+-]?\\d+)");
	string key;
	foreach m in modparse {
		if($strings[Muscle,Mysticality,Moxie] contains modparse[m][2])
			key = modparse[m][1]+"Stats"+modparse[m][3];
		else
			key = modparse[m][1]+"Prismatic"+modparse[m][3];
		if(!(modsort contains key) || modsort[key].val == modparse[m][4]) {
			modsort[ key ].original[ modparse[m][0] ] = true;
			modsort[ key ].val = modparse[m][4];
		}
	}
	foreach m,s in modsort
		if((m.contains_text("Stats") && count(s.original) == 3) || (m.contains_text("Prismatic") && count(s.original) == 5)) {
			foreach o in s.original
				evm = evm.replace_string(o, "");
			buffer result;
			if(length(evm) > 0) {
				result.append(evm);
				result.append(", ");
			}
			result.append(m);
			result.append(": ");
			result.append(s.val);
			evm = to_string(result);
		}
	
	//Combine modifiers for  (weapon and spell) damage bonuses, (min and max) regen modifiers and maximum (HP and MP) mods
	enew.set_length(0);
	matcher parse = create_matcher("((?:Hot|Cold|Spooky|Stench|Sleaze|Prismatic) )Damage: ([+-]?\\d+), \\1Spell Damage: \\2"
		+"|([HM]P Regen )Min: (\\d+), \\3Max: (\\d+)"
		+"|Maximum HP( Percent|):([^,]+), Maximum MP\\6:([^,]+)"
		+"|Weapon Damage( Percent|): ([+-]?\\d+), Spell Damage\\9?: \\10"
		+'|Avatar: "([^"]+)"'
		+'|[^ ]* Limit: 0'	// This is mostly for Cowrruption vs Cow Puncher having no limit
			, evm);
	while(parse.find()) {
		parse.append_replacement(enew, "");
		if(parse.group(1) != "") {
			enew.append("All ");
			enew.append(parse.group(1));
			enew.append("Dmg: ");
			enew.append(parse.group(2));
		} else if(parse.group(3) != "") {
			enew.append(parse.group(3));
			enew.append(parse.group(4));
			if(parse.group(4) != parse.group(5)) {
				enew.append("-");
				enew.append(parse.group(5));
			}
		} else if(parse.group(7) != "") {
			enew.append("Max HP/MP:");
			enew.append(parse.group(7));
			if(parse.group(7) != parse.group(8)) {
				enew.append("/");
				enew.append(parse.group(8));
			}
			if(parse.group(6) == " Percent") enew.append("%");
		} else if(parse.group(10) != "") {
			enew.append("All Dmg: ");
			enew.append(parse.group(10));
			if(parse.group(9) == " Percent") enew.append("%");
		} else if(parse.group(11) != "") {
			enew.append(parse.group(11));
		}
	}
	parse.append_tail(enew);
	evm = enew;
	
	// May be an extra comma left at start. :(
	// Add missing + in front of modifier, for consistency. Then remove colon because it is in the way of legibility
	// Change " Percent: +XX" and " Drop: +XX" to "+XX%"
	// If HP and MP regen are the same, combine them
	enew.set_length(0);
	parse = create_matcher("^\\s*([,\\s]*)"
		+"|(\\s*Drop|\\s*Percent([^:]*))?(?<!Limit):\\s*(([+-])?\\d+)"
		+"|(HP Regen ([0-9-]+), MP Regen \\6)", evm);
	while(parse.find()) {
		parse.append_replacement(enew, "");
		if(parse.group(1).contains_text(",")) {	// group would contain extra comma at beginning
			// Delete this: append nothing
		} else if(parse.group(4) != "") { 	// group is the numeric modifier
			enew.append(parse.group(3));	// group is possible words after "Percent"
			if(parse.group(5) == "")		// group would contain + or -
				enew.append(" +");
			else enew.append(" ");
			enew.append(parse.group(4));	// This does not contain Drop, Percent or the colon.
			if(parse.group(2) != "")		// group is Drop or Percent
				enew.append("%");
		
		} else if(parse.group(6) != "") {	// group is the HP&MP combined Regen	
			enew.append("All Regen ");
			enew.append(parse.group(7));
		}
	}
	parse.append_tail(enew);
	evm = enew;
	
	//shorten various text
	evm = replace_string(evm,"Damage Reduction","DR");
	evm = replace_string(evm,"Damage Absorption","DA");
	evm = replace_string(evm,"Weapon","Wpn");
	evm = replace_string(evm,"Damage","Dmg");
	evm = replace_string(evm,"Initiative","Init");
	evm = replace_string(evm,"Monster Level","ML");
	evm = replace_string(evm,"Moxie","Mox");
	evm = replace_string(evm,"Muscle","Mus");
	evm = replace_string(evm,"Mysticality","Myst");
	evm = replace_string(evm,"Resistance","Res");
	evm = replace_string(evm,"Familiar Experience","Fam xp");
	evm = replace_string(evm,"Familiar","Fam");
	evm = replace_string(evm,"Experience","Exp");
	evm = replace_string(evm,"Maximum","Max");
	evm = replace_string(evm,"Smithsness","Smith");
	evm = replace_string(evm,"Hobo Power","Hobo");
	evm = replace_string(evm,"Pickpocket Chance","Pickpocket");
	evm = replace_string(evm,"Adventures","Adv");
	evm = replace_string(evm,"PvP Fights","Fites");
	//highlight items, meat & ML
	if(span) {
		evm = replace_string(evm,"Item","<span class=moditem>Item</span>");
		evm = replace_string(evm,"Meat","<span class=moditem>Meat</span>");
		evm = replace_string(evm,"ML","<span class=modml>ML</span>");
	}
	
	//decorate elemental effects with pretty colors
	string prismatize(string input) {
		string [int] prism;
			prism[0] = "<span class=modHot>";
			prism[2] = "<span class=modSleaze>";
			prism[4] = "<span class=modStench>";
			prism[6] = "<span class=modCold>";
			prism[8] = "<span class=modSpooky>";
		buffer output;
		int i = 0;
		int last = length(input) - 1;
		while(i <= last) {
			output.append(prism[i % 10]);
			if(i < last)
				output.append(substring(input, i, i+ 2));
			else
				output.append(char_at(input, last));
			output.append("</span>");
			i += 2;
		}
		return output;
	}
	if(span) {
		matcher elemental = create_matcher("([^,]*(Hot|Cold|Spooky|Stench|Sleaze|Prismatic)[^,]*)(?:,|$)", evm);
		while(elemental.find()) {
			if(elemental.group(2) == "Prismatic")
				evm = replace_string(evm, elemental.group(1), prismatize(elemental.group(1)));
			else
				evm = replace_string(evm, elemental.group(1), "<span class=mod"+elemental.group(2)+">"+elemental.group(1)+"</span>");
		}
	}

	return evm;
}
string parseMods(string evm) { return parseMods(evm, true); }

string parseEff(effect ef, boolean span) {
	# if(ef == $effect[Polka of Plenty]) ef = $effect[Video... Games?];
	switch(ef) {
	case $effect[Knob Goblin Perfume]: return "";
	case $effect[Bored With Explosions]: 
		matcher wafe = create_matcher(":([^:]+):walk away from explosion:", get_property("banishedMonsters"));
		if(wafe.find()) return wafe.group(1);
		return "You're just over them"; 
	}

	# return string_modifier("Effect:" + ef,"Evaluated Modifiers").parseMods();
	return string_modifier(ef,"Evaluated Modifiers").parseMods(span);
}
string parseEff(effect ef) { return parseEff(ef, true); }




