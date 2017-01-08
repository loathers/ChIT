/************************************************************************************
CHaracter Info Toolbox tracker brick by ckb

TTD:
- better consistancy of wording / syntax
- checks / hints for elem airport quests
- other quests?

************************************************************************************/


buffer buildTracker() {
	
	//useful sub-functions for checking items: yes=green, no=red
	string ItemReport(boolean good, string itname) {
		return("<span style=\"color:" + (good? "green" : "red") + "\">"+itname+"</span>");
	}
	string ItemReport(boolean[item] itlist, string itname) {
		foreach it in itlist
			if (available_amount(it) > 0)
				return ItemReport(true, itname);
		return ItemReport(false, itname);
	}
	string ItemReport(item it, string itname) {
		return ItemReport(available_amount(it) > 0, itname);
	}
	string ItemReport(item it) {
		return ItemReport(available_amount(it) > 0, to_string(it));
	}
	string ItemReport(item it, string itname, int num) {
		return ItemReport(available_amount(it) >= num, itname + " "+available_amount(it)+"/"+num);
	}
	string ItemReport(item it, int num) {
		return ItemReport(it, to_plural(it), num);
	}
	
	
	
	string EquipReport(item it) {
		return "<a href=\"" + sideCommand("equip "+it) + "\">Equip</a> " + ItemReport(have_equipped(it),to_string(it));
	}
	
	
	
	string DecoMods(string ss) {
		//cap first letter
		ss = to_upper_case(substring(ss,0,1)) + substring(ss,1);
		//shorten various text
		ss = replace_string(ss,"Moxie","Mox");
		ss = replace_string(ss,"Muscle","Mus");
		ss = replace_string(ss,"Mysticality","Myst");
		//decorate elemental tags with pretty colors
		ss = replace_string(ss,"Hot","<span class=modHot>Hot</span>");
		ss = replace_string(ss,"Cold","<span class=modCold>Cold</span>");
		ss = replace_string(ss,"Spooky","<span class=modSpooky>Spooky</span>");
		ss = replace_string(ss,"Stench","<span class=modStench>Stench</span>");
		ss = replace_string(ss,"Sleaze","<span class=modSleaze>Sleaze</span>");
		return (ss);
	}
	
	boolean Started(string pref) {
		return get_property(pref) != "unstarted" && get_property(pref) != "finished";
	}
	
	void comma(buffer b, string s) {
		if (length(b) > 0)
			b.append(", ");
		b.append(s);
	}
	
	
	
	
	
	
	
	
	
	// Start building our table
	buffer result;
	result.append("<table id=chit_tracker class=\"chit_brick nospace\"><tr><th>");
	result.append("<img src=\"");
	result.append(imagePath);
	result.append("tracker.png\"  class=\"chit_walls_stretch\">");
	result.append("<a target=mainpane href=\"questlog.php\">Quest Tracker</a></th></tr>");
	
	//Add Tracker for each available quest
	//G for Guild. S for Sea. F for Familiar. I for Item. M for Miscellaneous 
	
	foreach bb in $strings[Easy, Hard, Special] {
		string bhit;
		bhit = get_property("current"+bb+"BountyItem");
		if (bhit != "") {
			result.append("<tr><td>");
			result.append("<a target=mainpane href=\"bhh.php\">Bounty</a>");
			result.append(" - ");
			result.append(bhit);
		}
	}
	
	//questM02Artist
	if (Started("questM02Artist")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"town_wrong.php\">Artist</a>");
		result.append(" - Find the supplies: <br>");
		result.append("<a target=mainpane href=\"place.php?whichplace=manor1\">Pantry</a>: "+ItemReport($item[pretentious palette], "Palette")+"<br>");
		result.append("<a target=mainpane href=\"place.php?whichplace=town_wrong\">Back Alley</a>: "+ItemReport($item[pail of pretentious paint], "Paint")+"<br>");
		result.append("<a target=mainpane href=\"place.php?whichplace=plains\">Outskirts</a>: "+ItemReport($item[pretentious paintbrush], "Paintbrush"));
		result.append("</td></tr>");
	}
	
	//questM01Untinker
	if (Started("questM01Untinker")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=forestvillage&action=fv_untinker\">Untinker</a>");
		result.append(" - Find the ");
		result.append(ItemReport($item[rusty screwdriver], "screwdriver"));
		result.append("</td></tr>");
	}
	
	//Gorgonzola wants you to exorcise a poltersandwich in the Haunted Pantry.
	//Take the poltersandwich back to Gorgonzola at the League of Chef-Magi.
	if (Started("questG07Myst")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=manor1\">Pantry</a>");
		result.append(" - Find a poltersandwich");
		result.append("</td></tr>");
	}
	
	//Shifty wants you to lure yourself into the Sleazy Back Alley and steal your own pants.
	//Take your pants back to Shifty at the Department of Shadowy Arts and Crafts.
	if (Started("questG08Moxie")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=town_wrong\">Alley</a>");
		result.append(" - Steal you pants");
		result.append("</td></tr>");
	}
	
	//Gunther wants you to get the biggest sausage you can find in Cobb's Knob.
	//Take the huge sausage back to Gunther at the Brotherhood of the Smackdown.
	if (Started("questG09Muscle")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"plains.php\">Outskirts</a>");
		result.append(" - Find a big sausage");
		result.append("</td></tr>");
	}
	
	
	//questM20Necklace
	if (Started("questM20Necklace")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=manor1\">Manor</a>");
		result.append(" - Find ");
		result.append(ItemReport($item[Lady Spookyraven's necklace]));
		if (available_amount($item[Spookyraven billiards room key])==0) {
			result.append("<br>Kitchen Drawers: "+get_property("manorDrawerCount")+"/21");
			result.append(", ");
			int hotres = to_int(numeric_modifier("Hot Resistance"));
			int stenchres = to_int(numeric_modifier("Stench Resistance"));
			if (hotres > stenchres) {
				result.append("<span class=modHot>Hot</span> Res: "+hotres);
			} else {
				result.append("<span class=modStench>Stench</span> Res: "+stenchres);
			}
		}
		if (available_amount($item[Spookyraven billiards room key])>0) {
		int pool = get_property("poolSkill").to_int()										// Training this run. 
			+ numeric_modifier("Pool Skill")														// Equipment and effects. 
			+ min(floor(get_property("poolSharkCount").to_int() ** 0.5 * 2), 10)		// Semirare boost. 
			+ min(my_inebriety(), 10)																// Liquid courage! 
			+ min((10 - my_inebriety()) * 2, 0);												// You're seeing double. 
			result.append("<br>Pool skill: "+pool+"/18");
		}
		result.append("<br>Writing Desks: "+get_property("writingDesksDefeated")+"/5");
		result.append("</td></tr>");
	}
	
	//questM21Dance
	if (Started("questM21Dance")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=manor2\">Manor 2nd Floor</a>");
		result.append(" - Find Lady Spookyravens dancing supplies:<br>");
		result.append("Gallery: "+ItemReport($item[Lady Spookyraven's dancing shoes], "dancing shoes")+"<br>");
		result.append("Bathroom: "+ItemReport($item[Lady Spookyraven's powder puff], "powder puff")+"<br>");
		result.append("Bedroom: "+ItemReport($item[Lady Spookyraven's finest gown], "finest gown"));
		result.append("</td></tr>");
	}
	
	//L2: get mosquito larva, questL02Larva
	if (Started("questL02Larva")) { 
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"woods.php\">Spooky Forest</a>");
		result.append(" - Find a ");
		result.append(ItemReport($item[mosquito larva]));
		result.append("</td></tr>");
	}
	
	//lastTempleUnlock
	if (to_int(get_property("lastTempleUnlock"))!=my_ascensions()) { 
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"woods.php\">Spooky Forest</a>");
		result.append(" - Unlock the Hidden Temple");
		result.append("</td></tr>");
	}
	
	//L3 Typical tavern, questL03Rat
	if (Started("questL03Rat")) { 
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"cellar.php\">Typical Tavern</a>");
		result.append(" - Clear the rats");
		result.append("</td></tr>");
	}
	
	//L4: find and defeat the boss bat, questL04Bat
	if (Started("questL04Bat")) { 
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"bathole.php\">Bat Hole</a>");
		result.append(" - Find and defeat the Boss Bat");
		result.append("</td></tr>");
	}
	
	//L5: encryption key - item_amount($item[Knob Goblin encryption key]), item_amount($item[Cobb's Knob map])
	if (item_amount($item[Knob Goblin encryption key])<1 && (get_property("questL05Goblin")=="unstarted" || item_amount($item[Cobb's Knob map])>0)) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"plains.php\">Outskirts</a>");
		result.append(" - Find the ");
		result.append(ItemReport($item[Knob Goblin encryption key], "KG encryption key"));
		result.append("</td></tr>");
	}
	
	//knob king, questL05Goblin
	if (Started("questL05Goblin")) { 
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"cobbsknob.php\">Cobb's Knob</a>");
		result.append(" - Find and defeat the Goblin King");
		result.append("<br>KGE: ");
		result.append(ItemReport($item[Knob Goblin elite polearm], "polearm"));
		result.append(", ");
		result.append(ItemReport($item[Knob Goblin elite pants], "pants"));
		result.append(", ");
		result.append(ItemReport($item[Knob Goblin elite helm], "helm"));
		result.append(", ");
		result.append(ItemReport($item[Knob cake], "cake"));
		result.append("<br>Harem: ");
		result.append(ItemReport($item[Knob Goblin harem veil], "veil"));
		result.append(", ");
		result.append(ItemReport($item[Knob Goblin harem pants], "pants"));
		result.append(", ");
		result.append(ItemReport($item[Knob Goblin perfume], "perfume"));
		result.append("</td></tr>");
	}
	
	//L6: Friars gate, questL06Friar
	if (Started("questL06Friar")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"friars.php\">Deep Fat Friars</a>");
		result.append(" - cleanse the taint<br>");
		result.append("Elbow: "+ItemReport($item[eldritch butterknife])+"<br>");
		result.append("Heart: "+ItemReport($item[box of birthday candles], "birthday candles")+"<br>");
		result.append("Neck: "+ItemReport($item[dodecagram]));
		result.append("</td></tr>");
	}
	
	//L6.5: Steel organ, questM10Azazel
	if (Started("questM10Azazel")) { 
		result.append("<tr><td>");
		string steelname() {
			if (!can_drink() && !can_eat()) { return "Steel Air Freshener"; }
			if (!can_drink()) { return "Steel Lasagna"; }
			return "Steel Margarita";
		}
		result.append("<a target=mainpane href=\"pandamonium.php\">Pandamonium</a>");
		result.append(" - Get "+steelname());
		result.append("<br><a target=mainpane href=\"pandamonium.php?action=infe\">Arena</a>: ");
		result.append(ItemReport($item[Azazel's unicorn], "Unicorn"));
		if (available_amount($item[Azazel's tutu])==0) {
			result.append(", ");
			result.append(ItemReport($item[bus pass],5));
		}
		result.append("<br><a target=mainpane href=\"pandamonium.php?action=beli\">Comedy</a>: ");
		result.append(ItemReport($item[Azazel's lollipop], "Lollipop"));
		if (available_amount($item[Azazel's tutu])==0) {
			result.append(", ");
			result.append(ItemReport($item[imp air],5));
		}
		result.append("<br><a target=mainpane href=\"pandamonium.php?action=moan\">Panda Square</a>: ");
		result.append(ItemReport($item[Azazel's tutu]));
		result.append("</td></tr>");
	}
	
	
	//L7: crypt, questL07Cyrptic
	if (Started("questL07Cyrptic")) {
		void evilat(buffer report, string place) {
			int evil = to_int(get_property("cyrpt"+place+"Evilness"));
			report.append("<span style=\"color:");
			if (evil==0) report.append("gray");
				else if (evil<26) report.append("red");
				else report.append("black");
			report.append("\">");
			report.append(place);
			report.append(": ");
			report.append(evil);
			report.append("</span>");
		}
		result.append("<tr><td><table><tr><td colspan=2><a target=mainpane href=\"crypt.php\">Cyrpt</a> Evilometer: ");
		if (get_property("cyrptTotalEvilness") == "0") {
			result.append("999</td></tr><tr><td><span style=\"color:black\">&nbsp;&nbsp;Haert of the Cyrpt</span>");
		} else {
			result.append(get_property("cyrptTotalEvilness"));
			result.append("</td></tr><tr><td><table><tr><td title=\"+items\">");
			result.evilat("Nook");
			result.append("</td><td title=\"sniff dirty old lihc\">");
			result.evilat("Niche");
			result.append("</td></tr><tr><td title=\"+NC, +ML\">");
			result.evilat("Cranny");
			result.append("</td><td title=\"+init\">");
			result.evilat("Alcove");
			result.append("</td></tr></table>");
		}
		result.append("</td></tr></table></td></tr>");
	}
	
	
	//Check for Island unlock and Swashbuckling Getup
	if (to_int(get_property("lastIslandUnlock"))!=my_ascensions()) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=desertbeach\">Beach</a> - Find a boat to the Island");
		result.append("</td></tr>");
	} else if (!have_outfit("Swashbuckling Getup") && available_amount($item[Pirate Fledges])==0) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"island.php\">Pirate's Cove</a>");
		result.append(" - Find the Swashbuckling Getup: ");
		result.append(ItemReport($item[eyepatch])+", ");
		result.append(ItemReport($item[swashbuckling pants], "pants")+", ");
		result.append(ItemReport($item[stuffed shoulder parrot], "parrot"));
		result.append("<tr><td>");
	}
	
	//L7.5ish: pirates, questM12Pirate
	//step1, step2, step3, step4 = insults
	//step5 = fcle
	if (have_outfit("Swashbuckling Getup") && available_amount($item[Pirate Fledges])==0) {
		result.append("<tr><td>");
		if (get_property("questM12Pirate")=="step5") {
			int itdrop = to_int(numeric_modifier("Item Drop"));
			result.append("<a target=mainpane href=\"cove.php\">F'c'le</a> - Find: ");
			result.append(ItemReport($item[mizzenmast mop])+", ");
			result.append(ItemReport($item[ball polish])+", ");
			result.append(ItemReport($item[rigging shampoo]));
			result.append(", Item Drop: "+ItemReport(itdrop>233,to_string(itdrop)));
		} else {
			int totalInsults = 0;
			for ii from 1 upto 8
				if (to_boolean(get_property("lastPirateInsult" + to_string(ii))))
					totalInsults = totalInsults + 1;
			result.append("<a target=mainpane href=cove.php>Barrrney's</a>");
			result.append(" - Insults: <span style=\"color:");
			switch (totalInsults) {
				case 1: result.append("red\"><b>1</b> (0.0%)"); break;
				case 2: result.append("red\"><b>2</b> (0.0%)"); break;
				case 3: result.append("red\"><b>3</b> (1.8%)"); break;
				case 4: result.append("red\"><b>4</b> (7.1%)"); break;
				case 5: result.append("red\"><b>5</b> (17.9%)"); break;
				case 6: result.append("orange\"><b>6</b> (35.7%)"); break;
				case 7: result.append("green\"><b>7</b> (62.5%)"); break;
				case 8: result.append("green\"><b>8</b> (100.0%)"); break;
				default: result.append("red\"><b>0</b> (0.0%)");
			}
			result.append("</span>");
		}
		result.append("</td></tr>");
	}
	
	//L8: trapper: 3 ore, 3 goat cheese, questL08Trapper
	if (Started("questL08Trapper")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=mclargehuge\">McLargeHuge</a>");
		result.append(" - <a target=mainpane href=\"place.php?whichplace=mclargehuge&action=trappercabin\">Trapper</a>");
		switch (get_property("questL08Trapper")) {
		case "step1":
			int itdrop = to_int(numeric_modifier("Item Drop"));
			result.append("<br>Mine: "+ItemReport(to_item(get_property("trapperOre")),3));
			result.append("<br>Goatlet: "+ItemReport($item[goat cheese],3));
			result.append(", Item Drop: "+ItemReport(itdrop>150,to_string(itdrop)));
			break;
		case "step2":
		case "step3":
			if (numeric_modifier("Cold Resistance")<5) {
				result.append("<br>Extreme: ");
				result.append(ItemReport($item[eXtreme scarf], "scarf, "));
				result.append(ItemReport($item[snowboarder pants], "pants, "));
				result.append(ItemReport($item[eXtreme mittens], "mittens"));
			}
			result.append("<br>Ninja: ");
			result.append(ItemReport($item[ninja rope], "rope, "));
			result.append(ItemReport($item[ninja crampons], "crampons, "));
			result.append(ItemReport($item[ninja carabiner], "carabiner"));
		case "step4":
			result.append("<br>Peak: Ascend and kill Groar");
		}
		result.append("</td></tr>");
	}
	
	
	
	
	
	string twinPeak() {
		int p = get_property("twinPeakProgress").to_int();
		boolean mystery(int c) { return (p & (1 << c)) == 0; }
		float famBonus() {
			switch (my_path()) {
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
		if (p < 7) {
			if (mystery(0)) need.comma(ItemReport(numeric_modifier("Stench Resistance") >= 4, "4 Stench Resist"));
			if (mystery(1)) need.comma(ItemReport(foodDrop()>=50, "+50% Food Drop"));
			if (mystery(2)) need.comma(ItemReport($item[Jar of Oil], "Jar of Oil"));
		} else if (p == 15)
			need.append(ItemReport(true, "Mystery Solved!"));
		else
			need.comma(ItemReport(numeric_modifier("Initiative") >= 40, "+40% Init"));
		return need;
	}
	
	buffer highlands() {
		buffer high;
		high.append("<br>A-boo: ");
		high.append(ItemReport(get_property("booPeakProgress")=="0", get_property("booPeakProgress")+"% haunted"));
		if (get_property("booPeakProgress")!="0") {
			high.append(", "+ItemReport($item[A-Boo clue]));
			high.append(" ("+item_amount($item[A-Boo clue])+")");
		}
		//L9: twin peak
		high.append("<br>Twin: "+twinPeak());
		//check 4 stench res, 50% items (no familiars), jar of oil, 40% init
		//L9: oil peak
		high.append("<br>Oil: ");
		high.append(ItemReport(get_property("oilPeakProgress").to_float()==0, get_property("oilPeakProgress")+" &mu;B/Hg"));
		if (high.contains_text(">0% haunt") && high.contains_text("Solved!") && high.contains_text("0.00")) {
			high.set_length(0);
			high.append("<br>Return to <a target=mainpane href=\"place.php?whichplace=highlands&action=highlands_dude\">High Landlord</a>");
		}
		return high;
	}
	
	
	//L9: orc chasm bridge, questL09Topping
	if (Started("questL09Topping")) {
		result.append("<tr><td>");
		int chasmBridgeInt = get_property("lastChasmReset").to_int()==my_ascensions()? get_property("chasmBridgeProgress").to_int() : 0;
		if (chasmBridgeInt < 30) {
			result.append("<a target=mainpane href=\"place.php?whichplace=orc_chasm\">Orc Chasm</a>");
			result.append("<br>Bridge Progress: "+to_string(chasmBridgeInt)+"/30");
		} else {
			result.append("<a target=mainpane href=\"place.php?whichplace=highlands\">Highland Peaks</a>");
			result.append(highlands());
		}
		result.append("</td></tr>");
	}
	
	
	
	
	
	
	//L10: SOCK, Giants Castle, questL10Garbage
	if (Started("questL10Garbage")) {
		result.append("<tr><td>");
		if (item_amount($item[S.O.C.K.])==0) {
			result.append("<a target=mainpane href=\"place.php?whichplace=beanstalk\">Beanstalk</a>");
			result.append(" - Find the "+ItemReport($item[S.O.C.K.]));
			int numina = item_amount($item[Tissue Paper Immateria])+item_amount($item[Tin Foil Immateria])+item_amount($item[Gauze Immateria])+item_amount($item[Plastic Wrap Immateria]);
			result.append("<br>Immateria found: "+ItemReport(numina==4, to_string(numina)+"/4"));
			result.append("<br>");
			result.append(ItemReport($item[amulet of extreme plot significance], "amulet")+", ");
			result.append(ItemReport($item[mohawk wig], "mohawk")+", ");
			result.append(ItemReport($item[titanium assault umbrella], "umbrella")+", ");
			result.append(ItemReport($item[soft green echo eyedrop antidote], "SGEEA")+": "+item_amount($item[soft green echo eyedrop antidote]));
		} else {
			result.append("<a target=mainpane href=\"place.php?whichplace=giantcastle\">Giant's Castle</a>");
			if (get_property("lastCastleTopUnlock").to_int()==my_ascensions()) {
				result.append(" - Turn off the garbage");
			} else if (get_property("lastCastleGroundUnlock").to_int()==my_ascensions()) {
				result.append(" - Explore the ground floor");
			} else {
				result.append(" - Find you way upstairs");
			}
		}
		result.append("</td></tr>");
	}
	
	//L11: MacGuffin, questL11MacGuffin
	if (Started("questL11MacGuffin")) {
		result.append("<tr><td>");
		result.append("<i>Quest for the Holy MacGuffin</i>");
		result.append("</td></tr>");
	}
	
	//L11: questL11Black
	if (Started("questL11Black")) {
		result.append("<tr><td>");
			switch (get_property("questL11Black")) {
			case "started": case "step1": case "step2":
				result.append("<a target=mainpane href=\"woods.php\">Black Forest</a>");
				result.append(" - Find the Market: "+get_property("blackForestProgress")+"/5");
				break;
			case "step3":
				result.append("<a target=mainpane href=\"shore.php\">Shore</a>");
				result.append(" - Get your Father's Diary");
				result.append("<br>"+ItemReport($item[forged identification documents]));
				break;
		}
		result.append("</td></tr>");
	}
	
	//Get pirate fledges from island.php
	if (Started("questL11MacGuffin") && get_property("questL11Palindome")=="unstarted") {
		result.append("<tr><td>");
		if (available_amount($item[pirate fledges])==0) {
			result.append("<a target=mainpane href=\"island.php\">Island</a>");
			result.append(" - Get the pirate fledges");
		} else if (available_amount($item[Talisman o' Namsilat])==0) {
			result.append("<a target=mainpane href=\"cove.php\">Pirate's Cove</a>");
			result.append(" - Find the "+ItemReport($item[Talisman o' Namsilat]));
		} else if (available_amount($item[Talisman o' Namsilat])>0) {
			result.append("<a target=mainpane href=\"plains.php\">Palindome</a>");
			result.append(" - Open the Palindome");
		}
		result.append("</td></tr>");
	}
		
	//L11: questL11Palindome
	if (Started("questL11Palindome")) {
		result.append("<tr><td>");
		if (get_property("questL11Palindome") == "step5") {
			result.append("<a target=mainpane href=\"place.php?whichplace=palindome\">Palindome</a>");
			result.append(" - Kill Dr. Awkward");
		} else {
			result.append("<a target=mainpane href=\"place.php?whichplace=palindome\">Palindome</a>");
			result.append(" - Seek Dr. Awkward");
		}
		if (get_property("questL11Palindome") == "started") {
			result.append("<br>Obtain: ");
			result.append(ItemReport($item[photograph of God],"photo of God"));
			result.append(", ");
			result.append(ItemReport($item[photograph of a red nugget],"photo of red nugget"));
			result.append(", ");
			result.append(ItemReport($item[photograph of a dog],"photo of dog"));
			result.append(", ");
			result.append(ItemReport($item[photograph of an ostrich egg],"photo of ostrich egg"));
			result.append(", ");
			result.append(ItemReport($item[[7262]&quot;I Love Me\, Vol. I&quot;],"I Love Me"));
			result.append(", ");
			result.append(ItemReport($item[stunt nuts]));
		}
		if (get_property("questL11Palindome") == "step1") {
			result.append("<br>Obtain: ");
			result.append(ItemReport($item[&quot;2 Love Me\, Vol. 2&quot;]));
		}
		// get wet stunt nut stew, mega gem
		if (available_amount($item[Mega Gem])==0) {
			result.append("<br><a target=mainpane href=\"place.php?whichplace=palindome\">Palindome</a>");
			result.append(" - Get the Mega Gem");
			result.append("<br>");
			if (available_amount($item[wet stunt nut stew])>0) {
				result.append(ItemReport($item[wet stunt nut stew]));
			} else if (available_amount($item[wet stew])>0) {
				result.append(ItemReport($item[stunt nuts]));
				result.append(", ");
				result.append(ItemReport($item[wet stew]));
			} else {
				result.append(ItemReport($item[stunt nuts]));
				result.append(", ");
				result.append(ItemReport($item[bird rib]));
				result.append(", ");
				result.append(ItemReport($item[lion oil]));
			}
		}
		result.append("</td></tr>");
	}
	
	//L11: questL11Manor, assume wine bomb route
	if (Started("questL11Manor")) {
		result.append("<tr><td>");
			switch (get_property("questL11Manor")) {
			case "started":
				result.append("<a target=mainpane href=\"manor2.php\">Manor</a>");
				result.append(" - Open Spookyraven cellar (Ballroom)");
				break;
			case "step1": case "step2":
				result.append("<a target=mainpane href=\"manor3.php\">Manor Cellar</a>");
				result.append(" - Find Lord Spookyraven");
				if (my_path()=="Nuclear Autumn" && available_amount($item[E-Z Cook&trade; oven])==0 && item_amount($item[recipe: mortar-dissolving solution])>0) {
					result.append("<br>Find mortar dissolvers:");
					result.append("<br><a target=mainpane href=\"place.php?whichplace=manor1\">Kitchen</a> - "+ItemReport($item[loosening powder]));
					result.append("<br><a target=mainpane href=\"place.php?whichplace=manor1\">Conservatory</a> - "+ItemReport($item[powdered castoreum],"castoreum"));
					result.append("<br><a target=mainpane href=\"place.php?whichplace=manor2\">Bathroom</a> - "+ItemReport($item[drain dissolver]));
					result.append("<br><a target=mainpane href=\"place.php?whichplace=manor2\">Gallery</a> - "+ItemReport($item[triple-distilled turpentine],"distilled turpentine"));
					result.append("<br><a target=mainpane href=\"place.php?whichplace=manor3\">Laboratory</a> - "+ItemReport($item[detartrated anhydrous sublicalc],"anhydrous sublicalc"));
					result.append("<br><a target=mainpane href=\"place.php?whichplace=manor3\">Storage</a> - "+ItemReport($item[triatomaceous dust]));
				} else if (available_amount($item[Lord Spookyraven's spectacles])==0) {
					result.append("<br>Find "+ItemReport($item[Lord Spookyraven's spectacles]));
				} else if (get_property("spookyravenRecipeUsed")!="with_glasses") {
					result.append("<br>Equip spectacles, read mortar recipe");
				} else if (available_amount($item[wine bomb])==0) {
					if (available_amount($item[unstable fulminate])>0) {
						result.append("<br>Boiler Room: "+ItemReport($item[wine bomb]));
					} else {
						result.append("<br>Wine Cellar: "+ItemReport($item[bottle of Chateau de Vinegar],"Chateau de Vinegar"));
						result.append("<br>Laundry Room: "+ItemReport($item[blasting soda]));
					}
				}
				break;
			case "step3":
				result.append("<a target=mainpane href=\"manor3.php\">Manor Cellar</a> - Kill Spookyraven");
				break;
			}
		result.append("</td></tr>");
	}
	
	
	if (Started("questL11Worship")) {
		// How many McClusky file pages are present?
		int files() {
			for f from 6693 downto 6689
				if (to_item(f).available_amount() > 0)
					return f - 6688;
			return 0;
		}
		result.append("<tr><td>");
		switch (get_property("questL11Worship")) {
		case "started": case "step1": case "step2":
			result.append("<a target=mainpane href=\"woods.php\">Hidden Temple</a> - Find the Hidden City");
			break;
		case "step3": case "step4":
			if (item_amount($item[stone triangle]) < 4) {
				result.append("<a target=mainpane href=\"hiddencity.php\">Hidden City</a><br>");
				boolean relocatePygmyJanitor = get_property("relocatePygmyJanitor").to_int() == my_ascensions();
				result.append("Hidden Park: ");
				if (available_amount($item[antique machete]) == 0 || !relocatePygmyJanitor) {
					result.append(ItemReport($item[antique machete]));
					result.append(", ");
					result.append(ItemReport(relocatePygmyJanitor, "relocate janitors"));
					result.append("<br>");
				} else 
					result.append(ItemReport(true, "Done!<br>"));
				foreach loc in $strings[Apartment, Office, Hospital, BowlingAlley] {
					result.append(loc+": ");
					int prog = get_property("hidden"+loc+"Progress").to_int();
					if (prog == 0)
						result.append(ItemReport(false, "Explore Shrine<br>"));
					else if (prog < 7) {
						switch (loc) {
						case "Apartment":
							//result.append(ItemReport(get_property("relocatePygmyLawyer").to_int() == my_ascensions(), "relocate Lawyers, "));
							//result.append(ItemReport(false, "Search for Boss<br>"));
							result.append(ItemReport((have_effect($effect[Thrice-Cursed])>0), "Thrice-Cursed"));
							result.append("<br>");
							break;
						case "Office":
							if (available_amount($item[McClusky file (complete)]) > 0)
								result.append(ItemReport(false, "Kill Boss!"));
							else {
								int f = files();
								if (f<5) {
									result.append(ItemReport(f >=5, "McClusky files (" + f + "/5)"));
								} else {
									result.append(ItemReport($item[boring binder clip], "binder clip"));
								}
							}
							result.append("<br>");
							break;
						case "Hospital":
							result.append(ItemReport(false, "Surgeonosity ("+to_string(numeric_modifier("surgeonosity"), "%.0f")+"/5)<br>"));
							break;
						case "BowlingAlley":
							//result.append(ItemReport($item[bowling ball]));
							//result.append(", ");
							result.append(ItemReport(false, "Bowled ("+(prog - 1)+"/5)<br>"));
							break;
						}
					} else if (prog == 7)
						result.append(ItemReport(false, "Use Sphere<br>"));
					else
						result.append(ItemReport(true, "Done!<br>"));
				}
				result.append("Tavern: ");
				if (get_property("hiddenTavernUnlock") != my_ascensions()) {
					result.append(ItemReport($item[book of matches]));
					result.append("<br>");
				} else
					result.append(ItemReport(true, "Unlocked<br>"));
			} else {
				result.append("<a target=mainpane href=\"hiddencity.php\">Hidden City</a>: Kill the Protector Spectre");
			}
			break;
		}
		result.append("</td></tr>");
	}
	
	
	
	//L11: questL11Desert
	if (Started("questL11Desert") && my_path()!="Actually Ed the Undying") {
		result.append("<tr><td>");
			result.append("<a target=mainpane href=\"beach.php\">Beach</a> - Find the Pyramid<br>");
			int desertExploration = get_property("desertExploration").to_int();
			if (desertExploration < 10) {
				result.append("<a target=mainpane href=\"beach.php\">Desert</a>");
				result.append(" - Find Gnasir<br>");
			}
			if (desertExploration < 100) {
				result.append("<a target=mainpane href=\"beach.php\">Desert</a>");
				result.append(" - Exploration: "+desertExploration+"%<br>");
				int gnasirProgress = get_property("gnasirProgress").to_int();
				buffer gnasir;
				if ((gnasirProgress & 4) == 0)
					gnasir.comma(ItemReport($item[killing jar]));
				if ((gnasirProgress & 2) == 0)
					gnasir.comma(ItemReport($item[can of black paint]));
				if ((gnasirProgress & 1) == 0)
					gnasir.comma(ItemReport($item[stone rose]));
				if ((gnasirProgress & 8) == 0) {
					gnasir.comma(ItemReport($item[worm-riding manual page], 15));
					gnasir.comma(ItemReport($item[drum machine]));
				} else if ((gnasirProgress & 16) == 0) {
					gnasir.comma(ItemReport($item[drum machine]));
					gnasir.comma(ItemReport($item[worm-riding hooks]));
					gnasir.append("<br><a target=mainpane href=\"place.php?whichplace=desertbeach&action=db_pyramid1&pwd="+my_hash()+"\">Ride the Worm !</a>");
					#gnasir.append("<br><a target=mainpane href=\"inv_use.php?which=3&whichitem=2328&pwd="+my_hash()+"\">Ride the Worm !</a>");
				}
				result.append(gnasir);
			}
		result.append("</td></tr>");
	
	}
	
	//L11: questL11Desert
	if (get_property("questL11Desert")=="finished" && get_property("questL11Pyramid")=="unstarted") {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"beach.php\">Beach</a>");
		result.append(" - Open the Pyramid: ");
		result.append(ItemReport($item[[7964]Staff of Fats], "Staff of Fats, "));
		result.append(ItemReport($item[[7963]ancient amulet], "amulet, "));
		result.append(ItemReport($item[[7962]Eye of Ed], "Eye of Ed"));
		result.append("</td></tr>");
	
	}
	
	//L11: questL11Pyramid
	if (Started("questL11Pyramid")) {
		string questL11Pyramid = get_property("questL11Pyramid");
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"pyramid.php\">Pyramid</a>");
		switch (questL11Pyramid) {
		case "started":
			result.append(" - Unlock the Middle Chamber<br>");
			break;
		case "step1": case "step2":
			result.append(" - Unlock the Control Room<br>");
			break;
		}
		if (get_property("pyramidBombUsed")=="false") {
			result.append(" - Find Ed<br>");
			result.append(ItemReport($item[tomb ratchet], "tomb ratchets: "+item_amount($item[tomb ratchet]))+"<br>");
			result.append(ItemReport($item[crumbling wooden wheel], "wooden wheels: "+item_amount($item[crumbling wooden wheel])));
			result.append("<br>");
			if (item_amount($item[ancient bomb]) == 0) {
				boolean token = item_amount($item[ancient bronze token]) > 0;
				if (!token) {
					if (get_property("pyramidPosition") != "4") {
						result.append("Turn wheel for ");
					} else {
						result.append("Get ");
					}
					result.append(ItemReport(token, "ancient token"));
					result.append("<br>Wait for ");
				} else {
					result.append("Have ");
					result.append(ItemReport(token, "ancient token"));
					if (get_property("pyramidPosition") != "3")
						result.append("<br>Turn wheel for ");
					else result.append("<br>Get ");
				}
				result.append(ItemReport($item[ancient bomb]));
			} else {
				if (get_property("pyramidPosition") == "1") {
					result.append(ItemReport(false, "Blow up Lower Chamber"));
				} else {
					result.append("Turn wheel to blow up chamber");
				}
			}
		} else {
			result.append(" - Kill Ed");
		}
		result.append("</td></tr>");
	}
	
	
	//L12: War, questL12War
	if (Started("questL12War")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"island.php\">Island</a>");
		result.append(" - Fight the War:");
		if (get_property("questL12War") == "started") {
			result.append("<br>Start the War... somehow");
		} else {
			result.append("<br>");
			result.append("<span style=\"color:purple\">Fratboys</span> defeated: "+get_property("fratboysDefeated"));
			result.append("<br>");
			result.append("<span style=\"color:green\">Hippies</span> defeated: "+get_property("hippiesDefeated"));
		}
		
		if (item_amount($item[jam band flyers])+item_amount($item[rock band flyers]) > 0 ) {
			float flyers = to_float(get_property("flyeredML"))/100.0;
			result.append("<br><a target=mainpane href=\"bigisland.php?place=concert\">Arena</a> - Flyering: ");
			result.append(ItemReport(flyers>=100, to_string(flyers,"%.2f")+"%"));
		}
		if (item_amount($item[molybdenum magnet])>0 && get_property("sidequestJunkyardCompleted")=="none" ) {
			result.append("<br><a target=mainpane href=\"bigisland.php?place=junkyard\">Junkyard</a>");
			result.append(" - Find some tools");
		}
		if (item_amount($item[barrel of gunpowder]) > 0 && get_property("sidequestLighthouseCompleted")=="none" ) {
			result.append("<br><a target=mainpane href=\"bigisland.php?place=lighthouse\">SonofaBeach</a> - ");
			result.append(ItemReport($item[barrel of gunpowder], "Barrels", 5));
		}
		
		if ( get_property("sidequestOrchardCompleted")=="none" && (item_amount($item[filthworm hatchling scent gland])>0 || have_effect($effect[Filthworm Larva Stench])>0 || item_amount($item[filthworm drone scent gland])>0 ||have_effect($effect[Filthworm Drone Stench])>0 ||item_amount($item[filthworm royal guard scent gland])>0 ||have_effect($effect[Filthworm Guard Stench])>0) ) {
			result.append("<br><a target=mainpane href=\"bigisland.php?place=orchard\">Orchard</a>");
			result.append(" - Destroy the Filthworms");
		}
		
		if ( to_int(get_property("currentNunneryMeat"))>0 && get_property("sidequestNunsCompleted")=="none" ) {
			int nunmeat = to_int(get_property("currentNunneryMeat"));
			result.append("<br><a target=mainpane href=\"bigisland.php?place=nunnery\">Nunnery</a>");
			result.append(" - Meat found: ");
			result.append(ItemReport(nunmeat>=10000, to_string(nunmeat,"%,d")));
		}
		
		result.append("</td></tr>");
	}
	
	
	//L13: NS, questL13Final
	// check for lair items, tower items, wand
	if (Started("questL13Final")) {
		result.append("<tr><td>");
		
		result.append("<a target=mainpane href=\"lair.php\">Naughty Sorceress</a>");
		
		//Gate item
		if ( $strings[started, step1, step2, step3, step4] contains get_property("questL13Final")) {
			result.append("<br>");
			result.append("<a target=mainpane href=\"place.php?whichplace=nstower&action=ns_01_contestbooth\">Contests</a>: ");
			if ( get_property("telescopeUpgrades")=="0" || in_bad_moon()) {
				result.append("no telescope");
			}
			else if (get_property("lastTelescopeReset") != my_ascensions()) {
				result.append("no current telescope info");
			}
			else {
				result.append("Init, ");
				result.append(DecoMods(get_property("nsChallenge1")));
				result.append(", ");
				result.append(DecoMods(get_property("nsChallenge2")));
				result.append("<br>");
				result.append("Hedges: ");
				result.append(DecoMods(get_property("nsChallenge3")));
				result.append(", ");
				result.append(DecoMods(get_property("nsChallenge4")));
				result.append(", ");
				result.append(DecoMods(get_property("nsChallenge5")));
			}
		}
		//Entryway items, "nsTowerDoorKeysUsed"
		if ( $strings[started, step1, step2, step3, step4, step5, step6, step7, step8] contains get_property("questL13Final") ) {
			boolean key_used(item it) {
				return contains_text(get_property("nsTowerDoorKeysUsed"),to_string(it));
			}
			result.append("<br>");
			result.append("<a target=mainpane href=\"place.php?whichplace=nstower_door\">Door</a>");
			result.append(" Keys: ");
			foreach kk in $items[Boris's key, Jarlsberg's key, Sneaky Pete's key, digital key, skeleton key, Richard's star key] {
				if (!key_used(kk)) { result.append(ItemReport(kk)+", "); }
			}
		}
		if ($strings[started, step1, step2, step3, step4, step5, step6, step7, step8] contains get_property("questL13Final") ) {
			result.append("<br>Tower: ");
			result.append(ItemReport($item[beehive]));
			result.append(", ");
			result.append("Meat: +"+to_string(to_int(meat_drop_modifier()))+"%");
			result.append(", ");
			result.append(ItemReport($item[electric boning knife], "boning knife"));
		}
		boolean NSfight = !($strings[Avatar of Boris, Bugbear Invasion, Zombie Slayer, Avatar of Jarlsberg, Heavy Rains, KOLHS, Avatar of Sneaky Pete, The Source] contains my_path());
		if ( NSfight && $strings[started, step1, step2, step3, step4, step5, step6, step7, step8, step9] contains get_property("questL13Final")) {
			if ( my_path()=="Bees Hate You" ) {
				result.append("<br>GMOB: ");
				result.append(ItemReport($item[antique hand mirror]));
			} else  {
				result.append("<br>NS: ");
				result.append(ItemReport($item[Wand of Nagamar]));
			}
			result.append("</td></tr>");
		}
	}
	
	
	if (Started("questL13Warehouse")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"tutorial.php\">Warehouse</a> ");
		result.append(" - Search progress: "+get_property("warehouseProgress")+"/40");
		result.append("</td></tr>");
	}
	
	
	//HITS: stars and lines and charts
	if ( item_amount($item[steam-powered model rocketship])>0 && item_amount($item[Richard's star key])==0 && !contains_text(get_property("nsTowerDoorKeysUsed"),"Richard's star key") ) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=beanstalk\">HITS</a>: ");
		result.append(ItemReport($item[star], 8));
		result.append(", ");
		result.append(ItemReport($item[line], 7));
		result.append(", ");
		result.append(ItemReport($item[star chart],"chart"));
		result.append("</td></tr>");
	}
	
	//Daily Dungeon
	if (!to_boolean(get_property("dailyDungeonDone"))&& get_property("questL13Final")!="finished" && !($strings[Bugbear Invasion, Actually Ed the Undying] contains my_path()) ) {
		int havekeys = available_amount($item[fat loot token]);
		int needkeys = 3;
		foreach kk in $items[Boris's key, Jarlsberg's key, Sneaky Pete's key] {
			havekeys = havekeys + available_amount(kk);
			needkeys = needkeys - to_int(contains_text(get_property("nsTowerDoorKeysUsed"),to_string(kk)));
		}
		if (havekeys<needkeys) {
			result.append("<tr><td>");
			result.append("<a target=mainpane href=\"da.php\">Daily Dungeon</a>");
			result.append(" - Get keys: "+havekeys+"/"+needkeys);
			result.append("</td></tr>");
		}
	}
	
	//Digital Key
	if (item_amount($item[digital key])==0 && !contains_text(get_property("nsTowerDoorKeysUsed"),to_string($item[digital key]))) {
		int whitepix = item_amount($item[white pixel]) + creatable_amount($item[white pixel]);
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"woods.php\">Digital Key</a>");
		result.append(" - Get white pixels: "+whitepix+"/30");
		result.append("</td></tr>");
	}
	
	
	//questM13Escape, Subject 37
	if (Started("questM13Escape") && can_interact()) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"cobbsknob.php?level=3\">Menagerie</a>");
		result.append(" - Help Subject 37 escape");	
		result.append("</td></tr>");
	}
	
	
	//L99: questM15Lol (facsimile dictionary)
	if (Started("questM15Lol") && my_level()>=9 && can_interact()) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"mountains.php\">Rof Lm Fao</a>");
		result.append(" - Find the 64735");
		result.append("</td></tr>");
	}
	
	
	
	
	//L99: Nemesis stuff ?
	//Sea quests
	
	
	//challenge path stuff
	/*
	if (my_path() == "Bees Hate You") 
		honeypot for gate in NS tower

	if (my_path() == "Avatar of Boris") 
		No star weapon is needed at the lair
	
	if (my_path() == "Avatar of Jarlsberg") 


	if (my_path() == "Trendy") 
	
	
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
	
	
	
	
	//questESlMushStash
	if (Started("questESlMushStash")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Fun-Guy Mansion</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc1\">Buff Jimmy</a>");
		result.append(" - Find ");
		result.append(ItemReport($item[pencil thin mushroom],"mushrooms",10));
		result.append("</td></tr>");
	}
	//questESlCheeseburger
	if (Started("questESlCheeseburger")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Sloppy Seconds Diner</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc1\">Buff Jimmy</a>");
		result.append(" - Get burger ");
		result.append(ItemReport(get_property("buffJimmyIngredients")=="15","ingredients: "+get_property("buffJimmyIngredients")+"/15"));
		if (!have_equipped($item[Paradaisical Cheeseburger recipe])) {
			result.append("<br>"+EquipReport($item[Paradaisical Cheeseburger recipe]));
		}
		result.append("</td></tr>");
	}
	//questESlSalt
	if (Started("questESlSalt")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Sunken Party Yacht</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc1\">Buff Jimmy</a>");
		result.append(" - Get sons of sailors ");
		result.append(ItemReport($item[salty sailor salt],"sailor salt",50));
		result.append("</td></tr>");
	}
	//questESlAudit
	if (Started("questESlAudit")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Fun-Guy Mansion</a>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc2\">Taco Dan</a>");
		result.append(" - ");
		result.append(" - Find lost ");
		result.append(ItemReport($item[Taco Dan's Taco Stand's Taco Receipt],"Receipts",10));
		if (have_effect($effect[Sleight of Mind])==0) {
			result.append("<br><span class=walford_nobucket>need <i>Sleight of Mind</i>, use sleight-of-hand mushroom</span>");
		}
		result.append("</td></tr>");
	}
	//questESlCocktail
	if (Started("questESlCocktail")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Sloppy Seconds Diner</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc2\">Taco Dan</a>");
		result.append(" - Get cocktail ");
		result.append(ItemReport(get_property("tacoDanCocktailSauce")=="15","sauce: "+get_property("tacoDanCocktailSauce")+"/15"));
		if (!have_equipped($item[Taco Dan's Taco Stand Cocktail Sauce Bottle])) {
			result.append("<br>"+EquipReport($item[Taco Dan's Taco Stand Cocktail Sauce Bottle]));
		}
		result.append("</td></tr>");
	}
	//questESlFish
	if (Started("questESlFish")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Sunken Party Yacht</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc2\">Taco Dan</a>");
		result.append(" - Find taco fish ");
		result.append(ItemReport(get_property("tacoDanFishMeat").to_int()>=300,"meat: "+get_property("tacoDanFishMeat")+"/300"));
		result.append("</td></tr>");
	}
	//questESlBacteria
	if (Started("questESlBacteria")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Fun-Guy Mansion</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc3\">Broden</a>");
		result.append(" - Get hot-tub ");
		result.append(ItemReport(get_property("brodenBacteria").to_int()>=10,"bacteria: "+get_property("brodenBacteria")+"/10"));
		//result.append("<br>(+resist all)"); 
		result.append("</td></tr>");
	}
	//questESlSprinkles
	if (Started("questESlSprinkles")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Sloppy Seconds Diner</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc3\">Broden</a>");
		result.append(" - Get Sundae ");
		result.append(ItemReport(get_property("brodenSprinkles").to_int()>=15,"sprinkles: "+get_property("brodenSprinkles")+"/15"));
		if (!have_equipped($item[sprinkle shaker])) {
			result.append("<br>"+EquipReport($item[sprinkle shaker]));
		}
		result.append("</td></tr>");
	}
	//questESlDebt
	if (Started("questESlDebt")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze\">Sunken Party Yacht</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_sleaze&action=airport1_npc3\">Broden</a>");
		result.append(" - collect drownedbeat debts: ");
		result.append(ItemReport($item[bike rental broupon],"broupons",15));
		result.append("</td></tr>");
	}
	
	
	//questESpEVE
	if (Started("questESpEVE")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Secret Government Lab</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Defeat E.V.E., the robot zombie");
		result.append("</td></tr>");
	}
	//questESpJunglePun
	if (Started("questESpJunglePun")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Deep Dark Jungle</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Collect ");
		result.append(ItemReport(get_property("junglePuns").to_int()>=11,"Jungle Puns: "+get_property("junglePuns")+"/11"));
		if (!have_equipped($item[encrypted micro-cassette recorder])) {
			result.append("<br>"+EquipReport($item[encrypted micro-cassette recorder]));
		}
		result.append("</td></tr>");
	}
	//questESpGore	Gore Tipper
	if (Started("questESpGore")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Secret Government Lab</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Collect ");
		result.append(ItemReport(get_property("goreCollected").to_int()>=100,"Gore: "+get_property("goreCollected")+"/100"));
		if (!have_equipped($item[gore bucket])) {
			result.append("<br>"+EquipReport($item[gore bucket]));
		}
		result.append("</td></tr>");
	}
	//questESpClipper
	if (Started("questESpClipper")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Dr. Weirdeaux</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Collect ");
		result.append(ItemReport(get_property("fingernailsClipped").to_int()>=23,"Fingernail Clippings: "+get_property("fingernailsClipped")+"/23"));
		result.append("</td></tr>");
	}
	//questESpFakeMedium
	if (Started("questESpFakeMedium")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Secret Government Lab</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Get ");
		result.append(ItemReport($item[ESP suppression collar]));
		result.append("</td></tr>");
	}
	//questESpSerum
	if (Started("questESpSerum")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Dr. Weirdeaux</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Get ");
		result.append(ItemReport($item[experimental serum P-00],"vials of serum P-00: ",5));
		result.append("</td></tr>");
	}
	//questESpSmokes
	if (Started("questESpSmokes")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Deep Dark Jungle</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Get ");
		result.append(ItemReport($item[pack of smokes],"pack of smokes: ",10));
		result.append("</td></tr>");
	}
	//questESpOutOfOrder
	if (Started("questESpOutOfOrder")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky\">Deep Dark Jungle</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_spooky&action=airport2_radio\">Conspiracy Radio</a>");
		result.append(" - Find ");
		result.append(ItemReport($item[Project T. L. B.]));
		if (!have_equipped($item[GPS-tracking wristwatch])) {
			result.append("<br>"+EquipReport($item[GPS-tracking wristwatch]));
		}
		result.append("</td></tr>");
	}
	
	
	//questEStFishTrash
	if (Started("questEStFishTrash")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Garbage Barges</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Collect ");
		result.append(ItemReport(get_property("dinseyFilthLevel").to_int()>=20,"Trash: "+get_property("dinseyFilthLevel")+"/20"));
		if (!have_equipped($item[trash net])) {
			result.append("<br>"+EquipReport($item[trash net]));
		}
		result.append("</td></tr>");
	}
	//questEStGiveMeFuel
	if (Started("questEStGiveMeFuel")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Toxic Teacups</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Get ");
		result.append(ItemReport($item[toxic globule],"toxic globule: ",20));
		result.append("</td></tr>");
	}
	//questEStNastyBears
	if (Started("questEStNastyBears")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Uncle Gator</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Remove ");
		result.append(ItemReport(get_property("dinseyNastyBearsDefeated").to_int()>=8,"Nasty Bears: "+get_property("dinseyNastyBearsDefeated")+"/8"));
		result.append("</td></tr>");
	}
	//questEStSocialJusticeI
	if (Started("questEStSocialJusticeI")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Garbage Barges</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Remove ");
		result.append(ItemReport(get_property("dinseySocialJusticeIProgress").to_int()>=15,"Sexism: "+get_property("dinseySocialJusticeIProgress")+"/15"));
		result.append("</td></tr>");
	}
	//questEStSocialJusticeII
	if (Started("questEStSocialJusticeII")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Uncle Gator</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Remove ");
		result.append(ItemReport(get_property("dinseySocialJusticeIIProgress").to_int()>=15,"Racism: "+get_property("dinseySocialJusticeIIProgress")+"/15"));
		result.append("</td></tr>");
	}
	//questEStSuperLuber
	if (Started("questEStSuperLuber")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Barf Mountain</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Lube the Rollercoaster");
		if (!have_equipped($item[lube-shoes]) && available_amount($item[lube-shoes])>0) {
			result.append("<br>"+EquipReport($item[lube-shoes]));
		}
		result.append("</td></tr>");
	}
	//questEStWorkWithFood
	if (Started("questEStWorkWithFood")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Barf Mountain</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Feed ");
		result.append(ItemReport(get_property("dinseyTouristsFed").to_int()>=30,"Tourists: "+get_property("dinseyTouristsFed")+"/30"));
		result.append("</td></tr>");
	}
	//questEStZippityDooDah
	if (Started("questEStZippityDooDah")) {
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench\">Toxic Teacups</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"place.php?whichplace=airport_stench&action=airport3_kiosk\">Dinsey Kiosk</a>");
		result.append(" - Have ");
		result.append(ItemReport(get_property("dinseyFunProgress").to_int()>=15,"Fun: "+get_property("dinseyFunProgress")+"/15"));
		if (!have_equipped($item[Dinsey mascot mask])) {
			result.append("<br>"+EquipReport($item[Dinsey mascot mask]));
		}
		result.append("</td></tr>");
	}
	
	
	//questECoBucket
	if (Started("questECoBucket")) {
		int current = get_property("walfordBucketProgress").to_int();
		buffer walprog;
		walprog.append(" - ");
		walprog.append("<a target=mainpane href=\"place.php?whichplace=airport_cold&action=glac_walrus\">Walford</a>");
		walprog.append(" "+get_property("walfordBucketItem")+": ");
		if (get_property("walfordBucketProgress").to_int()>=100) {
			walprog.append("<span class=walford_done>");
		} else {
			walprog.append("<span class=walford_nobucket>");
		}
		walprog.append(get_property("walfordBucketProgress")+"%");
		walprog.append("</span>");
		walprog.append("<br>");
		
		int NofamBonus(string wut) {
			item fameq = familiar_equipped_equipment(my_familiar());
			int famwt = round( familiar_weight(my_familiar()) + weight_adjustment() - numeric_modifier(fameq, "Familiar Weight") ); 
			float fambo = numeric_modifier( my_familiar(), wut, famwt , fameq );
			return floor(numeric_modifier(wut) - fambo);
		}
		
		result.append("<tr><td>");
		switch (get_property("walfordBucketItem")) {
		case "balls":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">VYKEA</a>");
			result.append(walprog);
			//result.append("+50% Item Drop");
			result.append(ItemReport(NofamBonus("Item Drop")>=50,"+50% Item Drop"));
			break;
		case "blood":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">The Glaciest</a>");
			result.append(walprog);
			result.append("Bleeding Damage");
			if ( !have_equipped($item[reindeer sickle]) && available_amount($item[reindeer sickle])>0 ) {
				result.append(" - "+EquipReport($item[reindeer sickle]));
			}
			break;
		case "bolts":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">VYKEA</a>");
			result.append(walprog);
			result.append(EquipReport($item[VYKEA hex key]));
			break;
		case "chicken":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">Ice Hotel</a>");
			result.append(walprog);
			result.append(ItemReport(numeric_modifier("Food Drop")>=50,"+50% Food Drop"));
			break;
		case "chum":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">VYKEA</a>");
			result.append(walprog);
			//result.append("+100% Meat Drop");
			result.append(ItemReport(NofamBonus("Meat Drop")>=100,"+100% Meat Drop"));
			break;
		case "ice":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">The Glaciest</a>");
			result.append(walprog);
			result.append("10 <span class=modCold>Cold</span> Damage per kill");
			break;
		case "milk":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">Ice Hotel</a>");
			result.append(walprog);
			result.append(ItemReport(numeric_modifier("Booze Drop")>=50,"+50% Booze Drop"));
			break;
		case "moonbeams":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">The Glaciest</a>");
			result.append(walprog);
			result.append("No hat");
			if (equipped_item($slot[hat])!=$item[none]) {
				result.append(" - <a href=\"");
				result.append(sideCommand("unequip Hat"));
				result.append("\">Unequip</a> ");
				result.append(ItemReport(equipped_item($slot[hat])==$item[none],"Hat"));
			}
			break;
		case "rain":
			result.append("<a target=mainpane href=\"place.php?whichplace=airport_cold\">Ice Hotel</a>");
			result.append(walprog);
			result.append(ItemReport(numeric_modifier("Hot Damage")>=100,"100 Hot Damage"));
			break;
		}
		if (!have_equipped($item[Walford's bucket])) {
			result.append("<br>"+EquipReport($item[Walford's bucket]));
		}
		result.append("</td></tr>");
	}
	
	
	//progress in questPAGhost, ghost location in ghostLocation
	if (Started("questPAGhost") && have_equipped($item[protonic accelerator pack])) {
		location gloc = to_location(get_property("ghostLocation"));
		string[location] loczone;
		loczone[$location[Cobb's Knob Treasury]] = "cobbsknob.php";
		loczone[$location[The Haunted Conservatory]] = "place.php?whichplace=manor1";
		loczone[$location[The Haunted Gallery]] = "place.php?whichplace=manor2";
		loczone[$location[The Haunted Kitchen]] = "place.php?whichplace=manor1";
		loczone[$location[The Haunted Wine Cellar]] = "place.php?whichplace=manor4";
		loczone[$location[The Icy Peak]] = "place.php?whichplace=mclargehuge";
		loczone[$location[Inside the Palindome]] = "place.php?whichplace=plains";
		loczone[$location[Madness Bakery]] = "place.php?whichplace=town_right";
		loczone[$location[The Old Landfill]] = "place.php?whichplace=woods";
		loczone[$location[The Overgrown Lot]] = "place.php?whichplace=town_wrong";
		loczone[$location[The Skeleton Store]] = "place.php?whichplace=town_market";
		loczone[$location[The Smut Orc Logging Camp]] = "place.php?whichplace=orc_chasm";
		loczone[$location[The Spooky Forest]] = "woods.php";
		
		item[location] locit;
		locit[$location[Cobb's Knob Treasury]] = $item[Mr. Screege's spectacles];
		locit[$location[The Haunted Conservatory]] = $item[Spookyraven signet];
		locit[$location[The Haunted Gallery]] = $item[Carpathian longsword];
		locit[$location[The Haunted Kitchen]] = $item[frigid derringer];
		locit[$location[The Haunted Wine Cellar]] = $item[Unfortunato's foolscap];
		locit[$location[The Icy Peak]] = $item[burnt snowpants];
		locit[$location[Inside the Palindome]] = $item[Liam's mail];
		locit[$location[Madness Bakery]] = $item[smoldering bagel punch];
		locit[$location[The Old Landfill]] = $item[tie-dyed fannypack];
		locit[$location[The Overgrown Lot]] = $item[haunted bindle];
		locit[$location[The Skeleton Store]] = $item[fleshy lump];
		locit[$location[The Smut Orc Logging Camp]] = $item[standards and practices guide];
		locit[$location[The Spooky Forest]] = $item[ghostly reins];
		
		result.append("<tr><td>");
		result.append("<span style=\"color: fuchsia\">Ghost Busting</span>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"");
		result.append(loczone[gloc]);
		result.append("\">");
		result.append(to_string(gloc));
		result.append("</a>");
		result.append(" - ");
		result.append(ItemReport(locit[gloc]));
		result.append("</td></tr>");
	}
	
	
	//questM26Oracle
	if (Started("questM26Oracle")) {
		string[location] loczone;
		loczone[$location[The Skeleton Store]] = "place.php?whichplace=town_market";
		loczone[$location[Madness Bakery]] = "place.php?whichplace=town_right";
		loczone[$location[The Overgrown Lot]] = "place.php?whichplace=town_wrong";
		loczone[$location[The Batrat and Ratbat Burrow]] = "place.php?whichplace=bathole";
		loczone[$location[The Haunted Kitchen]] = "place.php?whichplace=manor1";
		loczone[$location[Cobb's Knob Laboratory]] = "cobbsknob.php?action=tolabs";
		loczone[$location[Lair of the Ninja Snowmen]] = "place.php?whichplace=mclargehuge";
		loczone[$location[The VERY Unquiet Garves]] = "place.php?whichplace=cemetery";
		loczone[$location[The Castle in the Clouds in the Sky (Top Floor)]] = "place.php?whichplace=giantcastle";
		loczone[$location[The Red Zeppelin]] = "place.php?whichplace=zeppelin";
		loczone[$location[The Hidden Park]] = "place.php?whichplace=hiddencity";
		
		result.append("<tr><td>");
		result.append("<a target=mainpane href=\"place.php?whichplace=town_wrong&action=townwrong_oracle\">The Oracle</a>");
		result.append(" - ");
		result.append("<a target=mainpane href=\"");
		result.append(loczone[to_location(get_property("sourceOracleTarget"))]);
		result.append("\">");
		result.append(get_property("sourceOracleTarget"));
		result.append("</a>");
		result.append(" - Find ");
		result.append(ItemReport($item[no spoon]));
		result.append("</td></tr>");
	}
	
	
	
	result.append("</table>");
	return result;
}


void bakeTracker() {
	buffer result = buildTracker();
	
	if (length(result) > 184) { // 184 is the size of an empty table
		chitBricks["tracker"] = result;
		chitTools["tracker"] = "Tracker|tracker.png";
	}
}

