script "Character Info Toolbox";
notify "Bale";
import "zlib.ash";
string chitVersion = "0.8.5";

/************************************************************************************
CHaracter Info Toolbox
A character pane relay override script
By Chez up to v 0.6.0
Everything after that by Bale

Additional major contributors:
	AlbinoRhino - Provided invaluable assistance with CSS & Javascript
	ckb - Created the tracker brick and effect description code
	bordemstirs - Created the florist brick and moved the frams to make charpane taller

*************************************************************************************
Many thanks to:
	Zarqon, for his zlib library
	Bale, from whose CounterChecker script I stole some ideas and code
	All the countless KoLMafia devs and contributors, whose work make all our little pet projects possible
	Ereinion and Caprosmaster, for helping with initial testing and feedback
	rlbond who added css & java for familiar picker and other odds and ends
	Icons from http://www.famfamfam.com/lab/icons/silk/
	
*************************************************************************************
	0.1		Initial Release
	0.2		Fixed bug with Kung-Fu Hustler (and probably other) intrinsic effects
			Enabled daily version checking
	0.3		Fixed some parsing errors when in Valhalla
			Added Ronin information with a link to Hagnk's
			Recognize Way of the Fist paths correctly
			MCD changer now checks if the Gnomads camp is available
			Fixed some documentation errors
			Changed the order of organs in the consumption toolbar popup
			Added the "elements" tool (Displays the Elements chart fom the wiki)
			Fixed a custom title parsing bug
			Added chit.stats.showbars preference
			Added chit.effects.usermap preference
	0.4		Fixed a typo in 0.3 that prevented the semirare helper from popping up
			Added "update" brick
			Quests brick now recognizes the new "This quest tracker is a work in progress" message
			Fixed various bugs related to moods, effects and intrinsics
			Added a "Burn extra MP" toolbar icon
			Made layout changes so that the charpane doesn't look horrible when updated via AJAX
			Various other small code and styling tweaks
	0.5		Fixed more documentation errors (update vs. updates, spelling mistakes)
			When no MCD is available (unascended characters), show only ML info
			Add link to Hey Deze for characters in Bad Moon (untested)
	0.6		Added links for HP/MP/Meat/Adv doumentation
			Fixed Familiar annotations
			Add configurable margins to the top and bottom of the charpane (to make space for content added by GM scripts)
			Added support for the new Moveable Feast usage tracking preferences (_feastUsed, _feastedFamiliars)
			Added support for bootsCharged preference
	0.6.1	Bale has taken over support because Avatar of Boris breaks the script
	0.7		Boris support, Add Bugbear Invasion to Quest Log, Add Extreme Meter, Add PvP Fights
			Improve familiar switcher and familiar gear switcher
			MANY minor changes and bugfixes
			Begin Zombie Slayer support
	0.8		Support Young Man's Bathtub Adventure
			Jarlsberg support
			Snow Suit support
			Restore rollover warning to top of effects pane
			Lots more improvements and bugfixes
	0.8.1	Added tracker brick by ckb
	0.8.4	Updating through SVN!
			All future changelogs will be on the SVN and will be much more complete.
	
************************************************************************************/
	
string [string] chitSource;
string [string] chitBricks;
string [string] chitPickers;
string [string] chitTools;
string [string] chitEffectsMap;
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
		result.append(sideCommand('svn update mafiachit'));
		result.append('" title="SVN Update">here</a> to upgrade from SVN</p>');
	} else {
		result.append(sideCommand('svn checkout https://svn.code.sf.net/p/mafiachit/code/'));
		result.append('" title="SVN Installation">here</a> to install current version from SVN</p>');
	}
	result.append('</td></tr></tbody></table>');
	chitBricks["update"] = result.to_string();		
}

