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
string [string] cvars;
boolean [string] forceSections;
string [string,string] reason_options;
string [string] defaults;
boolean defaults_initialized = false;
boolean aftercore = qprop("questL13Final");

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

// str1 is picker name. Prefix with MANUAL: to specify not to envoke the picker func automatically.
// str2 is picker launcher text
int EXTRA_PICKER = 0;
// str1 is fold text
int EXTRA_FOLD = 1;
// str1 is link text
// str2 is optional for descline
// attrs is for the link itself
int EXTRA_LINK = 2;
// for familiars that equip non-familiar items
// str1 is the slot to_string'd
// str2 is "true" if it's a weirdo like fancypants or hatrack
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

extra_info extraInfoLink(string text, string desc, attrmap attrs, string image) {
	return new extra_info(EXTRA_LINK, image, text, desc, attrs);
}

extra_info extraInfoLink(string text, string desc, attrmap attrs) {
	return extraInfoLink(text, desc, attrs, '');
}

extra_info extraInfoLink(string text, attrmap attrs, string image) {
	return extraInfoLink(text, '', attrs, image);
}

extra_info extraInfoLink(string text, attrmap attrs) {
	return extraInfoLink(text, attrs, '');
}

extra_info extraInfoEquipFam(slot s, boolean weird) {
	return new extra_info(EXTRA_EQUIPFAM, '', s, weird, attrmap {});
}

extra_info extraInfoEquipFam(slot s) {
	return extraInfoEquipFam(s, false);
}

string sideCommand(string cmd);

// Just a shorthand for a link that executes a sideCommand
extra_info extraInfoCmd(string cmd) {
	return extraInfoLink('', attrmap {
		'href': sideCommand(cmd),
		'title': cmd,
	});
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
	string customStyle;
	string type;
	// for effect turns, but keeping the term more generic in case
	// I come up with a use for it on other types in the future
	int count;
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
void tagSelfClosing(buffer result, string type, attrmap attrs);
void addImg(buffer result, string imgSrc, attrmap attrs);

int popoverCount = 0;

void addElementWithPopover(buffer result, string ele, string eleContent, attrmap eleAttrs,
	string popoverTitle, string popoverDesc, string wrappingEle, attrmap wrappingEleAttrs) {
	if(popoverTitle != '') {
		if(cvars['chit.display.popovers'].to_boolean()) {
			++popoverCount;
			eleAttrs['class'] += ' chit_popoverlauncher';
			eleAttrs['aria-describedby'] = 'popover' + popoverCount;
		} else {
			eleAttrs['title'] = popoverTitle;
			if(popoverDesc != '') {
				eleAttrs['title'] += ' (' + popoverDesc + ')';
			}
		}
	}

	if(wrappingEle != '') {
		result.tagStart(wrappingEle, wrappingEleAttrs);
	}

	if(eleContent != '') {
		result.tagStart(ele, eleAttrs);
		result.append(eleContent);
		result.tagFinish(ele);
	} else {
		result.tagSelfClosing(ele, eleAttrs);
	}

	if(wrappingEle != '') {
		result.tagFinish(wrappingEle);
	}

	if(popoverTitle != '' && cvars['chit.display.popovers'].to_boolean()) {
		result.tagStart('div', attrmap {
			'id': 'popover' + popoverCount,
			'class': 'popover',
			'role': 'tooltip',
		});
		result.tagStart('div', attrmap {
			'class': 'popover_title',
		});
		result.append(popoverTitle);
		result.tagFinish('div');
		if(popoverDesc != '') {
			foreach i,descline in popoverDesc.split_string(', ') {
				result.tagStart('div', attrmap {
					'class': 'descline',
				});
				result.append(descline);
				result.tagFinish('div');
			}
		}
		result.tagStart('div', attrmap {
			'id': 'arrowpopover' + popoverCount,
			'class': 'chit_popoverarrow',
		});
		result.tagFinish('div');
		result.tagFinish('div');
	}
}

void addElementWithPopover(buffer result, string ele, string eleContent, attrmap eleAttrs,
	string popoverTitle, string popoverDesc) {
	addElementWithPopover(result, ele, eleContent, eleAttrs, popoverTitle, popoverDesc, '', attrmap {});
}

void addInfoIcon(buffer result, chit_info info, string title, string desc, string onclick, string wrappingElement, attrmap wrappingElementAttrs) {
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
	};
	if(onclick != '') {
		imgAttrs['onclick'] = onclick;
	}
	if(imgAttrs contains 'onclick') {
		imgAttrs['class'] += ' cursor';
	}
	if(info.customStyle != '') {
		imgAttrs['style'] = info.customStyle;
	}

	if(info.weirdoDivContents == '' || cvars['chit.familiar.iconize-weirdos'].to_boolean()) {
		imgAttrs['src'] = info.image;
		result.addElementWithPopover('img', '', imgAttrs, title, desc,
			wrappingElement, wrappingElementAttrs);
	}
	else {
		result.addElementWithPopover('div', info.weirdoDivContents, imgAttrs,
			title, desc, wrappingElement, wrappingElementAttrs);
	}
}

