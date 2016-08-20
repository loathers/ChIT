// The original version of the Gear Brick (including pickerGear and bakeGear) was written by soolar

float [item] favGear;
float [item] okFavGear;
float [string, item] recommendedGear;

string gearName(item it) {
	string name = to_string(it);
	string notes = "";

	switch(it) {
		case $item[pantsgiving]:
			notes = (10 - to_int(get_property("_pantsgivingCrumbs"))) + ' crumbs left, ' + (5- to_int(get_property("_pantsgivingBanish"))) + ' banishes';
			break;
		case $item[amulet of extreme plot significance]: name = "amulet of plot significance"; break;
		case $item[encrypted micro-cassette recorder]: name = "micro-cassette recorder"; break;
		case $item[stinky cheese eye]:
			if(!to_boolean(get_property("_stinkyCheeseBanisherUsed")))
				notes = "banish available, ";
			// no break intentionally
		case $item[stinky cheese sword]: case $item[stinky cheese diaper]: case $item[stinky cheese wheel]: case $item[Staff of Queso Escusado]:
			notes += to_int(get_property("_stinkyCheeseCount")) + '/100';
			break;
		case $item[bone abacus]:
			if(get_property("boneAbacusVictories").to_int() < 1000)
				notes += get_property("boneAbacusVictories") + "/1000";
			break;
		case $item[navel ring of navel gazing]:
			name = "navel ring";
			// no break intentionally
		case $item[Greatest American Pants]:
			int runs = to_int(get_property("_navelRunaways"));
			if(runs < 3) notes = "100% free run";
			else if(runs < 6) notes = "80% free run";
			else if(runs < 9) notes = "50% free run";
			else notes = "20% free run";
			break;
	}
	
	if(notes != "")
		name += " (" + notes + ")";

	return name;
}

int foldable_amount(item it, boolean generous);

int chit_available(item it, boolean generous, boolean foldcheck)
{
	int available = item_amount(it) + creatable_amount(it) + closet_amount(it);
	if(available == 0 && boolean_modifier(it, "Free Pull"))
	{
		available += available_amount(it);
	}
	
	if(pulls_remaining() == -1)
	{
		available += storage_amount(it);
	}
	else if(pulls_remaining() > 0 && (vars["chit.gear.pull"] == "anything" || (generous && vars["chit.gear.pull"] != "nothing")))
	{
		available += min(pulls_remaining(), storage_amount(it));
	}
	if(generous)
	{
		available += equipped_amount(it);
	}
	
	if(foldcheck)
	{
		available += foldable_amount(it, generous);
	}
	
	return available;
}

int chit_available(item it, boolean generous)
{
	return chit_available(it, generous, true);
}

int chit_available(item it)
{
	return chit_available(it, false);
}

int foldable_amount(item it, boolean generous) {
	int amount = 0;
	foreach foldable, i in get_related(it, "fold")
		if(foldable != it)
			amount += chit_available(foldable, generous, false);
	
	return amount;
}
int foldable_amount(item it) {
	return foldable_amount(it, false);
}

void addGear(item it, string reason, float score)
{
	class gear_class = class_modifier(it,"Class");
	boolean isFav = (reason == "");
	
	if(is_unrestricted(it) && can_equip(it) && chit_available(it, isFav) > 0
		&& !(have_equipped(it) && string_modifier(it, "Modifiers").contains_text("Single Equip"))
		&& (gear_class == $class[none] || gear_class == my_class() || (it == $item[Hand that Rocks the Ladle] && have_skill($skill[Utensil Twist]))))
	{
		if(isFav) okFavGear[it] = 1;
		else recommendedGear[reason][it] = score;
	}
}
void addGear(item it)
{
	addGear(it, "", 1);
}
void addGear(boolean [item] list, string reason)
{
	foreach it in list
		addGear(it, reason, 1);
}
void addGear(boolean [item] list)
{
	addGear(list, "");
}

void addGear(float [item] list, string reason)
{
	foreach it,score in list
		addGear(it, reason, score);
}

void addGear(item it, string reason)
{
	addGear(it, reason, 1);
}

