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
	Veracity's vProps
	(Actually this is just my simplified adaptation)
*****************************************************/

// There is a list of items to parse. They are separated by | or ,
boolean [item] to_list(string list) {
	boolean [item] retval;
	foreach i, it in split_string(list, "[,|]")
		retval[ to_item(it) ] = true;
		
	// In case there is no item in the list, or something doesn't parse as an item
	remove retval[ $item[none] ];
	
	return retval;
}

// Put the property back together. (Duplicates were removed.) Normalize delimiter to |
string cat_list(boolean [item] list) {
	buffer buf;
	foreach it in list {
		if(buf.length() > 0)
			buf.append("|");
		buf.append(it);
	}
	return buf;
}

// Because ChIT only handles a few types of properties I can handle those few options.
string normalize_prop(string value, string type) {
	switch(type) {
	case "boolean": // All boolean properties are a single boolean, so no need to parse
		return to_boolean(value);
	case "item": case "items":
		// This is a list of items to parse. They are separated by | or ,
		// Put the property back together. (Duplicates were removed.) Normalize delimiter to |
		return to_list(value).cat_list();
	case "string": // For strings, normalize nothing. Assume duplicates are intentional and so on.
		return value;
	}
	return value;
}

string define_prop(string name, string type, string def) {
	// All "built-in" properties exist. A "custom" property that doesn't exist uses the (normalized) default.
	string normalized_def = normalize_prop(def, type);
	if(!property_exists(name))
		return normalized_def;

	// The property exists and (potentially) overrides the default
	string raw_value = get_property(name);
	string value = normalize_prop(raw_value, type);

	if(value == normalized_def)
		remove_property(name);
	else if(raw_value != value)
		set_property(name, value);
		
	return value;
}

string [string] vars;
void setvar(string name, string type, string def) {
	vars[name] = define_prop(name, type, def);
}
void setvar(string name, boolean def) { setvar(name, "boolean", def); }
void setvar(string name, string def) { setvar(name, "string", def); }

/*****************************************************
	zLib functions
	Copied from zarqon's original
	Huh. This is more functions than I expected. My co-authors must love this stuff.
*****************************************************/

// returns the string between start and end in source
// passing an empty string for start or end means the end of the string
string excise(string source, string start, string end) {
   if (start != "") {
      if (!source.contains_text(start)) return "";
      source = substring(source,index_of(source,start)+length(start));
   }
   if (end == "") return source;
   if (!source.contains_text(end)) return "";
   return substring(source,0,index_of(source,end));
}

float abs(float n) { return n < 0 ? -n : n; }

boolean vprint(string message, string color, int level) {
   if (level == 0) abort(message);
   if (to_int(vars["verbosity"]) >= abs(level)) print(message,color);
   return (level > 0);
}
boolean vprint(string message, int level) { if (level > 0) return vprint(message,"black",level); return vprint(message,"red",level); }

// check a quest property, e.g. qprop("questL11MacGuffin >= step3")
boolean qprop(string test) {
   if (!test.contains_text(" ")) return get_property(test) == "finished";
   int numerize(string progress) {
      if (is_integer(progress)) return progress.to_int();
      switch (progress) {
         case "unstarted": return -1;
         case "started": return 0;
         case "finished": return 999;
      }
      return excise(progress,"step","").to_int();
   }
   string[int] tbits = split_string(test," ");
   if (count(tbits) != 3) return vprint("'"+test+"' not valid parameter for qprop().  Syntax is '<property> <relational operator> <value>'",-3);
   if (get_property(tbits[0]) == "") return vprint("'"+tbits[0]+"' is not a valid quest property.",-3);
   switch (tbits[1]) {
      case "==": case "=": return numerize(get_property(tbits[0])) == numerize(tbits[2]);
      case "!=": case "<>": return numerize(get_property(tbits[0])) != numerize(tbits[2]);
      case ">": return numerize(get_property(tbits[0])) > numerize(tbits[2]);
      case "=>": case ">=": return numerize(get_property(tbits[0])) >= numerize(tbits[2]);
      case "<": return numerize(get_property(tbits[0])) < numerize(tbits[2]);
      case "=<": case "<=": return numerize(get_property(tbits[0])) <= numerize(tbits[2]);
   } return vprint("'"+tbits[1]+"' is not a valid relational operator.", -3);
}

