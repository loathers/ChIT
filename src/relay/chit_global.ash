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

typedef string[string] attrmap;

record buff {
	effect eff;
	string effectName;
	string effectHTML;
	string effectImage;
	string effectType;
	int effectTurns;
	boolean isIntrinsic;
};

// some constants
int DANGER_NONE = 0;
int DANGER_WARNING = 1;
int DANGER_DANGEROUS = 2;
int DANGER_GOOD = -1;

int DROPS_NONE = 0;
int DROPS_SOME = 1;
int DROPS_ALL = 2;

// str1 is picker name
// str2 is picker launcher text
int EXTRA_PICKER = 0;
// str1 is fold text
int EXTRA_FOLD = 1;
// str1 is link text
// attrs is for the link itself
int EXTRA_LINK = 2;
// for mad hatrack and fancypants scarecrow, and who knows, maybe something else in the future
// str1 is the familiar modifiers
// str2 is the limit
int EXTRA_EQUIPFAM = 3;

record extra_info {
	int extraType;
	string image; // leave blank for own image
	string str1;
	string str2;
	attrmap attrs;
};

extra_info extraInfoPicker(string name, string launcherText, string image) {
	return new extra_info(EXTRA_PICKER, image, name, launcherText);
}

extra_info extraInfoPicker(string name, string launcherText) {
	return extraInfoPicker(name, launcherText, '');
}

extra_info extraInfoFoldable(string text, string image) {
	return new extra_info(EXTRA_FOLD, image, text);
}

extra_info extraInfoFoldable(string text) {
	return extraInfoFoldable(text, '');
}

extra_info extraInfoLink(string text, attrmap attrs, string image) {
	return new extra_info(EXTRA_LINK, image, text, '', attrs);
}

extra_info extraInfoLink(string text, attrmap attrs) {
	return extraInfoLink(text, attrs, '');
}

extra_info extraInfoEquipFam(string famEffect, string cap) {
	return new extra_info(EXTRA_EQUIPFAM, '', famEffect, cap, attrmap {});
}

record chit_info {
	string name;
	string desc;
	int hasDrops;
	int dangerLevel;
	string image;
	extra_info[int] extra;
	// for familiars
	string weirdoTag;
	string weirdoDivContents;
};

boolean incDrops(chit_info info, int level) {
	if(info.hasDrops < level) {
		info.hasDrops = level;
		return true;
	}
	return false;
}

string namedesc(chit_info info) {
	string res = info.name;
	if(info.desc != '') {
		res += ' (' + info.desc + ')';
	}
	return res;
}

void tagStart(buffer result, string type, attrmap attrs);
void tagFinish(buffer result, string type);
void addImg(buffer result, string imgSrc, attrmap attrs);

void addInfoIcon(buffer result, chit_info info, string title, string onclick) {
	string imgClass = 'chit_icon';

	if(info.hasDrops == DROPS_SOME) {
		imgClass += ' hasdrops';
	}
	else if(info.hasDrops == DROPS_ALL) {
		imgClass += ' alldrops';
	}

	if(info.dangerLevel == DANGER_WARNING) {
		imgClass += ' warning';
	}
	else if(info.dangerLevel == DANGER_DANGEROUS) {
		imgClass += ' danger';
	}
	else if(info.dangerLevel == DANGER_GOOD) {
		imgClass += ' good';
	}

	if(info.weirdoTag != '') {
		imgClass += ' chit_' + info.weirdoTag;
	}

	attrmap imgAttrs = {
		'class': imgClass,
		'title': title,
	};
	if(onclick != '') {
		imgAttrs['onclick'] = onclick;
	}

	if(info.weirdoDivContents == '') {
		result.addImg(info.image, imgAttrs);
	}
	else {
		result.tagStart('div', imgAttrs);
		result.append(info.weirdoDivContents);
		result.tagFinish('div');
	}
}