// checks script version once daily
// adapted from zlib's check_version() to only print update messages once per day, and only if version checking is enabled by the user
void checkVersion(string soft, string thisver, int thread) {

	vprint("Running "+soft+" version: "+thisver,"gray",8);

	if (!(vars["chit.checkversion"]=="true")) {
		return;
	}

	boolean sameornewer(string local, string server) {
      if (equals(local,server)) return true;
      string[int] loc = split_string(local,"\\.");
      string[int] ser = split_string(server,"\\.");
      for i from 0 to max(count(loc)-1,count(ser)-1) {
         if (i+1 > count(loc)) return false; if (i+1 > count(ser)) return true;
         if (loc[i].to_int() < ser[i].to_int()) return false;
         if (loc[i].to_int() > ser[i].to_int()) return true;
      }
		return local == server;
	}

	string page; 
	matcher findver;
	buffer result;

	record {
	   string ver;
	   string vdate;
	} [string] zv;
	file_to_map("zversions.txt", zv);

	if (zv[soft].vdate != today_to_string()) {
		vprint("Checking for updates...",1);
		page = visit_url("http://kolmafia.us/showthread.php?t="+thread);
		findver = create_matcher("<b>"+soft+" (.+?)</b>",page);
		zv[soft].vdate = today_to_string();
		if (findver.find()) {
			zv[soft].ver = findver.group(1);
			vprint("Latest version: " + zv[soft].ver,1);
			if (sameornewer(thisver,zv[soft].ver)) {
				vprint("You have a current version of "+soft+".","green",1); 
			} else {
				string msg = "<font color=red><b>New Version of "+soft+" Available: "+zv[soft].ver+"</b></font>";
				msg = msg + '<br>Upgrade from '+thisver+' to '+zv[soft].ver+' with <font color=blue><u>svn update</u></font> command!<br>';
				vprint_html(msg,1);
			}
		} else {
			vprint("Unable to load current version info.","red",-1); 
		}
		map_to_file(zv,"zversions.txt");
	}
	
	//Build update brick if required
	if(!sameornewer(thisver,zv[soft].ver))
		bakeUpdate(thisver, "Version ", zv[soft].ver);
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

string helperDanceCard() {

	//Bail if the user doesn't want to see the helper
	string pref = vars["chit.helpers.dancecard"];
	if (pref != "true") {
		return "";
	}

	buffer result;
	result.append('<table id="chit_matilda" class="chit_brick nospace">');
	result.append('<tr><th colspan="2"><img src="');
	result.append(imagePath);
	result.append('helpers.png">Dance Card</th></tr>');
	result.append('<tr>');
	result.append('<td class="icon"><img src="images/itemimages/guildapp.gif"></td>');
	result.append('<td class="location">');
	result.append('<a href="');
	result.append(to_url($location[The Haunted Ballroom]));
	result.append('" class="visit" target="mainpane">Haunted Ballroom</a>');
	result.append('You have a date with Matilda');
	result.append('</td>');
	result.append('</tr>');
	result.append('</table>');
	chitTools["helpers"] = "You have some expired counters|helpers.png";
	return result.to_string();
}

string helperWormwood() {

	//Bail if the user doesn't want to see the helper
	string pref = vars["chit.helpers.wormwood"];
	if (pref == "none" || pref == "") {
		return "";
	}

	// Set up all the location and reward data
	location [string] zones;
		zones["windmill"] = $location[The Rogue Windmill];
		zones["mansion"] = $location[The Mouldering Mansion];
		zones["dome"] = $location[The Stately Pleasure Dome];
			
	string [string] rewards;
		rewards["moxie"] = "discomask.gif|Gain Moxie Substats";
		rewards["muscle"] = "strboost.gif|Gain Muscle Substats";
		rewards["mysticality"] = "wand.gif|Gain Mysticality Substats";
		rewards["pipe"] = "notapipe.gif|Not-a-pipe";
		rewards["mask"] = "ballmask.gif|fancy ball mask";
		rewards["cancan"] = "cancanskirt.gif|Can-Can skirt";
		rewards["food"] = "sammich.gif|S.T.L.T.";
		rewards["necklace"] = "albaneck.gif|albatross necklace";
		rewards["booze"] = "flask.gif|flask of Amontillado";
	
	string [string, int] targets;
		targets["moxie", 9] = "windmill|Check the upstairs apartment|Absinthe-Minded";
		targets["moxie", 5] = "mansion|Approach the Man|Absinthe-Minded";
		targets["moxie", 1] = "dome|Walk the main deck|Absinthe-Minded";
		targets["muscle", 9] = "dome|Swim laps in the pool|Absinthe-Minded";
		targets["muscle", 5] = "windmill|Pitch in and help|Absinthe-Minded";
		targets["muscle", 1] = "mansion|Open the door|Absinthe-Minded";
		targets["mysticality", 9] = "mansion|Climb to the second floor|Absinthe-Minded";
		targets["mysticality", 5] = "dome|Ponder the measureless expanse |Absinthe-Minded";
		targets["mysticality", 1] = "windmill|Chat with the midnight tokers|Absinthe-Minded";

		targets["pipe", 9] = "dome|Wade in the Alph|Absinthe-Minded";
		targets["pipe", 5] = "mansion|Approach the Cat|Spirit of Alph";
		targets["pipe", 1] = "windmill|Chat with the jokers|Feelin' Philosophical";
		targets["mask", 9] = "dome|Wade in the Alph|Absinthe-Minded";
		targets["mask", 5] = "windmill|Pitch yourself into showbusiness|Spirit of Alph";
		targets["mask", 1] = "mansion|Ascend|Dancing Prowess";
		targets["cancan", 9] = "mansion|Climb to the belfry|Absinthe-Minded";
		targets["cancan", 5] = "dome|Investigate a nearby squeaky noise|Bats in the Belfry";
		targets["cancan", 1] = "windmill|Chat with the smokers|Good with the Ladies";
		targets["food", 9] = "mansion|Climb to the belfry|Absinthe-Minded";
		targets["food", 5] = "windmill|Pitch yourself up the stairs|Bats in the Belfry";
		targets["food", 1] = "dome|Go up to the crow's nest|No Vertigo";
		targets["necklace", 9] = "windmill|Check out the restrooms|Absinthe-Minded";
		targets["necklace", 5] = "mansion|Approach the Woman|Rat-Faced";
		targets["necklace", 1] = "dome|Check out the helm|Unusual Fashion Sense";
		targets["booze", 9] = "windmill|Check out the restrooms|Absinthe-Minded";
		targets["booze", 5] = "dome|Explore some side-tunnels|Rat-Faced";
		targets["booze", 1] = "mansion|Descend|Night Vision";

		
	//Normalize turns of Absinthe-Minded remaining
	int absinthe = have_effect($effect[Absinthe-Minded]);
	if(absinthe > 5) {
		absinthe = 9;
	} else if (absinthe > 1) {
		absinthe = 5;
	} else {
		absinthe = 1;
	}
	
	string [int] goals = split_string(pref, ",");	//split desired goals into separate strings
	string goal;											
	string goalname;
	string goalturns;

	//Helper functions to normalize goals
	string fix_goalname() {
		switch {
		case goal == "":
		case contains_text(goal, "none"):
			return "none";
		case contains_text(goal, "pipe"):
		case contains_text(goal, "spleen"):
			return "pipe";
		case contains_text(goal, "flask"):
		case contains_text(goal, "amont"):
		case contains_text(goal, "booze"):
			return "booze";
		case contains_text(goal, "s.t.l"):
		case contains_text(goal, "stl"):
		case contains_text(goal, "s t l"):
		case contains_text(goal, "s. t. l"):
		case contains_text(goal, "food"):
			return "food";
		case contains_text(goal, "reward"):
			return "rewards";
		case contains_text(goal, "main"):
			return to_string(my_primestat()).to_lower_case();
		case contains_text(goal, "stat"):
			return "stats";
		case contains_text(goal, "mus"):
			return "muscle";
		case contains_text(goal, "mox"):
			return "moxie";
		case contains_text(goal, "mys"):
			return "mysticality";
		case contains_text(goal, "fancy"):
		case contains_text(goal, "ball"):
		case contains_text(goal, "mask"):
		case contains_text(goal, "hat"):
			return "mask";
		case contains_text(goal, "albat"):
		case contains_text(goal, "nec"):
		case contains_text(goal, "acc"):
			return "necklace";
		case contains_text(goal, "can"):
		case contains_text(goal, "skirt"):
		case contains_text(goal, "pant"):
			return "cancan";
		default:
			return "none";		//If we can't recognize it, we'll ignore it...
		}
		return "none";
	}
	string fix_goalturns() {
		switch {
		case contains_text(goal, "9"):
			return "951";
		case contains_text(goal, "5"):
			return "51";
		case contains_text(goal, "1"):
			return "1";
		default:
			return "951";
		}
		return "951";
	}

	//Compile a (sorted) list of goals to include
	string [string] goallist;
	
	for i from 0 to goals.count()-1 {
		
		goal = replace_string(goals[i], " ", "").to_string().to_lower_case();

		goalname = fix_goalname();
		goalturns = fix_goalturns();

		if (contains_text(goalturns, to_string(absinthe))) {
			switch (goalname) {
			case "none":
				break;
			case "stats":
				goallist[i + "a"] = "muscle";
				goallist[i + "b"] = "mysticality";
				goallist[i + "c"] = "moxie";
				break;
			case "rewards":
				goallist[i + "a"] = "pipe";
				goallist[i + "b"] = "mask";
				goallist[i + "c"] = "cancan";
				goallist[i + "d"] = "food";
				goallist[i + "e"] = "booze";
				goallist[i + "f"] = "necklace";
				break;
			default:
				goallist[to_string(i)] = goalname;
			}
		}
	}
	
	string [3] target;
	string [2] reward;
	location zone;
	effect musthave;
	string hint;
	buffer result;
	buffer rowdata;
	int rows = 0;
	int [string] addeditems;
	
	//Iterate through the normalized list of goals, and show only those that are still achievable (based on required effects)
	foreach key, value in goallist {
		if (!(addeditems contains value)) {
			reward = split_string(rewards[value], "\\|");
			target = split_string(targets[value, absinthe], "\\|");
			zone = zones[target[0]];
			hint = target[1];
			musthave = to_effect(target[2]);		
			if (have_effect(musthave) > 0) {
				rowdata.append('<tr class="section">');
				rowdata.append('<td class="icon" title="');
				rowdata.append(reward[1]);
				rowdata.append('"><img src="images/itemimages/');
				rowdata.append(reward[0] );
				rowdata.append('"></td>');
				rowdata.append('<td class="location" title="');
				rowdata.append(reward[1]);
				rowdata.append('"><a class="visit" target="mainpane" href="');
				rowdata.append(to_url(zone));
				rowdata.append('">');
				rowdata.append(to_string(zone));
				rowdata.append('</a>');
				rowdata.append(hint);
				rowdata.append('</td>');
				rowdata.append('<tr>');
				rows = rows + 1;
				addeditems[value] = 1;
			}
		}
	}
	
	//wrap everything up in a pretty table
	if (rows > 0) {
		result.append('<table id="chit_wormwood" class="chit_brick nospace">');
		result.append('<tr class="helper"><th colspan="2"><img src="');
		result.append(imagePath);
		result.append('helpers.png">Wormwood</th></tr>');
		result.append(rowdata);
		result.append('</table>');

		chitTools["helpers"] = "You have some expired counters|helpers.png";

	}
	
	return result;
	
}

string helperSemiRare() {
	//Bail if the user doesn't want to see the helper
	if(vars["chit.helpers.semirare"] != "true") return "";

	buffer result;

	//Set up all the locations we support
	string [location] rewards;
		rewards[$location[The Sleazy Back Alley]] = "wine.gif|Distilled fotified wine (3)|0";
		rewards[$location[The Haunted Pantry]] = "pie.gif|Tasty tart (3)|0";
		rewards[$location[The Limerick Dungeon]] = "eyedrops.gif|cyclops eyedrops|0";
		rewards[$location[The Valley of Rof L'm Fao]] = "scroll2.gif|Fight Bad ASCII Art|68";
		rewards[$location[The Castle in the Clouds in the Sky (Top Floor)]] = "inhaler.gif|Mick's IcyVapoHotness Inhaler|85";
		rewards[$location[The Outskirts of Cobb's Knob]] = "lunchbox.gif|Knob Goblin lunchbox|0";
	if(get_property("kingLiberated") == "true") {
		rewards[$location[An Octopus's Garden]] = "bigpearl.gif|Fight a moister oyster|148";
	} else {
		if(available_amount($item[stone wool]) < 1 && get_property("questL11Worship") != "finished")
			rewards[$location[The Hidden Temple]] = "stonewool.gif|Fight Baa'baa'bu'ran|5";
		if(!have_outfit("Knob Goblin Elite Guard Uniform") && my_path() != "Way of the Surprising Fist" && my_path() != "Way of the Surprising Fist")
			rewards[$location[Cobb's Knob Kitchens]] = "elitehelm.gif|Fight KGE Guard Captain|20";
		if(!have_outfit("Mining Gear") && my_path() != "Way of the Surprising Fist")
			rewards[$location[Itznotyerzitz Mine]] = "mattock.gif|Fight Dwarf Foreman|53";
		if(get_property("questL11Palindome") != "finished" && item_amount($item[Talisman o' Nam]) == 0) {
			rewards[$location[The Copperhead Club]] = "rocks_f.gif|Flamin' Whatshisname (3)|104";
			rewards[$location[A Mob of Zeppelin Protesters]] = "bansai.gif|Choice of Protesting|104";
		}
	}
	if(get_property("grimstoneMaskPath") == "gnome")
		rewards[$location[Ye Olde Medievale Villagee]] = "leather.gif|3 each: Straw, Leather and Clay|0";
	
	int semirareCounter = to_int(get_property("semirareCounter"));
	location semirareLocation = semirareCounter == 0? $location[none]: get_property("semirareLocation").to_location();
	string message = semirareCounter == 0? "No semirare so far during this ascension"
		: ("Last semirare found " + (turns_played()-semirareCounter) + " turns ago (on turn " + semirareCounter + ") in " + semirareLocation);
	
	//Iterate through all the predefined zones
	string[3] reward;
	buffer rowdata;
	int rows = 0;
	foreach loc, value in rewards {
		reward = split_string(value, "\\|");
		if (loc != semirareLocation) {
			if (my_basestat(my_primestat()) >= to_int(reward[2])) {
				rowdata.append('<tr class="section">');
				rowdata.append('<td class="icon" title="');
				rowdata.append(reward[1]);
				rowdata.append('"><img src="images/itemimages/');
				rowdata.append(reward[0]);
				rowdata.append('"></td>');
				rowdata.append('<td class="location" title="');
				rowdata.append(reward[1]);
				rowdata.append('"><a class="visit" target="mainpane" href="');
				rowdata.append(to_url(loc));
				rowdata.append('">');
				rowdata.append(to_string(loc));
				rowdata.append('</a>');
				rowdata.append(reward[1]);
				rowdata.append('</td>');
				rowdata.append('</tr>');
				rows = rows + 1;
			}
		}
	}
	
	//wrap everything up in a pretty table
	if(rows > 0) {
		result.append('<table id="chit_semirares" class="chit_brick nospace">');
		result.append('<tr class="helper"><th colspan="2"><img src="');
		result.append(imagePath);
		result.append('helpers.png">Semi-Rares</th></tr>');
		result.append('<tr><td class="info" colspan="2">');
		result.append(message);
		result.append('</td></tr>');
		result.append(rowdata);
		result.append('</table>');		
		chitTools["helpers"] = "You have some expired counters|helpers.png";
	}
	
	return result;
}

string helperSpookyraven() {
	//Bail if the user doesn't want to see the helper
	if(vars["chit.helpers.spookyraven"] != "true") return "";
	
	void addRoom(buffer info, string child) {
		string room = get_property("nextSpookyraven"+child+"Room");
		if(room != "none") {
			info.append('<tr class="section">');
			info.append('<td class="location"><a class="visit" target="mainpane" href="');
			info.append(to_url(to_location(room)));
			info.append('">');
			info.append(room);
			info.append('</a><b>');
			info.append(child);
			info.append('\'s</b> Next Room</td>');
			info.append('</tr>');
		}
	}

	buffer result;
	result.append('<table id="chit_spookyraven" class="chit_brick nospace">');
	result.append('<tr class="helper"><th colspan="2"><img src="');
	result.append(imagePath);
	result.append('helpers.png"><a target="mainpane" href="place.php?whichplace=manor1">Spookyraven Lights Out</a></th></tr>');
	result.addRoom("Elizabeth");
	result.addRoom("Stephen");
	result.append('</table>');		
	
	chitTools["helpers"] = "You have some expired counters|helpers.png";
	return result.to_string();
}

// Functions for pickers
void pickerStart(buffer picker, string rel, string message) {
	picker.append('<div id="chit_picker' + rel + '" class="chit_skeleton" style="display:none">');	
	picker.append('<table class="chit_picker">');
	picker.append('<tr><th colspan="2">' + message + '</th></tr>');
}

void pickerStart(buffer picker, string rel, string message, string image) {
	picker.append('<div id="chit_picker' + rel + '" class="chit_skeleton" style="display:none">');	
	picker.append('<table class="chit_picker"><tr><th colspan="2"><img src="');
	picker.append(imagePath + image);
	picker.append('.png">');
	picker.append(message + '</th></tr>');
}

void addLoader(buffer picker, string message) {
	picker.append('<tr class="pickloader" style="display:none">');
	picker.append('<td class="info">' + message + '</td>');
	picker.append('<td class="icon"><img src="/images/itemimages/karma.gif"></td>');
	picker.append('</tr>');
}

void addSadFace(buffer picker, string message) {
	picker.append('<tr class="picknone">');
	picker.append('<td class="info" colspan="2">');
	picker.append(message);
	picker.append('</td></tr>');
}

// elementchart1.gif or elementchart2.gif are valid values for img
void addElementMap(buffer result, string img) {
	result.append('<img src="');
	result.append(imagePath);
	result.append(img);
	result.append('" width="190" height="190"');
	if(have_skill($skill[Flavour of Magic])) {
		result.append(' alt="Cast Flavour of Magic" usemap="#flavmap">');
		result.append('<map id="flavmap" name="flavmap"><area shape="circle" alt="Sleaze" title="Spirit of Bacon Grease (Sleaze)" coords="86,33,22" href="');
		result.append(sideCommand('cast spirit of bacon grease'));
		result.append('" /><area shape="circle" alt="Cold" title="Spirit of Peppermint (Cold)" coords="156,84,22" href="');
		result.append(sideCommand('cast spirit of peppermint'));
		result.append('" /><area shape="circle" alt="Spooky" title="Spirit of Wormwood (Spooky)" coords="133,155,22" href="');
		result.append(sideCommand('cast spirit of wormwood'));
		result.append('" /><area shape="circle" alt="Hot" title="Spirit of Cayenne (Hot)" coords="39,155,22" href="');
		result.append(sideCommand('cast spirit of cayenne'));
		result.append('" /><area shape="circle" alt="Stench" title="Spirit of Garlic (Stench)" coords="25,84,22" href="');
		result.append(sideCommand('cast spirit of garlic'));
		result.append('" /><area shape="circle" alt="Cancel Flavour of Magic" title="Cancel Flavour of Magic" coords="86,95,22" href="');
		result.append(sideCommand('cast spirit of nothing'));
		result.append('" /></map>');
	} else
		result.append('>');
}

void pickerFlavour() {
	buffer picker;
	picker.pickerStart("flavour", "Cast Flavour of Magic");
	
	picker.addLoader("Spiriting flavours...");
	picker.append('<tr class="pickitem"><td>');
	picker.addElementMap("elementchart2.gif");
	picker.append('</td></tr>');
	
	picker.append('</table></div>');
	chitPickers["flavour"] = picker;
}

//ckb: function for effect descriptions to make them short and pretty, called by chit.effects.describe
string parseMods(string ef) {
	# if(ef == "So Fresh and So Clean") ef = "Video... Games?";
	switch(ef) {
	case "Knob Goblin Perfume": return "";
	case "Bored With Explosions": 
		matcher wafe = create_matcher(":([^:]+):walk away from explosion:", get_property("banishedMonsters"));
		if(wafe.find()) return wafe.group(1);
		return "You're just over them"; 
	}

	string evm = string_modifier(ef,"Evaluated Modifiers");
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
		+'|Avatar: "([^"]+)"', evm);
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
	parse = create_matcher("^\\s*(,)\\s*"
		+"|(\\s*Drop|\\s*Percent([^:]*))?(?<!Limit):\\s*(([+-])?\\d+)"
		+"|(HP Regen ([0-9-]+), MP Regen \\6)", evm);
	while(parse.find()) {
		parse.append_replacement(enew, "");
		if(parse.group(1) == ",") {			// group would contain extra comma at beginning
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
	//decorate elemental tags with pretty colors
	evm = replace_string(evm,"Hot","<span class=modhot>Hot</span>");
	evm = replace_string(evm,"Cold","<span class=modcold>Cold</span>");
	evm = replace_string(evm,"Spooky","<span class=modspooky>Spooky</span>");
	evm = replace_string(evm,"Stench","<span class=modstench>Stench</span>");
	evm = replace_string(evm,"Sleaze","<span class=modsleaze>Sleaze</span>");
	evm = replace_string(evm,"Prismatic","<span class=modspooky>P</span><span class=modhot>ri</span><span class=modsleaze>sm</span><span class=modstench>at</span><span class=modcold>ic</span>");

	return evm;

}

record buff {
	string effectName;
	string effectHTML;
	string effectImage;
	string effectType;
	int effectTurns;
	boolean isIntrinsic;
};

buff parseBuff(string source) {
	buff myBuff;

	boolean doArrows = get_property("relayAddsUpArrowLinks").to_boolean();
	boolean showIcons = (vars["chit.effects.showicons"]=="false" || isCompact)? false: true;

	string columnIcon, columnTurns, columnArrow;
	string spoiler, style;

	matcher parse = create_matcher('(?:<td[^>]*>(.*?)</td>)?<td[^>]*>(<.*?itemimages/([^"]*).*?)</td><td[^>]*>[^>]*>(.*?) +\\((?:(.*?), )?((?:<a[^>]*>)?(\\d+||&infin;)(?:</a>)?)\\)(?:(?:</font>)?&nbsp;(<a.*?</a>))?.*?</td>', source);
	// The ? stuff at the end is because those arrows are a mafia option that might not be present
	if(parse.find()) {
		columnIcon = parse.group(2);	// This is full html for the icon
		myBuff.effectImage = parse.group(3);
		myBuff.effectName = parse.group(4);
		spoiler = parse.group(5);		// This appears for "Form of...Bird!" and "On the Trail"
		columnTurns = parse.group(6).replace_string('title="Use a remedy to remove', 'title="SGEEAs Left: '+ item_amount($item[soft green echo eyedrop antidote]) +'\nUse a remedy to remove');
		if(parse.group(7) == "&infin;") {	// Is it intrinsic?
			myBuff.effectTurns = -1;
			myBuff.isIntrinsic = true;
		} else
			myBuff.effectTurns = parse.group(7).to_int();
		// There are various problems with KoL's native uparrows. Only use them if KoL's uparrows are missing
		if(parse.group(8) != "")
			columnArrow = parse.group(8).replace_string("/images/", imagePath).replace_string("up.gif", "up.png");
		else if(parse.group(1) != "" ) {
			doArrows = true;			// In case they were disabled in KoLmafia. Make a column for it.
			columnArrow = parse.group(1);
		}
	}
	string effectAlias = myBuff.effectName;
	
	//Apply any styling/renaming as specified in effects map
	if(chitEffectsMap contains myBuff.effectName) {
		matcher pattern = create_matcher('(type|alias|style|href|image):"([^"]*)', chitEffectsMap[myBuff.effectName]);
		while(pattern.find()) {
			switch(pattern.group(1)) {
			case "type":
				myBuff.effectType = pattern.group(2);
				break;
			case "alias":
				// "href" might come before alias, so...
				effectAlias = effectAlias.replace_string(myBuff.effectName, pattern.group(2));
				break;
			case "style":
				style = pattern.group(2);
				break;
			case "href":
				effectAlias = '<a href="'+pattern.group(2)+'" target=mainpane>' + effectAlias + "</a>";
				break;
			case "image":
				if(vars["chit.effects.modicons"].to_boolean()) {
					string image = pattern.group(2);
					if(image == "corpsetini" && gameday_to_string() == "Boozember 7")
						image = "turkeyleg";
					columnIcon = columnIcon.replace_string(myBuff.effectImage, image);
					myBuff.effectImage = image;
				}
				break;
			}
		}
	}
	
	// Flavour of Magic picker!
	if($strings[Spirit of Cayenne, Spirit of Peppermint, Spirit of Garlic, Spirit of Wormwood, Spirit of Bacon Grease] contains myBuff.effectName) {
		columnIcon = '<a class="chit_launcher" rel="chit_pickerflavour" href="#">' + columnIcon + '</a>';
		columnTurns = '<a class="chit_launcher" rel="chit_pickerflavour" href="#">&infin;</a>';
		pickerFlavour();
	}
	
	// Check Mirror picker
	if($strings[Slicked-Back Do, Pompadour, Cowlick, Fauxhawk] contains myBuff.effectName)
		columnTurns = '<a target="mainpane" href="skills.php?pwd='+my_hash()+'&action=Skillz&whichskill=15017&skillform=Use+Skill&quantity=1">&infin;</a>';

	//Add spoiler info
	if(length(spoiler) > 0)
		effectAlias += " "+spoiler;
	// Fix for blank "On the Trail" problem.
	if(length(effectAlias) == 0)
		effectAlias = myBuff.effectName;
	
	//Replace effect icons, if enabled
	string [string] classmap;
		classmap["at"] = "accordion.gif";
		classmap["sc"] = "club.gif";
		classmap["tt"] = "turtle.gif";
		classmap["sa"] = "saucepan.gif";
		classmap["pm"] = "pastaspoon.gif";
		classmap["db"] = "discoball.gif";

	if ((index_of(vars["chit.effects.classicons"], myBuff.effectType) > -1) && (classmap contains myBuff.effectType)) {
		columnIcon = columnIcon.replace_string(myBuff.effectImage, classmap[myBuff.effectType]);
		myBuff.effectImage = classmap[myBuff.effectType];
	}

	buffer result;
	result.append('<tr class="effect"');
	if(length(style) > 0)
		result.append(' style="' + style + '"');
	result.append('>');
	if(showIcons) 
		result.append('<td class="icon">' + columnIcon + '</td>');
	result.append('<td class="info"');
	if(doArrows && myBuff.isIntrinsic)
		result.append(' colspan="2"');
	result.append('>');
	result.append(effectAlias);
	
	//ckb: Add modification details for buffs and effects
	if(vars["chit.effects.describe"] == "true") {
		string efMod = parseMods(myBuff.effectName);
		if(length(efMod)>0) {
			result.append('<br><span class="efmods">');
			result.append(efMod);
			result.append('</span>');
		}
	}
	
	result.append('</td>');
	if(myBuff.isIntrinsic) {
		result.append('<td class="infinity');
		if(!doArrows)
			result.append(' right');
		result.append('">');
	} else {
		if(!doArrows)
			result.append('<td class="right">');
		else if (columnTurns != "")
			result.append('<td class="shrug">');
		else
			result.append('<td class="noshrug">');
	}
	result.append(columnTurns);
	result.append('</td>');
	if(doArrows && !myBuff.isIntrinsic) {
		if(columnArrow == "")
			result.append('<td>&nbsp;</td>');
		else {
			result.append('<td class="powerup">');
			result.append(columnArrow);
			result.append('</td>');
		}
	}
	result.append('</tr>');
	myBuff.effectHTML = result.to_string();
	
	return myBuff;
}

void bakeEffects() {

	buffer result;
	buffer songs;
	buffer expression;
	buffer buffs;
	buffer intrinsics;
	buffer helpers;
	int total = 0;

	//Get layout preferences
	string layout = vars["chit.effects.layout"].to_lower_case().replace_string(" ", "");
	if (layout == "") layout = "buffs";
	boolean showSongs = contains_text(layout,"songs");
	
	//Load effects map
	string mapfile = "chit_effects.txt";
	if (vars["chit.effects.usermap"] == "true") {
		mapfile = "chit_effects_" + my_name() + ".txt";
	}
	if (!file_to_map(mapfile, chitEffectsMap)) {
		vprint("CHIT: Effects map could not be loaded (" + mapfile + ")", "red", 1);
	}
	
	buff currentbuff;
	
	//Regular Effects
	matcher rowMatcher = create_matcher("<tr>(.*?)</tr>", chitSource["effects"]);
	while (find(rowMatcher)) {
		currentbuff = rowMatcher.group(1).parseBuff();

		if (currentBuff.isIntrinsic) {
			intrinsics.append(currentbuff.effectHTML);
		} else if (showSongs && $strings[at, aob, aoj] contains currentbuff.effectType) {
			songs.append(currentbuff.effectHTML);
		} else if(showSongs && to_skill(currentbuff.effectName).expression == true) {
			expression.append('<tbody class="buffs">');
			expression.append(currentbuff.effectHTML);
			expression.append('</tbody>');
		} else {
			buffs.append(currentbuff.effectHTML);
		}
		total += 1;
		
		if(currentbuff.effectTurns == 0) {
			if(currentbuff.effectName == "Fortune Cookie")
				helpers.append(helperSemiRare());
			else if(currentbuff.effectName == "Wormwood")
				helpers.append(helperWormwood());
			else if(currentbuff.effectName == "Dance Card")
				helpers.append(helperDanceCard());
			else if(currentbuff.effectName == "Spookyraven Lights Out")
				helpers.append(helperSpookyraven());
		}
	}

	//Intrinsic Effects
	rowMatcher = create_matcher("<tr>(.*?)</tr>", chitSource["intrinsics"]);
	while (find(rowMatcher)){
		currentbuff = rowMatcher.group(1).parseBuff();
		intrinsics.append(currentbuff.effectHTML);
		total += 1;
	}
	
	// Add Flavour of Nothing for all classes
	boolean need_flavour() {
		for i from 167 to 171
			if(have_effect(to_effect(i)) > 0) return false;
		return true;
	}
	if(have_skill($skill[flavour of magic]) && need_flavour()) {
		intrinsics.append('<tr class="effect">');
		if(vars["chit.effects.showicons"] == "true" && !isCompact)
			intrinsics.append('<td class="icon"><img height=20 width=20 src="/images/itemimages/flavorofmagic.gif" onClick=\'javascript:poop("desc_skill.php?whichskill=3017&self=true","skill", 350, 300)\'></td>');
		intrinsics.append('<td class="info"');
		if(get_property("relayAddsUpArrowLinks").to_boolean())
			intrinsics.append(' colspan="2"');
		intrinsics.append('><a class="chit_launcher" rel="chit_pickerflavour" href="#">Choose a Flavour</a></td><td class="infizero right"><a class="chit_launcher" rel="chit_pickerflavour" href="#">00</a></td></tr>');
		pickerFlavour();
		total += 1;
	}

	// Sneaky Pete should check the mirror and fix his hair
	boolean need_hairdo() {
		foreach e in $effects[Slicked-Back Do, Pompadour, Cowlick, Fauxhawk]
			if(have_effect(e) > 0) return false;
		return true;
	}
	if(have_skill($skill[Check Mirror]) && need_hairdo()) {
		intrinsics.append('<tr class="effect">');
		if(vars["chit.effects.showicons"] == "true" && !isCompact)
			intrinsics.append('<td class="icon"><img height=20 width=20 src="/images/itemimages/bikemirror.gif" onClick=\'javascript:poop("desc_skill.php?whichskill=15017&self=true","skill", 350, 300)\'></td>');
		intrinsics.append('<td class="info"');
		if(get_property("relayAddsUpArrowLinks").to_boolean())
			intrinsics.append(' colspan="2"');
		intrinsics.append('>Need to Check Mirror</td><td class="infizero right"><a target="mainpane" href="skills.php?pwd=');
		intrinsics.append(my_hash());
		intrinsics.append('&action=Skillz&whichskill=15017&skillform=Use+Skill&quantity=1">00</a></td></tr>');
		total += 1;
	}
	
	// Some 0 mp Intrinsics should have reminders for their specific classe
	void lack_effect(buffer result, skill sk, effect ef, string short_ef) {
		if(have_skill(sk) && have_effect(ef) == 0 && my_class() == sk.class) {
			result.append('<tr class="effect">');
			if(vars["chit.effects.showicons"] == "true" && !isCompact) {
				result.append('<td class="icon"><img height=20 width=20 src="/images/');
				result.append(ef.image.substring(36));
				result.append('" onClick=\'javascript:poop("desc_skill.php?whichskill=');
				result.append(to_int(sk));
				result.append('&self=true","skill", 350, 300)\'></td>');
			}
			result.append('<td class="info"');
			if(get_property("relayAddsUpArrowLinks").to_boolean())
				result.append(' colspan="2"');
			result.append('>Lack of ');
			result.append(short_ef);
			result.append('</td><td class="infizero right"><a href="');
			result.append(sideCommand("cast "+sk));
			result.append('" title="Cast ');
			result.append(to_string(sk));
			result.append('">00</a></td></tr>');
		}
		total += 1;
	}
	intrinsics.lack_effect($skill[Iron Palm Technique], $effect[Iron Palms], "Iron Palms");
	intrinsics.lack_effect($skill[Blood Sugar Sauce Magic], $effect[Blood Sugar Sauce Magic], "Blood Sugar");

	if (length(intrinsics) > 0 ) {
		intrinsics.insert(0, '<tbody class="intrinsics">');
		intrinsics.append('</tbody>');
	}
	if (length(songs) > 0 ) {
		songs.insert(0, '<tbody class="songs">');
		songs.append('</tbody>');
	}
	if (length(buffs) > 0) {
		buffs.insert(0, '<tbody class="buffs">');
		buffs.append('</tbody>');
	}

	if (total > 0) {
		result.append('<table id="chit_effects" class="chit_brick nospace">');
		result.append('<thead><tr><th colspan="4"><img src="');
		result.append(imagePath);
		result.append('effects.png">Effects</th></tr></thead>');
		string [int] drawers = split_string(layout, ",");
		for i from 0 to (drawers.count() - 1) {
			switch (drawers[i]) {
				case "buffs": 
					result.append(expression); 
					result.append(buffs); 
					break;
				case "songs": result.append(songs); break;
				case "intrinsics": result.append(intrinsics); break;
				default: //ignore all other values					
			}
		}
		result.append('</table>');
	}
	
	chitBricks["effects"] = result;
	if (helpers.to_string() != "") chitBricks["helpers"] = helpers;	
		
}

void bakeElements() {
	buffer result;
	
	result.append('<table id="chit_elements" class="chit_brick nospace">');
	result.append('<thead><tr><th><img src="');
	result.append(imagePath);
	result.append('elements.png">Elements</th></tr></thead>');
	result.append("<tr><td>");
	result.addElementMap("elementchart1.gif");
	result.append('</tr></table>');
	
	chitBricks["elements"] = result;
}

record plantInfo {
	int no;
	string desc;
	boolean territorial;
	string terrain;
};
plantInfo[string] plantData;
	plantData[""]=new plantInfo(0,"No Plant",false,"");
	plantData["Rabid Dogwood"]=new plantInfo(1,"+30 Monster Level",true,"outdoor");
	plantData["Rutabeggar"]=new plantInfo(2,"+25% Item drops",true,"outdoor");
	plantData["Rad-ish Radish"]=new plantInfo(3,"+5 Moxie stats per fight",true,"outdoor");
	plantData["Artichoker"]=new plantInfo(4,"Delevels enemies before combat",false,"outdoor");
	plantData["Smoke-ra"]=new plantInfo(5,"Prevents enemies from attacking",false,"outdoor");
	plantData["Skunk Cabbage"]=new plantInfo(6,"Deals Stench damage",false,"outdoor");
	plantData["Deadly Cinnamon"]=new plantInfo(7,"Deals Hot damage",false,"outdoor");
	plantData["Celery Stalker"]=new plantInfo(8,"Deals Spooky damage",false,"outdoor");
	plantData["Lettuce Spray"]=new plantInfo(9,"Restores HP after combat",false,"outdoor");
	plantData["Seltzer Watercress"]=new plantInfo(10,"Restores MP after combat",false,"outdoor");
	plantData["War Lily"]=new plantInfo(11,"+30 Monster Level",true,"indoor");
	plantData["Stealing Magnolia"]=new plantInfo(12,"+25% Item drops",true,"indoor");
	plantData["Canned Spinach"]=new plantInfo(13,"+5 Muscle stats per fight",true,"indoor");
	plantData["Impatiens"]=new plantInfo(14,"+25% Combat Initiative",false,"indoor");
	plantData["Spider Plant"]=new plantInfo(15,"Damages and poisons enemies before combat",false,"indoor");
	plantData["Red Fern"]=new plantInfo(16,"Delevels enemies during combat",false,"indoor");
	plantData["BamBOO!"]=new plantInfo(17,"Deals Spooky damage",false,"indoor");
	plantData["Arctic Moss"]=new plantInfo(18,"Deals Cold damage",false,"indoor");
	plantData["Aloe Guv'nor"]=new plantInfo(19,"Restores HP after combat",false,"indoor");
	plantData["Pitcher Plant"]=new plantInfo(20,"Restores MP after combat",false,"indoor");
	plantData["Blustery Puffball"]=new plantInfo(21,"+30 Monster Level",true,"underground");
	plantData["Horn of Plenty"]=new plantInfo(22,"+25% Item drops",true,"underground");
	plantData["Wizard's Wig"]=new plantInfo(23,"+5 Myst stats per fight",true,"underground");
	plantData["Shuffle Truffle"]=new plantInfo(24,"+25% Combat Initiative",false,"underground");
	plantData["Dis Lichen"]=new plantInfo(25,"Delevels enemies before combat",false,"underground");
	plantData["Loose Morels"]=new plantInfo(26,"Deals Sleaze damage",false,"underground");
	plantData["Foul Toadstool"]=new plantInfo(27,"Deals Stench damage",false,"underground");
	plantData["Chillterelle"]=new plantInfo(28,"Deals Cold damage",false,"underground");
	plantData["Portlybella"]=new plantInfo(29,"Restores HP after combat",false,"underground");
	plantData["Max Headshroom"]=new plantInfo(30,"Restores MP after combat",false,"underground");
	plantData["Spankton"]=new plantInfo(31,"Delevels enemies before combat",true,"underwater");
	plantData["Kelptomaniac"]=new plantInfo(32,"+40% Item drops",true,"underwater");
	plantData["Crookweed"]=new plantInfo(33,"+60% Meat drops",true,"underwater");
	plantData["Electric Eelgrass"]=new plantInfo(34,"Prevents enemies from attacking",false,"underwater");
	plantData["Duckweed"]=new plantInfo(35,"You can hide behind it once per fight",false,"underwater");
	plantData["Orca Orchid"]=new plantInfo(36,"Deals Physical damage",false,"underwater");
	plantData["Sargassum"]=new plantInfo(37,"Deals Stench damage",false,"underwater");
	plantData["Sub-Sea Rose"]=new plantInfo(38,"Deals Cold damage",false,"underwater");
	plantData["Snori"]=new plantInfo(39,"Restores HP and MP after combat",false,"underwater");
	plantData["Up Sea Daisy"]=new plantInfo(40,"+30 stats per fight",false,"underwater");

string plantDesc(string plant, boolean html) {
	buffer desc;
	desc.append(plant);
	if(html)
		desc.append('<br>(');
	else
		desc.append('\n (');
	desc.append(plantData[plant].desc);
	desc.append(')');
	return desc;
}

string toPlant(int i) {
 foreach s in plantData if (i == plantData[s].no) return s;
 return "";
}

void pickerFlorist(string[int] planted){
	int plantsPlanted;
	string terrain = lastLoc.environment;
	boolean marked = false;
	foreach i,s in planted {
		if (s!="") plantsPlanted+=1;
		if (plantData[s].territorial) marked = true;
	}
	string plantsUsed = get_property("_floristPlantsUsed");
	boolean[int] plantable;
	foreach s in plantData if ((plantData[s].terrain == terrain) && (!plantsUsed.contains_text(s)) && (s != ""))
		plantable[plantData[s].no]= ((planted[0] != s) && (planted[1] != s) && (planted[2] != s));
	buffer picker;
	string color, plant;
	if (plantsPlanted == 3) {
		picker.pickerStart("florist", "Pull a Plant");
		foreach i,s in planted {
			color = plantsUsed.contains_text(s)? (plantData[s].territorial? 'Khaki': 'Gainsboro'): (plantData[s].territorial? 'PaleGreen': 'LightSkyBlue');
			picker.append('<tr class="florist" style="background-color:' + color + '"><td><img src="/images/itemimages/shovel.gif"></td>');
			picker.append('<td><a href="' + sideCommand('ashq visit_url("place.php?whichplace=forestvillage&action=fv_friar");visit_url("choice.php?option=2&whichchoice=720&pwd=' + my_hash() + '&plnti=' + i +'");') +'">'+ plantDesc(s, true) + '</a></td></tr>');
		}
		if (count(plantable)>0) {
			picker.append('<tr class="pickitem"><td colspan="2" style="color:white;background-color:blue;font-weight:bold;">Remaining Plants</th></tr>');
			foreach i in plantable {
				if (!plantable[i]) continue;
				plant = i.toPlant();
				color = plantable[i]? (plantData[plant].territorial? (marked? "Khaki": "PaleGreen"): "LightSkyBlue"): "Gainsboro";
				picker.append('<tr class="florist" style="background-color:' + color + '"><td><img src="/images/otherimages/friarplants/plant' + i + '.gif" title="' + plantDesc(plant, false) + '"></td>');
				picker.append('<td>' + plantDesc(plant, true) + '</td></tr>');
			}
		} else picker.append('<tr><th colspan="2">No plants in stock for this area.</th></tr>');
	} else {
		picker.pickerStart("florist", "Plant an " + terrain + " Herb");
		if (count(plantable)>0) foreach i in plantable {
			plant = i.toPlant();
			color = plantable[i]? (plantData[plant].territorial? (marked? "Khaki": "PaleGreen"): "LightSkyBlue"): "Gainsboro";
			picker.append('<tr class="florist" style="background-color:' + color + '"><td><img src="/images/otherimages/friarplants/plant' + i + '.gif" title="' + plantDesc(plant, false) + '"></td>');
			picker.append('<td><a href="' + sideCommand("florist plant "+plant) + '">' + plantDesc(plant, true) + '</a></td></tr>');
		} else picker.append('<tr><td colspan="2">No more plants available to plant here</td></tr>');
	}
	picker.addLoader("Planting");
	picker.append('</table></div>');
	chitPickers["florist"] = picker;
}

void addPlants(buffer result) {
	if((lastLoc.environment == "none" || lastLoc == $location[none])) {
		result.append('<a class="visit" target="mainpane" href="place.php?whichplace=forestvillage&action=fv_friar">(Cannot plant here)</a>');
		return;
	}
	string[int] plants=get_florist_plants()[lastLoc];
	result.append('<a class="chit_launcher" rel="chit_pickerflorist" href="#">');
	foreach i,s in plants
		if (plantData[s].no>0)
			result.append('<img src="/images/otherimages/friarplants/plant'+plantData[s].no+'.gif" title="'+plantDesc(s, false)+'">');
		else {
			result.append('<img src="/images/otherimages/friarplants/noplant.gif" title="No Plant">');
			#break;		// I think I prefer the look of three empty plots
		}
	result.append('</a>');
	pickerFlorist(plants);
}

void addFlorist(buffer result, boolean label) {
	if(florist_available()) {
		result.append('<tr><td class="label">');
		
		// label is not necessary if right after trail
		if(vars["chit.stats.layout"].contains_text("trail,florist"))
			label = false;
		result.append(label? '<a class="visit" target="mainpane" href="place.php?whichplace=forestvillage&action=fv_friar">Florist</a>': '&nbsp;');
		
		result.append('</td><td class="florist" colspan="2">');
		result.addPlants();
		result.append('</td></tr>');
	}
}

void bakeFlorist() {
	buffer result;

	if (florist_available()) {
		result.append('<table id="chit_florist" class="chit_brick nospace">');
		result.append('<tr><th><a class="visit" target="mainpane" href="place.php?whichplace=forestvillage&action=fv_friar">Florist Friar</a></th></tr>');
		result.append('<tr><td class="florist">');
		result.addPlants();
		result.append('</td></tr></table>');
	}
	
	chitBricks["florist"] = result;
}

void bakeTrail() {
	string source = chitSource["trail"];
	buffer result;
	
	result.append('<table id="chit_trail" class="chit_brick nospace">');
	
	//Container
	string url = "main.php";
	matcher target = create_matcher('href="(.*?)" target=mainpane>Last Adventure:</a>', source);
	if (find(target)) {
		url = group(target, 1);
	}
	result.append('<tr><th><a class="visit" target="mainpane" href="' + url + '"><img src="');
	result.append(imagePath);
	result.append('trail.png">Last Adventure</a></th></tr>');
	
	//Last Adventure
	target = create_matcher('target=mainpane href="(.*?)">(.*?)</a><br></font>', source);
	if (find(target)) {
		result.append('<tr><td class="last"><a class="visit" target="mainpane" href="' + group(target, 1) + '">' + group(target, 2) + '</a></td></tr>');
	}
	
	//Other adventures
	matcher others = create_matcher("<nobr>(.*?)</nobr>", source);
	while (find(others)) {
		target = create_matcher('target=mainpane href="(.*?)">(.*?)</a>', group(others, 1));
		if (find(target)) {
			result.append('<tr><td><a class="visit" target="mainpane" href="' + group(target, 1) + '">' + group(target, 2) + '</a></td></tr>');
		}
	}
	
	result.append("</table>");
	
	chitBricks["trail"] = result;
	chitTools["trail"] = "Recent Adventures|trail.png";

}

void pickerFamiliar(familiar myfam, item famitem, boolean isFed) {

	int [item] allmystuff = get_inventory();
	string [item] addeditems;
	buffer picker;

	item [int] generic;
	//Mr. Store Familiar Equipment
	generic[1]=$item[moveable feast];
	generic[2]=$item[little box of fireworks];
	generic[3]=$item[plastic pumpkin bucket];
	generic[4]=$item[lucky tam o'shanter];
	generic[5]=$item[lucky tam o'shatner];
	generic[6]=$item[mayflower bouquet];
	generic[7]=$item[miniature gravy-covered maypole];
	generic[8]=$item[wax lips];
	generic[9]=$item[tiny costume wardrobe];
	generic[10]=$item[snow suit];

	//Mr. Store Foldables
	generic[100]=$item[flaming familiar doppelg&auml;nger];	//flaming familiar doppelgÃ¤nger
	generic[101]=$item[origami &quot;gentlemen's&quot; magazine];	//origami "gentlemen's" magazine
	generic[102]=$item[Loathing Legion helicopter];
	
	//Special items
	generic[200]=$item[ittah bittah hookah];	
	generic[201]=$item[li'l businessman kit];
	generic[202]=$item[little bitty bathysphere];
	generic[203]=$item[das boot];
	
	//Summonable
	generic[300]=$item[sugar shield];
	
	string fam_equip(item famitem) {
		string ave(string l, string h) {
			float m = (to_int(l) + to_int(h)) / 2.0;
			if(m == to_int(m))
				return to_string(m, "%,.0f");
			return to_string(m, "%,.1f");
		}
		string eval(string mod) {
			float m = modifier_eval(mod);
			if(m == to_int(m))
				return to_string(m, "%+,.0f");
			return to_string(m, "%+,.1f");
		}
		
		switch(famitem) {
		case $item[none]:
			return "";
		case $item[bag of many confections]:
			return "Yummy Candy!";
		case $item[Loathing Legion helicopter]:
			return "Familiar acts more often";
		case $item[tiny costume wardrobe]:
			if(my_familiar() == $familiar[doppelshifter])
				return "Familiar Weight +25";
			return "Doppelshifter";
		case $item[bugged balaclava]:
			return "Volleyball, ML +20";
		case $item[bugged b&Atilde;&para;n&plusmn;&Atilde;&copy;t]:
			return "Fairy: Food, Pants, Candy +5%";
		case $item[fixed-gear bicycle]:
			return "+3 stats per fight";
		case $item[chiptune guitar]:
			return "+25% Item Drops";
		case $item[ironic moustache]:
			return "Weight: +10";
		case $item[school spirit socket set]:
			return "Keeps more steam in";
		case $item[flask of embalming fluid]:
			return "Helps collect body parts";
		case $item[tiny bowler]:
			return "Lets your familiar bowl";
		}
		
		if(famitem != $item[none]) {
			string mod = parseMods(to_string(famitem)); # string_modifier(to_string(famitem), "Evaluated Modifiers");
			// Effects for Scarecrow and Hatrack
			matcher m = create_matcher('Fam Effect: "(.*?), Cap ([^"]+)"', mod);
			if(find(m))
				return replace_string(m.group(1), "x", "x ");
			// farming implements from swarm of fire ants
			m  = create_matcher('"(.*? Dmg, Meat)", Meat Bonus ', mod);
			if(find(m))
				mod = mod.replace_string(m.group(0), m.group(1)+" Bonus ");
			// Remove boring stuff
			mod = mod.replace_string(' "Adventure Underwater"', ", Underwater");
			mod = create_matcher(',? *(Generic|Softcore Only|Fam Weight \\+5| *\\(Fam\\)|Equips On: "[^"]+"|Fam Effect:|Underwater Fam|")', mod).replace_all("");
			// Remove comma abandoned at the beginning
			mod = create_matcher('^ *, *', mod).replace_first("");
			// Last touch ups
			mod = mod.replace_string("Fam Weight", "Weight");
			if(famitem == $item[Snow Suit] && equipped_item($slot[familiar]) != $item[Snow Suit])
				mod += (length(mod) == 0? "(": " (") + get_property("_carrotNoseDrops")+"/3 carrots)";
			if(length(mod) > 1)
				return mod;
		}
		return "";
	}
	string fam_equip(string action, item famitem) {
		switch(famitem) {
		case $item[Loathing Legion helicopter]:
			action = action.replace_string(to_string(famitem), "Legion Helicopter");
			break;
		}
		string mod = fam_equip(famitem);
		if(mod == "") return action;
		return action + "<br /><span class='efmods'>" + mod + "<span>";
	}

	void addEquipment(item it, string cmd) {
		if (!(addeditems contains it)) {
			string hover;
			string cli;
			string action = to_string(it);
			switch (cmd) {
				case "remove":
					hover = "Unequip " + it.to_string();
					action = "Remove equipment";
					cli = "remove familiar";
					break;
				case "inventory":
					hover = "Equip " + it.to_string();
					cli = "equip familiar "+it;
					break;
				case "fold":
					hover = "Fold and equip " + it.to_string();
					cli = "fold "+it+";equip familiar "+it;
					break;
				case "make":
					hover = "Make and equip " + it.to_string();
					cli = "make "+it+";equip familiar "+it;
					break;
				case "retrieve":
					hover = "Retrieve and equip " + it.to_string();
					cli = "equip familiar "+it;
					break;
				case "clancy":
					hover = "Eequip Clancy with his " + it.to_string();
					cli = "use "+it;
					break;
				default:	
					hover = "Equip " + it.to_string();
					cli = "equip familiar "+it;
			}
			picker.append('<tr class="pickitem">');
			picker.append('<td class="' + cmd + '"><a class="change" href="' + sideCommand(cli) + '" title="' 
			  + hover + '">' + fam_equip(action, it) + '</a></td>');
			picker.append('<td class="icon"><a class="change" href="' + sideCommand(cli) + '" title="' 
			  + hover + '"><img src="/images/itemimages/' + it.image + '"></a></td>');
			picker.append('</tr>');
			addeditems[it] = to_string(it);
		}
	}

	string sadMessage(string it, string fam) {
		string famname = my_path() == "Avatar of Boris"? "Clancy": myfam.name;
		return "You don't have any "+it+" for your " + fam + ".<br><br>Poor "+famname;
	}
	
	void pickEquipment() {

		// First add a decorate link if you are using a Snow Suit
		if(equipped_item($slot[familiar]) == $item[Snow Suit]) {
			string suiturl = '<a target=mainpane class="change" href="inventory.php?pwd='+my_hash()+'&action=decorate" title="Decorate your Snow Suit\'s face">';
			int faceIndex = index_of(chitSource["familiar"], "itemimages/snow");
			string face = substring(chitSource["familiar"], faceIndex + 11, faceIndex + 24);
			picker.append('<tr class="pickitem">');
			picker.append('<td class="fold">' +suiturl+ 'Decorate Snow Suit<br /><span style="color:#707070">Choose a Face</span></a></td>');
			picker.append('<td class="icon">'+suiturl+'<img src="/images/itemimages/' + face + '"></a></td>');
			picker.append('</tr>');
		}
	
		//Most common equipment for current familiar
		item common = familiar_equipment(myfam);
		boolean havecommon = false;
		if (allmystuff contains common) {
			havecommon = true;
		} else {
			foreach foldable in get_related(common, "fold") {
				if ( allmystuff contains foldable) {
					common = foldable;
					havecommon = true;
					break;
				}
			}
		}
		if (havecommon) {
			addEquipment(common, "inventory");
			foreach foldable in get_related(common, "fold") {
				addEquipment(foldable, "fold");
			}
		}
		
		//Generic equipment
		foreach n, piece in generic {
			if (allmystuff contains piece) {
				addEquipment(piece, "inventory");
			} else if (available_amount(piece) > 0 ) {
				addEquipment(piece, "retrieve");
			} else if (n==100 || n==101 || n==102) {
				foreach foldable in get_related(piece, "fold") {
					if (available_amount(foldable) > 0 ) {
						addEquipment(piece, "fold");
						break;
					}
				}
			}
		}

		//Make Sugar Shield
		item shield = $item[sugar shield];
		if (!(addeditems contains shield)) {
			item sheet = $item[sugar sheet];
			if (allmystuff contains sheet) {
				addEquipment(shield, "make");
			}
		}
			
		//Check rest of inventory
		foreach thing in allmystuff {
			if ( (item_type(thing) == "familiar equipment") && (can_equip(thing))) {
				addEquipment(thing, "inventory");
			}
		}
	}

	void pickSlot(string slottype) {
		string pref = vars["chit.familiar."+slottype];
		if (pref != "") {
			string [int] equipmap = split_string(pref, ",");
			item equip;
			foreach i in equipmap {
				equip = to_item(equipmap[i]);
				if ( allmystuff contains equip) {
					addEquipment(equip, "inventory");
				} else if ( available_amount(equip) > 0 ) {
					addEquipment(equip, "retrieve");
				} else {
					foreach foldable in get_related(equip, "fold") {
						if ( allmystuff contains foldable) {
							addEquipment(equip, "fold");
						}
					}
				}
			}
		}
	}
	
	void pickClancy() {
		foreach instrument in $items[Clancy's sackbut,Clancy's crumhorn,Clancy's lute]
			if(allmystuff contains instrument)
				addEquipment(instrument, "clancy");
	}
	
	void pickChameleon() {
		string mods;
		//Scan inventory
		foreach thing in allmystuff {
			if(item_type(thing) == "familiar equipment") {
				mods = string_modifier(thing, "modifiers");
				if(!contains_text(mods, "Generic") && !contains_text(mods, "pet rock"))
					addEquipment(thing, "inventory");
			}
		}
	}
	
	picker.pickerStart("fam", "Equip Thy Familiar Well");
	
	//Feeding time
	string [familiar] feedme;
	feedme[$familiar[Slimeling]] = "Mass Slime";
	feedme[$familiar[Stocking Mimic]] = "Give lots of candy";
	feedme[$familiar[Spirit Hobo]] = "Encourage Chugging";
	feedme[$familiar[Gluttonous Green Ghost]] = "Force Feed";
	if (feedme contains myfam) {
		picker.append('<tr class="pickitem"><td class="action" colspan="2"><a class="done" target="mainpane" href="familiarbinger.php">' + feedme[myfam] + '</a></tr>');
	}

	// Use link for Moveable Feast
	if (myfam != $familiar[Comma Chameleon]) {
		item feast = $item[moveable feast];
		if(available_amount(feast) > 0) {
			if (isFed) {
				//currently fed
				picker.append('<tr class="picknone">');
				picker.append('<td class="info" colspan="2">Your familiar is overfed</td>');
				picker.append('</tr>');
			} else if (get_property("_feastedFamiliars").contains_text(to_string(myfam))) {
				//previously fed
				picker.append('<tr class="picknone">');
				picker.append('<td class="info" colspan="2">Your familiar has feasted today</td>');
				picker.append('</tr>');
			} else if (get_property("_feastUsed") == "5") {
				//no feast remaining
				picker.append('<tr class="picknone">');
				picker.append('<td class="info" colspan="2">Feast used 5 times today</td>');
				picker.append('</tr>');
			} else if (famitem == feast) {
				picker.append('<tr class="pickitem">');
				picker.append('<td class="action" colspan="2"><a class="change" href="');
				picker.append(sideCommand("remove familiar;use moveable feast;equip familiar moveable feast"));
				picker.append('">Use Moveable Feast</a></td>');
				picker.append('</tr>');
			} else if (available_amount(feast) > 0) {
				picker.append('<tr class="pickitem">');
				picker.append('<td class="action" colspan="2"><a class="change" href="');
				picker.append(sideCommand("use moveable feast"));
				picker.append('">Use Moveable Feast</a></td>');
				picker.append('</tr>');
			}
		}
	}

	//Bugged Bugbear (Get free equipment from Arena)
	if(myfam == $familiar[Baby Bugged Bugbear] && (available_amount($item[bugged beanie]) + available_amount($item[bugged balaclava]) + available_amount($item[bugged b&Atilde;&para;n&plusmn;&Atilde;&copy;t])) == 0)
		picker.append('<tr class="pickitem"><td class="action" colspan="2"><a class="done" target="mainpane" href="arena.php">Visit the Arena</a></tr>');

	//Handle Current Equipment
	if (famitem != $item[none]) {
		addEquipment(famitem, "remove");
		foreach foldable in get_related(famitem, "fold") {
			if ( (item_type(foldable) == "familiar equipment") && (can_equip(foldable))) {
				addEquipment(foldable, "fold");
			}
		}
	}
	
	switch (myfam) {
		case $familiar[Mad Hatrack]:
			picker.addLoader("Changing Hats...");
			pickSlot("hats");
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("hats", myfam));
			break;
		case $familiar[Fancypants Scarecrow]:
			picker.addLoader("Changing Pants...");
			pickSlot("pants");
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("pants", myfam));
			break;
		case $familiar[disembodied hand]:
			picker.addLoader("Changing Weapons...");
			pickSlot("weapons");
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("weapons", myfam));
			break;
		case $familiar[comma chameleon]:
			picker.addLoader("Changing Equipment...");
			pickChameleon();
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("equipment", myfam));
			break;
		case $familiar[none]:
			if(my_path() == "Avatar of Boris") {
				picker.addLoader("Changing Instrument...");
				pickClancy();
				if(item_amount($item[Clancy's lute]) + item_amount($item[Clancy's crumhorn]) == 0)
					picker.addSadFace("Clancy only has a sackbut to play with.<br><br>Poor Clancy.");
			}
			break;
		default:
			picker.addLoader("Changing Equipment...");
			pickEquipment();
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("equipment", myfam));
	}
	picker.append('</table></div>');

	chitPickers["equipment"] = picker;
		
}

void pickerCompanion(string famname, string famtype) {

	item [skill] companion;
		companion [$skill[Egg Man]] = $item[cosmic egg];
		companion [$skill[Radish Horse]] = $item[cosmic vegetable];
		companion [$skill[Hippotatomous]] = $item[cosmic potato];
		companion [$skill[Cream Puff]] = $item[cosmic Cream];
	
	string companionImg(skill s) {
		switch(s) {
		case $skill[Egg Man]: return "jarl_eggman";
		case $skill[Radish Horse]: return "jarl_horse";
		case $skill[Hippotatomous]: return "jarl_hippo";
		case $skill[Cream Puff]: return "jarl_creampuff";
		}
		return "blank";
	}
	
	// Made this function because Eggman is one word. This seemed the easiest solution.
	string to_companion(skill s) {
		switch(s) {
		case $skill[Egg Man]: return "the Eggman";
		case $skill[Radish Horse]: return "the Radish Horse";
		case $skill[Hippotatomous]: return "the Hippotatomous";
		case $skill[Cream Puff]: return "the Cream Puff";
		}
		return "";
	}
	
	void addCompanion(buffer result, skill s, boolean gotfood) {
		string hover = "Play with " + s +"<br />";
		if(gotfood)
			hover += "<span style='color:#707070'>Costs "+mp_cost(s)+" mp and <br />1 "+companion[s]+" (have "+item_amount(companion[s])+")";
		else
			hover += "<span style='color:#FF2B2B'>Need "+companion[s];
		hover +="</span>";
		string url = sideCommand("cast " + s);
		result.append('<tr class="pickitem">');
		if(gotfood) {
			result.append('<td class="inventory"><a class="change" href="' + url + '" title="Play with ' + s + '">' + hover + '</a></td>');
			result.append('<td class="icon"><a class="change" href="' + url + '" title="Play with ' + s + '"><img src="/images/itemimages/' + companionImg(s) + '.gif"></a></td>');
		} else {
			result.append('<td class="remove">' + hover + '</td>');
			result.append('<td class="icon"><img src="/images/itemimages/' + companionImg(s) + '.gif"></td>');
		}
		result.append('</tr>');
	}

	buffer picker;
	picker.pickerStart("fam", "Summon thy Companion");
	
	// Check for all companions
	picker.addLoader("Summoning Companion...");
	boolean sad = true;
	foreach s, i in companion
		if(have_skill(s) && (length(famtype) < 4 || substring(famtype, 4).to_skill() != s)) {  // Remove "the " from famtype before converting
			picker.addCompanion(s, available_amount(i) > 0);
			sad = false;
		}
	if(sad) {
		if(famname == "")
			picker.addSadFace("You haven't yet learned how to play with your food.<br /><br />How sad.");
		else
			picker.addSadFace("Poor "+famname+" has no other food to play with.");
	}
	
	picker.append('</table></div>');
	chitPickers["equipment"] = picker;
}

static { string [thrall] [int] pasta;
	pasta[$thrall[Vampieroghi]][1] = "Attacks and heals";
	pasta[$thrall[Vampieroghi]][5] = "Dispels bad effects";
	pasta[$thrall[Vampieroghi]][10] = "+60 max HP";
	pasta[$thrall[Vermincelli]][1] = "Attacks to restore MP";
	pasta[$thrall[Vermincelli]][5] = "Attacks enemy";
	pasta[$thrall[Vermincelli]][10] = "+30 max MP";
	pasta[$thrall[Angel Hair Wisp]][1] = "Combat Initiative";
	pasta[$thrall[Angel Hair Wisp]][5] = "Prevents enemy crits";
	pasta[$thrall[Angel Hair Wisp]][10] = "Blocks enemy attacks";
	pasta[$thrall[Elbow Macaroni]][1] = "Muscle matches Myst";
	pasta[$thrall[Elbow Macaroni]][5] = "+ Weapon damage";
	pasta[$thrall[Elbow Macaroni]][10] = "+10% Critical hits";
	pasta[$thrall[Penne Dreadful]][1] = "Moxie matches Myst";
	pasta[$thrall[Penne Dreadful]][5] = "Delevels enemy";
	pasta[$thrall[Penne Dreadful]][10] = "Damage Reduction: 10";
	pasta[$thrall[Spaghetti Elemental]][1] = "Increases exp";
	pasta[$thrall[Spaghetti Elemental]][5] = "Blocks first attack";
	pasta[$thrall[Spaghetti Elemental]][10] = "Spell damage +5";
	pasta[$thrall[Lasagmbie]][1] = "Increase meat drops";
	pasta[$thrall[Lasagmbie]][5] = "Attacks with Spooky";
	pasta[$thrall[Lasagmbie]][10] = "Spooky spells +10";
	pasta[$thrall[Spice Ghost]][1] = "Increases item drops";
	pasta[$thrall[Spice Ghost]][5] = "Drops spices";
	pasta[$thrall[Spice Ghost]][10] = "Better Entangling";
}

void pickerThrall() {

	thrall [int] binds;
	foreach s in $thralls[]
		binds[count(binds)] = s;
	sort binds by mp_cost(value.skill);

	string color(skill s) {
		if(my_mp() >= mp_cost(s)) return "inventory"; 	// Green
		if(my_maxmp() >= mp_cost(s)) return "make";		// Orange
		return "remove";								// Red
	}
	
	void addThrall(buffer result, thrall t) {
		skill s = t.skill;
		buffer url;
		if(t.level == 0) { // If this is a first time summmons, I want to see it in mainpaine!
			url.append('<a target=mainpane class="change" href="skills.php?action=Skillz&whichskill=');
			url.append(to_int(s));
			url.append('&skillform=Use+Skill&quantity=1&pwd=');
			url.append(my_hash());
		} else {
			url.append('<a class="change" href="');
			url.append(sideCommand("cast " + s));
		}
		url.append('" title="');
		url.append(s);
		url.append(' for ');
		url.append(mp_cost(s));
		url.append('mp">');
		
		result.append('<tr class="pickitem"><td class="');
		result.append(color(s));
		result.append('">');
		result.append(url);
		result.append('<b>');
		result.append(t);
		result.append('</b> <span style="float:right;color:#707070">');
		result.append(mp_cost(s));
		result.append('mp</span><br /><span style="color:blue">');
		result.append(pasta[t][1]);
		result.append('</span></a></td><td class="icon">');
		result.append(url);
		result.append('<img src="/images/itemimages/');
		result.append(t.tinyimage);
		result.append('"></a></td></tr>');
	}

	void dismissThrall(buffer result) {
		skill s = $skill[Dismiss Pasta Thrall];
		buffer url;
		url.append('<a class="change" href="');
		url.append(sideCommand("cast Dismiss Pasta Thrall"));
		url.append('" title="Dismiss Pasta Thrall">');
		
		result.append('<tr class="pickitem"><td class="retrieve">');
		result.append(url);
		result.append('<b>Dismiss ');
		result.append(my_thrall());
		result.append('</b><br /><span style="color:blue">Goodbye, ');
		result.append(my_thrall().name);
		result.append('</span></a></td><td class="icon">');
		result.append(url);
		result.append('<img src="/images/itemimages/');
		result.append(my_thrall().tinyimage);
		result.append('"></a></td></tr>');
	}

	buffer picker;
	picker.pickerStart("thrall", "Bind thy Thrall");
	
	// Check for all thralls
	picker.addLoader("Binding Thrall...");
	boolean sad = true;
	foreach x,t in binds
		if(have_skill(t.skill) && t != my_thrall()) {
			picker.addThrall(t);
			sad = false;
		}
	if(my_thrall() != $thrall[none])
		picker.dismissThrall();
	if(sad) {
		if(my_thrall() == $thrall[none])
			picker.addSadFace("You haven't yet learned how to summon Thralls.<br /><br />How sad.");
		else
			picker.addSadFace("Poor "+my_thrall().name+" has no other thralls to play with.");
	}
	
	picker.append('</table></div>');
	chitPickers["thrall"] = picker;
}

void FamBoris() {
	string famimage, equiptype, equipimage, clancyLink, famweight;
	string source = chitSource["familiar"];
	matcher level = create_matcher("Level <b>(.*?)</b> Minstrel", source);
	if(find(level)) famweight = level.group(1).to_int();
	matcher image = create_matcher("(otherimages/.*?) width=60", source);
	if(find(image)) famimage = image.group(1);

	// Does Clancy want attention?
	matcher att = create_matcher("Minstrel</font><br><a target=mainpane href=(.*?)>", source);
	if(find(att)) clancyLink = att.group(1);
	
	// What is Clancy equipped with?
	if(famimage.contains_text("_1"))
		equiptype = "Clancy's sackbut";
	else if(famimage.contains_text("_2"))
		equiptype = "Clancy's crumhorn";
	else if(famimage.contains_text("_3"))
		equiptype = "Clancy's lute";
	equipimage = equiptype.to_item().image;
	
	string info = '<br><span style="color:#606060;font-weight:normal">Level ' + famweight + ' Minstrel';
	switch(equiptype) {
	case "Clancy's sackbut": info += "<br><br>Restore HP/MP</span>"; break;
	case "Clancy's crumhorn": info += "<br><br>Increase Exp</span>"; break;
	case "Clancy's lute": info += "<br><br>Phat Loot!</span>"; break;
	}
	
	
	//Finally start some output
	buffer result;
	result.append('<table id="chit_familiar" class="chit_brick nospace">');
	
	result.append('</tr><tr>');
	result.append('<td class="clancy" title="Your Faithful Minstrel">');
	#result.append('<img src="/images/' + famimage + '" width=50 height=100 border=0>');
	if(clancyLink != "")
		result.append('<a target=mainpane href="'+clancyLink+'" class="familiarpick">');
	result.append('<img src="/images/' + famimage + '">');
	if(clancyLink != "")
		result.append('</a>');
	result.append('</td>');
	result.append('<td class="info">Clancy');
	result.append(info);
	result.append('</td>');
	result.append('<td class="icon" title="');
	result.append(equiptype);
	result.append('">');
	result.append('<a class="chit_launcher" rel="chit_pickerfam" href="#">');
	result.append('<img src="/images/itemimages/' );
	result.append(equipimage);
	result.append('">');
	result.append('</a></td>');
	result.append('</tr>');
	
	result.append('</table>');
	chitBricks["familiar"] = result;

	//Add Equipment Picker
	pickerFamiliar($familiar[none], familiar_equipped_equipment(my_familiar()), false);
}

# <font size=2><b>Companion:</b><br><img src=http://images.kingdomofloathing.com/adventureimages/jarlcomp3.gif width=100 height=100><br><b>Ella</b><br>the Hippotatomous</font><br><font color=blue size=2><b>+3 Stats per Combat</b></font>
# <font size=2><b>Companion:</b><br>(none)
void FamJarlsberg() {
	string famimage, famname, famtype, actortype, equiptype;
	matcher companion = create_matcher('images/(.*?\\.gif).*?<b>([^<]*)</b><br>([^<]*).*?<br>(.*?font>)', chitSource["familiar"]);
	if(find(companion)) {
		famimage = companion.group(1);
		famname = companion.group(2);
		famtype = companion.group(3);
		actortype = famname+', '+famtype;
		equiptype = companion.group(4);
	} else {
		famimage = "blank.gif";
		famname = "";
		famtype = "";
		actortype = "(No Companion)";
		equiptype = "<font color=blue size=2><b>Click to Summon a Companion</b></font>";
	}
	buffer result;
	result.append('<table id="chit_familiar" class="chit_brick nospace">');
	result.append('<tr><th colspan="2" title="Companion">');
	result.append(actortype);
	result.append('</th></tr>');
	
	result.append('<tr><td class="companion" title="Playing with this food">');
	result.append('<a class="chit_launcher" rel="chit_pickerfam" href="#">');
	result.append('<img src="images/adventureimages/' );
	result.append(famimage);
	result.append('"></a></td>');
	result.append('<td class="info"><a class="chit_launcher" rel="chit_pickerfam" href="#">');
	result.append(equiptype);
	result.append('</a></td>');
	result.append('</tr></table>');
	
	chitBricks["familiar"] = result;

	//Add Companion Picker
	pickerCompanion(famname, famtype);
}

# <a target=mainpane href=main.php?action=motorcycle><img src=/images/adventureimages/bigbike.gif width=100 height=100 border=0 alt="Hermes the Motorcycle" title="Hermes the Motorcycle"></a><br> <b>Hermes</b>
void FamPete() {
	string peteMotorbike(string part) {
		string pref = get_property("peteMotorbike"+part.replace_string(" ", ""));
		if(pref == "") return "(factory standard)";
		return pref;
	}
	string famlink, famimage, famname;
	matcher motorcycle = create_matcher('(<[^>]+>).*?adventureimages/([^ ]+).*?<b>(.+?)</b>', chitSource["familiar"]);
	if(find(motorcycle)) {
		famlink = motorcycle.group(1);
		famimage = motorcycle.group(2);
		famname = motorcycle.group(3);
	} else {
		famlink = "main.php";
		famimage = "blank.gif";
		famname = "No Motorcycle?";
	}
	buffer result;
	result.append('<table id="chit_familiar" class="chit_brick nospace">');
	result.append('<tr><th colspan="2" title="Motorcycle">');
	result.append(famname);
	result.append('</th></tr>');
	result.append('<tr><td class="motorcycle" title="');
	foreach pref in $strings[Tires, Gas Tank, Headlight, Cowling, Muffler, Seat] {
		result.append(pref);
		result.append(': ');
		result.append(peteMotorbike(pref));
		if(pref != "Seat") result.append('\n');
	}
	result.append('" style="overflow:hidden;">');
	result.append(famlink);
	result.append('<img src="images/adventureimages/');
	result.append(famimage);
	result.append('"></a></td>');
	result.append('</tr></table>');
	
	chitBricks["familiar"] = result;
}
		
void bakeFamiliar() {

	// Special Challenge Path Familiar-ish things
	switch(my_path()) {
	case "Avatar of Boris": FamBoris(); return;
	case "Avatar of Jarlsberg": FamJarlsberg(); return;
	case "Avatar of Sneaky Pete": FamPete(); return;
	}

	string source = chitSource["familiar"];

	string famname = "Familiar";
	string famtype = '<a target=mainpane href="familiar.php" class="familiarpick">(None)</a>';
	string famimage = "/images/itemimages/blank.gif";
	string equipimage = "blank.gif";
	string equiptype, actortype, famweight, info, famstyle, charges, chargeTitle;
	boolean isFed = false;
	string weight_title = "Buffed Weight";
	
	familiar myfam = my_familiar();
	item famitem = $item[none];

	if(myfam != $familiar[none]) {
		famtype = to_string(myfam);
		actortype = famtype;
		// Set Familiar image
		switch(myfam) {
			case $familiar[Fancypants Scarecrow]:
				famimage = "/images/itemimages/pantscrow2.gif";
				famtype = "Fancy Scarecrow"; // Name is too long when there's info added
				break;
			case $familiar[Disembodied Hand]:
				famimage = "/images/itemimages/dishand.gif";
				break;
			case $familiar[Mad Hatrack]:
				famimage = "/images/itemimages/hatrack.gif";
				break;
			case $familiar[Happy Medium]:
				switch(myfam.image) {
				case "medium_0.gif":
					famimage = '/images/itemimages/medium_0.gif';
					break;
				case "medium_1.gif":
					famimage = imagePath+'medium_blue.gif';
					break;
				case "medium_2.gif":
					famimage = imagePath+'medium_orange.gif';
					break;
				case "medium_3.gif":
					famimage = imagePath+'medium_red.gif';
					break;
				}
				break;
			default:
				famimage = '/images/itemimages/'+ myfam.image;
		}
	}
	
	//Get Familiar Name
	matcher nameMatcher = create_matcher("<b><font size=2>(.*?)</a></b>, the", source);
	if (find(nameMatcher)){
		famname = group(nameMatcher, 1);
	}
	
	//Drops
	matcher dropMatcher = create_matcher("<b>Familiar:</b>\\s*(\?:<br>)?\\s*\\((.*?)\\)</font>", source);
	if (find(dropMatcher)){
		info = group(dropMatcher, 1).replace_string("<br>", ", ");
		switch ( myfam ) {
			case $familiar[frumious bandersnatch]:
				info = "Runaways: " + info;
				break;
			case $familiar[rogue program]:
				info = "Tokens: " + info;
				break;
			case $familiar[green pixie]:
				info = "Absinthe: " + info;
				break;
			case $familiar[baby sandworm]:
				info = "Agua: " + info;
				break;
			case $familiar[llama lama]:
				info = "Gongs: " + info;
				break;
			case $familiar[astral badger]:
				info = "Shrooms: " + info;
				break;
			case $familiar[Mini-Hipster]:
				info = "Fights: " + info;
				break;
			case $familiar[Bloovian Groose]:
				info = "Grease: " + info;
				break;
			case $familiar[blavious kloop]:
				info = "Folio: " + info;
				break;
			case $familiar[Steam-Powered Cheerleader]:
				// Truncate the decimal
				info = replace_first(create_matcher("\\.\\d", info), "");
				break;
			default:
		}
	}

	// Show Reanimator parts
	if(myfam == $familiar[Reanimated Reanimator])
		foreach l in $strings[Arm, Leg, Skull, Wing, WeirdPart] {
			string prop = get_property("reanimator"+l+"s");
			if(prop != "0")
				info += (length(info) == 0? "": ", ") + prop + " "+ l +(prop == "1"? "": "s");
		}

	//Get Familiar Weight
	matcher weightMatcher = create_matcher("</a></b>, the (<i>extremely</i> well-fed)? <b>(.*?)</b> pound ", source);
	if (find(weightMatcher)) {
		isFed = weightMatcher.group(1) != "";
		famweight = weightMatcher.group(2);
	} else if (myfam != $familiar[none]) {
		famweight = to_string(familiar_weight(myfam) + weight_adjustment());
	}

	//Get equipment info
	if(myfam == $familiar[Comma Chameleon]) {
		famitem = $item[none];
		equiptype = to_string(famitem);
		matcher actorMatcher = create_matcher("</b\> pound (.*?),", source);
		if (find(actorMatcher)) {
			actortype = group(actorMatcher, 1);
			equipimage = to_familiar(actortype).image;
			info = actortype;
		}
	} else {
		famitem = familiar_equipped_equipment(my_familiar());
		if (famitem != $item[none]) {
			equiptype = to_string(famitem);
			// If using snow suit, find the current face & add carrot drop info
			if(famitem == $item[Snow Suit]) {
				int snowface = index_of(source, "itemimages/snow");
				equipimage = substring(source, snowface + 11, snowface + 24);
				info += (length(info) == 0? "": ", ") + get_property("_carrotNoseDrops")+"/3 carrots";
			} else
				equipimage = famitem.image;
		}
	}

	// Get Hatrack & Scarecrow info
	if(myfam == $familiar[Mad Hatrack] || myfam == $familiar[Fancypants Scarecrow]) {
		if(famitem != $item[none]) {
			matcher m = create_matcher('Familiar Effect: \\"(.*?), cap (.*?)\\"', string_modifier(famitem, "Modifiers"));
			if(find(m)) {
				info = replace_string(m.group(1), "x", " x ");
				if(group_count(m) > 1 ) {
					famweight = famweight + " / " + m.group(2);
					weight_title = "Buffed/Max Weight";
				}
			} else info = "Unknown effect";
		} else info = "None";
	} else if(myfam == $familiar[Reanimated Reanimator]) {
		famname += ' (<a target=mainpane href="main.php?talktoreanimator=1">chat</a>)';
	} else if(myfam == $familiar[Grim Brother] && source.contains_text("talk</a>)")) {
		famname += ' (<a target=mainpane href="familiar.php?action=chatgrim&pwd='+my_hash()+'">talk</a>)';
	}
	
	// Charges
	if (famitem == $item[sugar shield]) {
		charges = to_string( 31 - to_int(get_property("sugarCounter4183")));
		chargeTitle = "Charges remaining";
	} else 	if (famitem == $item[sugar chapeau]) {
		charges = to_string( 31 - to_int(get_property("sugarCounter4181")));
		chargeTitle = "Charges remaining";
	} else 	if (famitem == $item[moveable feast]) {
		charges = get_property("_feastUsed") + " / 5";
		chargeTitle = "Familiars Feasted";
	} else 	if ( (myfam == $familiar[Pair of Stomping Boots]) && (get_property("bootsCharged") == "true") ) {
		charges = "GO";
		chargeTitle = "Your Boots are charged and ready for some stomping";
	}
		
	string hover = "Visit your terrarium";	

	//Extra goodies for 100% runs
	boolean protect = false;
	if (to_familiar(vars["is_100_run"]) != $familiar[none]) {
		if (myfam == to_familiar(vars["is_100_run"])) {
			famstyle = famstyle + "color:green;";
			if (vars["chit.familiar.protect"] == "true") {
				hover = "Don't ruin your 100% run!";
				protect = true;
			}
		} else {
			famstyle = famstyle + "color:red;";
		}
	}
	
	//Add final touches to additional info
	if (info != "") {
		info = '<br><span style="color:#606060;font-weight:normal">(' + info + ')</span>';
	}
	
	//Finally start some output
	buffer result;
	result.append('<table id="chit_familiar" class="chit_brick nospace">');
	if (isFed) {
		result.append('<tr class="wellfed">');
	} else {
		result.append('<tr>');
	}	
	result.append('<th width="40" title="'+ weight_title +'" style="color:blue">' + famweight + '</th>');
	
	if (protect) {
		result.append('<th title="' + hover + '">' + famname + '</th>');
	} else {
		result.append('<th><a target=mainpane href="familiar.php" class="familiarpick" title="' + hover + '">' + famname + '</a></th>');
	}
	if (charges == "") {
		result.append('<th width="30">&nbsp;</th>');
	} else {
		result.append('<th width="30" title="' + chargeTitle + '">' + charges + '</th>');
	}
	result.append('</tr><tr>');
	result.append('<td class="icon" title="' + hover + '">');
	if (protect) {
		result.append('<img src="' + famimage + '">');
	} else {
		result.append('<a target=mainpane href="familiar.php" class="familiarpick">');
		result.append('<img src="' + famimage + '">');
		result.append('</a>');
	}
	result.append('</td>');
	result.append('<td class="info" style="' + famstyle + '"><a title="Familiar Haiku" class="hand" onclick="fam(' + to_int(myfam) + ')" origin-level="third-party"/>' + famtype + '</a>' + info + '</td>');
	if (myfam == $familiar[none]) {
		result.append('<td class="icon">');
		result.append('</td>');
	} else {
		if (equiptype == "") {
			result.append('<td class="icon" title="Equip your familiar">');
		} else {
			result.append('<td class="icon">');
		}
		boolean lockable = string_modifier(famitem, "Modifiers").contains_text("Generic") && vars["chit.familiar.showlock"].to_boolean();
		if(lockable)
			result.append('<div id="fam_equip">');
		result.append('<a class="chit_launcher" rel="chit_pickerfam" href="#">');
		result.append('<img title="' + equiptype + '" src="/images/itemimages/' + equipimage + '">');
		if(lockable) {
			result.append('<a href="' + sideCommand("ashq lock_familiar_equipment("+ (!is_familiar_equipment_locked()) +")")  +'"><img title="Equipment ');
			if(is_familiar_equipment_locked())
				result.append('Locked" id="fam_lock" src="/images/itemimages/padlock.gif"></a>');
			else
				result.append('Unlocked" id="fam_lock" src="/images/itemimages/openpadlock.gif"></a>');
		}
		result.append('</a>');
		if(lockable)
			result.append('</div>');
		result.append('</td>');
	}
	result.append('</tr>');
	
	//Add Progress bar if we have one
	matcher progMatcher = create_matcher("<table title='(.*?)' cellpadding=0", source);
	if (find(progMatcher)) {
		string[1] minmax = split_string(group(progMatcher, 1), " / ");
		int current = to_int(minmax[0]);
		int upper = to_int(minmax[1]);
		float progress = (current * 100.0) / upper;
		result.append('<tr><td colspan="3" class="progress" title="' + current + ' / ' + upper + '" >');
		result.append('<div class="progressbar" style="width:' + progress + '%"></div></td></tr>');
	}
	result.append('</table>');
	chitBricks["familiar"] = result;

	//Add Equipment Picker
	if (myfam != $familiar[none]) {
		pickerFamiliar(myfam, famitem, isFed);
	}
	
}

void bakeThrall() {
	if(my_class() != $class[Pastamancer]) return;
	buffer result;
	void bake(string lvl, string name, string type, string img) {
		result.append('<table id="chit_thrall" class="chit_brick nospace">');
		result.append('<tr><th title="Thrall Level">');
		if(lvl != "")
			result.append('Lvl.&nbsp;');
		result.append(lvl);
		result.append('</th><th colspan="2" title="Pasta Thrall"><a title="');
		result.append(name);
		result.append('" class="hand" onClick=\'javascript:window.open("desc_guardian.php","","height=200,width=300")\'>');
		result.append(type);
		result.append('</a></th></tr>');
		
		result.append('<tr><td class="icon" title="Thrall">');
		result.append('<a class="chit_launcher" rel="chit_pickerthrall" href="#">');
		result.append('<img title="Bind thy Thrall" src=/images/itemimages/');
		result.append(img);
		result.append('></a></td>');
		if(lvl != "") {
			result.append('<td class="info"><a title="Click for Thrall description" class="hand" onClick=\'javascript:window.open("desc_guardian.php","","height=200,width=300")\'><span style="color:blue;font-weight:bold">');
			foreach i,s in pasta[my_thrall()]
				if(my_thrall().level >= i) {
					result.append(s);
					result.append('<br>');
				}
			result.append('</span></a></td>');
		} else {
			result.append('<td class="info"><a class="chit_launcher" rel="chit_pickerthrall" href="#"><span style="color:blue;font-weight:bold">(Click to Summon a Thrall)</span></a></td>');
		}
		result.append('</tr></table>');
	}
	
	if(my_thrall() == $thrall[none])
		bake("", "No Thrall", "No Thrall", "blank.gif");
	else
		bake(my_thrall().level, my_thrall().name, my_thrall(), my_thrall().tinyimage);
	chitBricks["thrall"] = result;
	pickerThrall();
}

string currentMood() {
	matcher pattern = create_matcher(">mood (.*?)</a>", chitSource["mood"]);
	if(find(pattern))
		return group(pattern, 1);
	return "???";
}

void addCurrentMood(buffer result, boolean picker) {
	void addPick(buffer prefix) {
		if(picker)
			prefix.append('<tr class="pickitem"><td class="info"><a class="visit" ');
		prefix.append('<a ');
	}
	string source = chitSource["mood"];
	if(contains_text(source, "save+as+mood")) {
		result.addPick();
		result.append('title="Save as Mood" href="' + sideCommand("save as mood") + '">');
		result.append('<img src="' + imagePath + 'moodsave.png">');
		if(picker) result.append(' Save as Mood');
		result.append('</a>');
	} else if(contains_text(source, "mood+execute")) {
		string moodname = currentMood();
		result.addPick();
		result.append('title="Execute Mood: ' + moodname + '" href="' + sideCommand("mood execute") + '">');
		result.append('<img src="' + imagePath + 'moodplay.png">');
		if(picker) result.append(" "+moodname);
		result.append('</a>');
	} else if(contains_text(source, "burn+extra+mp")) {
		result.addPick();
		result.append('title="Burn extra MP" href="' + sideCommand("burn extra mp") + '">');
		result.append('<img src="' + imagePath + 'moodburn.png">');
		if(picker) result.append(' Burn MP');
		result.append('</a>');
		//[<a title="I'm feeling moody" href="/KoLmafia/sideCommand?cmd=burn+extra+mp&pwd=ea073fd3cf87360cd2316377bd85c92f" style="color:black">burn extra mp</a>]
	} else {
		if(picker) result.append('<tr><td>');
		result.append('<img src="' + imagePath + 'moodnone.png">');
	}
	if(picker)
		result.append('</td></tr>');
}

void pickMood() {
	boolean mood_plus(string full, string mood) {
		if(mood == "apathetic") return false;
		foreach i,m in split_string(full,", ")
			if(m == mood) return false;
		return true;
	}

	buffer picker;
	picker.pickerStart("mood", "Select New Mood");
	picker.addLoader("Getting Moody");
	string moodname = currentMood();
	foreach i,m in get_moods() {
		if(m == "") continue;
		picker.append('<tr class="pickitem"><td class="info"><a title="Make this your current mood" class="visit" href="');
		picker.append(sideCommand("mood "+m));
		picker.append('">');
		picker.append(m);
		picker.append('</a></td><td>');
		if(moodname != "???" && mood_plus(moodname,m)) {
			picker.append('<a title="ADD this to current mood" href="');
			picker.append(sideCommand("mood "+moodname+", "+m));
			picker.append('"><img src="');
			picker.append(imagePath);
			picker.append('control_add_blue.png"><a>');
		} else
			picker.append('&nbsp;');
		picker.append('</td></tr>');
	}
		
	// Add link to execute mood unless it's on the toolbar
	if(vars["chit.toolbar.moods"] != "bonus") {
		picker.append('<tr class="pickitem"><th colspan="2">Current Mood</th></tr>');
		picker.addCurrentMood(true);
	}
	
	picker.append('</table>');
	picker.append('</div>');
	
	chitPickers["mood"] = picker.to_string();
}

void bakeToolbar() {
	buffer toolbar;
	
	void addRefresh(buffer result) {
		result.append('<ul style="float:left"><li><a href="charpane.php" title="Reload"><img src="');
		result.append(imagePath);
		result.append('refresh.png"></a></li></ul>');
	}

	void addMood(buffer result) {
		if(vars["chit.toolbar.moods"] == "false")
			return;

		result.append('<ul style="float:right">');

		// Add button to switch mood
		result.append('<li><a href="#" class="chit_launcher" rel="chit_pickermood" title="Select Mood"><img src="');
		result.append(imagePath);
		result.append('select_mood.png"></a></li>');
		
		// If chit.toolbar.moods == bonus, then add extra mood execution button
		if(vars["chit.toolbar.moods"] == "bonus") {
			result.append('<li>');
			result.addCurrentMood(false);
			result.append('</li>');
		}
		
		result.append('</ul>');
		pickMood();
		
	}
	
	// If disable is first, attach it to the refresh button
	void addDisable(buffer result, int i) {
		buffer button;
		button.append('<li><a href="');
		button.append(sideCommand("zlib chit.disable = true"));
		button.append('" title="Disable ChIT"><img');
		if(i == 0)
			button.append(' style="height:11px;width:11px;vertical-align:bottom;margin:0px -4px -3px -8px;"');
		else
			button.append(' style="vertical-align:bottom;margin-bottom:-3px;"');
		button.append(' src="');
		button.append(imagePath);
		button.append('disable.png"></a></li>');
		int point = i == 0? result.index_of("</ul>"): length(result);
		result.insert(point, button);
	}
	
	void addTools (buffer result) {
		result.append('<ul>');
	
		string layout = vars["chit.toolbar.layout"];
		
		string [int] bricks = split_string(layout,",");
		string brick;
		string [int] toolprops;
		string toolicon;
		string toolhover;
		for i from 0 to (bricks.count()-1) {
			brick = bricks[i];
			if(brick == "disable") {
				result.addDisable(i);
			} else if ((chitTools contains brick) && (chitBricks contains brick)) {
				toolprops = split_string(chitTools[brick],"\\|");
				if (chitBricks[brick] == "") {
					result.append('<li>');
					result.append('<img src="' + imagePath + toolprops[1] + '" title="' + toolprops[0] + '" >');
					result.append('</li>');
				} else {
					result.append('<li><a class="tool_launcher" title="');
					result.append(toolprops[0]);
					result.append('" href="#" rel="');
					result.append(brick);
					result.append('"><img src="');
					result.append(imagePath);
					result.append(toolprops[1]);
					result.append('"></a></li>');				
				}
			}
		}	
		result.append("</ul>");
	}

	toolbar.append('<table id="chit_toolbar"><tr><th>');
	toolbar.addRefresh();
	if (!inValhalla) {
		toolbar.addMood();
		toolbar.addTools();
	}
 	toolbar.append('</th></tr>');
 	toolbar.append('</table>');	
	chitBricks["toolbar"] = toolbar;
}

float init_MLpenalty() {
	float ML = numeric_modifier("Monster Level");
	     if(ML <  21) return 0.0;
	else if(ML <  41) return   (ML - 20);
	else if(ML <  61) return 2*(ML - 40) + 20;
	else if(ML <  81) return 3*(ML - 60) + 60;
	else if(ML < 101) return 4*(ML - 80) + 120;
	return 5*(ML - 100) + 200;
}

string formatExp(string type) {
	float flat = numeric_modifier(type + " Experience");
	float perc = numeric_modifier(type + " Experience Percent");
	string formatFlat() {
		return to_string(flat, "%+.2f");
	}
	if(flat != 0 && perc != 0) return formatFlat() + ', ' + formatModifier(perc, 0);
	if(perc != 0) return formatModifier(perc, 0);
	if(flat != 0) return formatFlat() + "&nbsp;";
	return "+0";
}

string formatDamage(string type) {
	int flat = numeric_modifier(type + " Damage");
	float perc = numeric_modifier(type + " Damage Percent");
	if(flat != 0 && perc != 0) return formatModifier(flat) + ' / ' + formatModifier(perc, 0);
	if(perc != 0) return formatModifier(perc, 0);
	if(flat != 0) return formatModifier(flat) + "&nbsp;";
	return "+0";
}

string forcedDrop(float bonus) {
	if(item_drop_modifier() + bonus <= 0)
		return "--";
	return ceil(100 * (100.0/(100 + item_drop_modifier() +bonus))) + '%';
}

void bakeModifiers() {

	buffer result;
	
	//Heading
	result.append('<table id="chit_modifiers" class="chit_brick nospace">');
	result.append('<thead><tr><th colspan="2"><img src="');
	result.append(imagePath);
	result.append('modifiers.png">');
	result.append('Modifiers</th></tr>');
	result.append('</thead>');

	result.append('<tbody>');
	result.append('<tr>');
	result.append('<td class="label">Meat Drop</td>');
	result.append('<td class="info">' + formatModifier(meat_drop_modifier()) + '</td>');
	result.append('</tr>');
	result.append('<tr>');
	result.append('<td class="label">Item Drop</td>');
	result.append('<td class="info">' + formatModifier(item_drop_modifier()) + '</td>');
	result.append('</tr>');
	foreach drop in $strings[Food Drop, Booze Drop, Hat Drop, Weapon Drop, Offhand Drop, Shirt Drop, Pants Drop,
	  Accessory Drop, Candy Drop] if(numeric_modifier(drop) > 0) {
		result.append('<tr>');
		result.append('<td class="label">&nbsp;&nbsp;&nbsp;&nbsp;' + drop + '</td>');
		result.append('<td class="info">(' + formatModifier(numeric_modifier(drop)) + ')</td>');
		result.append('</tr>');
	}
	result.append('<tr>');
	result.append('<td class="label">&nbsp;&nbsp;Forced Drop @</td>');
	result.append('<td class="info">' + forcedDrop(0) + '</td>');
	result.append('</tr>');
	foreach drop in $strings[Food Drop, Booze Drop, Hat Drop, Weapon Drop, Offhand Drop, Shirt Drop, Pants Drop,
	  Accessory Drop, Candy Drop] if(numeric_modifier(drop) > 0) {
		result.append('<tr>');
		result.append('<td class="label">&nbsp;&nbsp;&nbsp;&nbsp;Forced ' + drop + '</td>');
		result.append('<td class="info">' + forcedDrop(numeric_modifier(drop)) + '</td>');
		result.append('</tr>');
	}
	result.append('</tbody>');

	result.append('<tbody>');
	if(mana_cost_modifier() != 0) {
		result.append('<tr>');
		result.append('<td class="label">MP Cost</td>');
		result.append('<td class="info">' + formatModifier(mana_cost_modifier()) + '</td>');
		result.append('</tr>');
	}
	result.append('<tr>');
	result.append('<td class="label">Monster Level</td>');
	result.append('<td class="info">' + formatModifier(monster_level_adjustment()) + '</td>');
	result.append('</tr>');
/*	result.append('<tr>');
	result.append('<td class="label">'+my_primestat()+' Exp</td>');
	result.append('<td class="info">' + formatExp(my_primestat()) + '</td>');
	result.append('</tr>'); */

	result.append('<tr>');
	result.append('<td class="label">Initiative</td>');
	result.append('<td class="info">' + formatModifier(initiative_modifier(), 0) + '</td>');
	result.append('</tr>');
	result.append('<tr>');
	result.append('<td class="label">Modified Init</td>');
	float MLmod = -init_MLpenalty();
	result.append('<td class="info">' + (MLmod == 0? formatModifier(initiative_modifier(), 0)
		: formatModifier(initiative_modifier() + MLmod, 0))); # +" ("+formatModifier(MLmod, 0)+")") + '</td>');
	result.append('</tr>');
	result.append('<tr>');
	result.append('<td class="label">Combat Rate</td>');
	result.append('<td class="info">' + formatModifier(combat_rate_modifier(), 0) + '</td>');
	result.append('</tr>');
	result.append('</tbody>');

	result.append('<tbody>');
	result.append('<tr>');
	result.append('<td class="label">Damage Absorb</td>');
	result.append('<td class="info">' + to_int(damage_absorption_percent()) 
	  + '%&nbsp;(' + formatInt(raw_damage_absorption()) + ')</td>');
	result.append('</tr>');
	result.append('<tr>');
	result.append('<td class="label">Damage Red</td>');
	result.append('<td class="info">' + formatInt(damage_reduction()) + '</td>');
	result.append('</tr>');
	result.append('</tbody>');

	result.append('<tbody>');
	result.append('<tr>');
	result.append('<td class="label">Spell Damage</td>');
	result.append('<td class="info">' + formatDamage("Spell") + '</td>');
	result.append('</tr>');
	result.append('<tr>');
	result.append('<td class="label">Weapon Damage</td>');
	result.append('<td class="info">' + formatDamage("Weapon") + '</td>');
	result.append('</tr>');
	result.append('<tr>');
	result.append('<td class="label">Ranged Damage</td>');
	result.append('<td class="info">' + formatDamage("Ranged") + '</td>');
	result.append('</tr>');
	result.append('</tbody>');

		
	result.append('</table>');
	chitBricks["modifiers"] = result.to_string();
	
}

void addStat(buffer result, stat s) {
	result.append('<tr>');
	result.append('<td class="label">');
	result.append(s == $stat[mysticality]? "Myst": to_string(s));
	result.append('</td>');
	result.append('<td class="info">' + formatStats(s) + '</td>');
	if(to_boolean(vars["chit.stats.showbars"]))
		result.append('<td class="progress">' + progressSubStats(s) + '</td>');
	result.append('</tr>');
}

string message(string organ, int severity) {
	switch(organ) {
	case "Stomach":
		if(severity == 4)
			return "You're too full to even eat a wafer-thin mint";
		return "Hmmm... pies";	
	case "Liver":
		switch(severity) {
		case 6: return "Sneaky!";
		case 5: return "You are falling-down drunk";
		case 4: return "You can't handle any more booze today";
		case 3: return "You can barely stand up straight...";
		case 2: return "You'd better keep an eye on your drinking...";
		case 1: return "Your drinking is still under control";
		case 0: return "You are stone-cold sober";	
		}
	case "Spleen":
		switch(severity) {
		case -1: return "You're too young to be taking drugs";
		case 4: return "Your spleen can't take any more abuse today";
		case 3:
		case 2: return "Your spleen has taken quite a bit of damage";
		case 1: return "Your spleen is in pretty good shape";	
		case 0: return "Your spleen is in perfect shape!";
		}
	}
	return "";
}

int severity(string organ, int cur, int lim) {
	switch(organ) {
	case "Stomach":
		if(cur == lim)
			return 4;
		return 1;
	case "Liver":
		if(cur > lim + 6)
			return 6;
		else if(cur > lim)
			return 5;
		else if(cur == lim)
			return 4;
		else if(cur > lim * .74) // lim is 4 in at least 2 paths, so...
			return 3;
		else if(cur > lim * .49)
			return 2;
		else if(cur > 0)
			return 1;
		return 0;
	case "Spleen":
		if(my_level() < 4 && available_amount($item[groose grease]) < 1)
			return -1;
		else if(cur == lim)
			return 4;
		else if(cur > lim * .65)
			return 2;
		else if(cur > 0)
			return 1;
		return 0;
	}
	return 0;
}

void addFury(buffer result) {
	void spanWrap(buffer wrap, string stuff, string span) {
		if(span == "")
			wrap.append(stuff);
		else {
			wrap.append(span);
			wrap.append(stuff);
			wrap.append("</span>");
		}
	}
	matcher fury = create_matcher("Fury:.*?<font color[^>]*>(<span[^>]*>)?((\\d+) gal.)", chitSource["stats"]);
	if(fury.find()) {
		result.append('<tr>');
		result.append('<td class="label">');
		result.spanWrap("Fury", fury.group(1));
		result.append('</td><td class="fury">');
		result.spanWrap(fury.group(2), fury.group(1));
		result.append('</td>');
		if(to_boolean(vars["chit.stats.showbars"])) {
			result.append('<td class="progress">');
			result.spanWrap('<div class="progressbox" title="' + my_fury() + ' / ' + my_maxfury() + '"><div class="progressbar" style="width:' + (100.0 * my_fury() / my_maxfury()) + '%"></div></div></td>', fury.group(1));
			result.append('</td>');
		}
		result.append('</tr>');
	}
}

void addSauce(buffer result) {
	result.append('<tr>');
	result.append('<td class="label">Sauce</td><td class="info">');
	result.append(my_soulsauce());
	result.append('</td>');
	if(to_boolean(vars["chit.stats.showbars"])) {
		result.append('<td class="progress">');
		result.append('<div class="progressbox" title="');
		result.append(my_soulsauce());
		result.append(' / 100"><div class="progressbar" style="width:');
		result.append(my_soulsauce());
		result.append('%"></div></div></td>');
		result.append('</td>');
	}
	result.append('</tr>');
}

void addHooch(buffer result) {
	matcher hooch = create_matcher("Hooch:</td><td align=left><b>(\\d+) / (\\d+)</b>", chitSource["stats"]);
	if(hooch.find()) {
		int my_hooch = hooch.group(1).to_int();
		int max_hooch = hooch.group(2).to_int();
		result.append('<tr>');
		result.append('<td class="label">Hooch</td><td class="info">');
		result.append(my_hooch);
		result.append(' / ');
		result.append(max_hooch);
		result.append('</td>');
		if(to_boolean(vars["chit.stats.showbars"])) {
			result.append('<td class="progress">');
			result.append('<div class="progressbox" title="');
			result.append(my_hooch);
			result.append(' / ');
			result.append(max_hooch);
			result.append('"><div class="progressbar" style="width:');
			result.append(to_string(100.0 * my_hooch / max_hooch));
			result.append('%"></div></div></td>');
			result.append('</td>');
		}
		result.append('</tr>');
	}
}

void addAud(buffer result) {
	matcher parseAud = create_matcher("Aud:</td><td align=left>(.+?)</td>", chitSource["stats"]);
	if(parseAud.find()) {
		result.append('<tr>');
		result.append('<td class="label">Aud</td><td class="info">');
		result.append(parseAud.group(1));
		result.append('</td>');
		int audience = abs(my_audience());
		if(to_boolean(vars["chit.stats.showbars"])) {
			int max_aud = have_equipped($item[Sneaky Pete's leather jacket]) || have_equipped($item[Sneaky Pete's leather jacket (collar popped)])? 50: 30;
			result.append('<td class="progress">');
			result.append('<div class="progressbox" title="');
			result.append(audience);
			result.append(' / ');
			result.append(max_aud);
			result.append('"><div class="progressbar" style="width:');
			result.append(to_string(audience * 100.0 / max_aud));
			result.append('%"></div></div></td>');
			result.append('</td>');
		}
		result.append('</tr>');
	}
}

void addOrgan(buffer result, string organ, boolean showBars, int current, int limit, boolean eff) {
	int sev = severity(organ, current, limit);
	result.append('<tr>');
	result.append('<td class="label">'+organ+'</td>');
	result.append('<td class="info">' + current + ' / ' + limit + '</td>');
	if(showBars) result.append('<td class="progress">' + progressCustom(current, limit, message(organ, sev), sev, eff) + '</td>');
	result.append('</tr>');
}

void addStomach(buffer result, boolean showBars) {
	if(can_eat())
		result.addOrgan("Stomach", showBars, my_fullness(), fullness_limit(), have_effect($effect[Got Milk]) > 0);
}
void addLiver(buffer result, boolean showBars) {
	if(can_drink())
		result.addOrgan("Liver", showBars, my_inebriety(), inebriety_limit(), have_effect($effect[Ode to Booze]) > 0);
}
void addSpleen(buffer result, boolean showBars) {
	result.addOrgan("Spleen", showBars, my_spleen_use(), spleen_limit(), false);
}

void bakeSubStats() {
	buffer result;

	//Heading
	result.append('<table id="chit_substats" class="chit_brick nospace">');
	result.append('<thead>');
	result.append('<tr>');
	result.append('<th colspan="'+(to_boolean(vars["chit.stats.showbars"])? 3: 2)+'"><img src="');
	result.append(imagePath);
	result.append('stats.png">Substats</th>');
	result.append('</tr>');
	result.append('</thead>');
	result.append('<tbody>');

	result.addStat($stat[muscle]);
	result.addStat($stat[mysticality]);
	result.addStat($stat[moxie]);
	
	result.append('</tbody>');
	result.append('</table>');
	chitBricks["substats"] = result.to_string();
}

// bake is used if the full MCD is always displayed instead of a drop-down list
void addMCD(buffer result, boolean bake) {
	string mcdname;
	string mcdlabel;
	string mcdtitle;
	string mcdpage;
	string mcdchange;
	string mcdbusy;
	int mcdmax =10;
	boolean mcdAvailable = true;
	boolean mcdSettable = true;
	string progress;

	void mcdlist(buffer mcd, boolean picker) {
		string [int] mcdmap;
			mcdmap[0] = "Turn it off";
			mcdmap[1] = "Turn it mostly off";
			mcdmap[2] = "Ratsworth's money clip";
			mcdmap[3] = "Glass Balls of the King";
			mcdmap[4] = "Boss Bat britches";
			mcdmap[5] = "Rib of the Bonerdagon";
			mcdmap[6] = "Horoscope of the Hermit";
			mcdmap[7] = "Codpiece of the King";
			mcdmap[8] = "Boss Bat bling";
			mcdmap[9] = "Ratsworth's tophat";
			mcdmap[10]= "Vertebra of the Bonerdagon";
			mcdmap[11]= "It goes to 11?";

		for mcdlevel from 0 to mcdmax {
			if (mcdlevel == current_mcd()) {
				mcd.append('<tr class="' + (picker? 'pickitem ': '') + 'current"><td class="info">' + mcdmap[mcdlevel] + '</td>');
			} else {
#				mcd.append('<tr class="' + (picker? 'pickitem ': 'change') + '"><td class="info"><a ref="charpane.php" class="clilink through" title="mcd '+mcdlevel+'">' + mcdmap[mcdlevel] + '</a></td>');
				mcd.append('<tr class="' + (picker? 'pickitem ': 'change') + '"><td class="info"><a ' + (picker? 'class="change" ': '') + ' href="' 
					+ (mcdchange == ""? "": sideCommand("mcd "+mcdlevel))
					+ '">' + mcdmap[mcdlevel] + '</a></td>');
			}
			mcd.append('<td class="level">' + mcdlevel + '</td>');
			mcd.append('</tr>');
		}
	}

	//Muscle Signs
	if (knoll_available()) {
		mcdname = "Detuned Radio";
		mcdlabel = "Radio";
		mcdtitle = "Turn it up or down, man";
		mcdpage = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=2682";
		mcdchange = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=2682&tuneradio=";
		mcdbusy = "Tuning Radio...";
		if (item_amount($item[detuned radio]) == 0) {
			mcdSettable = false;
			if (my_meat() < 300)
				progress = '<span title="You can\'t afford a Radio">Buy Radio</span>';
			else
				progress = '<a title="Buy a Detuned Radio (300 meat)" href="' + sideCommand("buy detuned radio") + '">Buy Radio</a>';
		}
	}

	// Moxie Signs
	else if(gnomads_available()) {
		mcdname = "Annoy-o-Tron 5000";
		mcdlabel = "AOT5K";
		mcdtitle = "Touch that dial!";
		mcdpage = "gnomes.php?place=machine";
		mcdchange = "gnomes.php?action=changedial&whichlevel=";
		mcdbusy = "Changing Dial...";
		if(get_property("lastDesertUnlock").to_int() != my_ascensions()) {
			mcdSettable = false;			
			progress = '<span title="The Gnomad camp has not been unlocked yet">No Beach?</span>';
		}
		
	// Myst Signs
	} else if(canadia_available()) {
		mcdmax = 11;
		mcdname = "Mind-Control Device";
		mcdlabel = "MCD";
		mcdtitle = "Touch that dial!";
		mcdpage = "canadia.php?place=machine";
		mcdchange = "canadia.php?action=changedial&whichlevel=";
		mcdbusy = "Changing Dial...";
		
	// Bad Moon Sign
	} else if(in_bad_moon()) {
		mcdname = "Heartbreaker's Hotel";
		mcdlabel = "Hotel";
		mcdtitle = "Hotel Floor #" + current_mcd();
		mcdpage = "heydeze.php";
		mcdchange = "";
		mcdSettable = false;
		progress = progressCustom(current_mcd(), mcdmax, mcdtitle, 5, false);
	
	// Unknown?
	} else {
		mcdname = "Monster Level";
		mcdlabel = "ML";
		mcdtitle = "No MCD Available";
		mcdpage = "";
		mcdchange = "";
		mcdSettable = false;
		mcdAvailable = false;
		progress = '<span title="You don\'t have access to a MCD">N/A</span>';
	}

	if(mcdSettable)
		progress = progressCustom(current_mcd(), mcdmax, mcdtitle, 5, false);
	else if(bake)
		return;

	if(bake) {
		result.append('<table id="chit_mcd" class="chit_brick nospace">');
		result.append('<thead>');
		result.append('<tr>');
		result.append('<th colspan="2" rel="' + mcdbusy + '"><img src="');
		result.append(imagePath);
		result.append('mcdon.png"><a href="' + mcdpage + '" target="mainpane" title="' + mcdtitle + '">' + mcdname + '</a></th>');
		result.append('</tr>');
		result.append('</thead><tbody>');
		result.mcdlist(false);
		result.append('</tbody></table>');
		result.append('</table>');
		return;
	}
	
	result.append('<tr><td class="label">');
	if(mcdpage == "")
		result.append(mcdlabel);
	else
		result.append('<a href="' + mcdpage + '" target="mainpane" title="' + mcdname + '">' + mcdlabel + '</a>');
	result.append('</td>');
	
	string mcdvalue() {
		if(mcdAvailable) {
			string mcdvalue = mcdSettable? '<a href="#" class="chit_launcher" style="white-space:pre" rel="chit_pickermcd" title="' + mcdtitle + '">' + to_string(current_mcd()) + '</a>'
				: '<span title="' + mcdname + '">' + to_string(current_mcd()) + '</span>';
			if(monster_level_adjustment() == current_mcd())
				return mcdvalue;
			return '<span style="color:' + (monster_level_adjustment() > current_mcd()? "blue": "red")
				+ '" title="Total ML">' + formatModifier(monster_level_adjustment()) + '</span>&nbsp;(' + mcdvalue + ')';
		}
		return '<span title="' + mcdname + '">' + to_string(monster_level_adjustment()) + '</span>';
	}
	result.append('<td class="info">' + mcdvalue() + '</td>');

	if (to_boolean(vars["chit.stats.showbars"])) {
		if (mcdSettable) {
			result.append('<td class="progress"><a href="#" id="chit_mcdlauncher" class="chit_launcher" rel="chit_pickermcd">' + progress + '</a></td>');
		} else {
			result.append('<td class="info">' + progress + '</td>');
		}
	}
	result.append('</tr>');
	
	//Create MCD picker
	if(mcdSettable && !(chitPickers contains "mcd")) {
		buffer picker;
		picker.pickerStart("mcd", mcdtitle);
		
		//Loader
		picker.addLoader(mcdbusy);
		picker.mcdlist(true);
		picker.append('</table>');
		picker.append('</div>');
		
		chitPickers["mcd"] = picker.to_string();
	}
}
void addMCD(buffer result) { result.addMCD(false); }

void bakeMCD() {
	buffer result;
	result.addMCD(true);
	chitBricks["mcd"] = to_string(result);
}

void bakeOrgans() {
	buffer result;
	
	//Heading
	result.append('<table id="chit_organs" class="chit_brick nospace">');
	result.append('<thead><tr><th colspan="3"><img src="');
	result.append(imagePath);
	result.append('organs.png">Consumption</th></tr>');
	result.append('</thead>');

	result.addStomach(true);
	result.addLiver(true);
	result.addSpleen(true);
	
	result.append('</table>');
	chitBricks["organs"] = result.to_string();
}

void addTrail(buffer result) {
	string source = chitSource["trail"];

	//Container
	string url = "main.php";
	matcher target = create_matcher('href="(.*?)" target=mainpane>Last Adventure:</a>', source);
	if (find(target)) {
		url = group(target, 1);
	}
	result.append('<tr>');
	result.append('<td class="label"><a class="visit" target="mainpane" href="' + url + '">Last</a></td>');
	
	//Last Adventure
	target = create_matcher('target=mainpane href="(.*?)">\\s*(.*?)</a><br></font>', source);
	if (find(target)) {
		result.append('<td class="info" style="display:block;" colspan="2"><a class="visit" target="mainpane" href="' + group(target, 1) + '">' + group(target, 2) + '</a></td>');
	} else {
		result.append('<td class="info" colspan="2">(None)</td>');
	}
	result.append('</tr>');
	
}

void bakeStats() {

	string health = chitSource["health"]; 
	buffer result;
	boolean showBars = to_boolean(vars["chit.stats.showbars"]);
	boolean checkExtra = true;

# <table align=center><tr><td align=right>Muscle:</td><td align=left><b><font color=blue>66</font>&nbsp;(60)</b></td></tr><tr><td align=right>Mysticality:</td><td align=left><b><font color=blue>49</font>&nbsp;(40)</b></td></tr><tr><td align=right>Moxie:</td><td align=left><b><font color=blue>44</font>&nbsp;(40)</b></td></tr><Tr><td align=right>Fullness:</td><td><b>2</b></td></tr><tr><td align=right>Temulency:</td><td><b>10</b></td></tr></table><Center>Extreme Meter:<br><img src=http://images.kingdomofloathing.com/otherimages/extmeter1.gif></center><table cellpadding=3 align=center>
# <Center>Extreme Meter:<br><img src=http://images.kingdomofloathing.com/otherimages/extmeter1.gif></center><table cellpadding=3 align=center>

	void addExtreme() {
		if(vars["chit.kol.coolimages"].to_boolean() && index_of(health, "Extreme Meter:") > -1) {
			matcher extreme = create_matcher("Extreme Meter.*?otherimages/(.*?)><", health);
			if(find(extreme)) {
				result.append('<tr style="height:'+(to_int(char_at(extreme.group(1), 8)) * 69 - 23)+'px;"><td colspan="'+ (showBars? 3: 2) +'"><center>');
				// extmeter1, extmeter2, extmeter3: width=200 height = 50,125,200 = 60x - 20. (176x44, 176x110, 176x176 = ) (height *.92 = 46, 115, 184 = 69x-23)
				result.append('<img style="width:95%;border:0px" src=images/otherimages/'+extreme.group(1)+'>');
				result.append('</center></td></tr>');
			}
		}
	}

	string progressTub(string s, int val) {
		int begin;
		switch(s) {
		case "Crew":
			begin = 37;
			break;
		case "Crayons":
			begin = 11;
			break;
		case "Bubbles":
			begin = 69;
			break;
		}
		int sev() {
			if(val > begin) return 0;
			if(val == begin) return 1;
			if(val < begin/2) return 3;
			return 2;
		}
		return progressCustom(to_int(val), begin, sev(), false);
	}
	
	void addBathtub() {
		if(chitSource contains "bathtub") {
			matcher tub = create_matcher("<b>(Crew|Crayons|Bubbles):</b></td><td class=small>(\\d+)</td>", chitSource["bathtub"]);
			while(find(tub)) {
				result.append('<tr>');
				result.append('<td class="label">'+tub.group(1)+'</td>');
				result.append('<td class="info">' + tub.group(2) + '</td>');
				if(to_boolean(vars["chit.stats.showbars"]))
					result.append('<td class="progress">' + progressTub(tub.group(1), tub.group(2).to_int()) + '</td>');
				result.append('</tr>');
			}
		}
	}
	
	int severity(int current, int limit, float red) {
		float ratio = to_float(current) / limit;
		if(ratio < red)
			return 3;
		else if(ratio < (2 + red) / 3)
			return 2;
		return 1;
	}
	
	string restore(string p) {
		if(p == "hp") {
			if(my_hp() <= my_maxhp() * to_float(get_property("hpAutoRecovery")))
				return "ash+restore_hp(0)";
		} else if(p == "mp") {
			if(my_path() == "Zombie Slayer") {
				if(my_mp() <= my_maxmp() * to_float(get_property("mpAutoRecovery")))
					return "ash+restore_hp(0)";
			} else if(my_mp() <= my_maxmp() * to_float(get_property("mpAutoRecovery")))
				return "ash+restore_hp(0)";
		}
		return "restore+"+p;
	}
	
	void addHP() {
		result.append('<tr>');
		result.append('<td class="label">HP</td>');
		#if(contains_text(health, "restore+HP")) {
		if(health.contains_text("restore+HP")) {
			result.append('<td class="info"><a title="Restore HP" href="' + sideCommand("restore hp") + '">' + my_hp() + '&nbsp;/&nbsp;' + my_maxhp() + '</a></td>');
		} else {
			result.append('<td class="info">' + my_hp() + '&nbsp;/&nbsp;' + my_maxhp() + '</td>');
		}
		if(showBars) {
			if(health.contains_text("restore+HP")) {
				result.append('<td class="progress"><a href="' + sideCommand("restore hp") + '">' 
					+ progressCustom(my_hp(), my_maxhp(), "Restore your HP", severity(my_hp(), my_maxhp(), to_float(get_property("hpAutoRecovery"))), false) + '</a></td>');
			} else {
				result.append('<td class="progress">' 
					+ progressCustom(my_hp(), my_maxhp(), "auto", severity(my_hp(), my_maxhp(), to_float(get_property("hpAutoRecovery"))), false) + '</td>');
			}
		}
		result.append('</tr>');
	}
	
	void addMP() {
		if(my_path() == "Zombie Slayer") {
			string HordeLink = get_property("baleUr_ZombieAuto") == ""? '<a href="skills.php" target="mainpane" title="Use Horde Skills">'
				// If using Universal_recovery, add link to recover Horde
				: '<a href="' + sideCommand("restore mp") + '" title="Restore Horde">';

			#<img src=http://images.kingdomofloathing.com/otherimages/zombies/horde_15.gif width=167 height=100 alt="Horde (23 zombie(s))" title="Horde (23 zombie(s))"><br>Horde: 23<center>
			if(vars["chit.kol.coolimages"].to_boolean()) {
				matcher horde = create_matcher("(zombies/.*?\\.gif).*?Horde:\\s*(\\d+)", health);
				if(find(horde)) {
					# image: 167 x 100 pixels
					result.append('<tr style="height:100px;"><td colspan="'+ (showBars? 3: 2) +'"><center><img src=images/otherimages/' + horde.group(1) + ' style="width:100%; border:0px"></center></td></tr>');
					result.append('<tr><td class="label" colspan="'+ (showBars? 3: 2) +'"><center>'+HordeLink+'Horde: ' + horde.group(2) + '</a></center></td></tr>');
					return;
				}
			}
			result.append('<tr><td class="label">'+HordeLink+'Horde</a></td>');
			result.append('<td class="info">'+HordeLink + my_mp() + '</a></td>');
			if(showBars) result.append('<td class="progress"></td>');
			result.append('</tr>');
			return;
		}
		result.append('<tr><td class="label">MP</td>');
		if(health.contains_text("restore+MP")) {
			result.append('<td class="info"><a title="Restore MP" href="' + sideCommand("restore mp") + '">' + my_mp() + '&nbsp;/&nbsp;' + my_maxmp() + '</a></td>');
		} else {
			result.append('<td class="info">' + my_mp() + '&nbsp;/&nbsp;' + my_maxmp() + '</td>');
		}

		if(showBars) {
			if(health.contains_text("restore+MP")) {
				result.append('<td class="progress"><a href="' + sideCommand("restore mp") + '">'
					+ progressCustom(my_mp(), my_maxmp(), "Restore your MP", severity(my_mp(), my_maxmp(), to_float(get_property("mpAutoRecovery"))), false) + '</a></td>');
			} else {
				result.append('<td class="progress">' 
					+ progressCustom(my_mp(), my_maxmp(), "auto", severity(my_mp(), my_maxmp(), to_float(get_property("mpAutoRecovery"))), false) + '</td>');
			}
		}
		result.append('</tr>');
	}
	
	void addAxel() {
		if (index_of(health, "axelottal.gif") > -1) {
			matcher axelMatcher = create_matcher("axelottal.gif\" /></td><td align=left><b>(.*?)</b>", health);
			if(find(axelMatcher)) {
				int courage = to_int(group(axelMatcher, 1));
				//result.append('<tr style="background-color:khaki">');
				result.append('<tr>');
				result.append('<td class="label">Axel</td>');
				result.append('<td class="info">' + courage + ' / 50</td>');
				if (showBars) result.append('<td class="progress">' + progressCustom(courage, 50, "Axel Courage", severity(courage, 40, 10), false) + '</td>');
				result.append('</tr>');
			}
		}
	}
	
	boolean contains_stat(string section) {
		if(section.contains_text("mainstat")) return true;
		switch(my_primestat()) {
		case $stat[muscle]: return section.contains_text("muscle");
		case $stat[mysticality]: return section.contains_text("myst");
		case $stat[moxie]: return section.contains_text("moxie");
		}
		return false;
	}
	
	void addSection(string section) {
		string [int] rows = split_string(section, ",");
		result.append("<tbody>");
		for i from 0 to (rows.count()-1) {
			switch (rows[i]) {
				case "mainstat":result.addStat(my_primestat()); 	break;
				case "muscle": 	result.addStat($stat[muscle]); 		break;
				case "myst": 	result.addStat($stat[mysticality]);	break;
				case "moxie": 	result.addStat($stat[moxie]); 		break;
				case "stomach": result.addStomach(showBars); 		break;
				case "liver": 	result.addLiver(showBars); 			break;
				case "spleen": 	result.addSpleen(showBars); 		break;
				case "florist": result.addFlorist(true);			break;
				case "hp": 		addHP(); 			break;
				case "mp": 		addMP(); 			break;
				case "axel": 	addAxel(); 			break;
				case "mcd": 	result.addMCD(); 	break;
				case "trail": 	result.addTrail();	break;
				default:
			}
		}
		
		// Add special stats to the section that contains mainstat
		if(section.contains_stat()) {
			if(my_fury() > 0)
				result.addFury();
			else if(my_soulsauce() > 0)
				result.addSauce();
			else if(my_path() == "Avatar of Sneaky Pete")
				result.addAud();
			
			if(numeric_modifier("Maximum Hooch") > 0)
				result.addHooch();
		}
		
		result.append("</tbody>");
	}

	boolean insertExtra(string remainder) {
		foreach s in $strings[mainstat, muscle, myst, moxie, hp, mp]
			if(remainder.contains_text(s)) return false;
		return true;
	}
	
	//Heading
	if (showBars) {
		result.append('<table id="chit_stats" class="chit_brick nospace">');
	} else {
		result.append('<table id="chit_stats" class="chit_brick nobars nospace">');
	}
	result.append('<thead>');
	result.append('<tr>');
	result.append('<th colspan="3">My Stats</th>');
	result.append('</tr>');
	result.append('</thead>');

	string layout = vars["chit.stats.layout"];
	string remainder = layout;
	string [int] sections = split_string(layout, "\\|");
	for i from 0 to (sections.count()-1) {
		if (sections[i] != "") {
			addSection(sections[i]);
		}
		// After stats,Mp& Hp, add extra optional sections
		remainder = replace_string(remainder, sections[i], "");
		if(checkExtra && insertExtra(remainder)) {
			if(!contains_text(vars["chit.stats.layout"], "axel"))
				addAxel();
			addBathtub();
			addExtreme();
			checkExtra = false;
		}
	}
#	result.append('<tr><td colspan="3"><a href="charpane.php" class="clilink through" title="mcd 10">MCD 10: Vertebra of the Bonerdagon</a></td></tr>');

	result.append('</table>');
	chitBricks["stats"] = result.to_string();
}

//fancy currency relay override for charpane by DeadNed (#1909053)
// http://kolmafia.us/showthread.php?12311-Fancy-Currency-(Charpane-override)
// Currently unimplemented, but being considered
string fancycurrency(string page) {
	string output='<ul id="chit_currency"> \n <li>';

	//big ol ugly case structure to figure out which thing you clicked last!
	switch(get_property("_ChitCurrency")){
	case "meat": 
		output+='<a href="#"><img src="/images/itemimages/meat.gif" class="hand" title="Meat" alt="Meat"><br>"+formatInt(my_meat())+" </a> ';
		break;
	case "sanddollar":
		output+='<a href="#"><img src="/images/itemimages/sanddollar.gif" class="hand" title="Sand Dollars" alt="Sand Dollars"> <br>'+ formatInt(item_amount($item[sand dollar]))+' </a>';
		break;
	 case "isotope":
		output+='<a href="#"><img src="/images/itemimages/isotope.gif" class="hand" title="Lunar Isotopes" alt="Lunar Isotopes"> <br>'+ formatInt(item_amount($item[lunar isotope]))+' </a>';
		break;
	 case "nickel":
		output+='<a href="#"><img src="/images/itemimages/nickel.gif" class="hand" title="Hobo Nickels" alt="Hobo Nickels"> <br>'+ formatInt(item_amount($item[hobo nickel]))+' </a>';
		break;
	}

	output+='\n <ul> \n <li><a href="/KoLmafia/sideCommand?cmd='+url_encode("set _ChitCurrency=sanddollar")+ '&pwd=' + my_hash() +'" ><img src="/images/itemimages/sanddollar.gif"> <br>'
		+ formatInt(item_amount($item[sand dollar]))+' </a></li> \n <li><a href="/KoLmafia/sideCommand?cmd='+url_encode("set _ChitCurrency=isotope")+ '&pwd=' 
		+ my_hash() +'" ><img src="/images/itemimages/isotope.gif"> <br>'+formatInt(item_amount($item[lunar isotope]))+' </a></li> \n <li><a href="/KoLmafia/sideCommand?cmd='
		+ url_encode("set _ChitCurrency=nickel")+ '&pwd=' + my_hash() +'" ><img src="/images/itemimages/nickel.gif"> <br>'
		+ formatInt(item_amount($item[hobo nickel]))+'</a></li> \n <li><a href="/KoLmafia/sideCommand?cmd='+url_encode("set _ChitCurrency=meat")+ '&pwd=' 
		+ my_hash() +'" ><img src="/images/itemimages/meat.gif"><br>'+formatInt(my_meat())+'</a></li> \n </li> \n </ul> \n';
	
	page.replace_string('<img src="/images/itemimages/meat.gif" class=hand onclick=\'doc("meat");\' title="Meat" alt="Meat"><br>',"output");

	matcher m;
	m = create_matcher('<img src="/images/itemimages/meat.gif" .+</td><td a',page);
	if (m.find()){
	page = replace_first(m, output +" </td><td a");
	}
	return page;
}

void pickOutfit() {
	location loc = my_location();
	if(loc == $location[none]) // Possibly beccause a fax was used
		loc = lastLoc;
	string localize(string o) {
		string boldit(string o) { return '<div style="font-weight:700;color:darkred;">'+o+'</div>'; }
		switch(o) {
		case "Swashbuckling Getup":
			if($locations[The Obligatory Pirate's Cove, Barrrney's Barrr, The F'c'le] contains loc || last_monster() == $monster[booty crab])
				return boldit(o);
			break;
		case "Mining Gear":
		case "eXtreme Cold-Weather Gear":
			if(loc.zone == "McLarge")
				return boldit(o);
			break;
		case "War Hippy Fatigues":
		case "Frat Warrior Fatigues":
			if($strings[IsleWar, Island] contains loc.parent)
				return boldit(o);
			break;
		case "Mer-kin Gladiatorial Gear":
		case "Mer-kin Scholar's Vestments":
		case "Clothing of Loathing":
			if(loc.parent == "The Sea")
				return boldit(o);
			break;
		}
		return o;
	}

	buffer picker;
	picker.pickerStart("outfit", "Select Outfit");
	
	//Loader
	foreach i,o in get_outfits()
		if(i != 0) {
			if(is_wearing_outfit(o) && o != "Birthday Suit")
				picker.append('<tr class="pickitem current"><td class="info" style="color:#999999">' + o + '</td>');
			else
				picker.append('<tr class="pickitem"><td class="info"><a class="change" href="'+ sideCommand("outfit "+o) + '">' + localize(o) + '</a></td>');
		}
		
	picker.append('<tr class="pickitem"><td style="color:white;background-color:blue;font-weight:bold;">Custom Outfits</td></tr>');
	foreach i,o in get_custom_outfits()
		if(i != 0)
			picker.append('<tr class="pickitem"><td class="info"><a class="change" href="'+ sideCommand("outfit "+o) + '">' + o + '</a></td>');

	// Special equipment control section
	buffer special;
	void addGear(buffer result, string cmd, string desc) {
		result.append('<tr class="pickitem"><td class="info"><a class="change" href="');
		result.append(sideCommand(cmd));
		result.append('">');
		result.append(desc);
		result.append('</a></td></tr>');
	}
	void addGear(buffer result, item e, string useName) {
		switch(to_slot(e)) {
		case $slot[acc1]: case $slot[acc2]: case $slot[acc3]:
			if(have_equipped(e))
				return;
			break;
		case $slot[off-hand]: // Cannot equip an off-hand item if you are using a 2 handed weapon
			if(weapon_hands(equipped_item($slot[weapon])) > 1) {
				result.append('<tr class="pickitem"><td class="info" style="color:#999999;font-weight:bold;">');
				result.append(e);
				result.append('</td></tr>');
				return;
			}
		default:
			if(equipped_item(to_slot(e)) == e)
				return;
		}
		if(can_equip(e) && available_amount(e) > 0)
			result.addGear("equip " + (e.to_slot() == $slot[acc1]? $slot[acc3]: e.to_slot()) + " " + e, useName);
	}
	void addGear(buffer result, item e) {
		addGear(result, e, to_string(e));
	}
	void addGear(buffer result, boolean [item] list) {
		foreach e in list
			result.addGear(e);
	}
	
	// If using Kung Fu Fighting, you might want to empty your hands
	if(have_effect($effect[Kung Fu Fighting]) > 0 && (equipped_item($slot[weapon]) != $item[none] || equipped_item($slot[off-hand]) != $item[none]))
		special.addGear("unequip weapon; unequip off-hand", "Empty Hands");
	// In KOLHS, might want to remove hat
	if(my_path() == "KOLHS") {
		if(equipped_item($slot[hat]) != $item[none])
			special.addGear("unequip hat; set _hatBeforeKolhs = "+equipped_item($slot[hat]), "Remove Hat for School");
		else if(get_property("_hatBeforeKolhs") != "")
			special.addGear("equip "+get_property("_hatBeforeKolhs")+"; set _hatBeforeKolhs = ", "Restore "+get_property("_hatBeforeKolhs"));
	}
	
	if(get_property("dailyDungeonDone") == "false")
		special.addGear($item[ring of Detect Boring Doors]);
		
	// Certain quest items need to be equipped to enter locations
	if(available_amount($item[digital key]) + creatable_amount($item[digital key]) < 1 && get_property("questL13Final") != "finished")
		special.addGear($item[continuum transfunctioner]);
	
	special.addGear($items[pirate fledges, Talisman o' Nam, black glass]);
	if(get_property("questL10Garbage") != "finished")
		switch(loc) {
		case $location[The Castle in the Clouds in the Sky (Basement)]:
			special.addGear($item[titanium assault umbrella]);
			special.addGear($item[amulet of extreme plot significance], "amulet of plot significance");
			break;
		case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
		case $location[The Castle in the Clouds in the Sky (Top Floor)]:
			special.addGear($item[mohawk wig]);
			break;
		}
	if(item_amount($item[Mega Gem]) > 0 && get_property("questL11Palindome") != "finished")
		special.addGear("equip acc3 Talisman o\' Nam;equip acc1 Mega+Gem", "Talisman & Mega Gem");
	if($strings[step3, step4] contains get_property("questL11Worship") && item_amount($item[antique machete]) > 0)
		special.addGear($item[antique machete]);
		#special.addGear("equip antique machete", "antique machete");
	if(get_property("questL11Desert") == "started")
		special.addGear($items[UV-resistant compass, ornate dowsing rod]);
	if(get_property("questL11Manor") == "step2")
		special.addGear($item[unstable fulminate]);
	if($strings[started,step1] contains get_property("questL11Manor"))
		special.addGear($item[Lord Spookyraven's spectacles], "Spookyraven's spectacles");
	
	if(length(special) > 0) {
		picker.append('<tr class="pickitem"><td style="color:white;background-color:blue;font-weight:bold;">Equip for Quest</td></tr>');
		picker.append(special);
	}
	
	
	// Special Smithsness section. Sometimes it is helpful to switch them around, like A Light that Never Goes Out or Half a Purse. Or sometimes put mainstat in offhand.
	if(have_effect($effect[Merry Smithsness]) > 0) {
		special.set_length(0);
		
		void addOffhand(buffer result, item e, string useName) {
			if(equipped_item($slot[off-hand]) != e && item_amount(e) > 0 && e != $item[none])
				result.addGear("equip off-hand " + e, useName);
		}
		
		item classSmiths() {
			switch(my_class()) {
			case $class[Seal Clubber]: return $item[Meat Tenderizer is Murder];
			case $class[Turtle Tamer]: return $item[Ouija Board\, Ouija Board];
			case $class[Pastamancer]: return $item[Hand that Rocks the Ladle];
			case $class[Sauceror]: return $item[Saucepanic];
			case $class[Disco Bandit]: return $item[Frankly Mr. Shank];
			case $class[Accordion Thief]: return $item[Shakespeare's Sister's Accordion];
			}
			return $item[none];
		} item classSmiths = classSmiths();
		
		special.addGear($items[A Light that Never Goes Out, Half a Purse, Work is a Four Letter Sword, Sheila Take a Crossbow, Hairpiece On Fire, Vicar's Tutu]);
		special.addGear($item[Staff of the Headmaster's Victuals], "Staff of the Headmaster");
		special.addGear(classSmiths);
		
		// Put Smithsness weapon in off-hand?
		if(my_class() != $class[Turtle Tamer] && have_skill($skill[Double-Fisted Skull Smashing]) && equipped_item($slot[off-hand]) != classSmiths && item_amount(classSmiths) > 0)
			special.addGear("equip off-hand " + classSmiths, "Offhand: Class Weapon");
		
		if(length(special) > 0) {
			picker.append('<tr class="pickitem"><td style="color:white;background-color:blue;font-weight:bold;">Swap Smithsness Items</td></tr>');
			picker.append(special);
		}
	}

	
	picker.addLoader("Getting Dressed");
	picker.append('</table>');
	picker.append('</div>');
	
	chitPickers["outfit"] = picker.to_string();
}

void bakeCharacter() {

	string source = chitSource["character"];
	buffer result;

	//Name
	string myName = "";
	matcher nameMatcher = create_matcher("href=\"charsheet.php\"><b>(.*?)</b></a>", source);
	if (find(nameMatcher)){
		myName = group(nameMatcher, 1);
	} else {
		myName = my_name();
	}

	//Title
	string myTitle = my_class();
	if (vars["chit.character.title"] == "true") {
		matcher titleMatcher = create_matcher("<br>(.*?)<br>(.*?)<", source);
		if (find(titleMatcher)) {
			myTitle = group(titleMatcher, 2);
			if (index_of(myTitle, "(Level ") == 0) {
				myTitle = group(titleMatcher, 1);
			}
		} else {
			titleMatcher = create_matcher("(?i)<br>(?:level\\s*"+my_level()+"|"+my_level()+".{2}?\\s*level\\s*)?([^<]*)", source); // Snip level out of custom title if it is at the beginning. Simple cases only.
			if (find(titleMatcher)) {
				myTitle = group(titleMatcher, 1);
			}
		}
	} else {
		if(myTitle == "Avatar of Jarlsberg" || myTitle == "Avatar of Sneaky Pete" || myTitle == "Unknown")  // Too long!
			myTitle = "Avatar";
	}

	//Avatar
	string myAvatar = "";
	if (vars["chit.character.avatar"] != "false") {
		matcher avatarMatcher = create_matcher('<img src="(.*?)" width=60 height=100 border=0>', source);
		if (find(avatarMatcher)){
			myAvatar = group(avatarMatcher, 1);
		}
	}
	
	//Outfit
	string myOutfit = "";
	matcher outfitMatcher = create_matcher('<center class=tiny>Outfit: (.*?)</center>', source);
	if (find(outfitMatcher)){
		myOutfit = "("+ group(outfitMatcher, 1)+")";
		int len = length(myName+myOutfit); // 105 is the limit to fit on a line.
		myOutfit = (len > 103 && len < 110? "<br />": " ") + myOutfit;
	}

	//Class-spesific stuff
	string myGuild = "guild.php?guild=";
	int myMainStats = 0;
	int mySubStats = 0;
	switch (my_primestat()) {
		case $stat[mysticality]:
			myGuild += "m";
			myMainStats = my_basestat($stat[mysticality]);
			mySubStats = my_basestat($stat[submysticality]);
			break;
		case $stat[moxie]:
			myGuild += "t";
			myMainStats = my_basestat($stat[moxie]);
			mySubStats = my_basestat($stat[submoxie]);
			break;
		case $stat[muscle]:
			myGuild += "f";
			myMainStats = my_basestat($stat[muscle]);
			mySubStats = my_basestat($stat[submuscle]);
			break;
	}
	
	if(my_path() == "Avatar of Boris")
		myGuild = "da.php?place=gate1";
	else if(my_path() == "Zombie Slayer")
		myGuild = "campground.php?action=grave";
	else if(my_path() == "Avatar of Jarlsberg")
		myGuild = "da.php?place=gate2";
	else if(my_path() == "Avatar of Sneaky Pete")
		myGuild = "da.php?place=gate3";

	// LifeStyle suitable for charpane
	string myLifeStyle() {
		if(get_property("kingLiberated") == true)
			return "Aftercore";
		else if(in_bad_moon())
			return "Bad Moon";
		else if(in_hardcore())
			return "Hardcore";
		else if(can_interact())
			return "Casual";
		return '<a target=mainpane href="storage.php">Ronin</a>: ' + formatInt(1000 - turns_played());
	}

	// Path title suitable for charpane
	string myPath() {
		if(get_property("kingLiberated") == true)
			return "No Restrictions";
		switch(my_path()) {
		case "None": return "No Path";
		case "Bees Hate You":
			int bees = 0;
			matcher bs;
			foreach s in $slots[] {
				if(equipped_item(s) != $item[none]) {
					bs = create_matcher("[Bb]", to_string(equipped_item(s)));
					while(bs.find())
						bees += 1;
				}
			}
			if(bees > 0)
				return '<span style="color:red" title="Beeosity">Bees Hate (' + bees + ')</span>';
			break;
		case "Way of the Surprising Fist": return "Surprising Fist";
			//myPath = "Surprising Fist: " + get_property("fistSkillsKnown");
		case "Bugbear Invasion": return "Bugbear&nbsp;Invasion";
		case "Avatar of Jarlsberg": return "Jarlsberg";
		case "KOLHS": return "<a target='mainpane' style='font-weight:normal;' href='place.php?whichplace=KOLHS'>KOLHS</a>";
		case "Class Act II: A Class For Pigs": return "Class Act <span style='font-family:Times New Roman,times,serif'>II</span>"; // Shorten. Also II looks a LOT better in serif
		case "Avatar of Sneaky Pete": return "Sneaky Pete";
		}
		return my_path();
	}
	
	//Stat Progress
	int x = my_level();
	int y = x + 1;
	int lower = (x**4)-(4*x**3)+(14*x**2)-(20*x)+25;
	if (x==1) lower=9;
	int upper = (y**4)-(4*y**3)+(14*y**2)-(20*y)+25;
	int range = upper - lower;
	int current = mySubStats - lower;
	int needed = range - current;
	float progress = (current * 100.0) / range;
	
	//Level + Council
	string councilStyle = "";
	string councilText = "Visit the Council";
	if(to_int(get_property("lastCouncilVisit")) < my_level() && get_property("kingLiberated") == "false") {
		councilStyle = 'background-color:#F0F060';
		councilText = "The Council wants to see you urgently";		
	}

	result.append('<table id="chit_character" class="chit_brick nospace">');

	// Character name and outfit name
	result.append('<tr>');
	result.append('<th colspan="'+ (myAvatar == ""? "2": "3") +'">');
	// If there's no avatar, place Outfit switcher here
	if(vars["chit.character.avatar"] == "false") {
		result.append('<div style="float:left"><a href="#" class="chit_launcher" rel="chit_pickeroutfit" title="Select Outfit"><img src="');
		result.append(imagePath);
		result.append('select_outfit.png"></a></div>');
	}
	result.append('<a target="mainpane" href="charsheet.php">' + myName + '</a>' + myOutfit + '</th>');
 	result.append('</tr>');
	
	result.append('<tr>');
	if(myAvatar != "")
		result.append('<td rowspan="4" class="avatar"><a href="#" class="chit_launcher" rel="chit_pickeroutfit" title="Select Outfit"><img src="' + myAvatar + '"></a></td>');
	pickOutfit();
	result.append('<td class="label"><a target="mainpane" href="' + myGuild +'" title="Visit your guild">' + myTitle + '</a></td>');
	result.append('<td class="level" rowspan="2" style="width:30px;' + councilStyle + '"><a target="mainpane" href="council.php" title="' + councilText + '">' + my_level() + '</a></td>');
	result.append('</tr>');

	result.append('<tr>');
	result.append('<td class="info">' + myPath() + '</td>');
	result.append('</tr>');
	
	// 30x30:	hp.gif		meat.gif		hourglass.gif		swords.gif
	// 20x20:	slimhp.gif	slimmeat.gif	slimhourglass.gif	slimpvp.gif
	result.append('<tr>');
	result.append('<td class="info">' + myLifeStyle() + '</td>');
	if(hippy_stone_broken() && index_of(chitSource["health"], "peevpee.php") > 0) {
		matcher fites = create_matcher("PvP Fights Remaining.+?black>(\\d+)</span>", chitSource["health"]);
		if(fites.find())
			result.append('<td><div class="chit_resource"><div title="PvP Fights Remaining" style="float:right"><span>' 
				+ fites.group(1) + '</span><a href="peevpee.php" target="mainpane">'
				+ '<img src="/images/itemimages/slimpvp.gif"></a></div></div></td><div style="clear:both"></div>');
		#result.append('<td class="turns" align="top" title="Turns played (this run)">' + formatInt(turns_played()) + '</td>');
	}
	result.append('</tr>');	

	result.append('<tr>');
	result.append('<td colspan="2"><div class="chit_resource">');
	result.append('<div title="Meat" style="float:left"><span>' + formatInt(my_meat()) 
		+ '</span><img src="/images/itemimages/meat.gif"></div>');
	result.append('<div title="'+my_adventures()+' Adventures remaining'
		+ (get_property("kingLiberated") == "true"? '': '\n Current Run: '+my_daycount() +' / '+ turns_played())
		+ '" style="float:right"><span>' + my_adventures() 
		+ '</span><img src="/images/itemimages/slimhourglass.gif"></div>');
	result.append('</div><div style="clear:both"></div></td>');
	result.append('</tr>');

	if (index_of(source, "<table title=") > -1) {
		result.append('<tr>');
		result.append('<td class="progress" colspan="3" title="' + (my_level() ** 2 + 4 - my_basestat(my_primestat())) + " " + my_primestat().to_lower_case() + " until level "+ (my_level() + 1) + '\n (' + formatInt(needed) + ' substats needed)" >');
		result.append('<div class="progressbar" style="width:' + progress + '%"></div></td>');
		result.append('</tr>');
	}	
	result.append('</table>');
		
	chitBricks["character"] = result;
		
}

void bakeQuests() {

	string source = chitSource["quests"]; 
	buffer result;	
	boolean hasQuests = (index_of(source, "<div>(none)</div>") == -1) && (index_of(source, "This Quest Tracker is a work in progress") == -1);
	static {
		record bio {
			string loc;
			string prop;
			int data;
		};
		bio [int] biodata;
		biodata[count(biodata)] = new bio("Sleazy Back Alley", "statusWasteProcessing", 3);
		biodata[count(biodata)] = new bio("Spooky Forest", "statusMedbay", 3);
		biodata[count(biodata)] = new bio("Bat Hole", "statusSonar", 3);
		biodata[count(biodata)] = new bio("Knob Laboratory", "statusScienceLab", 6);
		biodata[count(biodata)] = new bio("Defiled Nook", "statusMorgue", 6);
		biodata[count(biodata)] = new bio("Ninja Snowmen", "statusSpecialOps", 6);
		biodata[count(biodata)] = new bio("Haunted Gallery", "statusNavigation", 9);
		biodata[count(biodata)] = new bio("Fantasy Airship", "statusEngineering", 9);
		biodata[count(biodata)] = new bio("Battlefield (Frat Outfit)", "statusGalley", 9);
	}
	
	// Interpret readout for Oil Peak. u is µB/Hg.
	string to_slick(float u) {
		float ml = numeric_modifier("Monster Level");
		string oil = "cartel";
		float val = 63.4;
		if(ml < 20) {
			oil = "slick";
			val = 6.34;
		} else if(ml < 50) {
			oil = "tycoon";
			val = 19.02;
		} else if(ml < 100) {
			oil = "baron";
			val = 31.7;
		}
		if(have_equipped($item[dress pants]))
			val += 6.34;
		return ceil(u/ val) + " oil "+oil+"s left";
	}

	// See if we need to add any quest data for Bugbears
	string bugbears;
	if(my_path() == "Bugbear Invasion") {
		if(item_amount($item[key-o-tron]) > 0) {
			foreach i,b in biodata if(get_property(b.prop).is_integer())
				bugbears += '<br>&nbsp;&nbsp;&nbsp;* '+ b.loc +': ' + get_property(b.prop).to_int() + '/'+ b.data;
			if(bugbears != "")
				bugbears = '<tr><td class="small"><div>Bugbear '
				  +'<b><a class=nounder target=mainpane href="inv_use.php?whichitem=5653&pwd='+my_hash()
				  +'">key-o-tron:</a></b>'+bugbears +'</div></td></tr>';
		}
		else bugbears = '<tr><td class="small"><div>Create a bugbear <b>key-o-tron</b>:<br>'
		  + '&nbsp;&nbsp;&nbsp;BURTs: '+item_amount($item[BURT])+' /5</div></td></tr>';
	}
	
	//See if we actually need to display anything
	if ((source == "" && bugbears == "") || (!hasQuests && vars["chit.quests.hide"] == "true")) {
		//We're done here
		//chitBricks["quests"] = "";
		return;
	}
	
	//Otherwise we start building our table	
	//result.append('<div id="nudgeblock">');
	result.append('<table id="nudges" class="chit_brick nospace">');

	result.append('<tr><th><img src="');
	result.append(imagePath);
	result.append('quests.png"><a target="mainpane" href="questlog.php">Current Quests</a></th></tr>');
	
	matcher showAll = create_matcher('<a style="display.+?"showall".+?</a>', source);
	if(showAll.find()) {
		result.append('<tr><td>');
		result.append(showAll.group(0));
		result.append('</td></tr>');
	}
	
	if(bugbears != "")
		result.append(bugbears);	
	
	matcher rowMatcher = create_matcher("<tr(.*?)tr>", source);
	string quest = "";
	while (find(rowMatcher)) {
		quest = group(rowMatcher,0);
		if (contains_text(quest, "<div>(none)</div>")) {
			quest = replace_string(quest, "<div>", "");
			quest = replace_string(quest, "</div>", "");
		} else if (contains_text(quest, "Evilometer")) {
			string evil = "";
			int e;

			e = to_int(get_property("cyrptAlcoveEvilness"));
			if (e > 25) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Alcove]) +'" target="mainpane">Alcove:</a> ' + e + ' (+init)';
			} else if (e > 0) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Alcove]) +'" target="mainpane">Alcove:</a> ' + e + ' (Boss ready)';
			} else {
				evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Alcove</s>';
			}

			e = to_int(get_property("cyrptCrannyEvilness"));
			if (e > 25) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Cranny]) +'" target="mainpane">Cranny:</a> ' + e + ' (+NC, +ML)';
			} else if (e > 0) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Cranny]) +'" target="mainpane">Cranny:</a> ' + e + ' (Boss ready)';
			} else {
				evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Cranny</s>';
			}

			e = to_int(get_property("cyrptNicheEvilness"));
			if (e > 25) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Niche]) +'" target="mainpane">Niche:</a> ' + e + ' (sniff dirty old lihc)';
			} else if (e > 0) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Niche]) +'" target="mainpane">Niche:</a> ' + e + ' (Boss ready)';
			} else {
				evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Niche</s>';
			}

			e = to_int(get_property("cyrptNookEvilness"));
			if (e > 25) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Nook]) +'" target="mainpane">Nook:</a> ' + e + ' (+items)';
			} else if (e > 0) {			
				evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[The Defiled Nook]) +'" target="mainpane">Nook:</a> ' + e + ' (Boss ready)';
			} else {
				evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Nook</s>';
			}

			//quest = replace_string(quest, "Evilometer", evil + "Evilometer");
			quest = replace_string(quest, "<p>", "<br>");
			quest = replace_string(quest, "</div>", evil + "</div>");
		} else if (contains_text(quest, "Oil Peak")) {
			// current pressure: 234.58 &mu;B/Hg
			matcher pressure = create_matcher("(current pressure:\\s+([\\d\\.]+)\\s+&mu;B/Hg)", quest);
			if(pressure.find())
				quest = replace_string(quest, pressure.group(1), to_slick(pressure.group(2).to_float()));
			foreach peak in $strings[A-boo Peak, Twin Peak, Oil Peak]
				quest = replace_string(quest, "* "+peak, '* <a href="' + to_url(to_location(peak)) +'" target="mainpane">' + peak + '</a>');
		}
		result.append(quest);	
	}
 	result.append('</table>');
	
	//Append any javascript uncle CDM inlucded
	matcher jsMatcher = create_matcher("<script(.*?)script>", source);
	if (find(jsMatcher)) {
		result.append(group(jsMatcher,0));
	}

 	//result.append("</div>");
	
	chitBricks["quests"] = result;
	chitTools["quests"] = "Current Quests|quests.png";
}

