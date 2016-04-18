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