void addToDesc(chit_info info, string toAdd) {
	if(info.desc != '') {
		info.desc += ', ';
	}
	info.desc += toAdd;
}

// if limit is 0, the prop is a total rather than something to subtract from limit
int LIMIT_TOTAL = 0;
// if limit is -1, the prop is a boolean and you have 1 left to come if false
int LIMIT_BOOL = -1;
// if limit is -2, the prop is a boolean and you have 1 left to come if true
int LIMIT_BOOL_INVERTED = -2;
// if limit is -3, there is no limit to the amount that can drop
int LIMIT_INFINITE = -3;
// if limit is a smaller negative, the limit is periodic, with abs(limit) being the period,
// and prop being progress along that period
// hopefully we won't see a periodic drop with a period less than 3, haha
int LIMIT_PERIODIC = -4;

record drop_info {
	// if propName is '', limit is instead how many are left
	string propName;
	int limit;
	string singular;
	// if this is '', use singular for plural as well
	// because of how new works, can just be left off for those cases
	string plural;
	boolean unimportant;
	boolean useLeft;
	int left;
};

typedef drop_info[int] drops_info;

boolean addDrops(chit_info info, drop_info[int] drops) {
	string toAdd = '';
	boolean onlyBoolProps = true;
	// please put periodic drops first if they have others as well
	boolean onlyPeriodic = true;
	int bestDrop = DROPS_NONE;

	void upDrops(int level, drop_info info) {
		if(info.unimportant) {
			level = DROPS_NONE;
		}
		if(bestDrop < level) {
			bestDrop = level;
		}
	}

	foreach i, drop in drops {
		boolean percentile = drop.singular != '' && drop.singular.substring(0, 1) == '%';
		if(drop.limit > LIMIT_PERIODIC) {
			onlyPeriodic = false;
		}

		int left = 0;
		if(drop.useLeft) {
			left = drop.left;
			if(drop.limit > 1) {
				onlyBoolProps = false;
			}
			if(left == drop.limit) {
				upDrops(DROPS_ALL, drop);
			}
			else if(left > 0) {
				upDrops(DROPS_SOME, drop);
			}
		}
		else if(drop.limit == LIMIT_BOOL) {
			if(!get_property(drop.propName).to_boolean()) {
				left = 1;
				upDrops(DROPS_ALL, drop);
			}
		}
		else if(drop.limit == LIMIT_BOOL_INVERTED) {
			if(get_property(drop.propName).to_boolean()) {
				left = 1;
				upDrops(DROPS_ALL, drop);
			}
		}
		else if(drop.limit == LIMIT_TOTAL) {
			onlyBoolProps = false;
			left = get_property(drop.propName).to_int();
			upDrops(DROPS_SOME, drop);
		}
		else if(drop.limit == LIMIT_INFINITE) {
			onlyBoolProps = false;
			left = -1;
		}
		else if(drop.limit <= LIMIT_PERIODIC) {
			int timeToDrop = -1 * drop.limit - get_property(drop.propName).to_int();
			if(timeToDrop <= 1) {
				upDrops(DROPS_ALL, drop);
			}
			else if(timeToDrop <= 5 && drop.limit <= -30) {
				upDrops(DROPS_SOME, drop);
			}
			if(toAdd != '') {
				toAdd += ', ';
			}
			toAdd += timeToDrop + ' turn';
			if(timeToDrop != 1) {
				toAdd += 's';
			}
			toAdd += ' to ' + drop.singular;
		}
		else if(drop.propName != '') {
			onlyBoolProps = false;
			left = max(drop.limit - get_property(drop.propName).to_int(), 0);
			if(left == drop.limit) {
				upDrops(DROPS_ALL, drop);
			}
			else if(left > 0) {
				upDrops(DROPS_SOME, drop);
			}
		}
		else {
			onlyBoolProps = false;
			left = drop.limit;
		}

		if(drop.limit > LIMIT_PERIODIC) {
			if(toAdd != '') {
				toAdd += ', ';
			}
			if(drop.limit > 1) {
				if(left >= 0) {
					toAdd += left;
					if(!percentile) {
						toAdd += '/' + drop.limit;
					}
				}
			}
			else if(drop.limit == LIMIT_INFINITE) {
				toAdd += '&infin;';
			}
			else if(drop.limit == LIMIT_BOOL || drop.limit == LIMIT_BOOL_INVERTED) {
				if(left == 0) {
					toAdd += 'No ';
				}
			}

			if(drop.plural == '') {
				drop.plural = drop.singular;
			}
			if((drop.limit > 1 || drop.limit == LIMIT_INFINITE) && !percentile) {
				toAdd += ' ';
			}
			toAdd += (left == 1) ? drop.singular : drop.plural;
		}
	}
	if(toAdd != '') {
		if(!onlyPeriodic) {
			toAdd += onlyBoolProps ? ' available' : ' left';
		}
		info.addToDesc(toAdd);
		info.incDrops(bestDrop);
		return true;
	}
	return false;
}