// Tracker brick created by ckb
void bakeTracker() {
	
	//useful sub-functions for checking items: yes=green, no=red
	string item_report(boolean good, string itname) {
		return('<span style="color:' + (good? "green": "red") + '">'+itname+'</span>');
	}
	string item_report(boolean[item] itlist, string itname) {
		foreach it in itlist
			if(available_amount(it) > 0)
				return item_report(true, itname);
		return item_report(false, itname);
	}
	string item_report(item it, string itname) {
		return item_report(available_amount(it) > 0, itname);
	}
	string item_report(item it) {
		return item_report(available_amount(it) > 0, to_string(it));
	}
	string item_report(item it, string itname, int num) {
		return item_report(available_amount(it) >= num, itname + ' '+available_amount(it)+'/'+num);
	}
	string item_report(item it, int num) {
		return item_report(it, to_plural(it), num);
	}

	boolean started(string pref) {
		return get_property(pref) != "unstarted" && get_property(pref) != "finished";
	}
	
	void comma(buffer b, string s) {
		if(length(b) > 0)
			b.append(", ");
		b.append(s);
	}
	string twinPeak() {
		int p = get_property("twinPeakProgress").to_int();
		boolean mystery(int c) { return (p & (1 << c)) == 0; }
		float famBonus() {
			switch(my_path()) {
			case "Avatar of Boris":
				return minstrel_instrument() != $item[Clancy's lute]? 0:
					numeric_modifier($familiar[baby gravy fairy], "Item Drop", minstrel_level() * 5, $item[none]);
			case "Avatar of Jarlsberg":
				return my_companion() != "Eggman"? 0: (have_skill($skill[Working Lunch])? 75: 50);
			}
				item fameq = familiar_equipped_equipment(my_familiar());
				int famw = round( familiar_weight(my_familiar()) + weight_adjustment() - numeric_modifier(fameq, "Familiar Weight") ); 
				return numeric_modifier( my_familiar(), "Item Drop", famw , fameq );
		}
		float foodDrop() { return round(numeric_modifier("Item Drop") - famBonus() + numeric_modifier("Food Drop")); }
		buffer need;
		// Only check for final if first three done
		if(p < 7) {
			if(mystery(0)) need.comma(item_report(numeric_modifier("Stench Resistance") >= 4, "4 Stench Resistance"));
			if(mystery(1)) need.comma(item_report(foodDrop() >= 50, "+50% Food Drop"));
			if(mystery(2)) need.comma(item_report($item[Jar of Oil], "a Jar of Oil"));
		} else if(p == 15)
			need.append(item_report(true, "Mystery Solved!"));
		else
			need.comma(item_report(numeric_modifier("Initiative") >= 40, "+40% Initiative"));
		return need;
	}
	
	buffer highlands() {
		buffer high;
		high.append("<br>A-boo Peak: ");
		high.append(item_report(get_property("booPeakProgress") == "0", get_property("booPeakProgress")+'% haunted'));
		//L9: twin peak
		high.append("<br>Twin Peak: "+twinPeak());
		//check 4 stench res, 50% items (no familiars), jar of oil, 40% init
		//L9: oil peak
		high.append("<br>Oil Peak: ");
		high.append(item_report(get_property("oilPeakProgress").to_float() == 0, get_property("oilPeakProgress")+' &mu;B/Hg'));
		if(high.contains_text(">0% haunt") && high.contains_text("Solved!") && high.contains_text("0.00")) {
			high.set_length(0);
			high.append('<br>Return to <a target="mainpane" href="place.php?whichplace=highlands&action=highlands_dude">High Landlord</a>');
		}
		return high;
	}
	string source = chitSource["quests"]; 

	// Start building our table	
	buffer result;	
	result.append('<table id="chit_tracker" class="chit_brick nospace"><tr><th>');
	result.append('<img src="');
	result.append(imagePath);
	result.append('tracker.png">');
	result.append('<a target="mainpane" href="questlog.php">Quest Tracker</a></th></tr>');

	//Add Tracker for each available quest
	//G for Guild. S for Sea. F for Familiar. I for Item. M for Miscellaneous 
	
	string bhit;
	foreach b in $strings[Easy, Hard, Special] {
		bhit = get_property("current"+ b +"BountyItem");
		if(bhit != "") {
			result.append("<tr><td>");
			result.append('Your <a target="mainpane" href="bhh.php">Bounty</a> is: <br>');
			result.append(bhit);
		}
	}
	/*
	if (get_property("currentBountyItem")!="0") {
		item bhit = to_item(get_property("currentBountyItem"));
		result.append("<tr><td>");
		result.append('Get your <a target="mainpane" href="bhh.php">Bounty</a> from the ');
		result.append(bhit.bounty+" : ");
		result.append(to_string(to_item(get_property("currentBountyItem")))+" ("+to_string(item_amount(bhit))+"/"+bhit.bounty_count+")");
		
		result.append("</td></tr>");
	}
	*/
	// L1: Open Manor
	/*
	if(get_property("lastManorUnlock").to_int() != my_ascensions()) {
		result.append("<tr><td>");
		result.append('Open Spookyraven at <a target="mainpane" href="town_right.php">Pantry</a>');
		result.append("</td></tr>");
	}
	*/
	//L2: get mosquito larva, questL02Larva
	if(started("questL02Larva")) { 
		result.append("<tr><td>");
		result.append('Find a <a target="mainpane" href="woods.php">mosquito larva</a>');
		result.append("</td></tr>");
	}
	//L3 Typical tavern, questL03Rat
	if(started("questL03Rat")) { 
		result.append("<tr><td>");
		result.append('Clear the <a target="mainpane" href="cellar.php">Typical Tavern</a> rats');
		result.append("</td></tr>");
	}
	//L4: find and defeat the boss bat, questL04Bat
	if(started("questL04Bat")) { 
		result.append("<tr><td>");
		result.append('Find and defeat the <a target="mainpane" href="bathole.php">Boss Bat</a>');
		result.append("</td></tr>");
	}
	//L5: encryption key - item_amount($item[Knob Goblin encryption key]), item_amount($item[Cobb's Knob map])
	if(item_amount($item[Knob Goblin encryption key]) < 1 && (get_property("questL05Goblin") == "unstarted" || item_amount($item[Cobb's Knob map]) > 0)) {
		result.append("<tr><td>");
		result.append('Find encryption key at <a target="mainpane" href="plains.php">Outskirts</a>');
		result.append("</td></tr>");
	}
	//knob king, questL05Goblin
	if(started("questL05Goblin")) { 
		result.append("<tr><td>");
		result.append('Find and defeat the <a target="mainpane" href="cobbsknob.php">Goblin King</a>');
		result.append("</td></tr>");
	}
	//L6: Friars gate, questL06Friar
	if(started("questL06Friar")) {
		result.append("<tr><td>");
		result.append('Clear the <a target="mainpane" href="friars.php">Deep Fat Friars</a><br>');
		result.append(item_report($item[eldritch butterknife])+" (Elbow)<br>");
		result.append(item_report($item[box of birthday candles], "birthday candles")+" (Heart)<br>");
		result.append(item_report($item[dodecagram])+" (Neck)");
		result.append("</td></tr>");
	}
	//L6.5: Steel organ, questM10Azazel
	if (started("questM10Azazel")) { 
		result.append("<tr><td>");
		string steelname() {
			if (!can_drink() && !can_eat()) { return "Steel Air Freshener"; }
			if (!can_drink()) { return "Steel Lasagna"; }
			return "Steel Margarita";
		}
		result.append('Get '+steelname()+' from <a target="mainpane" href="pandamonium.php">Azazel</a>');
		result.append("<br><a target=mainpane href=\"pandamonium.php?action=infe\">Arena</a>: ");
		result.append(item_report($item[Azazel's unicorn], "Unicorn"));
		if(available_amount($item[Azazel's tutu])==0) {
			result.append(", ");
			result.append(item_report($item[bus pass],5));
		}
		result.append("<br><a target=mainpane href=\"pandamonium.php?action=beli\">Comedy</a>: ");
		result.append(item_report($item[Azazel's lollipop], "Lollipop"));
		if(available_amount($item[Azazel's tutu])==0) {
			result.append(", ");
			result.append(item_report($item[imp air],5));
		}
		result.append("<br><a target=mainpane href=\"pandamonium.php?action=moan\">Panda Square</a>: ");
		result.append(item_report($item[Azazel's tutu]));
		result.append("</td></tr>");
	}
	//L7: crypt, questL07Cyrptic
	if(started("questL07Cyrptic")) {
		void evilat(buffer report, string place) {
			int evil = to_int(get_property("cyrpt"+place+"Evilness"));
			report.append('<span style="color:');
			if(evil==0) report.append('gray');
				else if(evil<26) report.append('red');
				else report.append('black');
			report.append('">');
			report.append(place);
			report.append(': ');
			report.append(evil);
			report.append('</span>');
		}
		result.append('<tr><td><table><tr><td colspan=2><a target=mainpane href="crypt.php">Cyrpt</a> Evilometer: ');
		if(get_property("cyrptTotalEvilness") == "0") {
			result.append('999</td></tr><tr><td><span style="color:black">&nbsp;&nbsp;&nbsp;Haert of the Cyrpt</span>');
		} else {
			result.append(get_property("cyrptTotalEvilness"));
/*			result.append('</td></tr><tr><td>');
			result.evilat("Nook");
			result.append('<br>');
			result.evilat("Cranny");
			result.append('</td><td>');
			result.evilat("Niche");
			result.append('<br>');
			result.evilat("Alcove");*/
			result.append('</td></tr><tr><td><table><tr><td title="+items">');
			result.evilat("Nook");
			result.append('</td><td title="sniff dirty old lihc">');
			result.evilat("Niche");
			result.append('</td></tr><tr><td title="+NC, +ML">');
			result.evilat("Cranny");
			result.append('</td><td title="+init">');
			result.evilat("Alcove");
			result.append('</td></tr></table>');
		}
		result.append("</td></tr></table></td></tr>");
	}

	//L7.5ish: pirates, questM12Pirate
	//if (get_property("questM12Pirate")!="unstarted" && get_property("questM12Pirate")!="finished") { 
	//step1, step2, step3, step4 = insults
	//step5 = fcle
	if(have_outfit("Swashbuckling Getup") && available_amount($item[Pirate Fledges]) == 0) {
		result.append("<tr><td>");
		//fcle items mizzenmast mop, ball polish, rigging shampoo
		if (get_property("questM12Pirate")=="step5") {
			result.append("<a target=mainpane href=cove.php>F'c'le </a> Items: ");
			result.append("<br>&nbsp;&nbsp;"+item_report($item[mizzenmast mop]));
			result.append("<br>&nbsp;&nbsp;"+item_report($item[ball polish]));
			result.append("<br>&nbsp;&nbsp;"+item_report($item[rigging shampoo]));
		} else {
			int totalInsults = 0;
			for ii from 1 upto 8
				if (to_boolean(get_property("lastPirateInsult" + to_string(ii))))
					totalInsults = totalInsults + 1;
			result.append("<a target=mainpane href=cove.php>Pirate</a> Insults = <span style=\"color:");
			switch (totalInsults) {
				case 1: result.append("red\"><b>1</b> (0.0%)"); break;
				case 2: result.append("red\"><b>2</b> (0.0%)"); break;
				case 3: result.append("red\"><b>3</b> (1.8%)"); break;
				case 4: result.append("red\"><b>4</b> (7.1%)"); break;
				case 5: result.append("red\"><b>5</b> (17.9%)"); break;
				case 6: result.append("olive\"><b>6</b> (35.7%)"); break;
				case 7: result.append("green\"><b>7</b> (62.5%)"); break;
				case 8: result.append("green\"><b>8</b> (100.0%)"); break;
				default: result.append("red\"><b>0</b> (0.0%)");
			}
			result.append("</span>");
		}
		result.append("</td></tr>");
	}

	//L8: trapper: 3 ore, 3 goat cheese, questL08Trapper
	if(started("questL08Trapper")) {
		result.append('<tr><td><a target="mainpane" href="place.php?whichplace=mclargehuge">Help the Trapper</a>');
		switch(get_property("questL08Trapper")) {
		case "started":
			result.append('<br>Visit the <a target="mainpane" href="place.php?whichplace=mclargehuge&action=trappercabin">Trapper</a>');
			break;
		case "step1":
			if(get_property("trapperOre").to_item().available_amount() >= 3 && available_amount($item[goat cheese]) >= 3)
				result.append('<br>Visit the <a target="mainpane" href="place.php?whichplace=mclargehuge&action=trappercabin">Trapper</a>');
			else {
				result.append("<br>Mine: "+item_report(to_item(get_property("trapperOre")),3));
				result.append("<br>Goatlet: "+item_report($item[goat cheese],3));
			}
			break;
		case "step2":
		case "step3":
			if(numeric_modifier("Cold Resistance") < 5) {
				result.append("<br>Extreme: ");
				result.append(item_report($item[eXtreme scarf], "scarf, "));
				result.append(item_report($item[snowboarder pants], "pants, "));
				result.append(item_report($item[eXtreme mittens], "mittens"));
			}
			result.append("<br>Ninja: ");
			result.append(item_report($item[ninja rope], "rope, "));
			result.append(item_report($item[ninja crampons], "crampons, "));
			result.append(item_report($item[ninja carabiner], "carabiner"));
		case "step4":
			result.append("<br>Ascend the Mist-Shrouded Peak");
		}
		result.append("</td></tr>");
	}
	//L9: orc chasm bridge, questL09Topping
	if(started("questL09Topping")) {
		result.append('<tr><td>');
		int chasmBridgeProgress = get_property("lastChasmReset").to_int() == my_ascensions()? get_property("chasmBridgeProgress").to_int(): 0;
		if(chasmBridgeProgress < 30) {
		result.append('Cross the <a target="mainpane" href="place.php?whichplace=orc_chasm">Orc Chasm</a>');
			result.append("<br>Bridge Progress: "+(get_property("lastChasmReset") == my_ascensions()? get_property("chasmBridgeProgress"): "0")+"/30");
		} else {
			result.append('Explore the <a target="mainpane" href="place.php?whichplace=highlands">Highlands</a>');
			result.append(highlands());
		}
		result.append("</td></tr>");
	}
	
	//L10: SOCK, Giants Castle, questL10Garbage
	if(started("questL10Garbage")) {
		result.append("<tr><td>");
		if(item_amount($item[S.O.C.K.])==0) {
			result.append('Climb the <a target="mainpane" href="place.php?whichplace=beanstalk">Beanstalk</a>');
			int numina = item_amount($item[Tissue Paper Immateria])+item_amount($item[Tin Foil Immateria])+item_amount($item[Gauze Immateria])+item_amount($item[Plastic Wrap Immateria]);
			result.append('<br>Immateria found: '+item_report(numina == 4, to_string(numina)+'/4'));
		} else {
			result.append('Conquer the <a target="mainpane" href="place.php?whichplace=giantcastle">Giant\'s Castle</a>');
		}
		result.append("</td></tr>");
	}

	//L11: MacGuffin, questL11MacGuffin
	if (started("questL11MacGuffin")) {
		result.append("<tr><td>");
		result.append("Quest for the Holy MacGuffin");
		if(get_property("questL11MacGuffin")=="started") {
			if(item_amount($item[black market map]) == 0)
				result.append('<br>Find the <a target="mainpane" href="woods.php">Black Market</a>');
			else
				result.append('<br><a target="mainpane" href="inv_use.php?which=f0&whichitem=2054&pwd='+my_hash()+'">Follow the Black MAP!</a>');
		}
		if(get_property("questL11MacGuffin")=="step1" && item_amount($item[your father's MacGuffin diary])==0) {
			result.append('<br>Get your Father\'s <a target="mainpane" href="shore.php">Diary</a>');
			result.append("<br>"+item_report($item[forged identification documents]));
		}
		result.append("</td></tr>");		
	}
	
	//L11: questL11Manor
	// Open second floor and ballroom early
	if(get_property("lastManorUnlock").to_int() == my_ascensions() && item_amount($item[Spookyraven ballroom key]) == 0) {
		result.append("<tr><td>");
		if(item_amount($item[Spookyraven library key]) == 0)
			result.append('Get Library Key at <a target="mainpane" href="manor.php">Billiard Room</a>');
		else if(get_property("lastSecondFloorUnlock").to_int() != my_ascensions())
			result.append('Fix stairs at <a target="mainpane" href="manor.php">Library</a>');
		else
			result.append('Get Ballroom Key at <a target="mainpane" href="manor2.php">Bedroom</a>');
		result.append("</td></tr>");
	}
	// find wines
	if (started("questL11Manor")) {
		result.append("<tr><td>");
		if(get_property("questL11Manor") == "step2") {
			result.append('<a target="mainpane" href="manor3.php">Manor Cellar</a>: Kill Spookyraven');
		} else {
			result.append('Find wines in the <a target="mainpane" href="manor.php">Manor</a> <a target="mainpane" href="manor3.php">Cellar</a>');
			if(available_amount($item[Lord Spookyraven's spectacles]) == 0)
				result.append('Get Spookyravens spectacles from the <a target="mainpane" href="manor2.php">Bedroom</a>');
		}
		result.append("</td></tr>");
	}
	//lastDustyBottle2271=0
	//lastDustyBottle2272=0
	//lastDustyBottle2273=0
	//lastDustyBottle2274=0
	//lastDustyBottle2275=0
	//lastDustyBottle2276=0
	//lastDustyBottleReset==my_ascensions()
	//wineCellarProgress=3
	//cellarLayout=1092
	//lastCellarReset
		
	//L11: questL11Palindome
	if (started("questL11Palindome")) {
		result.append("<tr><td>");
		if(get_property("questL11Palindome") == "step4")
			result.append('<a target="mainpane" href="plains.php">Palindome</a>: Kill Dr. Awkward');
		else
			result.append('Seek Dr. Awkward at <a target="mainpane" href="plains.php">Palindome</a>');
		// pirate fledges found from island.php
		if(available_amount($item[pirate fledges])==0)
			result.append('<br>Get some <a target="mainpane" href="island.php">pirate fledges</a>');
		// get talisman o nam from island.php
		if(available_amount($item[Talisman o' Nam])==0)
			result.append('<br>Find the <a target="mainpane" href="cove.php">Talisman o Nam</a>');
		// have items required: photograph of God, hard rock candy, ketchup hound, hard-boiled ostrich egg 
		if(item_amount($item[&quot;I Love Me, Vol. I&quot;]) == 0) {
			result.append("<br>Obtain: ");
			result.append(item_report($item[photograph of God]));
			result.append(", ");
			result.append(item_report($item[hard rock candy]));
			result.append(", ");
			result.append(item_report($item[hard-boiled ostrich egg]));
			result.append(", ");
			result.append(item_report($item[ketchup hound]));
			result.append(", ");
			result.append(item_report($item[stunt nuts]));
		}
		// get wet stunt nut stew, mega gem
		if (available_amount($item[Mega Gem])==0) {
			result.append('<br>Get the <a target="mainpane" href="cobbsknob.php?level=2">Mega Gem</a>');
		}
		result.append("</td></tr>");
	}
	
	if(started("questL11Worship")) {
		// How many McClusky file pages are present?
		int files() {
			for f from 6693 downto 6689
				if(to_item(f).available_amount() > 0)
					return f - 6688;
			return 0;
		}
		result.append("<tr><td>");
		switch(get_property("questL11Worship")) {
		case "started": case "step1": case "step2":
			result.append('Search <a target="mainpane" href="woods.php">Temple</a> for Hidden City');
			break;
		case "step3":
			if(item_amount($item[stone triangle]) < 4) {
				result.append('Explore <a target="mainpane" href="hiddencity.php">Hidden City</a>:<br>');
				boolean relocatePygmyJanitor = get_property("relocatePygmyJanitor").to_int() == my_ascensions();
				result.append("Hidden Park: ");
				if(available_amount($item[antique machete]) == 0 || !relocatePygmyJanitor) {
					result.append(item_report($item[antique machete]));
					result.append(", ");
					result.append(item_report(relocatePygmyJanitor, "relocate janitors"));
					result.append("<br>");
				} else 
					result.append(item_report(true, "Done!<br>"));
				foreach loc in $strings[Hospital, BowlingAlley, Apartment, Office] {
					result.append(loc+": ");
					int prog = get_property("hidden"+loc+"Progress").to_int();
					if(prog == 0)
						result.append(item_report(false, "Explore Shrine<br>"));
					else if(prog < 7) {
						switch(loc) {
						case "Hospital":
							result.append(item_report(false, "Surgeonosity ("+to_string(numeric_modifier("surgeonosity"), "%.0f")+"/5)<br>"));
							break;
						case "BowlingAlley":
							result.append(item_report($item[bowling ball]));
							result.append(", ");
							result.append(item_report(false, "Bowled ("+(prog - 1)+"/5)<br>"));
							break;
						case "Apartment":
							result.append(item_report(get_property("relocatePygmyLawyer").to_int() == my_ascensions(), "relocate Lawyers, "));
							result.append(item_report(false, "Search for Boss<br>"));
							break;
						case "Office":
							if(available_amount($item[McClusky file (complete)]) > 0)
								result.append(item_report(false, "Kill Boss!"));
							else {
								int f = files();
								result.append(item_report(f >=5, "McClusky files (" + f + "/5), "));
								result.append(item_report($item[boring binder clip], "binder clip"));
							}
							result.append("<br>");
							break;
						}
					} else if(prog == 7)
						result.append(item_report(false, "Use Sphere<br>"));
					else
						result.append(item_report(true, "Done!<br>"));
				}
				result.append("Tavern: ");
				if(get_property("hiddenTavernUnlock") != my_ascensions()) {
					result.append(item_report($item[book of matches]));
					result.append("<br>");
				} else
					result.append(item_report(true, "Unlocked<br>"));
			} else
				result.append('<a target="mainpane" href="hiddencity.php">Hidden City</a>: Kill the Protector Spectre');
		}
		result.append("</td></tr>");
	}
	
	//L11: questL11Pyramid
	if(started("questL11Pyramid")) {
		string questL11Pyramid = get_property("questL11Pyramid");
		result.append("<tr><td>");
		// Step-by-step
		switch(questL11Pyramid) {
		case "started": case "step1": case "step2": case "step3": case "step4": case "step5": case "step6": case "step7": case "step8": case "step9": case "step10":
			result.append('Find the pyramid at the <a target="mainpane" href="beach.php">Beach</a><br>');
			int desertExploration = get_property("desertExploration").to_int();
			if(desertExploration < 10)
				result.append('Find Gnasir at the <a target="mainpane" href="beach.php">Desert</a><br>');
			if(desertExploration < 100) {
				result.append("Exploration: "+desertExploration+"%<br>");
				int gnasirProgress = get_property("gnasirProgress").to_int();
				buffer gnasir;
				if((gnasirProgress & 4) == 0)
					gnasir.comma(item_report($item[killing jar]));
				if((gnasirProgress & 2) == 0)
					gnasir.comma(item_report($item[can of black paint]));
				if((gnasirProgress & 1) == 0)
					gnasir.comma(item_report($item[stone rose]));
				if((gnasirProgress & 8) == 0) {
					gnasir.comma(item_report($item[worm-riding manual page], 15));
					gnasir.comma(item_report($item[drum machine]));
				} else if((gnasirProgress & 16) == 0) {
					gnasir.comma(item_report($item[drum machine]));
					gnasir.comma(item_report($item[worm-riding hooks]));
					gnasir.append('<br><a target="mainpane" href="place.php?whichplace=desertbeach&action=db_pyramid1&pwd='+my_hash()+'">Ride the Worm !</a>');
					#gnasir.append('<br><a target="mainpane" href="inv_use.php?which=3&whichitem=2328&pwd='+my_hash()+'">Ride the Worm !</a>');
				}
				result.append(gnasir);
			}
			break;
		// Open the Bottom Chamber of the Pyramid
		case "step11":
				result.append('Open the <a target="mainpane" href="beach.php?action=woodencity">Pyramid</a><br>');
				result.append(item_report($item[Staff of Fats], "Staff of Fats, "));
				result.append(item_report($item[ancient amulet], "amulet, "));
				result.append(item_report($item[Eye of Ed], "Eye of Ed"));
				result.append("<br>");
		case "step12":
			if(get_property("pyramidBombUsed")=="false") {
				result.append('Find Ed in the <a target="mainpane" href="pyramid.php">Pyramid</a><br>');
				result.append(item_report($item[tomb ratchet], "tomb ratchets: "+item_amount($item[tomb ratchet])));
				result.append("<br>");
				if(item_amount($item[ancient bomb]) == 0) {
					boolean token = item_amount($item[ancient bronze token]) > 0;
					if(!token) {
						if(get_property("pyramidPosition") != "4")
							result.append("Turn wheel for ");
						else result.append('<a target="mainpane" href="pyramid.php">Get</a> ');
						result.append(item_report(token, "ancient token"));
						result.append("<br>Wait for ");
					} else {
						result.append("Have ");
						result.append(item_report(token, "ancient token"));
						if(get_property("pyramidPosition") != "3")
							result.append("<br>Turn wheel for ");
						else result.append("<br>Get ");
					}
					result.append(item_report($item[ancient bomb]));
				} else {
					if(get_property("pyramidPosition") == "1")
						result.append(item_report(false, "Blow up Lower Chamber now!"));
					else
						result.append("Turn wheel to blow up chamber");
				}
			} else
				result.append('<a target="mainpane" href="pyramid.php">Pyramid</a>: Kill Ed');

		}
		result.append("</td></tr>");
	}

	//L12: War, questL12War
	if(started("questL12War")) {
		result.append("<tr><td>");
		result.append('Fight the <a target="mainpane" href="island.php">Island</a> War:');
		if(get_property("questL12War") == "started") {
			result.append("<br>Start the War... somehow");
		} else {
			result.append('<br><span style="color:purple">Fratboys</span> defeated: '+get_property("fratboysDefeated")+'<br>');
			result.append('<span style="color:green">Hippies</span> defeated: '+get_property("hippiesDefeated"));
		}
		
		if(item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) > 0 ) {
			float flyers = to_float(get_property("flyeredML"))/100.0;
			result.append('<br><a target="mainpane" href="bigisland.php?place=concert">Arena</a> Flyering: ');
			result.append(item_report(flyers >= 100, to_string(flyers,"%.2f")+'%'));
		}
		if(item_amount($item[molybdenum magnet])>0 && get_property("sidequestJunkyardCompleted")=="none" )
			result.append('<br>Find some tools in the <a target="mainpane" href="bigisland.php?place=junkyard">Junkyard</a>');
		if(item_amount($item[barrel of gunpowder]) > 0 && get_property("sidequestLighthouseCompleted")=="none" ) {
			result.append('<br><a target="mainpane" href="bigisland.php?place=lighthouse">SonofaBeach</a> ');
			result.append(item_report($item[barrel of gunpowder], "barrels", 5));
		}
		if ( get_property("sidequestOrchardCompleted")=="none" && (item_amount($item[filthworm hatchling scent gland])>0 || have_effect($effect[Filthworm Larva Stench])>0 || item_amount($item[filthworm drone scent gland])>0 ||have_effect($effect[Filthworm Drone Stench])>0 ||item_amount($item[filthworm royal guard scent gland])>0 ||have_effect($effect[Filthworm Guard Stench])>0) )
		{
			result.append('<br>Destroy the Filthworms in the <a target="mainpane" href="bigisland.php?place=orchard">Orchard</a>');
		}
		if ( to_int(get_property("currentNunneryMeat"))>0 && get_property("sidequestNunsCompleted")=="none" ) {
			result.append('<br><a target="mainpane" href="bigisland.php?place=nunnery">Nunnery</a> Meat found: '+to_string(to_int(get_property("currentNunneryMeat")),"%,d"));
		}
		
		result.append("</td></tr>");
	}

	//sidequestArenaCompleted=none
	//sidequestFarmCompleted=none
	//sidequestJunkyardCompleted=none
	//sidequestLighthouseCompleted=none
	//sidequestNunsCompleted=none
	//sidequestOrchardCompleted=none
	
	//L13: NS, questL13Final
	// check for lair items, tower items, wand
	if (started("questL13Final")) {
		result.append("<tr><td>");
		result.append('Go defeat the <a target="mainpane" href="lair.php">Naughty Sorceress</a>');

		// telescope data
		item [string] tscope;
		//gate items
		tscope["an armchair"] = $item[pygmy pygment];
		tscope["a cowardly-looking man"] = $item[wussiness potion];
		tscope["a banana peel"] = $item[gremlin juice];
		tscope["a coiled viper"] = $item[adder bladder];
		tscope["a rose"] = $item[Angry Farmer candy];
		tscope["a glum teenager"] = $item[thin black candle];
		tscope["a hedgehog"] = $item[super-spiky hair gel];
		tscope["a raven"] = $item[Black No. 2];
		tscope["a smiling man smoking a pipe"] = $item[Mick's IcyVapoHotness Rub];
		tscope["a mass of bees"] = $item[honeypot];
		//tower monetsr items
		tscope["catch a glimpse of a flaming katana"] = $item[frigid ninja stars];
		tscope["catch a glimpse of a translucent wing"] = $item[spider web];
		tscope["see a fancy-looking tophat"] = $item[sonar-in-a-biscuit];
		tscope["see a flash of albumen"] = $item[black pepper];
		tscope["see a giant white ear"] = $item[pygmy blowgun];
		tscope["see a huge face made of Meat"] = $item[meat vortex];
		tscope["see a large cowboy hat"] = $item[chaos butterfly];
		tscope["see a periscope"] = $item[photoprotoneutron torpedo];
		tscope["see a slimy eyestalk"] = $item[fancy bath salts];
		tscope["see a strange shadow"] = $item[inkwell];
		tscope["see moonlight reflecting off of what appears to be ice"] = $item[hair spray];
		tscope["see part of a tall wooden frame"] = $item[disease];
		tscope["see some amber waves of grain"] = $item[bronzed locust];
		tscope["see some long coattails"] = $item[Knob Goblin firecracker];
		tscope["see some pipes with steam shooting out of them"] = $item[powdered organs];
		tscope["see some sort of bronze figure holding a spatula"] = $item[leftovers of indeterminate origin];
		tscope["see the neck of a huge bass guitar"] = $item[mariachi G-string];
		tscope["see what appears to be the North Pole"] = $item[NG];
		tscope["see what looks like a writing desk"] = $item[plot hole];
		tscope["see the tip of a baseball bat"] = $item[baseball];
		tscope["see what seems to be a giant cuticle"] = $item[razor-sharp can lid];
		tscope["see a pair of horns"] = $item[barbed-wire fence];
		tscope["see a formidable stinger"] = $item[tropical orchid];
		tscope["see a wooden beam"] = $item[stick of dynamite];

		//Gate item
		if ( $strings[started, step1] contains get_property("questL13Final")) {
			result.append("<br>");
			if ( get_property("telescopeUpgrades")=="0" || in_bad_moon()) {
				result.append("no telescope");
			}
			else if (get_property("lastTelescopeReset") != my_ascensions()) {
				result.append("no current telescope info");
			}
			else {
				result.append("Gate: ");
				result.append(item_report(tscope[get_property("telescope1")]));
			}
		}

		//Entryway items
		if ( $strings[started, step1] contains get_property("questL13Final") ) {
			result.append("<br>Entryway: ");
			result.append(item_report($item[Boris's key]));
			result.append(", ");
			result.append(item_report($item[Jarlsberg's key]));
			result.append(", ");
			result.append(item_report($item[Sneaky Pete's key]));
			result.append(", ");
			result.append(item_report($item[digital key]));
			result.append(", ");
			result.append(item_report($item[skeleton key]));
			if ( !($strings[Avatar of Boris, Way of the Surprising Fist] contains my_path()) ) {
				result.append(", ");
				result.append(item_report($items[star sword, star staff, star crossbow],"star weapon"));
			}
			result.append(", ");
			result.append(item_report($item[star hat]));
			result.append(", ");
			result.append(item_report($item[Richard's star key]));
			result.append(", ");
			//check for instruments
			result.append(item_report($items[acoustic guitarrr, heavy metal thunderrr guitarrr, stone banjo, Disco Banjo, Shagadelic Disco Banjo, Seeger's Unstoppable Banjo, Crimbo ukulele, Massive sitar, 4-dimensional guitar, plastic guitar, half-sized guitar, out-of-tune biwa, Zim Merman's guitar, dueling banjo],"stringed instrument"));
			result.append(", ");
			result.append(item_report($items[stolen accordion, calavera concertina, Rock and Roll Legend, Squeezebox of the Ages, The Trickster's Trikitixa],"accordion"));
			result.append(", ");
			result.append(item_report($items[tambourine, big bass drum, black kettle drum, bone rattle, hippy bongo, jungle drum],"percussion instrument"));

		}

		//telescope items
		if($strings[started, step1, step2, step3, step4] contains get_property("questL13Final") ) {
			result.append("<br>Tower: ");
			if ( get_property("telescopeUpgrades")=="0" || in_bad_moon()) {
				result.append("no telescope");
			}
			else if (get_property("lastTelescopeReset") != my_ascensions()) {
				result.append("no current telescope info");
			}
			else if ( get_property("telescopeUpgrades").to_int()>=2 ) {
				for ii from 2 to get_property("telescopeUpgrades").to_int() {
					result.append(item_report( tscope[get_property("telescope"+ii)] ));
					if (ii!=1 && ii!=get_property("telescopeUpgrades").to_int()) {
						result.append(", ");
					}
				}
			}
		}

		boolean NSfight = !($strings[Avatar of Boris, Bugbear Invasion, Zombie Slayer, Avatar of Jarlsberg] contains my_path());
		if ( NSfight && $strings[started, step1, step2, step3, step4, step5, step6, step7, step8, step9] contains get_property("questL13Final")) {
			if( my_path()=="Bees Hate You" ) {
				result.append("<br>GMOB: ");
				result.append(item_report($item[antique hand mirror]));
			} else  {
				result.append("<br>NS: ");
				result.append(item_report($item[Wand of Nagamar]));
			}
			result.append("</td></tr>");
		}
	}


	

	//questM13Escape, Subject 37
	if (started("questM13Escape")) {
	//if (contains_text(source,"Subject 37")) {
		result.append("<tr><td>");
		result.append('Help <a target="mainpane" href="cobbsknob.php?level=3">Subject 37</a> escape');	
		result.append("</td></tr>");
	}
	
	
	//L99: questM15Lol (facsimile dictionary)
	if (started("questM15Lol") && my_level()>=9) {
		result.append("<tr><td>");
		result.append('Find the 64735 of <a target="mainpane" href="mountains.php">Rof Lm Fao</a>');	
		result.append("</td></tr>");
	}
	
	
	//L99: Nemesis stuff



	//Sea quests
	
	
	//challenge path stuff
	/*
	if(my_path() == "Bees Hate You") 
		honeypot for gate in NS tower

	if(my_path() == "Avatar of Boris") 
		No star weapon is needed at the lair
	
	if (my_path() == "Avatar of Jarlsberg") 


	if(my_path() == "Trendy") 
	
	
	if (my_path() == "Way of the Surprising Fist" ) 
		No star weapon is needed at the lair
	
	if (my_path() == "Zombie Slayer")
	
	
	if (my_path() == "Bugbear Invasion")
		//Bugbear biodata
		bio [int] biodata;
		biodata[count(biodata)] = new bio("Sleazy Back Alley", "biodataWasteProcessing", 3);
		biodata[count(biodata)] = new bio("Spooky Forest", "biodataMedbay", 3);
		biodata[count(biodata)] = new bio("Bat Hole", "biodataSonar", 3);
		biodata[count(biodata)] = new bio("Knob Laboratory", "biodataScienceLab", 6);
		biodata[count(biodata)] = new bio("The Defiled Nook", "biodataMorgue", 6);
		biodata[count(biodata)] = new bio("Ninja Snowmen", "biodataSpecialOps", 6);
		biodata[count(biodata)] = new bio("Haunted Gallery", "biodataNavigation", 9);
		biodata[count(biodata)] = new bio("Fantasy Airship", "biodataEngineering", 9);
		biodata[count(biodata)] = new bio("Battlefield (Frat Outfit)", "biodataGalley", 9);

 mothershipProgress goes from 0 to 3 as levels are cleared.
 statusMedbay (for example) is 0-x (insufficient bodata collected), open (all
 biodata collected and zone accessible), unlocked (biodata collected but zone
 not yet accessible), or cleared (zone has been cleared.
	
	
	*/


	result.append("</table>");
	
	if(length(result) > 184) { // 184 is the size of an empty table
		chitBricks["tracker"] = result;
		chitTools["tracker"] = "Tracker|tracker.png";
	}

}

void bakeHeader() {

	buffer result;

	//Try to get IE to play nicely in the absense of a proper doctype
	result = chitSource["header"].replace_string('<head>', '<head>\n<meta http-equiv="X-UA-Compatible" content="IE=8" />\n');
#	result = chitSource["header"].replace_string('<head>', '<head>\n<meta http-equiv="X-UA-Compatible" content="IE=8" />\n'
#		+'<script src="//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>\n'
#		+'<script src="clilinks.js"></script>\n');
#	result.replace_string('<script language=Javascript src="/images/scripts/jquery-1.3.1.min.js"></script>',"");
#	result.replace_string('</head>','<script src="//code.jquery.com/jquery-1.7.2.min.js"></script><script src="clilinks.js"></script></head>'); 

	// Add doctype to escape quirks mode
	result.replace_string('<html>', '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n<html>');
	
	//Add CSS to the <head> tag
	result.replace_string('</head>', '\n<link rel="stylesheet" href="chit.css">\n</head>');
	
	//Add JavaScript just before the <body> tag. 
	//Ideally this should go into the <head> tag too, but KoL adds jQuery outside of <head>, so that won't work
	result.replace_string('<body', '\n<script type="text/javascript" src="chit.js"></script>\n<body');
	
	//Remove KoL's javascript familiar picker so that it can use our modified version in chit.js
	result.replace_string('<script type="text/javascript" src="/images/scripts/familiarfaves.20120307.js"></script>', '');
	
	// Dunno... I'm not sure why KoLmafia adds these... Removing them is probably a mistake...
	#result = result.replace_string('<script language="Javascript" src="/basics.js"></script><link rel="stylesheet" href="/basics.css" />', '');
	result.replace_string('onload="updateSafetyText();" ', '');
	
	chitBricks["header"] = result.to_string();
		
}

void bakeFooter() {
	buffer result;
	result.append(chitSource["footer"]);

	chitBricks["footer"] = result.to_string();
		
}

//Parse the page and break it up into smaller consumable chunks
boolean parsePage(buffer original) {
	string source = to_string(original);
	matcher parse;

	// Familiar: Could be before or after effects block
	parse = create_matcher("(<p><span class=small><b>Familiar:.+?>none</a>\\)</span>"  // familiar (none)
		+ "|<table width\\=90%.+?Familiar:.+?</table></center>"  // regular familiar
		+ "|<b>Clancy</b>.*?</font></center>"  // Clancy (Avatar of Boris)
		+ "|<font size=2><b>Companion:</b>.*?(?:</b></font>|none\\))"  // (Avatar of Jarlsberg)
		+ "|<a target=mainpane href=main.php\\?action=motorcycle>.*?</b>"  // (Avatar of Sneaky Pete)
		+ ")", source);
	if(find(parse)) {
		chitSource["familiar"] = parse.group(1);
		source = parse.replace_first("");
	}
	
	// Parse the beginning of the page
	parse = create_matcher("(^.+?)(<center id='rollover'.+?</center>)(.*?)(<table align=center><tr><td align=right>Muscle:.*?)((?:<Center>Extreme Meter:|<img src=).*?</table>(?:.*?axelottal.*?</table>)?)", source);
	if(find(parse)) {
		// Header: Includes everything up to and including the body tag
		chitSource["header"] = parse.group(1);
		//Rollover: Edited because I want the pop-up to fit the text
		chitSource["rollover"] = parse.group(2).replace_string('doc("maintenance")', 'poop("doc.php?topic=maintenance", "documentation", 560, 518, "scrollbars=yes,resizable=no")');
		#matcher test=create_matcher("rollover \= (\\d+).*?rightnow \= (\\d+)",chitSource["header"]);if(test.find())chitSource["header"]=chitSource["header"].replace_string(test.group(1),to_string(to_int(test.group(2))+30));
		//Character: Name/Class/Level etc
		chitSource["character"] = parse.group(3);
		// Stats: Muscle/Mysticality/Moxie/Fullness/Drunkenness & Fury
		chitSource["stats"] = parse.group(4);
		// Health: HP/MP/Meat/Advs/PvP Fights & Extreme Meter. In Zombie Slayer, this inclusdes Horde
		// (?:.*?axelottal\\.gif.*?</table>)? is the spooky little girl, Axel
		chitSource["health"] = parse.group(5);
		// delete all matches
		source = parse.replace_first("");
	} else return vprint("CHIT: Error parsing start of charpane", "red", -1);

	//Footer: Includes everything after the close body tag
	parse = create_matcher("(</body></html>.*)", source);
	if(find(parse)) {
		chitSource["footer"] = parse.group(1);
		source = parse.replace_first("");
	} else return vprint("CHIT: Error parsing footer", "red", -1);
	
	// Quests: May or may not be present
	parse = create_matcher('(<center id="nudgeblock">.*?(?:</script>|</tr></table><p></center>))', source);
	if(find(parse)) {
		chitSource["quests"] = parse.group(1);
		source = parse.replace_first("");
	}
	
	// This is for help finding current location (below)
	location parseLoc(string loc) {
		if(to_location(loc) != $location[none])
			return to_location(loc);
		switch(loc) {	// Some of these are really tough for KoLmafia to deal with!
		case "(none)":
			return $location[none];
		case "The Orcish Frat House":
			return $location[Frat House];
		case "The Hippy Camp":
			return $location[Hippy Camp];
		}
		return get_property("lastAdventure").to_location();
	}
	// Recent Adventures: May or may not be present
	parse = create_matcher('<center><font size=2>.+?Last Adventure:.+?target=mainpane href="[^"]+">([^<]+)</a>.+?</center>', source);
	if(find(parse)) {
		chitSource["trail"] = parse.group(0);
		lastLoc = parse.group(1).parseLoc();  // Parse out last location for use by other functions
		source = parse.replace_first("");
		// Shorten some unreasonablely lengthy locations
		chitSource["trail"] = chitSource["trail"]
			.replace_string("The Castle in the Clouds in the Sky", "Giant's Castle")
			.replace_string(" Floor)", ")")  										// End of Castle
			.replace_string("McMillicancuddy", "Farm") 								// McMillicancuddy's various farm locations
			.replace_string("Haunted Wine Cellar", "Wine Cellar")
			.replace_string("The Enormous Greater-Than Sign", "Greater-Than Sign")
			.replace_string("The Penultimate Fantasy Airship", "Fantasy Airship")
			.replace_string("An Overgrown", "Overgrown")							// An Overgrown Shrine
			.replace_string("Next to that Barrel with Something Burning in it", "Barrel with Something Burning")
			.replace_string("Near an Abandoned Refrigerator", "Abandoned Refrigerator")
			.replace_string("Over Where the Old Tires Are", "Where the Old Tires Are")
			.replace_string("Out by that Rusted-Out Car", "Rusted-Out Car")
			.replace_string("Cobb's Knob Menagerie, Level", "Menagerie, Level")		// All three menagerie levels
			.replace_string('">The ', '">'); 										// Remove leading "The " from all locations
	}

	// Old Man's Bathtub Adventure. May or may not be present
	parse = create_matcher("<table>(<tr><td class=small align=right><b>Crew:</b>.+?)</table>", source);
	if(find(parse)) {
		chitSource["bathtub"] = parse.group(1);
		source = parse.replace_first("");
	}

	// Mood, Buffs, Intrinsic Effects
	parse = create_matcher('<b><font size=2>(?:Intrinsics|Effects):(.+?)?(<table><tr><td.+?</td></tr></table>)'
		+ '(?:.*?<b><font size=2>(?:Intrinsics|Effects):(.+?)?(<table><tr><td.+?</td></tr></table>))?'
		+ '(?:.*?(?:Recently Expired Effects.+?</tr>)(.+?</tr></table>))?' 			// This is a KoL option
		, source);
	if(find(parse)) {
		chitSource["mood"] = parse.group(1) + parse.group(3); 						// Only one of those might contain useful data
		chitSource["effects"] = parse.group(2) + parse.group(4) + parse.group(5); 	// Effects plus Instrinsics, plus recently expired effects
		source = parse.replace_first("");
	}
	
	// Pasta Thrall?
	parse = create_matcher('(<center><font size=2><b>Pasta Thrall:</b></font>.+?</font>)', source);
	if(find(parse)) {
		chitSource["thrall"] = parse.group(1);
		source = parse.replace_first("");
	}

	// Refresh Link: <center><font size=1>[<a href="charpane.php">refresh</a>]</font>
	parse = create_matcher("(<center><font.+?refresh.+?</font>)", source);
	if(find(parse)) {
		chitSource["refresh"] = parse.group(1);
		source = parse.replace_first("");
	} else return vprint("CHIT: Error Parsing Refresh", "red", -1);
	
	//Whatever is left
	chitSource["wtfisthis"] = source;

	return true;
}

void bakeValhalla() {

	buffer result;
	string myName = my_name();
	string inf = '<img src="/images/otherimages/inf_small.gif">';
	string karma = "??";

	matcher nameMatcher = create_matcher("<b>(.*?)</b></a><br>Level", chitSource["character"]);
	if(find(nameMatcher))
		myName = group(nameMatcher, 1);
	#<td align=center><img src="http://images.kingdomofloathing.com/itemimages/karma.gif" width=30 height=30 alt="Karma" title="Karma"><br>12,620</td>
	matcher karmaMatcher = create_matcher('title="Karma"><br>(.*?)</td>', chitSource["wtfisthis"]);
	if(find(karmaMatcher))
		karma = group(karmaMatcher, 1);

	result.append('<table id="chit_character" class="chit_brick nospace">');
	result.append('<tr>');
	result.append('<th colspan="3"><a target="mainpane" href="charsheet.php">' + myName + '</a></th>');
 	result.append('</tr>');
	
	result.append('<tr>');
	result.append('<td rowspan="4" class="avatar"><a target="mainpane" href="charsheet.php"><img src="/images/otherimages/spirit.gif"></a></td>');
	result.append('<td class="label">Astral Spirit</a></td>');
	result.append('<td class="level" rowspan="2" style="background-color:white"><img src="/images/otherimages/inf_large.gif"></td>');
	result.append('</tr>');

	result.append('<tr>');
	result.append('<td class="info">Valhalla</td>');
	result.append('</tr>');
	result.append('<tr class="section">');
	result.append('<td class="label">Karma</td>');
	result.append('<td class="turns" rowspan="2" style="background-color:white"><img src="/images/itemimages/karma.gif"></td>');
	result.append('</tr>');	

	result.append('<tr>');
	result.append('<td class="label" style="color:darkred;font-weight:bold">' + karma + '<td>');
	result.append('</tr>');
			
	result.append('</table>');

	
	string progress = "";
	result.append('<table id="chit_stats" class="chit_brick nospace">');

	//Heading
	result.append('<thead>');
	result.append('<tr>');
	result.append('<th colspan="3">My Stats</th>');
	result.append('</tr>');
	result.append('</thead>');

	progress = progressCustom(0, 10000, "&infin; / &infin;", -1, false);
	
	//Muscle
	result.append('<tr>');
	#result.append('<td class="label" width="40px">Muscle</td>');
	#result.append('<td class="info" width="60px">'+inf+'</td>');
	result.append('<td class="label">Muscle</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');
	
	//Mysticality
	result.append('<tr>');
	result.append('<td class="label">Myst</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');
	
	//Moxie
	result.append('<tr>');
	result.append('<td class="label">Moxie</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');

	//Spleen
	result.append('<tr class="section">');
	result.append('<td class="label">Spleen</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');

	//Stomach
	result.append('<tr>');
	result.append('<td class="label">Stomach</td>');
	result.append( '<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');

	//Liver
	result.append('<tr>');
	result.append('<td class="label">Liver</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');

	//HP
	result.append('<tr class="section">');
	result.append('<td class="label">HP</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');
	
	//MP
	result.append('<tr>');
	result.append('<td class="label">MP</td>');
	result.append('<td class="info">'+inf+'</td>');
	result.append('<td class="progress">' + progress + '</td>');
	result.append('</tr>');
	
	result.append('</table>');

	chitBricks["valhalla"] = result;

}

void bakeBricks() {

	bakeHeader();
	bakeFooter();

	// Standardize brick layouts
	foreach layout in $strings[chit.roof.layout, chit.walls.layout, chit.floor.layout, chit.toolbar.layout, chit.stats.layout, chit.effects.layout]
		vars[layout] = vars[layout].to_lower_case().replace_string(" ", "");
	

	if (inValhalla) {
		bakeValhalla();
	} else {
		foreach layout in $strings[roof, walls, floor, toolbar] {
			string [int] bricks = split_string(vars["chit." + layout + ".layout"],",");
			string brick;
			for i from 0 to (bricks.count()-1) {
				brick = bricks[i];
				if (!(chitBricks contains brick)) {
					switch (brick) {
						case "character":	bakeCharacter();	break;
						case "stats":		bakeStats();		break;
						case "familiar":	bakeFamiliar();		break;
						case "florist":		bakeFlorist();		break;
						case "trail":		bakeTrail();		break;
						case "quests":		bakeQuests();		break;
						case "effects":		bakeEffects();		break;
						case "mcd":			bakeMCD();			break;
						case "substats":	bakeSubstats();		break;
						case "organs":		bakeOrgans();		break;
						case "modifiers":	bakeModifiers();	break;
						case "elements":	bakeElements();		break;
						case "tracker":		bakeTracker();		break;
						case "thrall":		bakeThrall();		break;
						
						// Reserved words
						case "helpers": case "update": break;
						
						// Unknown brick is possible plugin if it begins with "plugin". Try to dynamically load it.
						// note: casing MUST match between brickname and bakebrickname function.
						default:
							if(index_of(brick, "plugin") == 0)
								chitBricks[brick] = call buffer brick();  //e.g. pluginOutfits()
							break;
					}
				}
			}
		}
	}

	bakeToolBar();
	
}

buffer addBricks(string layout) {

	buffer result;
	if (layout != "") {
		string [int] bricks = split_string(layout,",");
		string brick;
		for i from 0 to (bricks.count()-1) {
			brick = bricks[i];
			switch (brick) {
				case "toolbar":	
				case "header":	
				case "footer":	
					break;	//Special Bricks that are inserted manually in the correct places
				default: 
					result.append(chitBricks[brick]);
			}
		}
	}
	return result;

}

buffer buildRoof() {
	string layout = vars["chit.roof.layout"];
	
	buffer result;
	result.append('<div id="chit_roof" class="chit_chamber">');
	if(inValhalla)
		result.append(chitBricks["valhalla"]);
	else if(layout != "")
		result.append(addBricks(layout));
	result.append('</div>');
	return result;
}

buffer buildWalls() {
	string layout = vars["chit.walls.layout"];

	buffer result;
	result.append('<div id="chit_walls" class="chit_chamber">');
	result.append(chitSource["rollover"]);
	if(layout.length() > 0 && !inValhalla)
		result.append(addBricks(layout));
	result.append('</div>');
	return result;
}

buffer buildFloor() {
	string layout = vars["chit.floor.layout"];
	
	buffer result;
	result.append('<div id="chit_floor" class="chit_chamber">');
	if(!inValhalla)
		result.append(addBricks(layout));
	result.append(chitBricks["toolbar"]);
	result.append('</div>');
	return result;
}

buffer buildCloset() {
	buffer result;
	
	if(inValhalla)
		return result;
	
	result.append('<div id="chit_closet">');

	foreach key,value in chitPickers
		result.append(value);
	
	string layout = vars["chit.toolbar.layout"];
	
	string [int] bricks = split_string(layout,",");
	string brick;
	for i from 0 to (bricks.count()-1) {
		brick = bricks[i];
		switch (brick) {
			case "helpers":
			case "quests":
			case "mcd":
			case "trail":
			case "substats":
			case "organs":
			case "modifiers":
			case "elements":
			case "tracker":
			case "update":
				if ((chitBricks contains brick) && (chitBricks[brick] != "")) {
					result.append('<div id="chit_tool' + brick + '" class="chit_skeleton" style="display:none">');
					result.append(chitBricks[brick]);
					result.append('</div>');
				}
				break;
			default: 
				break;	//Special Bricks that are inserted manually in the correct places
		}
	}

	result.append('</div>');
	return result;
}

buffer buildHouse() {
	buffer house;
	house.append('<div id="chit_house">');
	house.append(buildRoof());
	house.append(buildWalls());
	house.append(buildFloor());
	house.append(buildCloset());
	house.append('</div>');
	return house;
}

buffer modifyPage(buffer source) {
	if(source.length() < 6)
		return source.append('<center><a href="charpane.php" title="Reload"><img src="' + imagePath + 'refresh.png"></a> &nbsp;Reload after cutscene...</center>');
	if(vars["chit.disable"]=="true")
		return source.replace_string('[<a href="charpane.php">refresh</a>]', '[<a href="'+ sideCommand('zlib chit.disable = false') +'">Enable ChIT</a>] &nbsp; [<a href="charpane.php">refresh</a>]');
	//Set default values for zlib variables
	setvar("chit.checkversion", true);
	setvar("chit.disable",false);
	setvar("chit.character.avatar", true);
	setvar("chit.character.title", true);
	setvar("chit.quests.hide", false);
	setvar("chit.familiar.hats", "spangly sombrero,sugar chapeau,Chef's Hat,party hat");
	setvar("chit.familiar.pants", "spangly mariachi pants,double-ice britches,BRICKO pants,pin-stripe slacks,Studded leather boxer shorts,Monster pants,Sugar shorts");
	setvar("chit.familiar.weapons", "time sword,batblade,Hodgman's whackin' stick,astral mace,Maxwell's Silver Hammer,goatskin umbrella,grassy cutlass,dreadful glove,Stick-Knife of Loathing,Work is a Four Letter Sword");
	setvar("chit.familiar.protect", false);
	setvar("chit.familiar.showlock", false);
	setvar("chit.effects.classicons", "none");
	setvar("chit.effects.showicons", true);
	setvar("chit.effects.modicons", true);
	setvar("chit.effects.layout","songs,buffs,intrinsics");
	setvar("chit.effects.usermap",false);
	setvar("chit.effects.describe",true);
	setvar("chit.helpers.wormwood", "stats,spleen");
	setvar("chit.helpers.dancecard", true);
	setvar("chit.helpers.semirare", true);
	setvar("chit.helpers.spookyraven", true);
	setvar("chit.roof.layout","character,stats");
	setvar("chit.walls.layout","helpers,thrall,effects");
	setvar("chit.floor.layout","update,familiar");
	setvar("chit.stats.showbars",true);
	setvar("chit.stats.layout","muscle,myst,moxie|hp,mp,axel|mcd|trail,florist");
	setvar("chit.toolbar.layout","trail,quests,modifiers,elements,organs");
	setvar("chit.toolbar.moods","true");
	setvar("chit.kol.coolimages",true);
	
	// Check var version.
	if(get_property("chitVarVer").to_int() < 1) {
		if(!vars["chit.stats.layout"].contains_text("florist") && vars["chit.stats.layout"].contains_text("trail"))
			vars["chit.stats.layout"] = vars["chit.stats.layout"].replace_string("trail", "trail,florist");
		if(!contains_text(vars["chit.walls.layout"], "thrall")) {
			if(length(vars["chit.walls.layout"]) >= 7 && substring(vars["chit.walls.layout"], 0, 7) == "helpers")
				vars["chit.walls.layout"] = vars["chit.walls.layout"].replace_string("helpers", "helpers,thrall");
			else vars["chit.walls.layout"] = "thrall,"+vars["chit.stats.layout"];
		}
		updatevars();
		set_property("chitVarVer", "1");
	}
	
	//Check for updates (once a day)
	if(svn_exists("mafiachit")) {
		if(get_property("_svnUpdated") == "false" && !svn_at_head("mafiachit")) {
			if(get_property("_chitChecked") != "true")
				print("Character Info Toolbox has become outdated. It is recommended that you update it from SVN...", "red");
			bakeUpdate(svn_info("mafiachit").revision, "Revision ", svn_info("mafiachit").last_changed_rev);
			set_property("_chitChecked", "true");
		}
	} else checkVersion("Character Info Toolbox", chitVersion, 7594);
	
	if( index_of(source, 'alt="Karma" title="Karma"><br>') > 0 ) {
		inValhalla = true;
	}
	if( contains_text(source, "<hr width=50%>") ) {
		isCompact = true;
		vprint("CHIT: Compact Character Pane not supported", "blue", 1);
	}
	
	if(isCompact || !parsePage(source))
		return source;

	//Set default values for toolbar icons
	chitTools["helpers"] = "No helpers available|helpersnone.png";
	chitTools["quests"] = "No quests available|questsnone.png";
	chitTools["mcd"] = "MCD not available|mcdnone.png";
	chitTools["trail"] = "No recent adventures|trailnone.png";
	chitTools["substats"] = "Substats|stats.png";
	chitTools["organs"] = "Consumption|organs.png";
	chitTools["modifiers"] = "Modifiers|modifiers.png";
	chitTools["elements"] = "Elements|elements.png";
	chitTools["tracker"] = "No trackers available|questsnone.png";
	chitTools["moods"] = "Change Moods|select_mood.png";
	chitTools["update"] = "New version available|update.png";
	
	// Bake all the bricks we're gonna need
	bakeBricks();
	
	//Build the house
	buffer page;
	page.append(chitBricks["header"]);
	page.append(buildHouse());
	page.append(chitBricks["footer"]);
	
	return page;

}

void main() {
	visit_url().modifyPage().write();
}
