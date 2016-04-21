/************************************************************************************
CHaracter Info Toolbox tracker brick by ckb

TTD:
- better consistancy of wording / syntax
- checks / hints for elem airport quests
- other quests?

************************************************************************************/


buffer buildTracker() {
	
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

	string decomods(string ss) {
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
			if(mystery(0)) need.comma(item_report(numeric_modifier("Stench Resistance") >= 4, "4 Stench Resist"));
			if(mystery(1)) need.comma(item_report(foodDrop()>=50, "+50% Food Drop"));
			if(mystery(2)) need.comma(item_report($item[Jar of Oil], "Jar of Oil"));
		} else if(p == 15)
			need.append(item_report(true, "Mystery Solved!"));
		else
			need.comma(item_report(numeric_modifier("Initiative") >= 40, "+40% Init"));
		return need;
	}
	
	buffer highlands() {
		buffer high;
		high.append("<br>A-boo: ");
		high.append(item_report(get_property("booPeakProgress")=="0", get_property("booPeakProgress")+"% haunted"));
		if (get_property("booPeakProgress")!="0") {
			high.append(", "+item_report($item[A-Boo clue]));
			high.append(" ("+item_amount($item[A-Boo clue])+")");
		}
		//L9: twin peak
		high.append("<br>Twin: "+twinPeak());
		//check 4 stench res, 50% items (no familiars), jar of oil, 40% init
		//L9: oil peak
		high.append("<br>Oil: ");
		high.append(item_report(get_property("oilPeakProgress").to_float()==0, get_property("oilPeakProgress")+" &mu;B/Hg"));
		if(high.contains_text(">0% haunt") && high.contains_text("Solved!") && high.contains_text("0.00")) {
			high.set_length(0);
			high.append('<br>Return to <a target="mainpane" href="place.php?whichplace=highlands&action=highlands_dude">High Landlord</a>');
		}
		return high;
	}
	
	
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
	foreach bb in $strings[Easy, Hard, Special] {
		bhit = get_property("current"+bb+"BountyItem");
		if(bhit != "") {
			result.append("<tr><td>");
			result.append('Your <a target="mainpane" href="bhh.php">Bounty</a> is: <br>');
			result.append(bhit);
		}
	}
	
	//questM02Artist
	if(started("questM02Artist")) {
		result.append("<tr><td>");
		result.append('Find the <a target="mainpane" href="town_wrong.php">Artists</a> supplies: <br>');
		result.append(item_report($item[pretentious palette], "Palette")+" (<a target=\"mainpane\" href=\"manor.php\">Pantry</a>)<br>");
		result.append(item_report($item[pail of pretentious paint], "Paint")+" (<a target=\"mainpane\" href=\"town_wrong.php\">Back Alley</a>)<br>");
		result.append(item_report($item[pretentious paintbrush], "Paintbrush")+" (<a target=\"mainpane\" href=\"plains.php\">Outskirts</a>)");
		result.append("</td></tr>");
	}
	
	//questM01Untinker
	if(started("questM01Untinker")) {
		result.append("<tr><td>");
		result.append('Find the <a target="mainpane" href="forestvillage.php">Untinker\'s</a> ');
		result.append(item_report($item[rusty screwdriver], "screwdriver"));
		result.append("</td></tr>");
	}
	
	//questM20Necklace
	if(started("questM20Necklace")) {
		result.append("<tr><td>");
		result.append("Find ");
		result.append(item_report($item[Lady Spookyraven's necklace]));
		result.append(" at the <a target=\"mainpane\" href=\"manor.php\">Manor</a>");
		if (available_amount($item[Spookyraven billiards room key])==0) {
			result.append("<br>Kitchen Drawers: "+get_property("manorDrawerCount")+"/21");
		}
		if (available_amount($item[Spookyraven billiards room key])>0) {
			result.append("<br>Pool skill: "+get_property("poolSkill")+"/18");
		}
		result.append("<br>Writing Desks: "+get_property("writingDesksDefeated")+"/5");
		result.append("</td></tr>");
	}
	
	//questM21Dance
	if(started("questM21Dance")) {
		result.append("<tr><td>");
		result.append("Find <a target=\"mainpane\" href=\"place.php?whichplace=manor2\">Lady Spookyravens</a> dancing supplies:<br>");
		result.append(item_report($item[Lady Spookyraven's dancing shoes], "dancing shoes")+" (Gallery)<br>");
		result.append(item_report($item[Lady Spookyraven's powder puff], "powder puff")+" (Bathroom)<br>");
		result.append(item_report($item[Lady Spookyraven's finest gown], "finest gown")+" (Bedroom)");
		result.append("</td></tr>");
	}
	
	//Gorgonzola wants you to exorcise a poltersandwich in the Haunted Pantry.
	//Take the poltersandwich back to Gorgonzola at the League of Chef-Magi.
	if(started("questG07Myst")) {
		result.append("<tr><td>");
		result.append('Find a poltersandwich in the <a target="mainpane" href="place.php?whichplace=manor1">Pantry</a>');
		result.append("</td></tr>");
	}
	
	//Shifty wants you to lure yourself into the Sleazy Back Alley and steal your own pants.
	//Take your pants back to Shifty at the Department of Shadowy Arts and Crafts.
	if(started("questG08Moxie")) {
		result.append("<tr><td>");
		result.append('Steal you pants in the <a target="mainpane" href="place.php?whichplace=town_wrong">Alley</a>');
		result.append("</td></tr>");
	}
	
	//Gunther wants you to get the biggest sausage you can find in Cobb's Knob.
	//Take the huge sausage back to Gunther at the Brotherhood of the Smackdown.
	if(started("questG09Muscle")) {
		result.append("<tr><td>");
		result.append('Find a big sausage in the <a target="mainpane" href="plains.php">Outskirts</a>');
		result.append("</td></tr>");
	}
	
	//L2: get mosquito larva, questL02Larva
	if(started("questL02Larva")) { 
		result.append("<tr><td>");
		result.append('Find a <a target="mainpane" href="woods.php">mosquito larva</a>');
		result.append("</td></tr>");
	}
	
	//lastTempleUnlock
	if(to_int(get_property("lastTempleUnlock"))!=my_ascensions()) { 
		result.append("<tr><td>");
		result.append('Unlock the <a target="mainpane" href="woods.php">Hidden Temple</a>');
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
		result.append("<br>KGE: ");
		result.append(item_report($item[Knob Goblin elite polearm], "polearm"));
		result.append(", ");
		result.append(item_report($item[Knob Goblin elite pants], "pants"));
		result.append(", ");
		result.append(item_report($item[Knob Goblin elite helm], "helm"));
		result.append(", ");
		result.append(item_report($item[Knob cake], "cake"));
		result.append("<br>Harem: ");
		result.append(item_report($item[Knob Goblin harem veil], "veil"));
		result.append(", ");
		result.append(item_report($item[Knob Goblin harem pants], "pants"));
		result.append(", ");
		result.append(item_report($item[Knob Goblin perfume], "perfume"));
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
	
	//Check for Island unlock and Swashbuckling Getup
	if (to_int(get_property("lastIslandUnlock"))!=my_ascensions()) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="beach.php">Find</a> a boat to the Island');
		result.append("</td></tr>");
	} else if (!have_outfit("Swashbuckling Getup") && available_amount($item[Pirate Fledges])==0) {
		result.append("<tr><td>");
		result.append('Find the <a target="mainpane" href="island.php">Swashbuckling Getup</a>:<br>');
		result.append(item_report($item[eyepatch])+", ");
		result.append(item_report($item[swashbuckling pants], "pants")+", ");
		result.append(item_report($item[stuffed shoulder parrot], "parrot"));
		result.append("<tr><td>");
	}
	
	//L7.5ish: pirates, questM12Pirate
	//step1, step2, step3, step4 = insults
	//step5 = fcle
	if (have_outfit("Swashbuckling Getup") && available_amount($item[Pirate Fledges])==0) {
		result.append("<tr><td>");
		//fcle items mizzenmast mop, ball polish, rigging shampoo
		if (get_property("questM12Pirate")=="step5") {
			result.append("<a target=mainpane href=cove.php>F'c'le</a> Items: ");
			result.append("<br>"+item_report($item[mizzenmast mop]));
			result.append("<br>"+item_report($item[ball polish]));
			result.append("<br>"+item_report($item[rigging shampoo]));
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
			result.append('<br>Ascend the <a target="mainpane" href="place.php?whichplace=mclargehuge">Mist-Shrouded Peak</a>');
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
			result.append('Explore the <a target="mainpane" href="place.php?whichplace=highlands">Highland</a> Peaks');
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
			result.append("<br>");
			result.append(item_report($item[amulet of extreme plot significance], "amulet")+", ");
			result.append(item_report($item[mohawk wig], "mohawk")+", ");
			result.append(item_report($item[titanium assault umbrella], "umbrella")+", ");
			result.append("<br>");
			result.append(item_report($item[soft green echo eyedrop antidote], "SGEEA")+": "+item_amount($item[soft green echo eyedrop antidote]));
		} else {
			result.append('Conquer the <a target="mainpane" href="place.php?whichplace=giantcastle">Giant\'s Castle</a>');
		}
		result.append("</td></tr>");
	}
	
	//L11: MacGuffin, questL11MacGuffin
	if (started("questL11MacGuffin")) {
		result.append("<tr><td>");
		result.append("Quest for the Holy MacGuffin");
		result.append("</td></tr>");
	}
	
	//L11: questL11Black
	if (started("questL11Black")) {
		result.append("<tr><td>");
			switch(get_property("questL11Black")) {
			case "started": case "step1": case "step2":
				result.append('Find the <a target="mainpane" href="woods.php">Black Market</a>');
				result.append(" ("+get_property("blackForestProgress")+"/5)");
				break;
			case "step3":
				result.append('<br>Get your Father\'s <a target="mainpane" href="shore.php">Diary</a>');
				result.append("<br>"+item_report($item[forged identification documents]));
				break;
		}
		result.append("</td></tr>");
	}
	
	//Get pirate fledges from island.php
	if (started("questL11MacGuffin") && get_property("questL11Palindome")=="unstarted") {
		result.append("<tr><td>");
		if(available_amount($item[pirate fledges])==0) {
			result.append('Get some <a target="mainpane" href="island.php">pirate fledges</a>');
		} else if(available_amount($item[Talisman o' Namsilat])==0) {
			result.append('Find the <a target="mainpane" href="cove.php">Talisman o Namsilat</a>');
		} else if(available_amount($item[Talisman o' Namsilat])>0) {
			result.append('Find the <a target="mainpane" href="plains.php">Palindome</a>');
		}
		result.append("</td></tr>");
	}
		
	//L11: questL11Palindome
	if (started("questL11Palindome")) {
		result.append("<tr><td>");
		if(get_property("questL11Palindome") == "step5") {
			result.append('<a target="mainpane" href="place.php?whichplace=palindome">Palindome</a>: Kill Dr. Awkward');
		} else {
			result.append('Seek Dr. Awkward at <a target="mainpane" href="place.php?whichplace=palindome">Palindome</a>');
		}
		if(get_property("questL11Palindome") == "started") {
			result.append("<br>Obtain: ");
			result.append(item_report($item[photograph of God],"photo of God"));
			result.append(", ");
			result.append(item_report($item[photograph of a red nugget],"photo of red nugget"));
			result.append(", ");
			result.append(item_report($item[photograph of a dog],"photo of dog"));
			result.append(", ");
			result.append(item_report($item[photograph of an ostrich egg],"photo of ostrich egg"));
			result.append(", ");
			result.append(item_report($item[&quot;I Love Me\, Vol. I&quot;],"I Love Me"));
			result.append(", ");
			result.append(item_report($item[stunt nuts]));
		}
		if(get_property("questL11Palindome") == "step1") {
			result.append("<br>Obtain: ");
			result.append(item_report($item[&quot;2 Love Me\, Vol. 2&quot;]));
		}
		// get wet stunt nut stew, mega gem
		if (available_amount($item[Mega Gem])==0) {
			result.append('<br>Get the <a target="mainpane" href="place.php?whichplace=palindome">Mega Gem</a>');
			result.append("<br>");
			if (available_amount($item[wet stunt nut stew])>0) {
				result.append(item_report($item[wet stunt nut stew]));
			} else if (available_amount($item[wet stew])>0) {
				result.append(item_report($item[stunt nuts]));
				result.append(", ");
				result.append(item_report($item[wet stew]));
			} else {
				result.append(item_report($item[stunt nuts]));
				result.append(", ");
				result.append(item_report($item[bird rib]));
				result.append(", ");
				result.append(item_report($item[lion oil]));
			}
		}
		result.append("</td></tr>");
	}
	
	//L11: questL11Manor, assume wine bomb route
	if (started("questL11Manor")) {
		result.append("<tr><td>");
			switch(get_property("questL11Manor")) {
			case "started":
				result.append('Open Spookyraven <a target="mainpane" href="manor2.php">Manor</a> cellar (Ballroom)');
				break;
			case "step1": case "step2":
				result.append('Find Spookyraven in the <a target="mainpane" href="manor3.php">Cellar</a>: ');
				if (available_amount($item[Lord Spookyraven's spectacles])==0) {
					result.append("<br>Find "+item_report($item[Lord Spookyraven's spectacles]));
				} else if (get_property("spookyravenRecipeUsed")!="with_glasses") {
					result.append("<br>Equip spectacles, read mortar recipe");
				} else if (available_amount($item[wine bomb])==0) {
					if (available_amount($item[unstable fulminate])>0) {
						result.append("<br>"+item_report($item[wine bomb])+" (Boiler Room)");
					} else {
						result.append("<br>"+item_report($item[bottle of Chateau de Vinegar],"Chateau de Vinegar")+" (Wine Cellar)");
						result.append("<br>"+item_report($item[blasting soda])+" (Laundry Room)");
					}
				}
				break;
			case "step3":
				result.append('<a target="mainpane" href="manor3.php">Manor Cellar</a>: Kill Spookyraven');
				break;
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
		case "step3": case "step4":
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
				foreach loc in $strings[Apartment, Office, Hospital, BowlingAlley] {
					result.append(loc+": ");
					int prog = get_property("hidden"+loc+"Progress").to_int();
					if(prog == 0)
						result.append(item_report(false, "Explore Shrine<br>"));
					else if(prog < 7) {
						switch(loc) {
						case "Apartment":
							//result.append(item_report(get_property("relocatePygmyLawyer").to_int() == my_ascensions(), "relocate Lawyers, "));
							//result.append(item_report(false, "Search for Boss<br>"));
							result.append(item_report((have_effect($effect[Thrice-Cursed])>0), "Thrice-Cursed"));
							result.append("<br>");
							break;
						case "Office":
							if(available_amount($item[McClusky file (complete)]) > 0)
								result.append(item_report(false, "Kill Boss!"));
							else {
								int f = files();
								if (f<5) {
									result.append(item_report(f >=5, "McClusky files (" + f + "/5)"));
								} else {
									result.append(item_report($item[boring binder clip], "binder clip"));
								}
							}
							result.append("<br>");
							break;
						case "Hospital":
							result.append(item_report(false, "Surgeonosity ("+to_string(numeric_modifier("surgeonosity"), "%.0f")+"/5)<br>"));
							break;
						case "BowlingAlley":
							//result.append(item_report($item[bowling ball]));
							//result.append(", ");
							result.append(item_report(false, "Bowled ("+(prog - 1)+"/5)<br>"));
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
			} else {
				result.append('<a target="mainpane" href="hiddencity.php">Hidden City</a>: Kill the Protector Spectre');
			}
			break;
		}
		result.append("</td></tr>");
	}
	
	
	
	//L11: questL11Desert
	if(started("questL11Desert") && my_path()!="Actually Ed the Undying") {
		result.append("<tr><td>");
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
		result.append("</td></tr>");
	
	}
	
	//L11: questL11Desert
	if(get_property("questL11Desert")=="finished" && get_property("questL11Pyramid")=="unstarted") {
		result.append("<tr><td>");
		result.append('Open the <a target="mainpane" href="beach.php">Pyramid</a>:<br>');
				result.append(item_report($item[Staff of Fats], "Staff of Fats, "));
				result.append(item_report($item[ancient amulet], "amulet, "));
				result.append(item_report($item[Eye of Ed], "Eye of Ed"));
				result.append("<br>");
		result.append("</td></tr>");
	
	}
	
	//L11: questL11Pyramid
	if(started("questL11Pyramid")) {
		string questL11Pyramid = get_property("questL11Pyramid");
		result.append("<tr><td>");
		switch(questL11Pyramid) {
		case "started":
			result.append('Unlock the <a target="mainpane" href="pyramid.php">Middle Chamber</a><br>');
			break;
		case "step1": case "step2":
			result.append('Unlock the <a target="mainpane" href="pyramid.php">Control Room</a><br>');
			break;
		}
			if(get_property("pyramidBombUsed")=="false") {
				result.append('Find Ed in the <a target="mainpane" href="pyramid.php">Pyramid</a><br>');
			result.append(item_report($item[tomb ratchet], "tomb ratchets: "+item_amount($item[tomb ratchet]))+"<br>");
			result.append(item_report($item[crumbling wooden wheel], "wooden wheels: "+item_amount($item[crumbling wooden wheel])));
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
		} else {
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
		
		if ( get_property("sidequestOrchardCompleted")=="none" && (item_amount($item[filthworm hatchling scent gland])>0 || have_effect($effect[Filthworm Larva Stench])>0 || item_amount($item[filthworm drone scent gland])>0 ||have_effect($effect[Filthworm Drone Stench])>0 ||item_amount($item[filthworm royal guard scent gland])>0 ||have_effect($effect[Filthworm Guard Stench])>0) ) {
			result.append('<br>Destroy the Filthworms in the <a target="mainpane" href="bigisland.php?place=orchard">Orchard</a>');
		}
		
		if ( to_int(get_property("currentNunneryMeat"))>0 && get_property("sidequestNunsCompleted")=="none" ) {
			result.append('<br><a target="mainpane" href="bigisland.php?place=nunnery">Nunnery</a> Meat found: '+to_string(to_int(get_property("currentNunneryMeat")),"%,d"));
		}
		
		result.append("</td></tr>");
	}
	
	
	//L13: NS, questL13Final
	// check for lair items, tower items, wand
	if (started("questL13Final")) {
		result.append("<tr><td>");
		result.append('Go defeat the <a target="mainpane" href="lair.php">Naughty Sorceress</a>');

		//Gate item
		if ( $strings[started, step1, step2, step3] contains get_property("questL13Final")) {
			result.append("<br>");
			if ( get_property("telescopeUpgrades")=="0" || in_bad_moon()) {
				result.append("no telescope");
			}
			else if (get_property("lastTelescopeReset") != my_ascensions()) {
				result.append("no current telescope info");
			}
			else {
				result.append("Contests: Init, ");
				result.append(decomods(get_property("nsChallenge1")));
				result.append(", ");
				result.append(decomods(get_property("nsChallenge2")));
				result.append("<br>");
				result.append("Hedges: ");
				result.append(decomods(get_property("nsChallenge3")));
				result.append(", ");
				result.append(decomods(get_property("nsChallenge4")));
				result.append(", ");
				result.append(decomods(get_property("nsChallenge5")));
			}
		}
		
		//Entryway items, "nsTowerDoorKeysUsed"
		if ( $strings[started, step1, step2, step3, step4, step5, step6, step7, step8] contains get_property("questL13Final") ) {
			boolean key_used(item it) {
				return contains_text(get_property("nsTowerDoorKeysUsed"),to_string(it));
			}
			result.append("<br>Door Keys: ");
			foreach kk in $items[Boris's key, Jarlsberg's key, Sneaky Pete's key, digital key, skeleton key, Richard's star key] {
				if (!key_used(kk)) { result.append(item_report(kk)+", "); }
			}
		}
		
		if($strings[started, step1, step2, step3, step4, step5, step6, step7, step8] contains get_property("questL13Final") ) {
			result.append("<br>Tower: ");
			result.append(item_report($item[beehive]));
			result.append(", ");
			result.append("Meat: +"+to_string(to_int(meat_drop_modifier()))+"%");
			result.append(", ");
			result.append(item_report($item[electric boning knife], "boning knife"));
		}
		
		boolean NSfight = !($strings[Avatar of Boris, Bugbear Invasion, Zombie Slayer, Avatar of Jarlsberg, Heavy Rains, KOLHS, Avatar of Sneaky Pete] contains my_path());
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
	
	
	if (started("questL13Warehouse")) {
		result.append("<tr><td>");
		result.append('Search the <a target="mainpane" href="tutorial.php">Warehouse</a> ');
		result.append(": "+get_property("warehouseProgress")+"/40");
		result.append("</td></tr>");
	}
	
	
	//HITS: stars and lines and charts
	if ( item_amount($item[steam-powered model rocketship])>0 && item_amount($item[Richard's star key])==0 && !contains_text(get_property("nsTowerDoorKeysUsed"),"Richard's star key") ) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=beanstalk">HITS</a>: ');
		result.append(item_report($item[star], 8));
		result.append(", ");
		result.append(item_report($item[line], 7));
		result.append(", ");
		result.append(item_report($item[star chart],"chart"));
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
			result.append("Get ");
			result.append('<a target="mainpane" href="da.php">Daily Dungeon</a>');
			result.append(" keys ("+havekeys+"/"+needkeys+")");
			result.append("</td></tr>");
		}
	}
	
	//Digital Key
	if (item_amount($item[digital key])==0 && !contains_text(get_property("nsTowerDoorKeysUsed"),to_string($item[digital key]))) {
		int whitepix = item_amount($item[white pixel]) + creatable_amount($item[white pixel]);
		result.append("<tr><td>");
		result.append("Get ");
		result.append('<a target="mainpane" href="woods.php">Digital Key</a>');
		result.append(" ("+whitepix+"/30 white)");
		result.append("</td></tr>");
	}
	
	
	//questM13Escape, Subject 37
	if (started("questM13Escape") && can_interact()) {
		result.append("<tr><td>");
		result.append('Help <a target="mainpane" href="cobbsknob.php?level=3">Subject 37</a> escape');	
		result.append("</td></tr>");
	}
	
	
	//L99: questM15Lol (facsimile dictionary)
	if (started("questM15Lol") && my_level()>=9 && can_interact()) {
		result.append("<tr><td>");
		result.append('Find the 64735 of <a target="mainpane" href="mountains.php">Rof Lm Fao</a>');	
		result.append("</td></tr>");
	}
	
	
	
	
	//L99: Nemesis stuff ?
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
	
	
	
	
	//questESlMushStash
	if (started("questESlMushStash")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc1">Buff Jimmy</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Fun-Guy Mansion</a>');
		result.append(" Find Buff Jimmy's ");
		result.append(item_report($item[pencil thin mushroom],"mushrooms",10));
		result.append("</td></tr>");
	}
	//questESlCheeseburger
	if (started("questESlCheeseburger")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc1">Buff Jimmy</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Sloppy Seconds Diner</a>');
		result.append(" - Get burger ");
		result.append(item_report(get_property("buffJimmyIngredients")=="15","ingredients: "+get_property("buffJimmyIngredients")+"/15"));
		if (!have_equipped($item[Paradaisical Cheeseburger recipe])) {
			result.append("<br><span class=walford_nobucket>Equip Cheeseburger recipe</span>");
		}
		result.append("</td></tr>");
	}
	//questESlSalt
	if (started("questESlSalt")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc1">Buff Jimmy</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Sunken Party Yacht</a>');
		result.append(" - Get sons of sailors ");
		result.append(item_report($item[salty sailor salt],"sailor salt",50));
		result.append("</td></tr>");
	}
	//questESlAudit
	if (started("questESlAudit")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc2">Taco Dan</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Fun-Guy Mansion</a>');
		result.append(" - Find lost ");
		result.append(item_report($item[Taco Dan's Taco Stand's Taco Receipt],"Receipts",10));
		if (have_effect($effect[Sleight of Mind])==0) {
			result.append("<br><span class=walford_nobucket>need <i>Sleight of Mind</i>, use sleight-of-hand mushroom</span>");
		}
		result.append("</td></tr>");
	}
	//questESlCocktail
	if (started("questESlCocktail")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc2">Taco Dan</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Sloppy Seconds Diner</a>');
		result.append(" - Get cocktail ");
		result.append(item_report(get_property("tacoDanCocktailSauce")=="15","sauce: "+get_property("tacoDanCocktailSauce")+"/15"));
		if (!have_equipped($item[Taco Dan's Taco Stand Cocktail Sauce Bottle])) {
			result.append("<br><span class=walford_nobucket>Equip Cocktail Sauce Bottle</span>");
		}
		result.append("</td></tr>");
	}
	//questESlFish
	if (started("questESlFish")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc2">Taco Dan</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Sunken Party Yacht</a>');
		result.append(" - Find taco fish ");
		result.append(item_report(get_property("tacoDanFishMeat").to_int()>=300,"meat: "+get_property("tacoDanFishMeat")+"/300"));
		result.append("</td></tr>");
	}
	//questESlBacteria
	if (started("questESlBacteria")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc3">Broden</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Fun-Guy Mansion</a>');
		result.append(" - Get hot-tub ");
		result.append(item_report(get_property("brodenBacteria").to_int()>=10,"bacteria: "+get_property("brodenBacteria")+"/10"));
		//result.append("<br>(+resist all)"); 
		result.append("</td></tr>");
	}
	//questESlSprinkles
	if (started("questESlSprinkles")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc3">Broden</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Sloppy Seconds Diner</a>');
		result.append(" - Get Sundae ");
		result.append(item_report(get_property("brodenSprinkles").to_int()>=15,"sprinkles: "+get_property("brodenSprinkles")+"/15"));
		if (!have_equipped($item[sprinkle shaker])) {
			result.append("<br><span class=walford_nobucket>Equip sprinkle shaker</span>");
		}
		result.append("</td></tr>");
	}
	//questESlDebt
	if (started("questESlDebt")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze&action=airport1_npc3">Broden</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_sleaze">Sunken Party Yacht</a>');
		result.append(" - collect drownedbeat debts: ");
		result.append(item_report($item[bike rental broupon],"broupons",15));
		result.append("</td></tr>");
	}
	
	
	//questESpEVE
	if (started("questESpEVE")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Secret Government Laboratory</a>');
		result.append(" - Defeat E.V.E., the robot zombie");
		result.append("</td></tr>");
	}
	//questESpJunglePun
	if (started("questESpJunglePun")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Deep Dark Jungle</a>');
		result.append(" - Collect ");
		result.append(item_report(get_property("junglePuns").to_int()>=11,"Jungle Puns: "+get_property("junglePuns")+"/11"));
		if (!have_equipped($item[encrypted micro-cassette recorder])) {
			result.append("<br><span class=walford_nobucket>Equip micro-cassette recorder</span>");
		}
		result.append("</td></tr>");
	}
	//questESpGore	Gore Tipper
	if (started("questESpGore")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Secret Government Laboratory</a>');
		result.append(" - Collect ");
		result.append(item_report(get_property("goreCollected").to_int()>=100,"Gore: "+get_property("goreCollected")+"/100"));
		if (!have_equipped($item[gore bucket])) {
			result.append("<br><span class=walford_nobucket>Equip gore bucket</span>");
		}
		result.append("</td></tr>");
	}
	//questESpClipper
	if (started("questESpClipper")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Mansion of Dr. Weirdeaux</a>');
		result.append(" - Collect ");
		result.append(item_report(get_property("fingernailsClipped").to_int()>=23,"Fingernail Clippings: "+get_property("fingernailsClipped")+"/23"));
		result.append("</td></tr>");
	}
	//questESpFakeMedium
	if (started("questESpFakeMedium")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Secret Government Laboratory</a>');
		result.append(" - Get ");
		result.append(item_report($item[ESP suppression collar]));
		result.append("</td></tr>");
	}
	//questESpSerum
	if (started("questESpSerum")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Mansion of Dr. Weirdeaux</a>');
		result.append(" - Get ");
		result.append(item_report($item[experimental serum P-00],"vials of serum P-00: ",5));
		result.append("</td></tr>");
	}
	//questESpSmokes
	if (started("questESpSmokes")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Deep Dark Jungle</a>');
		result.append(" - Get ");
		result.append(item_report($item[pack of smokes],"pack of smokes: ",10));
		result.append("</td></tr>");
	}
	//questESpOutOfOrder
	if (started("questESpOutOfOrder")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky&action=airport2_radio">Conspiracy Radio</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_spooky">Deep Dark Jungle</a>');
		result.append(" - Find ");
		result.append(item_report($item[Project T. L. B.]));
		if (!have_equipped($item[GPS-tracking wristwatch])) {
			result.append("<br><span class=walford_nobucket>Equip GPS-tracking wristwatch</span>");
		}
		result.append("</td></tr>");
	}
	
	
	//questEStFishTrash
	if (started("questEStFishTrash")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Pirates of the Garbage Barges</a>');
		result.append(" - Collect ");
		result.append(item_report(get_property("dinseyFilthLevel").to_int()>=20,"Trash: "+get_property("dinseyFilthLevel")+"/20"));
		if (!have_equipped($item[trash net])) {
			result.append("<br><span class=walford_nobucket>Equip trash net</span>");
		}
		result.append("</td></tr>");
	}
	//questEStGiveMeFuel
	if (started("questEStGiveMeFuel")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Toxic Teacups</a>');
		result.append(" - Get ");
		result.append(item_report($item[toxic globule],"toxic globule: ",20));
		result.append("</td></tr>");
	}
	//questEStNastyBears
	if (started("questEStNastyBears")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Uncle Gator</a>');
		result.append(" - Remove ");
		result.append(item_report(get_property("dinseyNastyBearsDefeated").to_int()>=8,"Nasty Bears: "+get_property("dinseyNastyBearsDefeated")+"/8"));
		result.append("</td></tr>");
	}
	//questEStSocialJusticeI
	if (started("questEStSocialJusticeI")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Pirates of the Garbage Barges</a>');
		result.append(" - Remove ");
		result.append(item_report(get_property("dinseySocialJusticeIProgress").to_int()>=15,"Sexism: "+get_property("dinseySocialJusticeIProgress")+"/15"));
		result.append("</td></tr>");
	}
	//questEStSocialJusticeII
	if (started("questEStSocialJusticeII")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Uncle Gator</a>');
		result.append(" - Remove ");
		result.append(item_report(get_property("dinseySocialJusticeIIProgress").to_int()>=15,"Racism: "+get_property("dinseySocialJusticeIIProgress")+"/15"));
		result.append("</td></tr>");
	}
	//questEStSuperLuber
	if (started("questEStSuperLuber")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Barf Mountain</a>');
		result.append(" - Lube the Rollercoaster");
		if (!have_equipped($item[lube-shoes]) && available_amount($item[lube-shoes])>0) {
			result.append("<br><span class=walford_nobucket>Equip lube-shoes</span>");
		}
		result.append("</td></tr>");
	}
	//questEStWorkWithFood
	if (started("questEStWorkWithFood")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Barf Mountain</a>');
		result.append(" - Feed ");
		result.append(item_report(get_property("dinseyTouristsFed").to_int()>=30,"Tourists: "+get_property("dinseyTouristsFed")+"/30"));
		result.append("</td></tr>");
	}
	//questEStZippityDooDah
	if (started("questEStZippityDooDah")) {
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench&action=airport3_kiosk">Dinsey Kiosk</a>');
		result.append(" - ");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_stench">Toxic Teacups</a>');
		result.append(" - Have ");
		result.append(item_report(get_property("dinseyFunProgress").to_int()>=15,"Fun: "+get_property("dinseyFunProgress")+"/15"));
		if (!have_equipped($item[Dinsey mascot mask])) {
			result.append("<br><span class=walford_nobucket>Equip mascot mask</span>");
		}
		result.append("</td></tr>");
	}
	
	
	
	
	//questECoBucket
	if (started("questECoBucket")) {
		int current = get_property("walfordBucketProgress").to_int();
		string[string] walhint;
		walhint["balls"] =     '<a target="mainpane" href="place.php?whichplace=airport_cold">VYKEA</a>, +50% Item Drop';
		walhint["blood"] =     '<a target="mainpane" href="place.php?whichplace=airport_cold">The Glaciest</a>, Bleeding Damage';
		walhint["bolts"] =     '<a target="mainpane" href="place.php?whichplace=airport_cold">VYKEA</a>, hex key equipped';
		walhint["chicken"] =   '<a target="mainpane" href="place.php?whichplace=airport_cold">Ice Hotel</a>, +50% Food Drop';
		walhint["chum"] =      '<a target="mainpane" href="place.php?whichplace=airport_cold">VYKEA</a>, +100% Meat Drop';
		walhint["ice"] =       '<a target="mainpane" href="place.php?whichplace=airport_cold">The Glaciest</a>, 10 <span class=modCold>Cold</span> Damage';
		walhint["milk"] =      '<a target="mainpane" href="place.php?whichplace=airport_cold">Ice Hotel</a>, +50% Booze Drop';
		walhint["moonbeams"] = '<a target="mainpane" href="place.php?whichplace=airport_cold">The Glaciest</a>, No hat';
		walhint["rain"] =      '<a target="mainpane" href="place.php?whichplace=airport_cold">Ice Hotel</a>, 100 <span class=modHot>Hot</span> Damage';
		
		result.append("<tr><td>");
		result.append('<a target="mainpane" href="place.php?whichplace=airport_cold&action=glac_walrus">Walford</a>');
		result.append(" needs "+get_property("walfordBucketItem")+": ");
		if (get_property("walfordBucketProgress").to_int()>=100) {
			result.append('<span class="walford_done">');
		} else {
			result.append('<span class="walford_nobucket">');
		}
		result.append(get_property("walfordBucketProgress")+"/100");
		result.append("</span>");
		result.append("<br>"+walhint[get_property("walfordBucketItem")]);
		if (!have_equipped($item[Walford's bucket])) {
			result.append("<br><span class=walford_nobucket>Equip Walford's bucket</span>");
		}
		result.append("</td></tr>");
	}
	
	
	
	
	
	result.append("</table>");
	return result;
}


void bakeTracker() {
	buffer result = buildTracker();
	
	if(length(result) > 184) { // 184 is the size of an empty table
		chitBricks["tracker"] = result;
		chitTools["tracker"] = "Tracker|tracker.png";
	}
}