// determine if something is path-safe
boolean be_good(string johnny) {
   switch (my_path()) {
      case "Bees Hate You": if (johnny.to_lower_case().index_of("b") > -1) return false; break;
      case "Trendy": if (!is_trendy(johnny)) return false; break;
      case "G-Lover": if (johnny.to_lower_case().index_of("g") == -1) return false; break;
   }
   return is_unrestricted(johnny);
}
boolean be_good(item johnny) {
   switch (my_path()) {
      case "Bees Hate You": if (johnny.to_lower_case().index_of("b") > -1) return false; break;
      case "Trendy": if (!is_trendy(johnny)) return false; break;
      case "Avatar of Boris": if (johnny == $item[trusty]) return true;
      case "Way of the Surprising Fist": if ($slots[weapon,off-hand] contains johnny.to_slot()) return false; break;
      case "KOLHS": if (johnny.inebriety > 0 && !contains_text(johnny.notes, "KOLHS")) return false; break;
      case "Zombie Slayer": if (johnny.fullness > 0 && !contains_text(johnny.notes, "Zombie Slayer")) return false; break;
      case "G-Lover": if (johnny.to_lower_case().index_of("g") == -1) return $items[source terminal] contains johnny; break;
   }
   if (class_modifier(johnny,"Class") != $class[none] && class_modifier(johnny,"Class") != my_class()) return false;
   return is_unrestricted(johnny);
}
boolean be_good(familiar johnny) {
   switch (my_path()) {
      case "Trendy": if (!is_trendy(johnny)) return false; break;
      case "Avatar of Boris":
      case "Avatar of Jarlsberg":
      case "Avatar of Sneaky Pete": 
      case "Actually Ed the Undying": return false;
      case "G-Lover": if (johnny.to_lower_case().index_of("g") == -1) return false; break;
   }
   return is_unrestricted(johnny);
}
boolean be_good(skill johnny) {
   switch (my_path()) {
      case "Trendy": if (!is_trendy(johnny)) return false; break;
      case "G-Lover": if (johnny.to_lower_case().index_of("g") == -1) return false; break;
   }
   return is_unrestricted(johnny);
}

// the opposite of split_string(); useful for working with comma-delimited lists
string join(string[int] pieces, string glue) {
   buffer res;
   boolean middle;
   foreach index in pieces {
      if (middle) res.append(glue);
      middle = true;
      res.append(pieces[index]);
   }
   return res;
}
// returns true if a glue-delimited list contains needle (case-insensitive)
boolean list_contains(string list, string needle, string glue) {
   return create_matcher("(^|"+glue+")\\Q"+to_lower_case(needle)+"\\E($|"+glue+")",to_lower_case(list)).find();
}
boolean list_contains(string list, string needle) { return list_contains(list, needle, ", "); }
// adds a unique entry to a glue-delimited list (and so won't add if already exists), returns modified list
string list_add(string list, string add, string glue, string gluepat) {
   if (length(list) == 0) return add;
   if (list_contains(list,add,gluepat)) return list;
   return list+glue+add;
}
string list_add(string list, string add, string glue) { return list_add(list, add, glue, glue); }
string list_add(string list, string add) { return list_add(list, add, ", "); }
// removes any matching entries from a glue-delimited list, returns modified list
string list_remove(string list, string del, string glue, string gluepat) {
   string[int] bits;
   foreach i,b in split_string(list, gluepat) if (b != del) bits[i] = b;
   return join(bits,glue);
}
string list_remove(string list, string del, string glue) { return list_remove(list, del, glue, glue); }
string list_remove(string list, string del) { return list_remove(list, del, ", "); }

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