void addInfoIcon(buffer result, chit_info info, string title, string desc, string onclick) {
	addInfoIcon(result, info, title, desc, onclick, '', attrmap {});
}

void addInfoIcon(buffer result, chit_info info, string title, string onclick) {
	addInfoIcon(result, info, title, '', onclick);
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
	boolean useDropped;
	int dropped;
	boolean oneOrNone;
};

typedef drop_info[int] drops_info;

boolean addDrops(chit_info info, drop_info[int] drops) {
	string toAdd = '';
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

		int dropped = 0;
		// if this is -1 dropped is instead left
		int limit = 0;
		if(drop.useDropped) {
			dropped = drop.dropped;
			limit = drop.limit;
			if(dropped == 0) {
				upDrops(DROPS_ALL, drop);
			}
			else if(dropped < limit) {
				upDrops(DROPS_SOME, drop);
			}
		}
		else if(drop.limit == LIMIT_BOOL) {
			limit = 1;
			if(!get_property(drop.propName).to_boolean()) {
				upDrops(DROPS_ALL, drop);
			}
			else {
				dropped = 1;
			}
		}
		else if(drop.limit == LIMIT_BOOL_INVERTED) {
			limit = 1;
			if(get_property(drop.propName).to_boolean()) {
				upDrops(DROPS_ALL, drop);
			}
			else {
				dropped = 1;
			}
		}
		else if(drop.limit == LIMIT_TOTAL) {
			dropped = get_property(drop.propName).to_int();
			limit = -1;
			upDrops(DROPS_SOME, drop);
		}
		else if(drop.limit == LIMIT_INFINITE) {
			dropped = -1;
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
			dropped = max(get_property(drop.propName).to_int(), 0);
			limit = drop.limit;
			if(dropped == 0) {
				upDrops(DROPS_ALL, drop);
			}
			else if(dropped < limit) {
				upDrops(DROPS_SOME, drop);
			}
		}
		else {
			limit = -1;
			dropped = drop.limit;
		}

		if(drop.oneOrNone && (dropped == 0 || (dropped == 1 && limit == -1))) {
			upDrops(DROPS_SOME, drop);
		}

		if(drop.limit > LIMIT_PERIODIC) {
			boolean space = true;
			if(toAdd != '') {
				toAdd += ', ';
			}

			if(drop.limit == LIMIT_INFINITE) {
				toAdd += 'drops';
			}
			else if(limit == -1) {
				if(!drop.oneOrNone || dropped != 1) {
					toAdd += dropped;
				}
				else {
					space = false;
				}
			}
			else if(percentile) {
				toAdd += (limit - dropped);
			}
			else {
				toAdd += dropped + '/' + limit;
			}

			if(drop.plural == '') {
				drop.plural = drop.singular;
			}
			if(space && (drop.limit > LIMIT_PERIODIC) && !percentile) {
				toAdd += ' ';
			}
			toAdd += (limit == 1) ? drop.singular : drop.plural;
		}
	}
	if(toAdd != '') {
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

void chit_setvar(string name, string type, string def) {
	cvars[name] = define_prop(name, type, def);
}
void chit_setvar(string name, boolean def) { chit_setvar(name, "boolean", def); }
void chit_setvar(string name, string def) { chit_setvar(name, "string", def); }
void chit_setvar(string name, int def) { chit_setvar(name, "int", def); }

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

void progressSubStats(buffer result, stat s) {
	int statval = my_basestat(s);

	int lower = statval**2;
	int range = (statval + 1)**2 - lower;
	int current = my_basestat(findSub(s)) - lower;
	int needed = range - current;
	float progress = (current * 100.0) / range;
	// this is kinda gross but oh well
	result.addElementWithPopover('div',
		'<div class="progressbar" style="width:' + progress + '%"></div>',
		attrmap { 'class': 'progressbox' }, s + ' substats',
		current + ' / ' + range + ', ' + needed + ' needed',
		'td', attrmap { 'class': 'progress' });
}

void progressCustom(buffer result, int current, int limit, string hover,
	int severity, boolean active, string wrappingEle, attrmap wrappingEleAttrs) {

	string color = "";
	string title = "";
	string desc = "";

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
		case "auto": title = title(); break;
		default: title = hover; desc = title(); break;
	}
	attrmap divAttrs = { 'class': 'progressbox' };
	if (active) divAttrs['style'] = 'border-color:#707070';
	if (limit == 0) limit = 1;
	float progress = (min(current, limit) * 100.0) / limit;

	result.addElementWithPopover('div',
		'<div class="progressbar" style="width:' + progress + '%;background-color:' + color + '"></div>',
		divAttrs, title, desc, wrappingEle, wrappingEleAttrs);
}