boolean addDrop(chit_info info, drop_info drop) {
	return info.addDrops(drops_info { drop });
}

void addExtra(chit_info info, extra_info extra) {
	info.extra[info.extra.count()] = extra;
}

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
	if(!property_exists(name)) {
		set_property(name, "DEFAULT:" + def);
	}

	boolean nondefault = false;

	// The property exists and (potentially) overrides the default
	string raw_value = get_property(name);
	if(raw_value.starts_with("DEFAULT")) {
		set_property(name, "DEFAULT:" + def);
		raw_value = def;
	}
	else if(raw_value.starts_with("NONDEFAULT:")) {
		nondefault = true;
		raw_value = raw_value.substring(11); // It's ridiculous. It's not even funny.
	}

	string value = normalize_prop(raw_value, type);

	if(value == normalize_prop(def, type) && !nondefault)
		set_property(name, "DEFAULT:" + def);
	else if(raw_value != value) {
		if(nondefault) {
			set_property(name, "NONDEFAULT:" + value);
		}
		else {
			set_property(name, value);
		}
	}

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
   switch (my_path().name) {
      case "Bees Hate You": if (johnny.to_lower_case().index_of("b") > -1) return false; break;
      case "Trendy": if (!is_trendy(johnny)) return false; break;
      case "G-Lover": if (johnny.to_lower_case().index_of("g") == -1) return false; break;
   }
   return is_unrestricted(johnny);
}
boolean be_good(item johnny) {
   switch (my_path().name) {
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
   switch (my_path().name) {
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
   switch (my_path().name) {
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
	HTML functions
*****************************************************/
int[string] tagsOpen;

void tagStart(buffer buf, string type, attrmap attrs, boolean selfClosing) {
	if(!selfClosing) {
		tagsOpen[type] += 1;
	}

	buf.append('<');
	buf.append(type);
	foreach attr, value in attrs {
		buf.append(' ');
		buf.append(attr);
		buf.append('="');
		// TODO: Escape " in value
		buf.append(value);
		buf.append('"');
	}
	if(selfClosing) {
		buf.append(' /');
	}
	buf.append('>');
}

void tagStart(buffer buf, string type, attrmap attrs) {
	tagStart(buf, type, attrs, false);
}

void tagStart(buffer buf, string type) {
	tagStart(buf, type, attrmap {});
}

void tagFinish(buffer buf, string type) {
	if(tagsOpen[type] < 1) {
		print('Tried to close a <' + type + '> without opening one first', 'red');
	}
	else {
		tagsOpen[type] -= 1;
	}
	buf.append('</');
	buf.append(type);
	buf.append('>');
}

void tagSelfClosing(buffer buf, string type, attrmap attrs) {
	tagStart(buf, type, attrs, true);
}

void addImg(buffer buf, string src, attrmap attrs) {
	attrs['src'] = src;
	buf.tagSelfClosing('img', attrs);
}

string itemimage(string src) {
	return '/images/itemimages/' + src;
}

void br(buffer buf) {
	buf.tagSelfClosing('br', attrmap {});
}

/*****************************************************
	Picker functions
*****************************************************/
string[int] pickerStack;

void pickerStart(buffer picker, string name, string message) {
	if(chitPickers contains name) {
		print("Tried to start picker " + name + ", but we already finished that one!", "red");
	}
	pickerStack[pickerStack.count()] = name;

	picker.tagStart('div', attrmap {
		'id': 'chit_picker' + name, 'class': 'chit_skeleton', 'style': 'display:none'
	});
	picker.tagStart('table', attrmap {
		'class': 'chit_picker'
	});
	picker.tagStart('tr');
	picker.tagStart('th', attrmap {
		'colspan': '3'
	});
	picker.append(message);
	picker.tagFinish('th');
	picker.tagFinish('tr');
}

void pickerStart(buffer picker, string name, string message, string image) {
	picker.pickerStart(picker, name, '<img src="' + imagePath + image + '.png" />' + message);
}

void addLoader(buffer picker, string message, string subloader) {
	picker.tagStart('tr', attrmap {
		'class': 'pickloader' + subloader, 'style': 'display:none'
	});
	picker.tagStart('td', attrmap { 'class': 'info' });
	picker.append(message);
	picker.tagFinish('td');
	picker.tagStart('td', attrmap { 'class': 'icon' });
	picker.addImg(itemimage('karma.gif'), attrmap {});
	picker.tagFinish('td');
	picker.tagFinish('tr');
}

void addLoader(buffer picker, string message) {
	addLoader(picker,message,"");
}

void pickerFinish(buffer picker, string loadingText) {
	if(pickerStack.count() == 0) {
		print("Tried to finish a picker, but couldn't because none were open...", "red");
		return;
	}
	if(loadingText != "") {
		picker.addLoader(loadingText);
	}
	picker.tagFinish('table');
	picker.tagFinish('div');
	chitPickers[remove pickerStack[pickerStack.count() - 1]] = picker;
}

void pickerFinish(buffer picker) {
	pickerFinish(picker, "");
}

void addSadFace(buffer picker, string message) {
	picker.tagStart('tr', attrmap { 'class': 'picknone' });
	picker.tagStart('td', attrmap { 'class': 'info', 'colspan': '3' });
	picker.append(message);
	picker.tagFinish('td');
	picker.tagFinish('tr');
}

void pickerStartOption(buffer picker, boolean usable) {
	picker.tagStart('tr', attrmap { 'class': 'pickitem' + (usable ? '' : ' currentitem') });
}

void pickerFinishOption(buffer picker) {
	// Just in case I want to restructure pickers in the future
	picker.tagFinish('tr');
}

void pickerAddImage(buffer picker, string src, boolean withLink, attrmap linkAttrs) {
	picker.tagStart('td', attrmap { 'class': 'icon' });
	if(withLink) {
		picker.tagStart('a', linkAttrs);
	}
	picker.addImg(src, attrmap { 'class': 'chit_icon' });
	if(withLink) {
		picker.tagFinish('a');
	}
	picker.tagFinish('td');
}

void pickerAddImage(buffer picker, string src, attrmap linkAttrs) {
	pickerAddImage(picker, src, true, linkAttrs);
}

void pickerAddImage(buffer picker, string src) {
	pickerAddImage(picker, src, false, attrmap {});
}

void pickerGenericOption(buffer picker, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string imgSrc, attrmap imgAttrs, attrmap linkAttrs, string rightSection) {
	picker.pickerStartOption(usable);

	if(href == '') {
		usable = false;
	}

	picker.pickerAddImage(imgsrc, imgAttrs.count() > 0, imgAttrs);
	attrmap tdAttrs;
	if(rightSection == '') {
		tdAttrs['colspan'] = '2';
	}
	picker.tagStart('td', tdAttrs);
	if(usable) {
		if(linkAttrs['href'] == '') {
			linkAttrs['href'] = href;
		}
		if(linkAttrs['class'] == '') {
			linkAttrs['class'] = 'change';
		}
		picker.tagStart('a', linkAttrs);
		picker.tagStart('b');
		picker.append(verb);
		picker.tagFinish('b');
		picker.append(' ');
	}
	picker.append(noun);
	if(parenthetical != "") {
		picker.append(' (');
		picker.append(parenthetical);
		picker.append(')');
	}
	if(desc != "") {
		picker.br();
		picker.tagStart('span', attrmap { 'class': 'descline' });
		picker.append(desc);
		picker.tagFinish('span');
	}
	if(usable) {
		picker.tagFinish('a');
	}
	picker.tagFinish('td');
	if(rightSection != '') {
		picker.tagStart('td');
		picker.append(rightSection);
		picker.tagFinish('td');
	}
	picker.pickerFinishOption();
}

void pickerGenericOption(buffer picker, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string imgSrc, attrmap imgAttrs, attrmap linkAttrs) {
	pickerGenericOption(picker, verb, noun, desc, parenthetical, href, usable, imgSrc, imgAttrs, linkAttrs, '');
}

void pickerGenericOption(buffer picker, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string imgSrc, attrmap imgAttrs) {
	pickerGenericOption(picker, verb, noun, desc, parenthetical, href, usable, imgSrc, imgAttrs, attrmap {});
}

void pickerGenericOption(buffer picker, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string imgSrc) {
	pickerGenericOption(picker, verb, noun, desc, parenthetical, href, usable, imgSrc, attrmap {});
}

void pickerPickerOption(buffer picker, string noun, string desc, string parenthetical, string pickerToLaunch, string imgSrc) {
	pickerGenericOption(picker, 'Pick', noun, desc, parenthetical, '#', true, imgSrc, attrmap {}, attrmap {
		'class': 'chit_launcher done',
		'rel': 'chit_picker' + pickerToLaunch,
	});
}

void pickerSkillOption(buffer picker, skill sk, string desc, string parenthetical, boolean usable) {
	if(sk.combat) {
		usable = false;
		if(desc != "") {
			desc += '<br />';
		}
		desc += '(Available in combat)';
	}

	picker.pickerGenericOption('Cast', sk.to_string(), desc, parenthetical, sideCommand('cast 1 ' + sk.to_string()), usable, itemimage(sk.image), attrmap {
		'class': 'done',
		'onclick': "javascript:poop('desc_skill.php?whichskill=" + sk.to_int() + "&self=true','skill',350,300);",
		'title': 'Pop out skill description',
		'href': '#',
	});
}

// Examples: Edpiece, Jurassic Parka, etc
void pickerSelectionOption(buffer picker, string name, string desc, string cmd, string img, boolean current, boolean usable) {
	if(current) {
		name = '<b>Current</b>: ' + name;
	}
	picker.pickerGenericOption('Select', name, desc, '', sideCommand(cmd), usable, img);
}

void pickerSelectionOption(buffer picker, string name, string desc, string cmd, string img, boolean current) {
	picker.pickerSelectionOption(name, desc, cmd, img, current, !current);
}

string parseEff(effect eff);

void pickerEffectOption(buffer picker, string verb, effect eff, string desc, int duration, string href, boolean usable) {
	if(desc == '') {
		desc = parseEff(eff);
	}
	if(duration > 0) {
		desc += ' (' + duration + ' turns)';
	}

	picker.pickerGenericOption(verb, eff.to_string(), desc, "", href, usable, itemimage(eff.image), attrmap {
		'class': 'done',
		'onclick': "javascript:eff('" + eff.descid + "');",
		'title': 'Pop out effect description',
		'href': '#',
	});
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
		+"|Maximum HP( Percent|): ([^,]+), Maximum MP\\6: ([^,]+)"
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
	evm = replace_string(evm,"Critical Hit","Crit");
	evm = replace_string(evm,"Spell Critical","Spell Crit");
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



/*****************************************************
	Latte support
*****************************************************/

string latteDropName(location l) {
	switch(l) {
		case $location[The Mouldering Mansion]: return "ancient";
		case $location[The Overgrown Lot]: return "basil";
		case $location[Whitey's Grove]: return "belgian";
		case $location[The Bugbear Pen]: return "bug-thistle";
		case $location[Madness Bakery]: return "butternut";
		case $location[The Black Forest]: return "cajun";
		case $location[The Haunted Billiards Room]: return "chalk";
		case $location[The Dire Warren]: return "carrot";
		case $location[Barrrney's Barrr]: return "carrrdamom";
		case $location[The Haunted Kitchen]: return "chili";
		case $location[The Sleazy Back Alley]: return "cloves";
		case $location[The Haunted Boiler Room]: return "coal";
		case $location[The Icy Peak]: return "cocoa";
		case $location[Battlefield (No Uniform)]: return "diet";
		case $location[Itznotyerzitz Mine]: return "dwarf";
		case $location[The Feeding Chamber]: return "filth";
		case $location[The Road to the White Citadel]: return "flour";
		case $location[The Fungal Nethers]: return "fungus";
		case $location[The Hidden Park]: return "grass";
		case $location[Cobb's Knob Barracks]: return "greasy";
		case $location[The Daily Dungeon]: return "healing";
		case $location[The Dark Neck of the Woods]: return "hellion";
		case $location[Wartime Frat House (Hippy Disguise)]: return "greek";
		case $location[The Old Rubee Mine]: return "grobold";
		case $location[The Bat Hole Entrance]: return "guarna";
		case $location[1st Floor, Shiawase-Mitsuhama Building]: return "gunpowder";
		case $location[Hobopolis Town Square]: return "hobo";
		case $location[The Haunted Library]: return "ink";
		case $location[Wartime Hippy Camp (Frat Disguise)]: return "kombucha";
		case $location[The Defiled Niche]: return "lihc";
		case $location[The Arid, Extra-Dry Desert]: return "lizard";
		case $location[Cobb's Knob Laboratory]: return "mega";
		case $location[The Unquiet Garves]: return "mold";
		case $location[The Briniest Deepests]: return "msg";
		case $location[The Haunted Pantry]: return "noodles";
		case $location[The Ice Hole]: return "norwhal";
		case $location[The Old Landfill]: return "oil";
		case $location[The Haunted Gallery]: return "paint";
		case $location[The Stately Pleasure Dome]: return "paradise";
		case $location[The Spooky Forest]: return "rawhide";
		case $location[The Brinier Deepers]: return "rock";
		case $location[The Briny Deeps]: return "salt";
		case $location[Noob Cave]: return "sandalwood";
		case $location[Cobb's Knob Kitchens]: return "sausage";
		case $location[The Hole in the Sky]: return "space";
		case $location[The Copperhead Club]: return "squash";
		case $location[The Caliginous Abyss]: return "squamous";
		case $location[The VERY Unquiet Garves]: return "teeth";
		case $location[The Middle Chamber]: return "venom";
		case $location[The Dark Elbow of the Woods]: return "vitamins";
		case $location[The Dark Heart of the Woods]: return "wing";
		default: return "";
	}
}

boolean latteDropAvailable(location l) {
	// obviously no latte drops are available if you don't HAVE a latte
	if(available_amount($item[latte lovers member's mug]) == 0)
		return false;
	string latteDrop = latteDropName(l);
	if(latteDrop == "")
		return false;
	return !get_property("latteUnlocks").contains_text(latteDrop);
}

boolean isImportantOffhand(item it) {
	return $items[UV-resistant compass, ornate dowsing rod, unstable fulminate, wine bomb] contains it;
}

boolean usesSubstats() {
	return my_class() != $class[Grey Goo];
}
