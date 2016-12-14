script "Character Info Toolbox";
notify "Bale";
since r17526; // handle proper item disambiguation for I Love Me, Staff of Fats, ancient amulet & Eye of Ed

import "zlib.ash";
import "chit_global.ash";
import "chit_brickFamiliar.ash"; // This has to be before chit_brickGear due to addItemIcon() and... weirdly enough pickerFamiliar()
import "chit_brickGear.ash";
import "chit_brickTracker.ash";
import "chit_brickTerminal.ash";

/************************************************************************************
CHaracter Info Toolbox
A character pane relay override script
By Chez up to v 0.6.0
Everything after that by Bale
As of r241 on SVN, some revisions also by soolar

Additional major contributors:
	AlbinoRhino - Provided invaluable assistance with CSS & Javascript
	ckb - Created the tracker brick and effect description code
	bordemstirs - Created the florist brick and moved the frams to make charpane taller
	soolar - Added the gear brick, and some general tweaks/polish

For Help and Documentation, you will find that in your KoLmafia/data directory:
	/data/chit_ReadMe.txt

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
		rewards[$location[The Outskirts of Cobb's Knob]] = "lunchbox.gif|Knob Goblin lunchbox|0";
		rewards[$location[The Limerick Dungeon]] = "eyedrops.gif|cyclops eyedrops|0";
	if($strings[step1, step2, finished] contains get_property("questL05Goblin"))
		rewards[$location[Cobb's Knob Harem]] = "vial.gif|scented massage oil (3)|20";
	if(get_property("lastCastleTopUnlock").to_int() == my_ascensions())
		rewards[$location[The Castle in the Clouds in the Sky (Top Floor)]] = "inhaler.gif|Mick's IcyVapoHotness Inhaler|85";
	if(get_property("grimstoneMaskPath") == "gnome")
		rewards[$location[Ye Olde Medievale Villagee]] = "leather.gif|3 each: Straw, Leather and Clay|0";
	if(get_property("kingLiberated") == "true") {
		rewards[$location[An Octopus's Garden]] = "bigpearl.gif|Fight a moister oyster|148";
	} else {
		if(available_amount($item[stone wool]) < 2 && get_property("lastTempleUnlock").to_int() == my_ascensions() && !($strings[step3, finished] contains get_property("questL11Worship")))
			rewards[$location[The Hidden Temple]] = "stonewool.gif|Fight Baa'baa'bu'ran|5";
		if(!have_outfit("Knob Goblin Elite Guard Uniform") && get_property("lastDispensaryOpen").to_int() != my_ascensions() && ($strings[step1, step2, finished] contains get_property("questL05Goblin"))
		  && my_path() != "Way of the Surprising Fist" && my_path() != "Way of the Surprising Fist")
			rewards[$location[Cobb's Knob Kitchens]] = "elitehelm.gif|Fight KGE Guard Captain|20";
		if(!have_outfit("Mining Gear") && my_path() != "Way of the Surprising Fist" && ($strings[started, step1] contains get_property("questL08Trapper")))
			rewards[$location[Itznotyerzitz Mine]] = "mattock.gif|Fight Dwarf Foreman|53";
		if(get_property("questL11Palindome") != "finished" && item_amount($item[Talisman o' Namsilat]) == 0) {
			rewards[$location[The Copperhead Club]] = "rocks_f.gif|Flamin' Whatshisname (3)|104";
			rewards[$location[A Mob of Zeppelin Protesters]] = "bansai.gif|Choice of Protesting|104";
		}
	}
	
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

string helperXiblaxian() {
	
	// turns to next drop - taken from kol wiki - 11, 16, 21...
	int xidrops = get_property("_holoWristDrops").to_int();
	int xiprog = get_property("_holoWristProgress").to_int() + 1;
	int xinext = 11 + 5*xidrops;
	int countdown = xinext - xiprog;

	int circuit = 3-available_amount($item[xiblaxian circuitry]);
	int alloy = 1-available_amount($item[xiblaxian alloy]);
	int polymer = 1-available_amount($item[xiblaxian polymer]);
	
	if(countdown == 0 && !can_interact() && get_counters("Xiblaxian Material", 0, 0) == "")
		cli_execute("counters add 0 Xiblaxian Material holoputer.gif");

	// Build a buffer that creates a bar similar to the fortune cookie
	buffer result;
	result.append('<table id="chit_xibalaxian" class="chit_brick nospace">');
	result.append('<tr class="effect"');
	if(countdown == 0)
		result.append(' style="background-color: khaki"');
	// Icon
	result.append('><td class="icon"><a target=mainpane href="chit_xiblaxian.php"><img src="/images/itemimages/holoputer.gif"></a></td>');
	// Text
	if(countdown == 0) {
		string bold_if(string text, boolean condition) {
			if(condition)
				return '<b>' + text + '</b>';
			else
				return text;
		}
		location currLoc = my_location();
		boolean circ = currLoc.environment == "indoor";
		boolean poly = currLoc.environment == "outdoor" || currLoc.environment == "underwater";
		boolean alloy = currLoc.environment == "underground";
		result.append('<td class="info" style="text-align:right;">');
		result.append(bold_if('Circuit (indoor):', circ));
		result.append('<br />');
		result.append(bold_if('Polymer (outdoor):', poly));
		result.append('<br />');
		result.append(bold_if('Alloy (under):', alloy));
		result.append('</td><td class="info">');
		result.append(bold_if(available_amount($item[xiblaxian circuitry]), circ));
		result.append('<br />');
		result.append(bold_if(available_amount($item[xiblaxian polymer]), poly));
		result.append('<br />');
		result.append(bold_if(available_amount($item[xiblaxian alloy]), alloy));
		result.append('</td>');
	} else {
		result.append('<td class="info">Xiblaxian <br />Wrist-puter</td>');
		// Counter
		result.append('<td class="info">' + xiprog + ' /' + xinext + '</td>');
		result.append('</tr>');
		result.append('</table>');
	}
	
	chitTools["helpers"] = "You have some expired counters|helpers.png";
	return result.to_string();
}

// elementchart1.gif or elementchart2.gif are valid values for img
void addElementMap(buffer result, string img) {
	result.append('<img src="');
	result.append(imagePath);
	result.append(img);
	
	if     (have_effect($effect[Spirit of Peppermint]) > 0) result.append("cold");
	else if(have_effect($effect[Spirit of Bacon Grease]) > 0) result.append("sleaze");
	else if(have_effect($effect[Spirit of Garlic]) > 0) result.append("stench");
	else if(have_effect($effect[Spirit of Cayenne]) > 0) result.append("hot");
	else if(have_effect($effect[Spirit of Wormwood]) > 0) result.append("spooky");
	
	result.append('.gif" width="190" height="190"');
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
	picker.addElementMap("elementchart2");
	picker.append('</td></tr>');
	
	picker.append('</table></div>');
	chitPickers["flavour"] = picker;
}

buff parseBuff(string source) {
	buff myBuff;

	boolean doArrows = get_property("relayAddsUpArrowLinks").to_boolean();
	boolean showIcons = (vars["chit.effects.showicons"]=="false" || isCompact)? false: true;

	string columnIcon, columnTurns, columnArrow;
	string spoiler, style;

	matcher parse = create_matcher('(?:<td[^>]*>(.*?)</td>)?<td[^>]*>(<.*?itemimages/([^"]*)"(?:.*?eff\\("([^"]+)"\\))?.*?)</td><td[^>]*>[^>]*>(.*?) +\\((?:(.*?), )?((?:<a[^>]*>)?(\\d+||&infin;)(?:</a>)?)\\)(?:(?:</font>)?&nbsp;(<a.*?</a>))?.*?</td>', source);
	// The ? stuff at the end is because those arrows are a mafia option that might not be present
	if(parse.find()) {
		columnIcon = parse.group(2);	// This is full html for the icon
		
		//ckb: eliminate the heigh and width callout so we can controll it with css instead
		columnIcon = replace_string(columnIcon,"width=30 height=30","");
		
		myBuff.effectImage = parse.group(3);
		myBuff.eff = parse.group(4).desc_to_effect();
		myBuff.effectName = parse.group(5);
		spoiler = parse.group(6);		// This appears for "Form of...Bird!" and "On the Trail"
		if(get_campground() contains $item[jar of psychoses (The Crackpot Mystic)] && $strings[Consumed by Anger, Consumed by Doubt, Consumed by Fear, Consumed by Regret] contains myBuff.effectName)
			columnTurns = '<a target="mainpane" href="/place.php?whichplace=junggate_3&action=mystic_face" title="This... This isn\'t me.">'+parse.group(8)+'</a>';
		else
			columnTurns = parse.group(7).replace_string('title="Use a remedy to remove', 'title="SGEEAs Left: '+ item_amount($item[soft green echo eyedrop antidote]) +'\nUse a remedy to remove');
		if(parse.group(8) == "&infin;") {	// Is it intrinsic?
			myBuff.effectTurns = -1;
			myBuff.isIntrinsic = true;
		} else
			myBuff.effectTurns = parse.group(8).to_int();
		// There are various problems with KoL's native uparrows. Only use them if KoL's uparrows are missing
		if(parse.group(9) != "")
			columnArrow = parse.group(9).replace_string("/images/", imagePath).replace_string("up.gif", "up.png");
		else if(parse.group(1) != "" ) {
			doArrows = true;			// In case they were disabled in KoLmafia. Make a column for it.
			columnArrow = parse.group(1);
		}
	}
	string effectAlias = myBuff.effectName;
	
	// Add MP or item cost to increase effect
	matcher howUp = create_matcher("cmd\\=((cast 1 )?(.+?))&pwd", url_decode(columnArrow));
	if(howUp.find()) {
		string upCost = howUp.group(1);
		if(howUp.group(2) != "") {
			skill upSkill = howUp.group(3).to_skill();
			if(have_skill(upSkill)) {
				if(mp_cost(upSkill) > 0)
					upCost = mp_cost(upSkill)+' mp to cast '+upSkill;
				else if(soulsauce_cost(upSkill) > 0)
					upCost = soulsauce_cost(upSkill)+' sauce to cast '+upSkill;
				else if(thunder_cost(upSkill) > 0)
					upCost = thunder_cost(upSkill)+' dB to cast '+upSkill;
				else if(rain_cost(upSkill) > 0)
					upCost = rain_cost(upSkill)+' drops to cast '+upSkill;
				else if(lightning_cost(upSkill) > 0)
					upCost = lightning_cost(upSkill)+' bolts to cast '+upSkill;
			} else upCost = "You lack the skill: "+howUp.group(3);
		}
		columnArrow = columnArrow.replace_string('Increase rounds of', upCost+'\nIncrease rounds of');
	}
	
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
	if($effects[Spirit of Cayenne, Spirit of Peppermint, Spirit of Garlic, Spirit of Wormwood, Spirit of Bacon Grease] contains myBuff.eff) {
		columnIcon = '<a class="chit_launcher" rel="chit_pickerflavour" href="#">' + columnIcon + '</a>';
		columnTurns = '<a class="chit_launcher" rel="chit_pickerflavour" href="#">&infin;</a>';
		pickerFlavour();
	}
	
	// Check Mirror picker
	if($effects[Slicked-Back Do, Pompadour, Cowlick, Fauxhawk] contains myBuff.eff)
		columnTurns = '<a target="mainpane" href="skills.php?pwd='+my_hash()+'&action=Skillz&whichskill=15017&skillform=Use+Skill&quantity=1">&infin;</a>';

	//Add spoiler info
	if(length(spoiler) > 0)
		effectAlias += " "+spoiler;
	// Fix for blank "On the Trail" problem.
	if(length(effectAlias) == 0)
		effectAlias = myBuff.effectName;
	
	// Add spoiler info that mafia doesn't provide
	if(myBuff.effectName.contains_text("Romantic Monster window"))
		effectAlias = effectAlias.replace_string("Romantic Monster", get_property("romanticTarget"));
	else if(myBuff.effectName.contains_text("Digitize Monster"))
		effectAlias = "Digitized " + get_property("_sourceTerminalDigitizeMonster") + " #" +
                  (to_int(get_property("_sourceTerminalDigitizeMonsterCount")) + 1);
	
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
	if(!to_boolean(vars["chit.effects.describe"])) {
		string efMod = parseEff(myBuff.eff, false);
		if(length(efMod)>0) {
			result.append(' title="');
			result.append(efMod);
			result.append('"');
		}
	}
	result.append('>');
	if(showIcons) 
		result.append('<td class="icon">' + columnIcon + '</td>');
	result.append('<td class="info"');
	if(doArrows && myBuff.isIntrinsic)
		result.append(' colspan="2"');
	result.append('>');
	result.append(effectAlias);
	
	//ckb: Add modification details for buffs and effects
	if(to_boolean(vars["chit.effects.describe"])) {
		string efMod = parseEff(myBuff.eff);
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
	static {
		string mapfile = "chit_effects.txt";
		if(vars["chit.effects.usermap"] == "true")
			mapfile = "chit_effects_" + my_name() + ".txt";
		if(!file_to_map(mapfile, chitEffectsMap))
			vprint("CHIT: Effects map could not be loaded (" + mapfile + ")", "red", 1);
	}
	
	buff currentbuff;
	
	//Regular Effects
	matcher rowMatcher = create_matcher("<tr>(.*?)</tr>", chitSource["effects"]);
	while (find(rowMatcher)) {
		currentbuff = rowMatcher.group(1).parseBuff();

		if (currentBuff.isIntrinsic) {
			intrinsics.append(currentbuff.effectHTML);
		} else if (showSongs && $strings[at, aob, aoj, awol] contains currentbuff.effectType) {
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
	
	// Add helper for Xiblaxian holo-wrist-puter
	if(vars["chit.helpers.xiblaxian"] != "false" && have_equipped($item[Xiblaxian holo-wrist-puter]))
		helpers.append(helperXiblaxian());
	
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
	result.addElementMap("elementchart1");
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
	if(target.find())
		url = target.group(1);
	if(url == "place.php?whichplace=town_right" && source.contains_text("Investigating a Plaintive Telegram"))
		url = "place.php?whichplace=town_right&action=townright_ltt";
	result.append('<tr><th><a class="visit" target="mainpane" href="');
	result.append(url);
	result.append('"><img src="');
	result.append(imagePath);
	result.append('trail.png">Last Adventure</a></th></tr>');
	
	//Last Adventure
	target = create_matcher('target=mainpane href="(.*?)">(.*?)</a><br></font>', source);
	if(target.find()) {
		result.append('<tr><td class="last"><a class="visit" target="mainpane" href="');
		result.append(target.group(1));
		result.append('">');
		result.append(target.group(2));
		result.append('</a></td></tr>');
	}
	
	//Other adventures
	matcher others = create_matcher("<nobr>(.*?)</nobr>", source);
	while (find(others)) {
		target = create_matcher('target=mainpane href="(.*?)">(.*?)</a>', group(others, 1));
		if (find(target)) {
			result.append('<tr><td><a class="visit" target="mainpane" href="');
			result.append(target.group(1));
			result.append('">');
			result.append(target.group(2));
			result.append('</a></td></tr>');
		}
	}
	
	result.append("</table>");
	
	chitBricks["trail"] = result;
	chitTools["trail"] = "Recent Adventures|trail.png";

}

static { string [thrall] [int] pasta;
	pasta[$thrall[Vampieroghi]][1] = "Attacks and heals";
	pasta[$thrall[Vampieroghi]][5] = "Dispels bad effects";
	pasta[$thrall[Vampieroghi]][10] = "+60 max HP";
	pasta[$thrall[Vermincelli]][1] = "Restores MP after combat";
	pasta[$thrall[Vermincelli]][5] = "Attacks and poisons enemy";
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
		if(t.level == 0) { // If this is a first time summmons, I want to see it in mainpain!
			url.append('<a target=mainpane class="change" href="runskillz.php?action=Skillz&whichskill=');
			url.append(to_int(s));
			url.append('&pwd=');
			url.append(my_hash());
			url.append("&quantity=1&targetplayer=");
			url.append(my_id());
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

void bakeThrall() {
	if(my_class() != $class[Pastamancer] || my_path() == "Nuclear Autumn") return;
	buffer result;
	void bake(string lvl, string name, string type, string img) {
		if(to_boolean(vars["chit.thrall.showname"])) {
			string temp = name;
			name = type;
			type = temp;
		}
		
		result.append('<table id="chit_thrall" class="chit_brick nospace">');
		result.append('<tr><th title="Thrall Level">');
		if(lvl != "")
			result.append('Lvl.&nbsp;');
		result.append(lvl);
		result.append('</th><th title="Pasta Thrall"><a title="');
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

void bakeVYKEA() {
	string img_margin() {
		switch(get_property("_VYKEACompanionType")) {
		case "couch":
		case "dishrack":
			return 'top:-20';
		case "dresser":
		case "bookshelf":
			return 'top:-10';
		case "ceiling fan":
			return 'bottom:-20';
		}
		return 'top:0';
	}
	vykea v = my_vykea_companion();
	if(v != $vykea[none]) {
		buffer result;
		result.append('<table id="chit_VYKEA" class="chit_brick nospace">');
		result.append('<tr class="effect"><td class="vykea" style="overflow:hidden;"><img title="VYKEA Companion" src="images/adventureimages/');
		result.append(v.image);
		result.append('" style="margin-'+img_margin()+'px; border:0" /></td><td class="info"><b>VYKEA Companion</b><p style="margin-top:2px; margin-bottom:0px"><b>');
		result.append(replace_string(to_string(v), ", t", "</b>, t"));
		result.append('</td></tr></table>');
		chitBricks["vykea"] = result;
	}
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
		boolean isActive = list_contains(moodname,m);
		if(moodname != "???" && m != "apathetic" && moodname != m) {
			if(!isActive) {
				string mlist = moodname;
				if(m == "combat")
					mlist = list_remove(mlist, "noncom");
				else if(m == "noncom")
					mlist = list_remove(mlist, "combat");
				picker.append('<a title="ADD ' + m + ' to current mood" href="');
				picker.append(sideCommand("mood " + list_add(mlist,m)));
				picker.append('"><img src="');
				picker.append(imagePath);
				picker.append('control_add_blue.png"></a>');
			} else {
				picker.append('<a title="REMOVE ' + m + ' from current mood" href="');
				picker.append(sideCommand("mood " + list_remove(moodname,m)));
				picker.append('"><img src="');
				picker.append(imagePath);
				picker.append('control_remove_red.png"></a>');
			} 
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
	float ML = monster_level_adjustment();
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
	if(fury.find() && my_maxfury() > 0) {
		result.append('<tr><td class="label">');
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
	result.append('<tr><td class="label">Sauce</td><td class="info">');
	result.append(my_soulsauce());
	result.append('</td>');
	if(to_boolean(vars["chit.stats.showbars"])) {
		result.append('<td class="progress"><div class="progressbox" title="');
		result.append(my_soulsauce());
		result.append(' / 100"><div class="progressbar" style="width:');
		result.append(my_soulsauce());
		result.append('%"></div></div></td></td>');
	}
	result.append('</tr>');
}

void addHeavyRains(buffer result) {
	buffer block;
	
	// Detect Thunder
	matcher weather = create_matcher("Thunder:</td><td align=left><b><font color=black>((\\d+) dBs?)", chitSource["stats"]);
	if(weather.find()) {
		block.append('<div title="Thunder: ');
		block.append(weather.group(1));
		block.append('"><span>');
		block.append(weather.group(2));
		block.append('</span><img src="/images/itemimages/echo.gif"></div>');
	}
	
	// Detect Rain
	weather = create_matcher("Rain:</td><td align=left><b><font color=black>((\\d+) drops?)", chitSource["stats"]);
	if(weather.find()) {
		block.append('<div title="Rain: ');
		block.append(weather.group(1));
		block.append('"><span>');
		block.append(weather.group(2));
		block.append('</span><img src="/images/itemimages/familiar31.gif"></div>');
	}
	
	// Detect Lightning
	weather = create_matcher("Lightning:</td><td align=left><b><font color=black>((\\d+) bolts?)", chitSource["stats"]);
	if(weather.find()) {
		block.append('<div title="Lightning: ');
		block.append(weather.group(1));
		block.append('"><span>');
		block.append(weather.group(2));
		block.append('</span><img src="/images/itemimages/lightningrod.gif"></div>');
	}

	// Add block to results if any of the stats were found
	if(length(block) > 0) {
		result.append('<tr><td class="label">Stormy:</td><td class="info"');
		if(to_boolean(vars["chit.stats.showbars"]))
			result.append(' colspan="2"');
		result.append('><div class="chit_stormy">');
		result.append(block);
		result.append('</div><div style="clear:both"></div></td></tr>');
	}
}

void addEnlightenment(buffer result) {
	string enlightenment = get_property("sourceEnlightenment");
	if(enlightenment != "0") {
		result.append('<tr><td class="label"><a href="place.php?whichplace=manor1&action=manor1_sourcephone_ring" target="mainpane">Enlight</a></td><td class="info"');
		result.append('><a href="place.php?whichplace=manor1&action=manor1_sourcephone_ring" target="mainpane">');
		result.append(enlightenment);
		result.append('</a></td></tr>');
	}
}

void addHooch(buffer result) {
	matcher hooch = create_matcher("Hooch:</td><td align=left><b>(\\d+) / (\\d+)</b>", chitSource["stats"]);
	if(hooch.find()) {
		int my_hooch = hooch.group(1).to_int();
		int max_hooch = hooch.group(2).to_int();
		result.append('<tr><td class="label">Hooch</td><td class="info">');
		result.append(my_hooch);
		result.append(' / ');
		result.append(max_hooch);
		result.append('</td>');
		if(to_boolean(vars["chit.stats.showbars"])) {
			result.append('<td class="progress"><div class="progressbox" title="');
			result.append(my_hooch);
			result.append(' / ');
			result.append(max_hooch);
			result.append('"><div class="progressbar" style="width:');
			result.append(to_string(100.0 * my_hooch / max_hooch));
			result.append('%"></div></div></td></td>');
		}
		result.append('</tr>');
	}
}

void addGhostBusting(buffer result) {
	string ghostLocation = get_property("ghostLocation");
	boolean hasPack = available_amount($item[protonic accelerator pack]) > 0;
	if(!hasPack && ghostLocation == "")
		return;
	
	string zone_url(string loc) {
		switch(loc) {
		case "Madness Bakery":
			if(get_property("questM25Armorer") == "unstarted" && npc_price($item[sweet ninja sword]) != 0)
				return "shop.php?whichshop=armory&action=talk";
			return "place.php?whichplace=town_right";
		case "The Overgrown Lot":
			if(get_property("questM24Doc") == "unstarted" && npc_price($item[Doc Galaktik's Pungent Unguent]) != 0)
				return "shop.php?whichshop=doc&action=talk";
			return "place.php?whichplace=town_wrong";
		case "The Skeleton Store":
			if(get_property("questM23Meatsmith") == "unstarted" && npc_price($item[big stick]) != 0)
				return "shop.php?whichshop=meatsmith&action=talk";
			return "place.php?whichplace=town_market";
		case "The Haunted Conservatory":
		case "The Haunted Kitchen":
			return "place.php?whichplace=manor1";
		case "The Haunted Gallery": return "place.php?whichplace=manor2";
		case "The Haunted Wine Cellar": return "place.php?whichplace=manor4";
		case "The Spooky Forest":
		case "The Old Landfill": return "place.php?whichplace=woods";
		case "Cobb's Knob Treasury": return "cobbsknob.php";
		case "The Icy Peak": return "place.php?whichplace=mclargehuge";
		case "The Smut Orc Logging Camp": return "place.php?whichplace=orc_chasm";
		case "Inside the Palindome": return "place.php?whichplace=palindome";
		}
		return "main.php";
	}

	int turnsToGo = to_int(get_property("nextParanormalActivity")) - total_turns_played();
	result.append('<tr><td class="label">Bust</td><td class="ghostbust info" colspan="2">');
	if(ghostLocation == "") {
		result.append('<a ');
		if(turnsToGo <= 0) {
			if(hasPack && equipped_amount($item[protonic accelerator pack]) < 1) {
				result.append('href="');
				result.append(sideCommand("equip protonic accelerator pack"));
				result.append('" title="Equip your PAP"');
			}
			else result.append('style="color:#555555;"');
			result.append('>ghost report due!');
		}
		else {
			result.append('style="color:#BBBBBB;">ghost in ');
			result.append(turnsToGo);
			result.append(' turns');
		}
		result.append('</a></td></tr>');
	}
	else {
		result.append('<a href="');
		result.append(zone_url(ghostLocation));
		result.append('" title="Bust a ghost here');
		if(turnsToGo > 0) {
			result.append('\nReplacement ghost in ');
			result.append(turnsToGo);
			result.append(' turns');
		}
		result.append('" target="mainpane">');
		result.append(ghostLocation);
		result.append(' (');
		if(turnsToGo > 0) {
			result.append(turnsToGo);
			result.append(' turns');
		} else result.append('next ready');
		result.append(')</a></td></tr>');
	}
}

// if KoL adds sprinkle count, do that here also.
void addSprinkles(buffer result) {
	if(chitSource["stats"].contains_text("Sprinkles:")) {
		result.append('<tr>');
		result.append('<td class="label">Sprinkles</td><td class="info">');
		result.append(available_amount($item[sprinkles]));
		result.append('</td>');
		result.append('</tr>');
	}
}

void addCIQuest(buffer result) {
	boolean active_quest(string prop) { return get_property(prop) == "started" ||  get_property(prop).contains_text("step"); }
	int current, final;
	string label;
	if(active_quest("questESpGore")) {
		if(!have_equipped($item[gore bucket])) return;
		current = get_property("questESpGore") == "step2"? 100: get_property("goreCollected").to_int();
		final = 100;
		label = "Gore";
	} else if(active_quest("questESpJunglePun")) {
		if(!have_equipped($item[encrypted micro-cassette recorder])) return;
		current = get_property("junglePuns").to_int();
		final = 11;
		label = "Puns";
	} else if(active_quest("questESpSmokes")) {
		current = item_amount($item[pack of smokes]);
		if(current < 1) return;
		final = 10;
		label = "Smokes";
	} else if(active_quest("questESpClipper")) {
		current = get_property("fingernailsClipped").to_int();
		if(current < 1) return;
		final = 23;
		label = "Clippings";
	} else return;
	result.append('<tr><td class="label"><a href="place.php?whichplace=airport_spooky&action=airport2_radio" target="mainpane">');
	result.append(label);
	result.append('</a></td><td class="info"><a href="place.php?whichplace=airport_spooky&action=airport2_radio" target="mainpane">');
	result.append(current);
	result.append(' / ');
	result.append(final);
	result.append('</a></td>');
	if(to_boolean(vars["chit.stats.showbars"])) {
		result.append('<td class="progress"><div class="progressbox" title="');
		result.append(current);
		result.append(' / ');
		result.append(final);
		result.append('"><a href="place.php?whichplace=airport_spooky&action=airport2_radio" target="mainpane"><div class="progressbar" style="width:');
		result.append(to_string(100.0 * current / final));
		result.append('%"></div></a></div></td>');
	}
	result.append('</tr>');
}

void addWalfordBucket(buffer result) {
	if(have_equipped($item[Walford's bucket]) || get_property("questECoBucket") != "unstarted") {
		int current = get_property("walfordBucketProgress").to_int();
		result.append('<tr title="');
		if(get_property("walfordBucketItem") != "") {
			result.append(current);
			result.append('% full of ');
			result.append(get_property("walfordBucketItem"));
		} else
			result.append("Select something to put in the bucket");
		result.append('"><td class="label"><a href="place.php?whichplace=airport_cold&action=glac_walrus" target="mainpane">');
		if(current >= 100)
			result.append('<span class="walford_done">Walford</span>');
		else if(!have_equipped($item[Walford's bucket]))
			result.append('<span class="walford_nobucket">Walford</span>');
		else if(get_property("questECoBucket") == "unstarted" || get_property("walfordBucketItem") == "")
			result.append('<span class="walford_noquest">Walford</span>');
		else
			result.append('Walford');
		result.append('</a></td><td class="info"><a href="place.php?whichplace=airport_cold&action=glac_walrus" target="mainpane">');
		result.append(current);
		result.append(' % </a></td>');
		if(to_boolean(vars["chit.stats.showbars"])) {
			result.append('<td class="progress"><div class="progressbox"><a href="place.php?whichplace=airport_cold&action=glac_walrus" target="mainpane"><div class="progressbar" style="width:');
			result.append(current);
			result.append('%"></div></a></div></td>');
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
			result.append('<td class="progress"><div class="progressbox" title="');
			result.append(audience);
			result.append(' / ');
			result.append(max_aud);
			result.append('"><div class="progressbar" style="width:');
			result.append(to_string(audience * 100.0 / max_aud));
			result.append('%"></div></div></td></td>');
		}
		result.append('</tr>');
	}
}

void addKa(buffer result) {
	result.append('<tr><td class="label">Ka</td><td class="info">');
	result.append(formatInt(item_amount($item[Ka Coin])));
	if(to_boolean(vars["chit.stats.showbars"]))
		result.append('</td><td><div title="Ka Coins" style="float:left"><img style="max-width:14px;padding-left:3px;" onClick="descitem(826932303,0, event);" src="/images/itemimages/kacoin.gif"></td></tr>');
	else
		result.append('<img title="Ka Coins" style="max-width:14px;padding-left:3px;" src="/images/itemimages/kacoin.gif"></td></tr>');
}

void addRadSick(buffer result) {
	int sickness = current_rad_sickness();
	if(sickness > 0) {
		result.append('<tr><td class="label"><a target="mainpane" href="campground.php" title="Head to your fallout shelter to deal with Radiation Sickness">Radsick</a></td><td class="info" title="-');
		result.append(sickness);
		result.append(' to All Stats">');
		result.append(sickness);
		if(to_boolean(vars["chit.stats.showbars"])) {
			result.append('</td><td title="-');
			result.append(sickness);
			result.append(' to All Stats" style="float:left"><img style="max-width:14px;padding-left:3px;" src="/images/itemimages/radiation.gif">');
		} else {
			result.append('<img title="-');
			result.append(sickness);
			result.append(' to All Stats" style="max-width:14px;padding-left:3px;" src="/images/itemimages/radiation.gif">');
		}
		result.append('</td></tr>');
	}
}

void addOrgan(buffer result, string organ, boolean showBars, int current, int limit, boolean eff) {
	int sev = severity(organ, current, limit);
	result.append('<tr><td class="label">'+organ+'</td>');
	result.append('<td class="info">' + current + ' / ' + limit + '</td>');
	if(showBars) result.append('<td class="progress">' + progressCustom(current, limit, message(organ, sev), sev, eff) + '</td></tr>');
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
		picker.append('</table></div>');
		
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
	if(target.find())
		url = target.group(1);
	if(url == "place.php?whichplace=town_right" && source.contains_text("Investigating a Plaintive Telegram"))
		url = "place.php?whichplace=town_right&action=townright_ltt";
		
	result.append('<tr><td class="label"><a class="visit" target="mainpane" href="');
	result.append(url);
	result.append('">Last</a></td>');
	
	//Last Adventure
	target = create_matcher('target=mainpane href="(.*?)">\\s*(.*?)</a><br></font>', source);
	if(target.find()) {
		result.append('<td class="info" colspan="2" style="display:block;"><a class="visit" target="mainpane" href="');
		result.append(target.group(1));
		result.append('">');
		result.append(target.group(2));
		result.append('</a></td>');
	} else
		result.append('<td class="info" colspan="2">(None)</td>');
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
				case "terminal":result.addTerminal();				break;
				case "hp": 		addHP(); 			break;
				case "mp": 		addMP(); 			break;
				case "axel": 	addAxel(); 			break;
				case "mcd": 	result.addMCD(); 	break;
				case "trail": 	result.addTrail();	break;
				case "gear": 	result.addGear();	break;
				default:
			}
		}
		
		// Add special stats to the section that contains mainstat
		if(section.contains_stat()) {
			switch(my_class()) {
			case $class[Seal Clubber]:
				if(my_path() != "Nuclear Autumn")
					result.addFury();
				break;
			case $class[Sauceror]:
				if(my_path() != "Nuclear Autumn")
					result.addSauce();
				break;
			case $class[Avatar of Sneaky Pete]:
				result.addAud();
				break;
			case $class[Ed]:
				result.addKa();
				break;
			}
			
			switch(my_path()) {
			case "Heavy Rains":
				result.addHeavyRains();
				break;
			case "The Source":
				result.addEnlightenment();
				break;
			case "Nuclear Autumn":
				result.addRadSick();
				break;
			}
			
			if(numeric_modifier("Maximum Hooch") > 0)
				result.addHooch();
			
			if(available_amount($item[sprinkles]) > 0)
				result.addSprinkles();
			
			// Quest updates should be shown if the tracker brick is not in use.
			boolean tracker;
			foreach layout in $strings[roof, walls, floor, toolbar]
				if(vars["chit." + layout + ".layout"].contains_text("tracker"))
					tracker = true;
			if(!tracker) {
				result.addGhostBusting();
				result.addCIQuest();
				result.addWalfordBucket();
			}
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

// Based on fancy currency relay override for charpane by DeadNed (#1909053)
// http://kolmafia.us/showthread.php?12311-Fancy-Currency-(Charpane-override)
void allCurrency(buffer result) {
	string amount_of(item it) {
		if(it == $item[none])
			return formatInt(my_meat());
		return formatInt(item_amount(it));
	}
	
	string name_of(item it) {
		if(it == $item[none])
			return "Meat";
		return to_string(it);
	}
	
	string image_of(item it) {
		if(it == $item[none])
			return "meat.gif";
		return it.image;
	}
	
	boolean [item] displayedCurrencies;
	
	void addCurrencyIcon(buffer result, item currency, string link) {
		result.append(link);
		result.append('<img class="currency_icon" src="/images/itemimages/');
		result.append(image_of(currency));
		result.append('" alt="');
		result.append(name_of(currency));
		if(link == "") {
			result.append('" class="hand" title="');
			result.append(name_of(currency));
		}
		result.append('" />');
		if(link != "")
			result.append('</a>');
	}
	
	void addCurrency(buffer result, item currency) {
		if(displayedCurrencies[currency])
			return;
		
		displayedCurrencies[currency] = true;
		
		result.append('<span class="currency_amount">');
		result.append(amount_of(currency));
		result.append('</span>');
		
		switch(currency) {
			case $item[disassembled clover]:
				result.addCurrencyIcon(currency, item_amount($item[ten-leaf clover]) > 0 ? '<a title="disassemble a clover" href="' + sideCommand("use 1 ten-leaf clover") + '">' : "");
				result.addCurrency($item[ten-leaf clover]);
				break;
			case $item[ten-leaf clover]:
				result.addCurrencyIcon(currency, item_amount($item[disassembled clover]) > 0 ? '<a title="assemble a clover" href="' + sideCommand("use 1 disassembled clover") + '">' : "");
				result.addCurrency($item[disassembled clover]);
				break;
			case $item[Beach Buck]:
				result.addCurrencyIcon(currency, '<a title="Take a trip to Spring Break Beach" target="mainpane" href="place.php?whichplace=airport_sleaze">');
				break;
			case $item[Coinspiracy]:
				result.addCurrencyIcon(currency, '<a title="Down the hatch to the Conspiracy Island bunker" target="mainpane" href="place.php?whichplace=airport_spooky_bunker">');
				break;
			case $item[FunFunds&trade;]:
				result.addCurrencyIcon(currency, '<a title="Buy some souvenirs at the Dinsey Company Store" target="mainpane" href="shop.php?whichshop=landfillstore">');
				break;
			case $item[Volcoino]:
				result.addCurrencyIcon(currency, '<a title="Boogie right on down to Disco GiftCo" target="mainpane" href="shop.php?whichshop=infernodisco">');
				break;
			case $item[Wal-Mart gift certificate]:
				result.addCurrencyIcon(currency, '<a title="Browse the goods at Wal-Mart" target="mainpane" href="shop.php?whichshop=glaciest">');
				break;
			case $item[rad]:
				result.addCurrencyIcon(currency, '<a title="Fiddle with your genes" target="mainpane" href="shop.php?whichshop=mutate">');
				break;
			case $item[source essence]:
				string termlink = 'campground.php?action=terminal';
				if(my_path() == "Nuclear Autumn")
					termlink = 'place.php?whichplace=falloutshelter&action=vault_term';
				result.addCurrencyIcon(currency, '<a title="Boot up the Source Terminal" target="mainpane" href="' + termlink + '">');
				break;
			case $item[BACON]:
				result.addCurrencyIcon(currency, '<a title="Born too late to explore the Earth&#013;Born too soon to explore the galaxy&#013;Born just in time to BROWSE DANK MEMES" target="mainpane" href="shop.php?whichshop=bacon">');
				break;
			case $item[cop dollar]:
				result.addCurrencyIcon(currency, '<a title="Visit the quartermaster" target="mainpane" href="shop.php?whichshop=detective">');
				break;
			default:
				result.addCurrencyIcon(currency, "");
				break;
		}
	}

	boolean showMany = to_boolean(vars["chit.currencies.showmany"]);
	string chitCurrency = showmany ? get_property("chitCurrency") : get_property("_chitCurrency");
	string [int] dispCurrencies = split_string(chitCurrency, ",");
	item current = to_item(dispCurrencies[0]);
	
	result.append('<div style="float:left" class="hand"><ul id="chit_currency"><li>');
	foreach i,curr in dispCurrencies {
		result.append('<span class="currency_block">');
		result.addCurrency(to_item(curr));
		result.append('</span>');
	}
	result.append('<ul>');
	
	boolean [item] currencies; // This is to ensure no duplication of currencies, perhaps due to ambiguous names being rectified by to_item().
	foreach x,cur in split_string("none,"+vars["chit.currencies"], "\\s*(?<!\\\\),\\s*") {
		item it = to_item(cur);
		if(amount_of(it) > 0 && !(currencies contains it)) {
			currencies[it] = true;
			result.append('<li');
			if(displayedCurrencies[it]) result.append(' class="current"');
			result.append('><a href="/KoLmafia/sideCommand?cmd=');
			if(showMany) {
				result.append(url_encode("set chitCurrency="));
				if(list_contains(chitCurrency,cur,","))
					result.append(list_remove(chitCurrency,cur,","));
				else
					result.append(list_add(chitCurrency,cur,","));
			} else {
				result.append(url_encode("set _chitCurrency="));
				result.append(it);
			}
			result.append('&pwd=');
			result.append(my_hash());
			result.append('" title="');
			result.append(name_of(it));
			result.append('" alt="');
			result.append(name_of(it));
			result.append('"><span>');
			result.append(amount_of(it));
			result.append('</span><img src="/images/itemimages/');
			result.append(image_of(it));
			result.append('"></a></li>');
		}
	}
	result.append('<li class="currency_edit"><a onclick=\'var currencies = prompt("Edit displayed currencies: (Items that you have none of will not be displayed)", "');
	result.append(vars["chit.currencies"]);
	result.append('"); if(currencies!=null) { window.location.href = "/KoLmafia/sideCommand?cmd=zlib+chit.currencies+=+" + currencies.replace(/ /g,"+") + "&pwd=');
	result.append(my_hash());
	result.append('"; }\'>Edit List</a></li></ul>');
	
	result.append('</li></ul></div>');
}

// This function also makes use of gearName() which is in chit_brickGear.ash
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
		if(o != " - No Change - ")
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
	
	// In KOLHS, might want to remove hat
	if(my_path() == "KOLHS") {
		if(equipped_item($slot[hat]) != $item[none])
			special.addGear("unequip hat; set _hatBeforeKolhs = "+equipped_item($slot[hat]), "Remove Hat for School");
		else if(get_property("_hatBeforeKolhs") != "")
			special.addGear("equip "+get_property("_hatBeforeKolhs")+"; set _hatBeforeKolhs = ", "Restore "+get_property("_hatBeforeKolhs"));
	}
	
	// If using Kung Fu Fighting, you might want to empty your hands
		if(have_effect($effect[Kung Fu Fighting]) > 0 && (equipped_item($slot[weapon]) != $item[none] || equipped_item($slot[off-hand]) != $item[none]))
			special.addGear("unequip weapon; unequip off-hand", "Empty Hands");
	
	boolean noGearBrick = true;
	foreach layout in $strings[roof, walls, floor, toolbar]
		if(vars["chit." + layout + ".layout"].contains_text("gear"))
			noGearBrick = false;
	if(noGearBrick) {
		foreach it in favGear
			special.addGear(it, gearName(it));
		foreach reason in recommendedGear
			foreach it in recommendedGear[reason]
				special.addGear(it, '<span style="font-weight:bold">(' + reason + ")</span> " + gearName(it));

		if(item_amount($item[Mega Gem]) > 0 && get_property("questL11Palindome") != "finished")
			special.addGear("equip acc3 Talisman o\' Namsilat;equip acc1 Mega+Gem", "Talisman & Mega Gem");
		if(get_property("questL11Manor") == "step1" || get_property("questL11Manor") == "step2") {
			if(available_amount($item[bottle of Chateau de Vinegar]) == 1 && available_amount($item[blasting soda]) == 1)
				special.addGear("create unstable fulminate; equip unstable fulminate", "Cook & Equip unstable fulminate");
		}
	}
	
	if(length(special) > 0) {
		picker.append('<tr class="pickitem"><td style="color:white;background-color:blue;font-weight:bold;">Equipment Helper</td></tr>');
		picker.append(special);
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
	string myTitle() {
		string myTitle = my_class();
		if(vars["chit.character.title"] == "true" && my_path() != "Actually Ed the Undying") {
			matcher titleMatcher = create_matcher("<br>(.*?)<br>(.*?)<", source);
			if(find(titleMatcher)) {
				myTitle = group(titleMatcher, 2);
				if(index_of(myTitle, "(Level ") == 0)
					myTitle = group(titleMatcher, 1);
			} else {
				titleMatcher = create_matcher("(?i)<br>(?:level\\s*"+my_level()+"|"+my_level()+".{2}?\\s*level\\s*)?([^<]*)", source); // Snip level out of custom title if it is at the beginning. Simple cases only.
				if(find(titleMatcher))
					return group(titleMatcher, 1);
			}
		} else {
			if(myTitle == "Avatar of Jarlsberg" || myTitle == "Avatar of Sneaky Pete" || myTitle == "Unknown")  // Too long!
				return "Avatar";
		}
		return myTitle;
	}

	//Avatar
	string myAvatar;
	if(vars["chit.character.avatar"] != "false") {
		matcher avatarMatcher = create_matcher('<table align=center><tr><td>(.*?)<a class=\'([^\']+).+?("><img.+?</a>)', source);
		if(avatarMatcher.find())
			myAvatar = avatarMatcher.group(1) + '<a href="#" rel="chit_pickeroutfit" title="Select Outfit" class="chit_launcher ' + avatarMatcher.group(2) + avatarMatcher.group(3);
	}
	
	//Outfit
	string myOutfit = "";
	matcher outfitMatcher = create_matcher('<center class=tiny>Outfit: (.+?onClick\\=\'(outfit\\("(\\d+)"\\);).+?)</center>', source);
	if (find(outfitMatcher)){
		myOutfit = "("+ outfitMatcher.group(1).replace_string( outfitMatcher.group(2), 'javascript:window.open("desc_outfit.php?whichoutfit='+ outfitMatcher.group(3) +'","","height=200,width=300")' ) +")";
		int len = length(myName+myOutfit); // 105 is the limit to fit on a line.
		myOutfit = (len > 103 && len < 110? "<br />": " ") + myOutfit;
	}

	// SubStats
	int mySubStats() {
		switch (my_primestat()) {
		case $stat[mysticality]:
			return my_basestat($stat[submysticality]);
		case $stat[moxie]:
			return my_basestat($stat[submoxie]);
		case $stat[muscle]:
			return my_basestat($stat[submuscle]);
		}
		return 0;
	}
	
	string myGuild() {
		if(my_path() == "Nuclear Autumn")
			return "shop.php?whichshop=mutate";
		switch(my_class()) {
		case $class[Seal Clubber]:
		case $class[Turtle Tamer]:
			return "guild.php?guild=f";
		case $class[Disco Bandit]:
		case $class[Accordion Thief]:
			return "guild.php?guild=t";
		case $class[Pastamancer]:
		case $class[Sauceror]:
			return "guild.php?guild=m";
		case $class[Avatar of Boris]:
			return "da.php?place=gate1";
		case $class[Zombie Master]:
			return "campground.php?action=grave";
		case $class[Avatar of Jarlsberg]:
			return "da.php?place=gate2";
		case $class[Avatar of Sneaky Pete]:
			return "da.php?place=gate3";
		case $class[Ed]:
			return "place.php?whichplace=edbase&action=edbase_book";
		case $class[Cow Puncher]:
		case $class[Beanslinger]:
		case $class[Snake Oiler]:
			return "chit_WestGuild.php";
		}
		return "town.php";
	}

	// LifeStyle suitable for charpane
	string myLifeStyle() {
		if(get_property("kingLiberated") == "true")
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
		if(get_property("kingLiberated") == "true")
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
		case "Actually Ed the Undying": return "The Undying";
		case "Avatar of West of Loathing": return "West of Loathing";
		case "The Source": return "<a target='mainpane' style='font-weight:normal;' href='place.php?whichplace=town_wrong&action=townwrong_oracle'>The Source</a>";
		case "Nuclear Autumn": return "<a target='mainpane' style='font-weight:normal;' href='campground.php'>Nuclear Autumn</a>";
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
	int current = mySubStats() - lower;
	int needed = range - current;
	float progress = (current * 100.0) / range;
	
	//Level + Council
	string councilStyle = "";
	string councilText = "Visit the Council";
	if(to_int(get_property("lastCouncilVisit")) < my_level() && my_path() != "Community Service" && get_property("kingLiberated") == "false") {
		councilStyle = 'background-color:#F0F060';
		councilText = "The Council wants to see you urgently";		
	}

	result.append('<table id="chit_character" class="chit_brick nospace">');

	// Character name and outfit name
	result.append('<tr>');
	result.append('<th colspan="');
	result.append(myAvatar == ""? "2": "3");
	result.append('">');
	// If there's no avatar, place Outfit switcher here
	if(vars["chit.character.avatar"] == "false") {
		result.append('<div style="float:left"><a href="#" class="chit_launcher" rel="chit_pickeroutfit" title="Select Outfit"><img src="');
		result.append(imagePath);
		result.append('select_outfit.png"></a></div>');
	}
	result.append('<a target="mainpane" href="charsheet.php">');
	result.append(myName);
	result.append('</a>');
	result.append(myOutfit);
	if(vars["chit.clan.display"] == "on" || vars["chit.clan.display"] == "true" || (vars["chit.clan.display"] == "away" && get_clan_name() != vars["chit.clan.home"])) {
		result.append('<br /><span style="font-weight:normal">');
		result.append(get_clan_name());
		result.append('</span>');
	}
	result.append('</th></tr>');
	
	result.append('<tr>');
	if(myAvatar != "") {
		result.append('<td rowspan="4" class="avatar">');
		result.append(myAvatar);
		result.append('</td>');
		# result.append('<td rowspan="4" class="avatar"><a href="#" class="chit_launcher" rel="chit_pickeroutfit" title="Select Outfit">' + myAvatar + '</a></td>');
	}
	pickOutfit();
	result.append('<td class="label">');
	result.append('<a target="mainpane" href="');
	result.append(myGuild());
	result.append('" title="Visit your guild">');
	result.append(myTitle());
	result.append('</a>');
	result.append('</td><td class="level" rowspan="2" style="width:30px;');
	result.append(councilStyle);
	result.append('"><a target="mainpane" href="council.php" title="');
	result.append(councilText);
	result.append('">');
	result.append(my_level());
	result.append('</a></td></tr>');

	result.append('<tr><td class="info">');
	result.append(myPath());
	result.append('</td></tr>');
	
	// 30x30:	hp.gif		meat.gif		hourglass.gif		swords.gif
	// 20x20:	slimhp.gif	slimmeat.gif	slimhourglass.gif	slimpvp.gif
	result.append('<tr><td class="info">');
	result.append(myLifeStyle());
	result.append('</td>');
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
	result.allCurrency();
	result.append('<div title="'+my_adventures()+' Adventures remaining'
		+ (get_property("kingLiberated") == "true"? '': '\n Current Run: '+my_daycount() +' / '+ turns_played())
		+ '" style="float:right"><span>' + my_adventures() 
		+ '</span><img src="/images/itemimages/slimhourglass.gif"></div>');
	result.append('</div><div style="clear:both"></div></td>');
	result.append('</tr>');

	if(index_of(source, "<table title=") > -1) {
		result.append('<tr><td class="progress" colspan="3" title="');
		result.append( to_string(my_level() ** 2 + 4 - my_basestat(my_primestat())) );
		result.append(' ');
		result.append(my_primestat().to_lower_case());
		result.append(' until level ');
		result.append(to_string(my_level() + 1));
		result.append('\n (');
		result.append(formatInt(needed));
		result.append(' substats needed)" ><div class="progressbar" style="width:');
		result.append(progress);
		result.append('%"></div></td></tr>');
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
	
	// Interpret readout for Oil Peak. u is B/Hg.
	string to_slick(float u) {
		float ml = monster_level_adjustment();
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
	//fix my syntax highlighting "

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

// heeheehee wrote this to make ChIT remember the position of the scrollbar when the screen is refreshed.
string autoscrollScript = "<script>\
$(window).unload(function () {\
	var scrolls = {};\
	$('div').each(function () {\
		var scroll = $(this).scrollTop();\
		if (scroll !== 0) {\
			scrolls[$(this).attr('id')] = $(this).scrollTop();\
		}\
	});\
	sessionStorage.setItem('chit.scroll', JSON.stringify(scrolls));\
});\

$(document).ready(function () {\
	if (sessionStorage.getItem('chit.scroll') !== '') {\
		var scrolls = JSON.parse(sessionStorage.getItem('chit.scroll'));\
		console.log(\"scrolls\", scrolls);\
		for (var key in scrolls) {\
			$('#' + key).scrollTop(scrolls[key])\
		}\
	}\
});\
</script><body ";

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
	
	//Add CSS to the <head> tag -- chit_custom.css overrides the default chit.css stylesheet.
	result.replace_string('</head>', '\n<link rel="stylesheet" href="chit.css">\n<link rel="stylesheet" href="chit_custom.css">\n</head>');
	
	//Add JavaScript just before the <body> tag. 
	//Ideally this should go into the <head> tag too, but KoL adds jQuery outside of <head>, so that won't work
	result.replace_string('<body', '\n<script type="text/javascript" src="chit.js"></script>\n<body');
	
	//Remove KoL's javascript familiar picker so that it can use our modified version in chit.js
	result.replace_string('<script type="text/javascript" src="/images/scripts/familiarfaves.20120307.js"></script>', '');
	
	// remove restricted familiars for KoL's familiar picker
	matcher famfavmatch = create_matcher("(var FAMILIARFAVES = .+?\\];)",result);
	if(famfavmatch.find()) {
		string replacefamfavs = "var FAMILIARFAVES = [";
		matcher singlefamfavmatch = create_matcher('\\[".+?","(.+?)","(.+?)",\\d+\\]',famfavmatch.group(1)); // ["Onegai Marie","Angry Jung Man","jungman",165]
		while(singlefamfavmatch.find()) {
			familiar fam = to_familiar(replace_string(singlefamfavmatch.group(1),"\\",""));
			if(is_unrestricted(fam)) {
				string singlefamfav = singlefamfavmatch.group(0);
				singlefamfav = singlefamfav.replace_string("[[", "[");
				// Attend to familiar images also. (This uses mdofied familiar images!)
				singlefamfav = singlefamfav.replace_string(singlefamfavmatch.group(2), familiar_image(fam));
				replacefamfavs += singlefamfav + ",";
			}
		}
		replacefamfavs+="];";
		replacefamfavs .replace_string("= [[[","= [[");
		result.replace_string(famfavmatch.group(0),replacefamfavs);
	}
	
	// Add javascript for remembering autoscroll if desired
	if(to_boolean(vars["chit.autoscroll"]))
		result.replace_string("<body ", autoscrollScript);
	
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
		+ "|<font size=2><b>Companion:</b>.*?(?:</b></font>|none\\))"  // Avatar of Jarlsberg
		+ "|<a target=mainpane href=main.php\\?action=motorcycle>.*?</b>"  // Avatar of Sneaky Pete
		+ "|<p><font size=2><b>Servant:</b>.*?</p>"  // Ed the Undying
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
		# matcher test = create_matcher("rollover \= (\\d+).*?rightnow \= (\\d+)",chitSource["header"]); if(test.find())chitSource["header"]=chitSource["header"].replace_string(test.group(1),to_string(to_int(test.group(2))+120));
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
			.replace_string("McMillicancuddy's Farm", "Farm") 						// McMillicancuddy's aftercore location
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
						case "gear":		bakeGear();			break;
						case "vykea":		bakeVYKEA();		break;
						case "terminal":	bakeTerminal();		break;
						
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
			case "gear":
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

buffer spelunky(buffer source) {
	int index = source.index_of("<center><p><b><font size=2>Effects");
	if(index < 0) // Try compact charpane
		index = source.index_of("<hr width=50%><font size=2 color=black>");
	if(index < 0) // apathetic mood (Feature by Hellno)
		index = source.index_of("</center><center><font size=1>[<a href=\"charpane.php\">refresh</a>]</font>");
	if(index < 0) return source;
	
	// Add combat phase information
	buffer spelunk;
	spelunk.append("<div class=small><br><b>Non-combat Phase: ");
	spelunk.append(get_property("spelunkyNextNoncombat"));
	if(get_property("spelunkyWinCount").to_int() < 3) { // This can legitimately go over 3
		spelunk.append("</b><br>Encounter in ");
		spelunk.append(get_property("spelunkyWinCount"));
		spelunk.append(" /3 wins</div>");
	} else
		spelunk.append("</b><br><i>- NOW -</i></div>");
	source.insert(index, spelunk);
	
	// Add Buddy tooltip info
	if(source.contains_text("title='A Helpful Guy'"))
		source = source.replace_string("title='A Helpful Guy'", "title='A Helpful Guy\nDelevels by 5-10 at start of all combats'");
	else if(source.contains_text("title='A Skeleton'"))
		source = source.replace_string("title='A Skeleton'", "title='A Skeleton\nDeals 9-10 damage every round of combat'");
	else if(source.contains_text("title='A Damselfly'"))
		source = source.replace_string("title='A Damselfly'", "title='A Damselfly\nHeals 8-10 HP at the end of all successful combats'");
	else if(source.contains_text("title='A Resourceful Kid'"))
		source = source.replace_string("title='A Resourceful Kid'", "title='A Resourceful Kid\n Gives 7 gold at the end of all successful combats\nUnlocks that one Idol NC choice'");
	
	return source;
}

buffer modifyPage(buffer source) {
	if(source.length() < 6)
		return source.append('<center><a href="charpane.php" title="Reload"><img src="' + imagePath + 'refresh.png"></a> &nbsp;Reload after cutscene...</center>');
	if(vars["chit.disable"]=="true")
		return source.replace_string('[<a href="charpane.php">refresh</a>]', '[<a href="'+ sideCommand('zlib chit.disable = false') +'">Enable ChIT</a>] &nbsp; [<a href="charpane.php">refresh</a>]');
	//Set default values for zlib variables
	setvar("chit.checkversion", false);
	setvar("chit.autoscroll", true);
	setvar("chit.disable", false);
	setvar("chit.currencies", "rad,source essence,BACON,cop dollar");
	setvar("chit.currencies.showmany", false);
	setvar("chit.character.avatar", true);
	setvar("chit.character.title", true);
	setvar("chit.clan.display", "off"); // Valid values are on,off,away
	setvar("chit.clan.home", "");
	setvar("chit.quests.hide", false);
	setvar("chit.familiar.hats", "spangly sombrero,sugar chapeau,Chef's Hat,party hat");
	setvar("chit.familiar.pants", "spangly mariachi pants,double-ice britches,BRICKO pants,pin-stripe slacks,Studded leather boxer shorts,Monster pants,Sugar shorts");
	setvar("chit.familiar.weapons", "time sword,batblade,Hodgman's whackin' stick,astral mace,Maxwell's Silver Hammer,goatskin umbrella,grassy cutlass,dreadful glove,Stick-Knife of Loathing,Work is a Four Letter Sword");
	setvar("chit.familiar.protect", false);
	setvar("chit.familiar.showlock", false);
	setvar("chit.familiar.anti-gollywog", true);
	setvar("chit.familiar.hiddengear", "");
	setvar("chit.effects.classicons", "none");
	setvar("chit.effects.showicons", true);
	setvar("chit.effects.modicons", true);
	setvar("chit.effects.layout", "songs,buffs,intrinsics");
	setvar("chit.effects.usermap",false);
	setvar("chit.effects.describe",true);
	setvar("chit.helpers.wormwood", "stats,spleen");
	setvar("chit.helpers.dancecard", true);
	setvar("chit.helpers.semirare", true);
	setvar("chit.helpers.spookyraven", true);
	setvar("chit.helpers.xiblaxian", true);
	setvar("chit.kol.coolimages", true);
	setvar("chit.roof.layout", "character,stats,gear");
	setvar("chit.walls.layout", "helpers,thrall,vykea,effects");
	setvar("chit.floor.layout", "update,familiar");
	setvar("chit.stats.showbars", true);
	setvar("chit.stats.layout", "muscle,myst,moxie|hp,mp,axel|mcd|trail,florist");
	setvar("chit.toolbar.layout", "trail,quests,modifiers,elements,organs");
	setvar("chit.toolbar.moods", "true");
	string gearDispInRunDefault = "favorites:amount=all:pull=true:create=true, astral:amount=all, item, -combat, +combat, quest:amount=all:pull=true:create=true, today:amount=all:create=false, ML, path:amount=all, prismatic, res, charter:amount=all, rollover, DRUNK:amount=all, Wow:amount=all, resistance:amount=3";
	setvar("chit.gear.display.in-run", gearDispInRunDefault);
	setvar("chit.gear.display.aftercore", "favorites:amount=all, quest:amount=all, charter:amount=all, today:amount=all:create=false, rollover, DRUNK:amount=all");
	setvar("chit.gear.display.in-run.defaults", "create=false, pull=false, amount=1");
	setvar("chit.gear.display.aftercore.defaults", "create=true, pull=true, amount=1");
	setvar("chit.gear.layout", "default");
	setvar("chit.gear.favorites", "");
	setvar("chit.thrall.showname", false);
	
	// Check var version.
	int varVer = get_property("chitVarVer").to_int();
	if(varVer < 3) {
		if(!vars["chit.walls.layout"].contains_text("vykea")) {
			if(vars["chit.walls.layout"].contains_text("effects"))
				vars["chit.walls.layout"] = vars["chit.walls.layout"].replace_string("effects", "vykea,effects");
			else 
				vars["chit.walls.layout"] += ",vykea";
		}
		if(!(vars["chit.roof.layout"].contains_text("gear") || vars["chit.stats.layout"].contains_text("gear")))
			vars["chit.roof.layout"] += ",gear";
		updatevars();
		set_property("chitVarVer", "3");
	}
	// Update in-run gear display IF it has not been changed from the old default
	if(varVer < 4) {
		if(vars["chit.gear.display.in-run"] == "favorites:amount=all:pull=true:create=true, astral:amount=all, item, meat, ML, exp, initiative, quest:amount=all:pull=true:create=true, path:amount=all, prismatic, res, charter:amount=all, today:amount=all:create=false, rollover, DRUNK:amount=all, Wow:amount=all") {
			vars["chit.gear.display.in-run"] = gearDispInRunDefault;
			updatevars();
		}
		set_property("chitVarVer", "4");
	}
	
	//Check for updates (once a day)
	if(vars["chit.checkversion"]=="true" && svn_exists("mafiachit") && get_property("_svnUpdated") == "false") {
		if(get_property("_chitSVNatHead").length() == 0)
			set_property("_chitSVNatHead", svn_at_head("mafiachit"));
		if(get_property("_chitSVNatHead") == "false") {
			if(get_property("_chitChecked") != "true")
				print("Character Info Toolbox has become outdated. It is recommended that you update it from SVN...", "red");
			set_property("_chitChecked", "true");
			bakeUpdate(svn_info("mafiachit").revision, "Revision ", svn_info("mafiachit").last_changed_rev);
		}
	}
	
	// handle limit modes
	switch(limit_mode()) {
	case "":			// Mode is not limited
	case "edunder":		// Ed's Underworld
		break;
	case "spelunky":	// Needs special handling for the Spelunkin' minigame
		return source.spelunky();
	case "batman":		// Bat-folk mini-game
		if(!source.contains_text("<b>You're Batfellow</b>"))
			break;
	default:			// Unknown limit mode could be dangerous
		return source;
	}
	
	// KoL still has a bug where it doesn't always detect limit mode for batman
	if(source.contains_text("<b>You're Batfellow</b>"))
		return source;
	
	if( index_of(source, 'alt="Karma" title="Karma"><br>') > 0 )
		inValhalla = true;
	
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