void progressCustom(buffer result, int current, int limit, string hover,
	int severity, boolean active) {
	result.progressCustom(current, limit, hover, severity, active, '', attrmap {});
}

void progressCustom(buffer result, int current, int limit, int severity, boolean active) {
	result.progressCustom(current, limit, current + ' / ' + limit, severity, active);
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
		// for simpler conditional attrs
		if(value == "") {
			continue;
		}
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

void tagSelfClosing(buffer buf, string type) {
	tagSelfClosing(buf, type, attrmap {});
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

void pickerAddImage(buffer picker, string src, boolean withLink, attrmap imgAttrs) {
	picker.tagStart('td', attrmap { 'class': 'icon' });
	if(!(imgAttrs contains 'class')) {
		imgAttrs['class'] = 'chit_icon';
	}
	picker.addImg(src, imgAttrs);
	picker.tagFinish('td');
}

void pickerAddImage(buffer picker, string src, attrmap linkAttrs) {
	pickerAddImage(picker, src, true, linkAttrs);
}

void pickerAddImage(buffer picker, string src) {
	pickerAddImage(picker, src, false, attrmap {});
}

void pickerGenericOption(buffer picker, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string leftSection, attrmap linkAttrs, string rightSection) {
	picker.pickerStartOption(usable);

	if(href == '') {
		usable = false;
	}

	picker.append(leftSection);
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

void pickerGenericOption(buffer picker, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string imgSrc, attrmap imgAttrs, attrmap linkAttrs, string rightSection) {
	buffer leftSection;
	leftSection.pickerAddImage(imgsrc, imgAttrs.count() > 0, imgAttrs);

	pickerGenericOption(picker, verb, noun, desc, parenthetical, href, usable, leftSection, linkAttrs, rightSection);
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
	if(sk.combat && usable) {
		usable = false;
		if(desc != "") {
			desc += '<br />';
		}
		desc += '(Available in combat)';
	}

	picker.pickerGenericOption('Cast', sk.to_string(), desc, parenthetical, sideCommand('cast 1 ' + sk.to_string()), usable, itemimage(sk.image), attrmap {
		'onclick': "javascript:poop('desc_skill.php?whichskill=" + sk.to_int() + "&self=true','skill',350,300);",
		'title': 'Pop out skill description',
	});
}

// Examples: Edpiece, Jurassic Parka, etc
void pickerSelectionOption(buffer picker, string name, string desc, string cmd, string img, boolean current, boolean usable, attrmap imgAttrs) {
	if(current) {
		name = '<b>Current</b>: ' + name;
		usable = false;
	}
	picker.pickerGenericOption('Select', name, desc, '', sideCommand(cmd), usable, img, imgAttrs);
}

void pickerSelectionOption(buffer picker, string name, string desc, string cmd, string img, boolean current, boolean usable) {
	pickerSelectionOption(picker, name, desc, cmd, img, current, usable, attrmap {});
}

void pickerSelectionOption(buffer picker, string name, string desc, string cmd, string img, boolean current) {
	picker.pickerSelectionOption(name, desc, cmd, img, current, true);
}

string parseEff(effect eff);

void addEffectIcon(buffer result, effect eff, string titlePrefix, boolean popupDescOnClick,
	string wrappingElement, attrmap wrappingElementAttrs);
chit_info getEffectInfo(effect eff, boolean avoidRecursion);


void pickerEffectOption(buffer picker, string verb, string name, effect eff, string desc, int duration, string href, boolean usable) {
	chit_info info = getEffectInfo(eff, true);
	if(name == '') {
		name = info.name;
	}
	if(desc == '') {
		desc = info.desc;
	}

	buffer iconSection;
	iconSection.tagStart('td', attrmap { 'class': 'icon' });
	iconSection.addEffectIcon(eff, '', true, '', attrmap {});
	iconSection.tagFinish('td');

	picker.pickerGenericOption(verb, name, desc, duration > 0 ? (duration + ' turns') : duration < 0 ?
		'intrinsic' : '', href, usable, iconSection, attrmap {}, '');
}

void pickerEffectOption(buffer picker, string verb, effect eff, string desc, int duration, string href, boolean usable) {
	pickerEffectOption(picker, verb, '', eff, desc, duration, href, usable);
}

void pickerEffectFromSkillOption(buffer picker, string verb, effect eff, skill sk, boolean usable) {
	chit_info info = getEffectInfo(eff, true);

	buffer iconSection;
	iconSection.tagStart('td', attrmap { 'class': 'icon' });
	iconSection.addEffectIcon(eff, '', true, '', attrmap {});
	iconSection.tagFinish('td');

	int price;
	string priceType;

	boolean checkPrice(string method, string kind) {
		int amount = call int method(sk);
		if(amount > 0) {
			price = amount;
			priceType = kind;
			return true;
		}
		return false;
	}

	boolean havePrice = checkPrice('mp_cost', 'mp')
		|| checkPrice('hp_cost', 'hp')
		|| checkPrice('soulsauce_cost', 'sauce')
		|| checkPrice('adv_cost', 'adv')
		|| checkPrice('fuel_cost', 'fuel')
		|| checkPrice('lightning_cost', 'lightning')
		|| checkPrice('thunder_cost', 'thunder')
		|| checkPrice('rain_cost', 'rain');

	int duration = turns_per_cast(sk);
	string parenthetical = duration > 0 ? (duration + ' turns') : duration < 0 ? 'intrinsic' : '';
	if(havePrice) {
		if(parenthetical != '') {
			parenthetical += ', ';
		}
		parenthetical += price + ' ' + priceType;
	}
	if(sk.dailylimitpref != '') {
		if(parenthetical != '') {
			parenthetical += ', ';
		}
		parenthetical += get_property(sk.dailylimitpref) + '/' + sk.dailylimit;
		if(get_property(sk.dailylimitpref) >= sk.dailylimit) {
			usable = false;
		}
	}

	picker.pickerGenericOption(verb, info.name, info.desc, parenthetical, sideCommand('cast 1 ' + sk),
		usable, iconSection, attrmap { 'title': 'cast 1 ' + sk }, '');
}

void pickerEffectFromSkillOption(buffer picker, string verb, effect eff, boolean usable) {
	pickerEffectFromSkillOption(picker, verb, eff, to_skill(eff), usable);
}

void addItemIcon(buffer buf, item it, string title, boolean popupDescOnClick);

void pickerItemOption(buffer picker, item it, string verb, string noun, string desc, string parenthetical, string href, boolean usable, string rightSection) {
	buffer iconSection;
	iconSection.tagStart('td', attrmap { 'class': 'icon' });
	iconSection.addItemIcon(it, '', true);
	iconSection.tagFinish('td');

	pickerGenericOption(picker, verb, noun, desc, parenthetical, href, usable, iconSection, attrmap {}, rightSection);
}

void pickerItemOption(buffer picker, item it, string verb, string noun, string desc, string parenthetical, string href, boolean usable) {
	pickerItemOption(picker, it, verb, noun, desc, parenthetical, href, usable, '');
}

/*****************************************************
	Modifier parsing functions
*****************************************************/

//ckb: function for effect descriptions to make them short and pretty, called by chit.effects.describe
string parseMods(string evm, boolean span, boolean debug) {
	buffer enew;  // This is used for rebuilding evm with append_replacement()

	if(debug) print("1: " + evm);

	// Standardize capitalization
	matcher uncap = create_matcher("(?:^|[^'])\\b[a-z]", evm);
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

	// Reword Lanterns
	matcher parse = create_matcher('Lantern Element: "([^"]+)"', evm);
	evm = parse.replace_all("$1 Lantern");
	evm = evm.replace_string("None Lantern","Phys Lantern");

	// Reword Sporadic Damage Aura
	parse = create_matcher('Sporadic Damage Aura: 0\\.(\\d+)', evm);
	if(parse.find()) {
		string numStr = parse.group(1);
		if(numStr.length() == 1) {
			numStr += '0';
		} else if(numStr.length() > 2) {
			numStr = numStr.substring(0,2) + '.' + numStr.substring(2);
		}
		numStr += '%';
		evm = evm.replace_string(parse.group(0), 'Damage Aura +' + numStr);
	}

	// Get rid of things people don't need to worry about in this context
	parse = create_matcher('Last Available: "[^"]+"'
		+ '|Familiar Effect: "[^"]+"'
		+ '|Equips On: "[^"]+"'
		+ '|Softcore Only:? ?\\+?\\d*'
		+ '|Single Equip'
		+ '|(?:Equipped|Inventory) Conditional Skill ?: (?:"[^"]+"|\\+\\d+)'
		+ '|Lasts Until Rollover'
		+ '|: True'
		+ '|None'
		+ '|Generic'
		+ '|[^,:]+: 0(?:, |$)'
		+ '|Wiki Name: "[^"]+"'
		+ '|Free Pull:? ?\\+?\\d*', evm);
	evm = parse.replace_all("");

	// cleanup extra commas from removing things
	parse = create_matcher(",+\\s*,+[\\s,]*", evm);
	evm = parse.replace_all(", ");
	parse = create_matcher(",+\\s*$", evm);
	evm = parse.replace_all("");

	if(debug) print("2: " + evm);

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
	parse = create_matcher("((?:Hot|Cold|Spooky|Stench|Sleaze|Prismatic) )Damage: ([+-]?\\d+), \\1Spell Damage: \\2"
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

	parse = create_matcher('Class: "([^"]+)"', evm);
	evm = parse.replace_all("$1 Only");

	parse = create_matcher('Rollover Effect: "([^"]+)", Rollover Effect Duration \\+(\\d+)', evm);
	evm = parse.replace_all('$2 Rollover Turns $1');

	parse = create_matcher('Effect: "([^"]+)", Effect Duration \\+(\\d+)', evm);
	evm = parse.replace_all('$2 Turns $1');

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
	evm = replace_string(evm,"Mysticality","Mys");
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
	evm = replace_string(evm,"Seal Clubber","SC");
	evm = replace_string(evm,"Turtle Tamer","TT");
	evm = replace_string(evm,"Pastamancer","PM");
	evm = replace_string(evm,"Sauceror","S");
	evm = replace_string(evm,"Disco Bandit","DB");
	evm = replace_string(evm,"Accordion Thief","AT");
	//highlight items, meat & ML
	if(span) {
		evm = replace_string(evm,"Item","<span class=moditem>Item</span>");
		evm = replace_string(evm,"Meat","<span class=moditem>Meat</span>");
		evm = replace_string(evm,"ML","<span class=modml>ML</span>");
	}

	if(span) {
		matcher elemental =
		create_matcher("(((?:^|,)\\s*)([^,]*(Hot|Cold|Spooky|Stench|Sleaze|Prismatic)[^,]+))", evm);
		while(elemental.find()) {
			evm = replace_string(evm, elemental.group(1), elemental.group(2) + "<span class=mod" +
				elemental.group(4) + ">" + elemental.group(3) + "</span>");
		}
	}

	if(debug) print("3: " + evm);

	parse = create_matcher('(\\d+(?: Rollover)? Turns )([^,]+)(,|$)', evm);
	while(parse.find()) {
		effect eff = to_effect(parse.group(2));
		if(eff != $effect[none]) {
			string parsedEff = parseEff(eff);
			if(parsedEff != '') {
				parsedEff = '[' + parsedEff.replace_string(', ', '], [') + ']';
				evm = evm.replace_string(parse.group(0), parse.group(1) + eff.name + ', ' + parsedEff
					+ parse.group(3));
			}
		}
	}

	if(debug) print("4: " + evm);

	return evm;
}
string parseMods(string evm, boolean span) { return parseMods(evm, span, false); }
string parseMods(string evm) { return parseMods(evm, true); }

chit_info getEffectInfo(effect eff, boolean avoidRecursion, boolean span);

string parseEff(effect ef, boolean span) {
	chit_info info = getEffectInfo(ef, true, span);
	return info.desc;
}
string parseEff(effect ef) { return parseEff(ef, true); }

string parseItem(item it, string evmAddon, boolean weirdFamMode) {
	if(weirdFamMode) {
		matcher m = create_matcher('^(.*?), cap (.*?)$', string_modifier(it, 'Familiar Effect'));
		if(find(m)) {
			return m.group(1) + ', limit ' + m.group(2) + 'lbs';
		} else {
			return 'Unknown Effect';
		}
	}

	string evm = string_modifier(it, "Evaluated Modifiers") + evmAddon;
	return evm.parseMods(true);
}

string parseItem(item it, string evmAddon) {
	return parseItem(it, evmAddon, false);
}

string parseItem(item it) {
	return parseItem(it, "", false);
}


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
		case $location[The Cola Wars Battlefield]: return "diet";
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

// Why did ChIT not have a helper function for this already...

int clamp(int toClamp, int min, int max) {
	return min(max(toClamp, min), max);
}

float clamp(float toClamp, float min, float max) {
	return min(max(toClamp, min), max);
}

string get_option(string reason, string option) {
	if(forceSections[reason] && option == "amount")
		return "all";
	if(reason != "" && reason_options[reason,option] != "")
		return reason_options[reason,option];

	if(!defaults_initialized) {
		foreach i,s in split_string(cvars["chit.gear.display." + (aftercore ? "aftercore" : "in-run") + ".defaults"], ", ?") {
			string [int] spl = split_string(s, "[=_]");
			defaults[spl[0]] = spl[1];
		}
		defaults_initialized = true;
	}

	return defaults[option];
}

int foldable_amount(item it, string reason, boolean hagnk);

int chit_available(item it, string reason, boolean hagnk, boolean foldcheck)
{
	int available = item_amount(it) + closet_amount(it);
	if(to_boolean(reason.get_option("create")))
		available += creatable_amount(it);
	if(available == 0 && boolean_modifier(it, "Free Pull"))
		available += available_amount(it);

	if(pulls_remaining() == -1)
		available += storage_amount(it);
	else if(hagnk && pulls_remaining() > 0 && to_boolean(reason.get_option("pull")))
		available += min(pulls_remaining(), storage_amount(it));
	available += equipped_amount(it);
	if(it.to_slot() == $slot[familiar]) {
		foreach fam in $familiars[] {
			if(my_familiar() != fam && have_familiar(fam) && familiar_equipped_equipment(fam) == it) {
				++available;
			}
		}
	}

	if(foldcheck)
		available += foldable_amount(it, reason, hagnk);
	if(it == $item[pantogram pants] && available == 0 && item_amount($item[portable pantogram]) > 0)
		available = 1;

	return available;
}

int chit_available(item it, string reason, boolean hagnk) {
	return chit_available(it, reason, hagnk, true);
}
int chit_available(item it, string reason)
{
	return chit_available(it, reason, true);
}

int chit_available(item it)
{
	return chit_available(it, "");
}

int foldable_amount(item it, string reason, boolean hagnk) {
	int amount = 0;
	foreach foldable, i in get_related(it, "fold")
		if(foldable != it)
			amount += chit_available(foldable, reason, hagnk, false);

	return amount;
}