void addFavGear() {	
	boolean aftercore = (get_property("questL13Final") == "finished");

	// Certain quest items need to be equipped to enter locations
	if(available_amount($item[digital key]) + creatable_amount($item[digital key]) < 1 && get_property("questL13Final") != "finished")
		addGear($item[continuum transfunctioner], "quest");
	if(get_property("questL11Palindome") == "unstarted" && !aftercore)
		addGear($item[pirate fledges], "quest");
	else if(get_property("currentHardBountyItem").contains_text("warrrrrt"))
		addGear($item[pirate fledges], "bounty");
	
	if(get_property("questS02Monkees") != "finished")
		addGear($items[black glass], "quest");
		
	if(get_property("questL11Palindome") != "finished")
		addGear($items[Talisman o' Namsilat,Mega Gem], "quest");
	else if(get_property("currentHardBountyItem").contains_text("bit of wilted lettuce"))
		addGear($item[Talisman o' Namsilat], "bounty");
	else if(get_property("ghostLocation") == "Inside the Palindome")
		addGear($item[Talisman o' Namsilat], "ghost");
	
	// Ascension specific quest items
	int total_keys() { return available_amount($item[fat loot token]) + available_amount($item[Boris's key]) + available_amount($item[Jarlsberg's key]) + available_amount($item[Sneaky Pete's key]); }
	if(!aftercore && get_property("dailyDungeonDone") == "false" && total_keys() < 3)
		addGear($item[ring of Detect Boring Doors], "quest");
	switch(get_property("questL10Garbage")) {
		// castle basement unlocked, but not cleared
		case "step7":
			addGear($items[titanium assault umbrella,amulet of extreme plot significance], "quest");
			break;
		// castle top floor unlocked, but not cleared
		case "step9":
			addGear($item[mohawk wig], "quest");
			break;
	}
	string blackForest = get_property("questL11Black");
	if(blackForest == "started" || blackForest == "step1")
		addGear($item[blackberry galoshes], "quest");
	if($strings[step3, step4] contains get_property("questL11Worship")) {
		if(item_amount($item[antique machete]) > 0)
			addGear($item[antique machete], "quest");
		if(get_property("hiddenHospitalProgress") == "1")
			addGear($items[surgical apron, bloodied surgical dungarees, surgical mask, head mirror, half-size scalpel], "quest");
	}
	if(get_property("questL11Desert") == "started")
		addGear($items[UV-resistant compass, ornate dowsing rod], "quest");
	if($strings[step1,step2,step3] contains get_property("questL11Manor"))
		addGear($item[unstable fulminate], "quest");
	if($strings[started, step1] contains get_property("questL11Manor"))
		addGear($item[Lord Spookyraven's spectacles], "quest");
	
	if(get_property("questL13Final") == "step6" && available_amount($item[beehive]) < 1)
		addGear($items[hot plate, smirking shrunken head, bottle opener belt buckle, Groll doll, hippy protest button], "towerkilling");
		

	// Nemesis Quest
	switch(get_property("questG04Nemesis")) {
	case "step5":  // Kill Beelzebozo
		addGear($items[clown shoes,bloody clown pants,balloon helmet,balloon sword,foolscap fool's cap,big red clown nose,polka-dot bow tie,clown wig,clownskin belt,clownskin buckler,clown whip,clownskin harness], "quest");
		break;
	case "step8":	// Fight Nemesis in The Dark and Dank and Sinister Cave
	case "step27":	// Fight Nemesis on Secret Tropical Island Volcano Lair
		addGear($items[Hammer of Smiting, Chelonian Morningstar, Greek Pasta Spoon of Peril, 17-Alarm Saucepan, Shagadelic Disco Banjo, Squeezebox of the Ages], "quest");
		break;
	case "step25":
	case "step26":
		addGear($items[fouet de tortue-dressage, spaghetti cult robe], "quest");
		break;
	}
	
	// Charter zone quest equipment
	addGear($items[
		Paradaisical Cheeseburger recipe, Taco Dan's Taco Stand Cocktail Sauce Bottle, sprinkle shaker,
		Personal Ventilation Unit, gore bucket,encrypted micro-cassette recorder,GPS-tracking wristwatch,
		lube-shoes, Dinsey mascot mask, trash net
	], "charter");
	if((get_property("hotAirportAlways") == "true" || get_property("_hotAirportToday") == "true") && get_property("_infernoDiscoVisited") == "false")
		addGear($items[smooth velvet pants, smooth velvet shirt, smooth velvet hat, smooth velvet pocket square, smooth velvet socks, smooth velvet hanky], "charter");
	if(get_property("coldAirportAlways") == "true" || get_property("_coldAirportToday") == "true") {
		addGear($items[bellhop's hat, Walford's bucket], "charter");
		if(get_property("walfordBucketItem") == "bolts")
			addGear($item[VYKEA hex key], "charter");
		else if(get_property("walfordBucketItem") == "blood")
			addGear($item[remorseless knife], "charter");
	}
	
	// Miscellaneous
	int turnsToGhost = to_int(get_property("nextParanormalActivity")) - total_turns_played();
	if(turnsToGhost <= 0 || get_property("ghostLocation") != "")
		addGear($item[protonic accelerator pack], "ghost");

	if(get_property("questM03Bugbear") == "step2") // Felonia
		addGear($item[spooky glove], "quest");
	
	// Path specific stuff
	switch(my_path()) {
	case "KOLHS":
		addGear($items[Yearbook Club Camera, over-the-shoulder Folder Holder], "path");
		break;
	case "Actually Ed the Undying":
		addGear($items[The Crown of Ed the Undying, 7961, obsidian nutcracker], "path");
		break;
	case "Heavy Rains":
		addGear($items[pool skimmer, lightning rod, thunder down underwear, famous blue raincoat, thor's pliers], "path");
		break;
	case "One Crazy Random Summer":
		addGear($items[dice ring, dice belt buckle, dice-print pajama pants, dice-shaped backpack, dice-print do-rag, dice sunglasses], "path");
		break;
	case "Avatar of West of Loathing":
		addGear($items[Heimz Fortified Kidney Beans, Tesla's Electroplated Beans, Mixed Garbanzos and Chickpeas, Hellfire Spicy Beans, Frigid Northern Beans, World's Blackest-Eyed Peas, 
			Trader Olaf's Exotic Stinkbeans, Pork 'n' Pork 'n' Pork 'n' Beans, Shrub's Premium Baked Beans], "beans");
		break;
	}
	
	// Find varous stuff instead of hardcoding lists
	static {
		void addItemIf(float [string, item] list, string category, item it, float val, float min) {
			if(val >= min)
				list[category, it] = val;
		}
		
		float [string, item] ascendGear, drunkGear;
		foreach it in $items[] {
			ascendGear.addItemIf("item", it, numeric_modifier(it, "Item Drop"), 10);
			ascendGear.addItemIf("ML", it, numeric_modifier(it, "Monster Level"), 10);
			ascendGear.addItemIf("-combat", it, -numeric_modifier(it, "Combat Rate"), 0.5);
			ascendGear.addItemIf("+combat", it, numeric_modifier(it, "Combat Rate"), 0.5);
			ascendGear.addItemIf("exp", it, numeric_modifier(it, "Experience") + numeric_modifier(it, my_primestat()+ " Experience"), 1);
			float prisdmg = numeric_modifier(it, "Spooky Damage");
			foreach s in $strings["Stench Damage", "Hot Damage", "Cold Damage", "Sleaze Damage"]
				prisdmg = min(prisdmg, numeric_modifier(it, s));
			ascendGear.addItemIf("prismatic", it, prisdmg, 2);
			ascendGear.addItemIf("res", it, numeric_modifier(it, "Spooky Resistance") + numeric_modifier(it, "Stench Resistance") + numeric_modifier(it, "Hot Resistance")
				+ numeric_modifier(it, "Cold Resistance") + numeric_modifier(it, "Sleaze Resistance"), 10);
			if(string_modifier(it, "Evaluated Modifiers").contains_text("Lasts Until Rollover"))
				ascendGear["today", it] = 1;
			drunkGear.addItemIf("nopvprollover", it, numeric_modifier(it, "Adventures"), 1);
			drunkGear.addItemIf("pvprollover", it, numeric_modifier(it, "Adventures") + numeric_modifier(it, "PVP Fights"), 1);
		}
		drunkGear["DRUNK", $item[Drunkula's wineglass]] = 100;
	}
	
	// Rollover equipment
	if(my_inebriety() > inebriety_limit())
		foreach type in drunkGear {
			switch(type) {
				case "nopvprollover":
					if(!hippy_stone_broken())
						addGear(drunkGear[type], "rollover");
					break;
				case "pvprollover":
					if(hippy_stone_broken())
						addGear(drunkGear[type], "rollover");
					break;
				default:
					addGear(drunkGear[type], type);
			}
		}
	// Melties
	addGear(ascendGear["today"], "today");
		
	// some handy in-run stuff
	if((vars["chit.gear.recommend"] == "in-run" && !aftercore) || vars["chit.gear.recommend"] == "always") {
		
		foreach type in ascendGear
			addGear(ascendGear[type], type);
		
		addGear($item[World's Best Adventurer sash], "Wow");
		addGear($items[astral bludgeon, astral shield, astral chapeau, astral bracer, astral longbow, astral shorts, astral mace, astral trousers, astral ring, astral statuette, astral pistol,
			astral mask, astral pet sweater, astral shirt], "astral"); // You must have taken this for a reason
		
	}
	
	if(my_inebriety() > inebriety_limit())
		addGear($item[Drunkula's wineglass], "drunk");
	
	// manual favorites
	foreach i,fav in split_string(vars["chit.gear.favorites"], "\\s*(?<!\\\\),\\s*") {
		item it = to_item(fav.replace_string("\\,", ","));
		favGear[it] = 1;
		addGear(it);
	}
}

void pickerEdpiece() {
	buffer picker;
	picker.pickerStart("edpiece", "Adorn thy crown");
	
	string current = get_property("edPiece");
	
	void addJewel(buffer buf, string jewel, string desc, string icon) {
		string jewelLink = '<a class="change" href="' + sideCommand("edpiece " + jewel) + '">';
		
		picker.append('<tr class="pickitem');
		if(jewel == current)  picker.append(' currentitem');
		picker.append('"><td class="icon">');
		if(jewel != current) picker.append(jewelLink);
		picker.append('<img class="chit_icon');
		picker.append('" src="/images/itemimages/');
		picker.append(icon);
		picker.append('.gif" title="');
		if(jewel == current) picker.append('Current:');
		else picker.append('Install');
		picker.append(' a golden ');
		picker.append(jewel);
		picker.append(' (');
		picker.append(desc);
		picker.append(')" />');
		if(jewel != current) picker.append('</a>');
		picker.append('</td><td colspan="2">');
		if(jewel != current) {
			picker.append(jewelLink);
			picker.append('<b>Install</b>');
		}
		else picker.append('<b>Current:</b>');
		picker.append(' a golden ');
		picker.append(jewel);
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span>');
		if(jewel != current) picker.append('</a>');
		picker.append('</td></tr>');
	}
	
	picker.addJewel("bear", "Musc +20, +2 Musc exp", "teddybear");
	picker.addJewel("owl", "Myst +20, +2 Myst exp", "owl");
	picker.addJewel("puma", "Moxie +20, +2 Moxie exp", "blackcat");
	picker.addJewel("hyena", "+20 Monster Level", "lionface");
	picker.addJewel("mouse", "+10% Items, +20% Meat", "mouseskull");
	picker.addJewel("weasel", "Dodge first attack, 10-20 HP regen", "weasel");
	picker.addJewel("fish", "Lets you breathe underwater", "fish");
	
	picker.addLoader("Cool jewels!");
	picker.append('</table></div>');
	chitPickers["edpiece"] = picker;
}

void pickerGear(slot s) {
	item in_slot = equipped_item(s);
	boolean take_action = true; // This is un-set if there's a reason to do nothing (such as not enough hands)

	buffer picker;
	picker.pickerStart("gear" + s, "Change " + s);
	
	boolean good_slot(slot s, item it) {
		if(to_slot(it) == s) return true;
		switch(s) {
		case $slot[off-hand]:
			switch(weapon_type(it)) {
			case $stat[Muscle]: case $stat[Mysticality]:
				if(equipped_item($slot[weapon]).weapon_type() == $stat[Moxie])
					return false;
				break;
			case $stat[Moxie]:
				if(equipped_item($slot[weapon]).weapon_type() != $stat[Moxie])
					return false;
			}
			return to_slot(it) == $slot[weapon] && item_type(it) != "chefstaff" && item_type(it) != "accordion" && weapon_hands(it) == 1 && have_skill($skill[double-fisted skull smashing]);
		case $slot[acc2]: case $slot[acc3]:
			return to_slot(it) == $slot[acc1];
		}
		return false;
	}
	
	boolean any_options = false;
	// for use with custom context suggestions
	void start_option(item it, int modify_image) {
		# any_options = true;
		picker.append('<tr class="pickitem"><td class="icon"><a class="done" href="#" oncontextmenu="descitem(');
		picker.append(it.descid);
		picker.append(',0,event); return false;" onclick="descitem(' + it.descid + ',0,event)">');
		picker.addItemIcon(it, "Click for item description", 0, modify_image);
		picker.append('</a></td>');
	}
	
	void start_option(item it, boolean modify_image) {
		start_option(it, modify_image ? MODIFY : NO_MODIFY);
	}
	
	// give configurable gear some love if it's in slot
	item fold_from(item original) {
		foreach it in get_related(in_slot, "fold")
			if(it != in_slot)
				return it;
		return $item[none];
	}
	string cmd;
	switch(in_slot) {
		case $item[buddy bjorn]:
			pickerFamiliar(my_bjorned_familiar(), "bjornify", "Change bjorned buddy :D");
			start_option(in_slot, false);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerbjornify" href="#">Pick a buddy to bjornify!</a></td></tr>');
			break;
		case $item[crown of thrones]:
			pickerFamiliar(my_enthroned_familiar(), "enthrone", "Put a familiar on your head :D");
			start_option(in_slot, false);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerenthrone" href="#">Pick a familiar to enthrone!</a></td></tr>');
			break;
		case $item[The Crown of Ed the Undying]:
			pickerEdpiece();
			start_option(in_slot, FORCE_MODIFY);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickeredpiece" href="#">Change decoration (currently ');
			if(get_property("edPiece") == "")
				picker.append('none');
			else
				picker.append(get_property("edPiece"));
			picker.append(')</a></td></tr>');
			break;
		case $item[jarlsberg's pan]:
			              cmd = "Shake Portal Open";
		case $item[jarlsberg's pan (cosmic portal mode)]:
			if(cmd == "") cmd = "Shake Portal Closed";
		case $item[Boris's Helm]:
			if(cmd == "") cmd = "Twist Horns Askew";
		case $item[Boris's Helm (askew)]:
			if(cmd == "") cmd = "Untwist Horns";
		case $item[Sneaky Pete's leather jacket]:
			if(cmd == "") cmd = "Pop Collar Aggressively";
		case $item[Sneaky Pete's leather jacket (collar popped)]:
			if(cmd == "") cmd = "Unpop Collar";
			item other = fold_from(in_slot);
			start_option(other, true);
			picker.append('<td colspan="2"><a class="change" href="');
			picker.append(sideCommand("fold " + other));
			picker.append('">');
			picker.append(cmd);
			picker.append('</a></td></tr>');
			break;
		case $item[over-the-shoulder Folder Holder]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane href="inventory.php?action=useholder">Manage your folders.</a></td></tr>');
			break;
		case $item[fish hatchet]:
			              cmd = "Get Wood";
		case $item[codpiece]:
			if(cmd == "") cmd = "Wring Out";
		case $item[bass clarinet]:
		  if(cmd == "") cmd = "Drain Spit";
		  if(!to_boolean(get_property("_floundryItemUsed"))) {
				start_option(in_slot, true);
				picker.append('<td colspan="2"><a class="change" href="');
				picker.append(sideCommand("use 1 " + to_string(in_slot) + ";equip " + to_string(s) + " " + to_string(in_slot)));
				picker.append('">');
				picker.append(cmd);
				picker.append('</a></td></tr>');
			}
			break;
	}
	
	void add_favorite_button(buffer result, item it) {
		result.append('<a class="change chit_favbutton" href="');
		if(favGear contains it) {
			result.append(sideCommand("chit_changeFav.ash (remove, " + it + ")"));
			result.append('" rel="delfav"><img src="');
			result.append(imagePath);
			result.append('control_remove_red.png"></a>');
		} else {
			result.append(sideCommand("chit_changeFav.ash (add, " + it + ")"));
			result.append('" rel="addfav"><img src="');
			result.append(imagePath);
			result.append('control_add_blue.png"></a>');
		}
	}
	
	// option to unequip current item, or blurb about the slot being empty
	if(in_slot != $item[none]) {
		start_option(in_slot,true);
		picker.append('<td><a class="change" href="');
		picker.append(sideCommand("unequip " + s));
		picker.append('"><span style="font-weight:bold;">unequip</span> ');
		picker.append(gearName(in_slot));
		picker.append('</a></td><td>');
		picker.add_favorite_button(in_slot);
		picker.append('</td></tr>');
	} else {
		picker.append('<tr class="pickitem"><td colspan="3">');
		if(s == $slot[off-hand] && weapon_hands(equipped_item($slot[weapon])) > 1) {
			picker.append("You can't equip an off-hand item with a ");
			picker.append(weapon_hands(equipped_item($slot[weapon])));
			picker.append("-handed weapon equipped!");
			take_action = false;
		} else {
			picker.append("You don't have ");
			// gotta get that a/an right
			switch(s) {
			case $slot[back]:  // back doesn't sound like gear
				picker.append("a cloak");
				break;
			default:
				picker.append("a");
				string slotStart = to_lower_case(char_at(to_string(s),0));
				if($strings[a,e,i,o,u] contains slotStart)
					picker.append("n");
				picker.append(" ");
			case $slot[pants]: // Don't put article in front of pants so skip to here.
				picker.append(s);
			}
			picker.append(" equipped.");
		}
		picker.append('</td></tr>');
	}
	
	boolean [item] displayedItems;
	
	boolean add_gear_option(buffer b, item it, string reason) {
		int danger_level = 0;
		string cmd;
		string action = "";
		string action_description = "";
		
		if(!take_action) {
			// Leave action and cmd blank.
		} else if(item_amount(it) > 0) { // can just plain old equip it
			action = "equip";
			cmd = "equip ";
		} else if(closet_amount(it) > 0) {
			if(get_property("autoSatisfyWithCloset") == "false")
				danger_level = 1;
			action = "uncloset";
			cmd = "closet take " + it + "; equip ";
		} else if(boolean_modifier(it, "Free Pull") && available_amount(it) > 0) {
			action = "free pull";
			cmd = "equip ";
		} else if(foldable_amount(it) > 0) {
			action = "fold";
			cmd = "fold " + it + "; equip ";
		} else if(storage_amount(it) > 0 && pulls_remaining() == -1) { // Out of ronin (or in aftercore), prefer pulls to creation
			action = "pull";
			cmd = "pull " + it + "; equip ";
		} else if(creatable_amount(it) > 0 && it.seller == $coinmaster[none] && !(pulls_remaining() == -1 && storage_amount(it) > 0) && reason != "today") { // Not including purchases from coinmasters (Because of Shrub's Premium Baked Beans)
			danger_level = 1;
			action = "create";
			action_description = "(up to " + creatable_amount(it) + ")";
			cmd = "create "+ it+ "; equip ";
		} else if(storage_amount(it) > 0 && pulls_remaining() > 0) {
			action = "pull";
			danger_level = 2;
			action_description += '(' + pulls_remaining() + ' left)';
			cmd = "pull " + it + "; equip ";
		} else // no options were found, give up
			return false;
		
		any_options = true;
		displayedItems[it] = true;
		
		string command = sideCommand(cmd + s + " " + it);
		
		switch(vars["chit.gear.layout"]) {
		case "experimental":
			b.append('<div class="chit_flexitem" style="order:');
			b.append(danger_level);
			b.append(';"><div><a class="done" oncontextmenu="descitem(');
			b.append(it.descid);
			b.append(',0,event); return false;" onclick="descitem(');
			b.append(it.descid);
			b.append(',0,event)" href="#">');
			
			b.addItemIcon(it,"Click for item description",danger_level);
			b.append('</a></div><div style="max-width:160px;">');
			//b.add_favorite_button(it);
			if(take_action) {
				b.append('<a class="change" href="');
				b.append(command);
				b.append('">');
			}
			b.append('<span style="font-weight:bold;">');
			if(danger_level > 0)
				b.append('<span class="warning-link">');
			b.append(action);
			if(danger_level > 0)
				b.append('</span>');
			b.append(' ');
			b.append(action_description);
			b.append('</span> ');
			b.append(gearName(it));
			if(take_action)
				b.append('</a>');
			b.append('</div></div>');
			break;
			
		case "minimal":
			b.append('<span><a class="');
			if(take_action)
				b.append('change');
			else
				b.append('icon');
			b.append('" oncontextmenu="descitem(');
			b.append(it.descid);
			b.append(',0,event); return false;"');
			if(take_action) {
				b.append(' href="');
				b.append(command);
				b.append('"');
			}
			b.append('>');
			if(take_action)
				b.addItemIcon(it,gearName(it) + '&#013;Left click to ' + action + ' ' + action_description + '&#013;Right click for description',danger_level);
			else
				b.addItemIcon(it,'&#013;Right click for description',danger_level);
			if(take_action)
				b.append('</a>');
			b.append('</span>');
			break;
			
		default:
			b.append('<tr class="pickitem"><td class="icon"><a class="done" oncontextmenu="descitem(');
			b.append(it.descid);
			b.append(',0,event); return false;" onclick="descitem(');
			b.append(it.descid);
			b.append(',0,event)" href="#">');
			b.addItemIcon(it,"Click for item description",danger_level);
			b.append('</a></td><td>');
			if(take_action) {
				b.append('<a class="change" href="');
				b.append(command);
				b.append('">');
			}
			b.append('<span style="font-weight:bold;">');
			if(danger_level > 0)
				b.append('<span class="warning-link">');
			b.append(action);
			if(danger_level > 0)
				b.append('</span>');
			b.append(' ');
			b.append(action_description);
			b.append('</span> ');
			b.append(gearName(it));
			if(reason != "favorites") {
				b.append(' (');
				b.append(reason);
				b.append(')');
			}
			if(take_action)
				b.append('</a>');
			b.append('</td><td>');
			b.add_favorite_button(it);
			b.append('</td></tr>');
		}
		
		return true;
	}
	
	void add_gear_section(string name, float [item] list) {
		item [int] toDisplay;
		foreach it in list
			if(it != $item[none] && good_slot(s, it) && in_slot != it
				&& !(vars["chit.gear.layout"] == "default" && displayedItems contains it))
					toDisplay[ count(toDisplay) ] = it;
		
		if(count(toDisplay) > 0) {
			buffer temp;
			boolean show = false;
			
			switch(vars["chit.gear.layout"]) {
			case "experimental":
				temp.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">');
				temp.append(name);
				temp.append('</td></tr><tr class="pickitem chit_pickerblock"><td colspan="3"><div class="chit_flexcontainer">');
				break;
			case "minimal":
				temp.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">');
				temp.append(name);
				temp.append('</td></tr><tr class="pickitem chit_pickerblock"><td colspan="3">');
				break;
			}
			
			sort toDisplay by -list[value];
			
			foreach i,it in toDisplay
				if(temp.add_gear_option(it, name))
					show = true;
			
			switch(vars["chit.gear.layout"]) {
			case "experimental":
				temp.append('</div></td></tr>');
				break;
			case "minimal":
				temp.append('</td></tr>');
				break;
			}
			
			if(show)
				picker.append(temp.to_string());
		}
	}
	
	add_gear_section("favorites", okFavGear);
	
	foreach reason in recommendedGear
		add_gear_section(reason, recommendedGear[reason]);
	
	float mod_val(item it, string mod) {
		switch(it) {
		case $item[your cowboy boots]:
			return equipped_item($slot[bootskin]).numeric_modifier(mod)
				+ equipped_item($slot[bootspur]).numeric_modifier(mod);
		case $item[over-the-shoulder Folder Holder]:
			float modtot;
			foreach sl in $slots[folder1, folder2, folder3, folder4, folder5]
				modtot += equipped_item(sl).numeric_modifier(mod);
			return modtot;
		}
		return numeric_modifier(it, mod);
	}
	float mod_val(item it, string mod, int weight) {
		if(weight == 0) return 0;
		return mod_val(it, mod) * weight;
	}
	
	// Which gear is more desirable?
	int gear_weight(item it) {
		float weight;
		
		switch(item_type(it)) {
		case "chefstaff":
			weight = numeric_modifier(it, "Spell Damage Percent");  // They all have 10 power, so this number is a surrogate
			break;
		case "accessory":
			# weight = get_power(it) + mod_val(it, "Item Drop", 6) + mod_val(it, "Monster Level", my_level() < 13? 4: 0)
				# + (mod_val(it, "MP Regen Max") + mod_val(it, "MP Regen Min")) * 5;
			weight = get_power(it) + numeric_modifier(it, "Item Drop") * 6 + numeric_modifier(it, "Monster Level") * (my_level() < 13? 4: 0)
				+ (numeric_modifier(it, "MP Regen Max") + numeric_modifier(it, "MP Regen Min")) * 5;
			break;
		case "club":
			if(my_class() == $class[Seal Clubber])
				weight = get_power(it) * 2;
			else weight = get_power(it);
			break;
		case "shield":
			if(my_class() == $class[Turtle Tamer])
				weight = get_power(it) * 2;
			else weight = get_power(it) * 1.4;
			break;
		case "accordion":
			if(my_class() == $class[Accordion Thief])
				weight = get_power(it) * 2;
			else weight = get_power(it);
			break;
		default:
			weight = get_power(it);
		}
		
		// This is for Thor's Pliers, but if anything else has this, then it is deserved.
		if(string_modifier(it, "Modifiers").contains_text("Attacks Can't Miss"))
			weight *= 1.6;
		
		// Tired of seeing the antique gear on top. For stuff like that, let's halve base power or whatever is computed in it's place.
		if(string_modifier(it, "Modifiers").contains_text("Breakable"))
			weight *= 0.5;
		else if(weapon_hands(it) == 1)
			weight *= 1.6;
		
		switch(my_primestat()) {
		case $stat[Muscle]:
			if(weapon_type(it) == $stat[Moxie])
				weight *= 0.5;
			weight += numeric_modifier(it, "MP Regen Max") + numeric_modifier(it, "MP Regen Min");
			weight += numeric_modifier(it, "Muscle") * 2;
			weight += numeric_modifier(it, "Muscle Percent") * my_basestat($stat[Muscle]) / 50;
			break;
		case $stat[Mysticality]:
			weight += (numeric_modifier(it, "MP Regen Max") + numeric_modifier(it, "MP Regen Min")) * 2;
			weight += numeric_modifier(it, "Spell Damage") * 3;
			weight += numeric_modifier(it, "Spell Damage Percent");
			break;
		case $stat[Moxie]:
			if(weapon_type(it) != $stat[Moxie] && !(have_skill($skill[Tricky Knifework]) && item_type(it) == "knife"))
				weight *= 0.5;
			weight += numeric_modifier(it, "Moxie") * 3;
			weight += numeric_modifier(it, "Moxie Percent") * my_basestat($stat[Moxie]) / 33.3;
			break;
		}

		return weight;
	}
	
	// Find some best gear to recommend
	void add_inventory_section() {
		item [int] avail;
		foreach it in get_inventory()
			if(can_equip(it) && good_slot(s, it) && !have_equipped(it) && !(vars["chit.gear.layout"] == "default" && displayedItems contains it))
				avail[ count(avail) ] = it;
		
		if(count(avail) > 0) {
			sort avail by -gear_weight(value);
			
			switch(vars["chit.gear.layout"]) {
			case "experimental":
				picker.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">best inventory</td></tr>');
				picker.append('<tr class="pickitem chit_pickerblock"><td colspan="3"><div class="chit_flexcontainer">');
				break;
			case "minimal":
				picker.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">best inventory</td></tr><tr class="pickitem chit_pickerblock"><td colspan="3">');
				break;
			}
			
			// If this is the only section, show no title. Otherwise it is "inventory"
			string name = any_options? "inventory": "favorites";
			
			boolean shield; // Make sure there is at least one shield!
			
			// For minimal, space isn't an issue so show a dozen. Otherwise If there are recommended options, show only 5 additional items
			int amount = vars["chit.gear.layout"] == "minimal"? 11
				: any_options? 4: 11;
			for x from 0 to min(count(avail) - 1, amount) {
				picker.add_gear_option(avail[x], name);
				if(item_type(avail[x]) == "shield")
					shield = true;
			}
			if(!shield) // Find a shield!
				for x from min(count(avail) - 1, amount) to count(avail) - 1
					if(item_type(avail[x]) == "shield") {
						picker.add_gear_option(avail[x], name);
						break;
					}
			
			switch(vars["chit.gear.layout"]) {
			case "experimental":
				picker.append('</div></td></tr>');
				break;
			case "minimal":
				picker.append('</td></tr>');
				break;
			}
		}
	}
	
	add_inventory_section(); // Last chance to find something in inventory to display
	if(!any_options)
		picker.addSadFace("You have nothing " + (equipped_item(s) == $item[none]? "": "else") + " available. Poor you :(");

	picker.addLoader("Changing " + s + "...");
	picker.addLoader("Adding to favorites...", "addfav");
	picker.addLoader("Removing from favorites...", "delfav");
	picker.append('</table></div>');
	chitPickers["gear" + s] = picker;
}

// Part of gear block that can be included in stats for a smaller footprint
void addGear(buffer result) {
	addFavGear();
	void addSlot(slot s) {
		switch(s) {
		case $slot[shirt]:
			if(!have_skill($skill[Torso Awaregness]) && !have_skill($skill[Best Dressed])) {
				result.append('<span><img class="chit_icon" src="/images/itemimages/antianti.gif" title="Torso Unawaregness"></span>');
				return;
			}
			break;
		case $slot[off-hand]:
			if(weapon_hands(equipped_item($slot[weapon])) > 1) {
				result.append('<span><a class="chit_launcher" rel="chit_pickergearoff-hand" href="#"><img class="chit_icon" src="/images/itemimages/antianti.gif" title="Not enough hands"></a></span>');
				pickerGear(s);
				return;
			}
			break;
		}
		result.append('<span><a class="chit_launcher" rel="chit_pickergear');
		result.append(s);
		result.append('" href="#">');
		result.addItemIcon(equipped_item(s), s + ": " + gearName(equipped_item(s)));
		result.append('</a></span>');
		pickerGear(s);
	}
	
	result.append('<tr><td colspan="4">');
	foreach s in $slots[ hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3 ]
		addSlot(s);
	result.append('</td></tr>');
}

void bakeGear() {
	buffer result;

	result.append('<table id="chit_gear" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label"><a class="visit" target="mainpane" href="./inventory.php?which=2"><img src="');
	result.append(imagePath);
	result.append('equipment.png">Gear</a></th></tr>');
	
	result.addGear();

	result.append('</tbody></table>');

	chitBricks["gear"] = result.to_string();
	chitTools["gear"] = "Gear|equipment.png";
}

