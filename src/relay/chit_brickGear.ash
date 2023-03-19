// The original version of the Gear Brick (including pickerGear and bakeGear) was written by soolar

boolean [item] favGear;
float [string, item] recommendedGear;
boolean [string] forceSections;
boolean aftercore = qprop("questL13Final");

float equip_modifier(item it, string mod) {
	if(my_path().name == "Gelatinous Noob") return 0;
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
float equip_modifier(item it, string mod, int weight) {
	if(weight == 0) return 0;
	return equip_modifier(it, mod) * weight;
}

string beardToShorthand(effect beard) {
	string [effect] shorthands = {
		$effect[Spectacle Moustache]: "item/spooky",
		$effect[Toiletbrush Moustache]: "ML/stench",
		$effect[Barbell Moustache]: "mus/gear",
		$effect[Grizzly Beard]: "mp reg/cold",
		$effect[Surrealist's Moustache]: "mys/food",
		$effect[Musician's Musician's Moustache]: "mox/booze",
		$effect[Gull-Wing Moustache]: "init/hot",
		$effect[Space Warlord's Beard]: "wpn dmg/crit",
		$effect[Pointy Wizard Beard]: "spl dmg/crit",
		$effect[Cowboy Stache]: "rng dmg/hp/mp",
		$effect[Friendly Chops]: "meat/sleaze"
	};

	return shorthands[beard];
}

effect getCurrBeard();
effect getNextBeard();
int locketFightsRemaining();

string gearName(item it, slot s) {
	string name = to_string(it);
	string notes = "";

	switch(it) {
		case $item[V for Vivala mask]:
			if(hasDrops(it) > 0) notes = hasDrops(it) + ' adv gainable';
			break;
		case $item[mayfly bait necklace]:
			if(hasDrops(it) > 0) notes = hasDrops(it) + ' summons left';
			break;
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
			if(it == $item[Greatest American Pants] && get_property("_gapBuffs").to_int() < 5)
				notes += ", " + (5 - get_property("_gapBuffs").to_int()) + " super powers";
			break;
		case $item[Kremlin\'s Greatest Briefcase]:
			int darts = 3 - to_int(get_property("_kgbTranquilizerDartUses"));
			if(darts > 0) notes = darts + " darts";
			int drinks = 3 - to_int(get_property("_kgbDispenserUses"));
			if(drinks > 0) notes += (notes == "" ? "" : ", ") + drinks + " drinks";
			int clicks = max(22 - to_int(get_property("_kgbClicksUsed")), 0);
			if(clicks > 0) notes += (notes == "" ? "" : ", ") + clicks + " clicks";
			break;
		case $item[deceased crimbo tree]:
			int needles = to_int(get_property("garbageTreeCharge"));
			if(needles > 0)
				notes = needles + " needles";
			break;
		case $item[broken champagne bottle]:
			int ounces = to_int(get_property("garbageChampagneCharge"));
			if(ounces > 0)
				notes = ounces + " ounces";
			break;
		case $item[makeshift garbage shirt]:
			int scraps = to_int(get_property("garbageShirtCharge"));
			if(scraps > 0)
				notes = scraps + " scraps";
			break;
		case $item[FantasyRealm G. E. M.]:
			matcher m = create_matcher("(\\d+) hours? remaining", chitSource["fantasyRealm"]);
			if(find(m)) {
				int hours = m.group(1).to_int();
				if(hours > 0)
					notes = hours + " hours";
			}
			break;
		case $item[latte lovers member\'s mug]:
			name = "latte";
			int refills = 3 - get_property("_latteRefillsUsed").to_int();
			if(refills > 0)
				notes = refills;
			else
				notes = "no";
			notes += " refill";
			if(refills != 1)
				notes += "s";
			string [int] latteThings;
			if(!get_property("_latteBanishUsed").to_boolean())
				latteThings[latteThings.count()] = "throw";
			if(!get_property("_latteCopyUsed").to_boolean())
				latteThings[latteThings.count()] = "share";
			if(!get_property("_latteDrinkUsed").to_boolean())
				latteThings[latteThings.count()] = "gulp";
			if(latteThings.count() > 0) {
				notes += ", ";
				for(int i = 0; i < latteThings.count(); ++i) {
					notes += latteThings[i];
					if(i < latteThings.count() - 1)
						notes += "/";
				}
				notes += " available";
			}
			break;
		case $item[Lil\' Doctor&trade; bag]:
			int otoscopes = 3 - get_property("_otoscopeUsed").to_int();
			int reflexes = 3 - get_property("_reflexHammerUsed").to_int();
			int xrays = 3 - get_property("_chestXRayUsed").to_int();
			if(otoscopes > 0)
				notes = otoscopes + " otoscope" + (otoscopes == 1 ? "" : "s");
			if(reflexes > 0)
			{
				if(notes != "")
					notes += ", ";
				notes += reflexes + " hammer" + (reflexes == 1 ? "" : "s");
			}
			if(xrays > 0)
			{
				if(notes != "")
					notes += ", ";
				notes += xrays + " x-ray" + (xrays == 1 ? "" : "s");
			}
			break;
		case $item[Red Roger\'s red left foot]:
			notes = "island";
			break;
		case $item[Red Roger\'s red right foot]:
			notes = "sailing";
			break;
		case $item[Fourth of May Cosplay Saber]:
			int forceUses = 5 - get_property("_saberForceUses").to_int();
			if(forceUses > 0) {
				notes = forceUses + " force uses";
			}
			break;
		case $item[Beach Comb]:
			int beachCombs = 11 - get_property("_freeBeachWalksUsed").to_int();
			if(beachCombs > 0) {
				notes = beachCombs + " free combs";
			}
			break;
		case $item[Powerful Glove]:
			int batteryLeft = 100 - get_property("_powerfulGloveBatteryPowerUsed").to_int();
			notes = batteryLeft + "% battery";
			break;
		case $item[[10462]fire flower]:
			name = "fire flower";
			break;
		case $item[vampyric cloake]:
			int transformsLeft = 10 - get_property("_vampyreCloakeFormUses").to_int();
			notes = transformsLeft + " transformations";
			break;
		case $item[Cargo Cultist Shorts]:
			boolean pocketEmptied = get_property("_cargoPocketEmptied").to_boolean();
			if(!pocketEmptied)
				notes = "pocket pickable";
			break;
		case $item[backup camera]:
			// 5 extra uses in You, Robot
			int backupsLeft = (my_path().id == 41 ? 16 : 11) - get_property("_backUpUses").to_int();
			notes = backupsLeft + " backups left: " + get_property("lastCopyableMonster");
			if(!get_property("backupCameraReverserEnabled").to_boolean()) {
				notes += ", REVERSER NOT ENABLED!";
			}
			break;
		case $item[familiar scrapbook]:
			notes = get_property("scrapbookCharges") + " scraps";
			break;
		case $item[industrial fire extinguisher]:
			int extinguisherCharge = get_property("_fireExtinguisherCharge").to_int();
			if(extinguisherCharge <= 0) {
				notes = "empty";
			}
			else {
				notes = extinguisherCharge + "% full";
			}
			break;
		case $item[mafia thumb ring]:
			int thumbAdvs = get_property("_mafiaThumbRingAdvs").to_int();
			if(thumbAdvs > 0) {
				notes = thumbAdvs + " adv gained";
			}
			break;
		case $item[Daylight Shavings Helmet]:
			effect nextBeard = getNextBeard();
			if(nextBeard != $effect[none]) {
				notes = beardToShorthand(nextBeard);
				if(getCurrBeard() != $effect[none]) {
					notes += " next";
				}
				else {
					notes += " due";
				}
			}
			break;
		case $item[cursed magnifying glass]:
			notes += get_property("cursedMagnifyingGlassCount") + "/13 charge, " + get_property("_voidFreeFights") + "/5 free";
			break;
		case $item[combat lover's locket]:
			int locketFights = locketFightsRemaining();
			if(locketFights > 0) {
				notes += locketFights + " reminiscence" + (locketFights == 1 ? "" : "s") + " remain";
			}
			else {
				notes += "done reminiscing";
			}
			break;
		case $item[unbreakable umbrella]:
			notes += get_property("umbrellaState");
			break;
		case $item[June cleaver]:
			int juneFights = get_property("_juneCleaverFightsLeft").to_int();
			if(juneFights == 0) {
				notes += "noncom now!";
			}
			else {
				notes += juneFights + " to noncom";
			}
			break;
		case $item[designer sweatpants]:
			int sweat = max(min(100, get_property("sweat").to_int()), 0);
			int sweatboozeleft = 3 - get_property("_sweatOutSomeBoozeUsed").to_int();
			notes += sweat + "% sweaty";
			if(sweatboozeleft > 0) {
				notes += ", " + sweatboozeleft + " booze sweats";
			}
			break;
		case $item[Jurassic Parka]:
			string parkaMode = get_property("parkaMode");
			if(parkaMode.length() > 0) {
				notes += parkaMode + " mode";
			}
			break;
	}

	if(equipped_item(s) == it && s == $slot[off-hand] && vars["chit.gear.lattereminder"].to_boolean() && my_location().latteDropAvailable()) {
		if(it != $item[latte lovers member\'s mug] && !it.isImportantOffhand()) {
			if(notes != "")
				notes += ", ";
			notes += "latte unlock available!";
		}
	}

	if(notes != "")
		name += " (" + notes + ")";

	return name;
}

string [string] defaults;
boolean defaults_initialized = false;

string [string,string] reason_options;

void gear_display_options() {
	foreach i,s in split_string(vars["chit.gear.display." + (aftercore ? "aftercore" : "in-run")], ", ?") {
		string [string] options;
		string [int] spl = split_string(s,":");
		if(spl.count() > 1) {
			for i from 1 to spl.count() - 1 {
				string [int] opt = split_string(spl[i], " ?= ?");
				if(opt.count() == 2)
					options[opt[0]] = opt[1];
			}
		}
		reason_options[spl[0]] = options;
	}
}

string get_option(string reason, string option) {
	if(forceSections[reason] && option == "amount")
		return "all";
	if(reason != "" && reason_options[reason,option] != "")
		return reason_options[reason,option];

	if(!defaults_initialized) {
		foreach i,s in split_string(vars["chit.gear.display." + (aftercore ? "aftercore" : "in-run") + ".defaults"], ", ?") {
			string [int] spl = split_string(s, "=");
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

void addGear(item it, string reason, float score)
{
	class gear_class = class_modifier(it,"Class");

	if(vars["chit.gear.ignoreG-Lover"].to_boolean() == false && my_path().name == "G-Lover" && reason != "quest" && index_of(it.to_lower_case(), "g") < 0)
		return;

	if(is_unrestricted(it) && can_equip(it) && chit_available(it, reason) > 0
		&& !(have_equipped(it) && string_modifier(it, "Modifiers").contains_text("Single Equip"))
		&& (gear_class == $class[none] || gear_class == my_class() || (it == $item[Hand that Rocks the Ladle] && have_skill($skill[Utensil Twist]))))
	{
		recommendedGear[reason][it] = score;
	}
}
// Don't overuse this, it will force the display of the item's section regardless of user settings
void forceAddGear(item it, string reason)
{
	addGear(it, reason, 1000);
	forceSections[reason] = true;
}
void addGear(boolean [item] list, string reason)
{
	foreach it in list
		addGear(it, reason, 1);
}
void forceAddGear(boolean [item] list, string reason)
{
	addGear(list, reason);
	forceSections[reason] = true;
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
	gear_display_options();

	// Certain quest items need to be equipped to enter locations
	if(available_amount($item[digital key]) + creatable_amount($item[digital key]) < 1 && get_property("questL13Final") != "finished")
		addGear($item[continuum transfunctioner], "quest");

	if(get_property("ghostLocation") == "Inside the Palindome")
		forceAddGear($item[Talisman o\' Namsilat], "ghost");

	// Ascension specific quest items
	int total_keys() { return available_amount($item[fat loot token]) + available_amount($item[Boris\'s key]) + available_amount($item[Jarlsberg\'s key]) + available_amount($item[Sneaky Pete\'s key]); }
	if(!aftercore && get_property("dailyDungeonDone") == "false" && total_keys() < 3)
		addGear($item[ring of Detect Boring Doors], "quest");

	if(get_property("questL13Final") == "step6" && available_amount($item[beehive]) < 1)
		forceAddGear($items[hot plate, smirking shrunken head, bottle opener belt buckle, Groll doll, hippy protest button], "towerkilling");


	// Charter zone quest equipment
	if((get_property("hotAirportAlways") == "true" || get_property("_hotAirportToday") == "true") && get_property("_infernoDiscoVisited") == "false")
		addGear($items[smooth velvet pants, smooth velvet shirt, smooth velvet hat, smooth velvet pocket square, smooth velvet socks, smooth velvet hanky], "charter");
	if(get_property("coldAirportAlways") == "true" || get_property("_coldAirportToday") == "true") {
		addGear($items[bellhop's hat, Walford's bucket], "charter");
		if(get_property("walfordBucketItem") == "bolts")
			addGear($item[VYKEA hex key], "charter");
		else if(get_property("walfordBucketItem") == "blood")
			addGear($item[remorseless knife], "charter");
	}

	// FantasyRealm equipment
	if(equipped_amount($item[FantasyRealm G. E. M.]) > 0) {
		forceAddGear($items[LyleCo premium magnifying glass, LyleCo premium monocle, charged druidic orb, dragon slaying sword], "FantasyRealm");
		// recommend the hats if you aren't wearing one
		if(equipped_amount($item[FantasyRealm Mage's Hat]) + equipped_amount($item[FantasyRealm Rogue's Mask]) + equipped_amount($item[FantasyRealm Warrior's Helm]) == 0)
			forceAddGear($items[FantasyRealm Mage's Hat, FantasyRealm Rogue's Mask, FantasyRealm Warrior's Helm], "FantasyRealm");
	}

	// PirateRealm equipment
	if(equipped_amount($item[PirateRealm eyepatch]) > 0) {
		forceAddGear($items[cursed compass, bloody harpoon, Red Roger's red right hand, Red Roger's red left hand, Red Roger's red right foot, Red Roger's red left foot, recursed compass, PirateRealm party hat], "PirateRealm");
	}

	// "I Voted!" Sticker, for wanderers only
	if((total_turns_played() % 11 == 1) &&
		(total_turns_played() != get_property("lastVoteMonsterTurn").to_int())) {
		boolean voteFree = get_property("_voteFreeFights").to_int() < 3;
		forceAddGear($item[&quot;I Voted!&quot; sticker], voteFree ? "free wanderer" : "wanderer");
	}

	// latte, if an unlock is available
	if(my_location().latteDropAvailable())
		forceAddGear($item[latte lovers member\'s mug], "latte unlock");

	// Miscellaneous
	int turnsToGhost = to_int(get_property("nextParanormalActivity")) - total_turns_played();
	if(turnsToGhost <= 0 || get_property("ghostLocation") != "")
		forceAddGear($item[protonic accelerator pack], "ghost");

	// Find varous stuff instead of hardcoding lists
	static {
		record modifier {
			float multiplier;
			string mod;
		};
		record gear_category {
			float [item] list;
			string name;
			modifier [int] modifiers;
			string [string, int] attributes;
		};
		gear_category [int] catList;
		gear_category newCategory(string name, string mods, string attrs) {
			gear_category cat;
			cat.name = name;
			foreach i,mod in mods.split_string(" *, *") {
				string [int] split = mod.split_string(" *\\* *");
				modifier curr;
				if(split.count() == 1) {
					if(split[0].to_float() != 0.0) {
						curr.multiplier = split[0].to_float();
						curr.mod = "flatval";
					} else {
						curr.multiplier = 1;
						curr.mod = split[0];
					}
				} else {
					curr.multiplier = to_float(split[0]);
					curr.mod = split[1];
				}
				cat.modifiers[i] = curr;
			}
			if(attrs != "") {
				foreach i,attr in attrs.split_string(" *, *") {
					string [int] split = attr.split_string(" *: *");
					if(split.count() == 2) {
						string [int] attrVals = cat.attributes[split[0]];
						attrVals[attrVals.count()] = split[1];
						cat.attributes[split[0]] = attrVals;
					} else
						vprint("CHIT: Malformed gear category attribute (" + attr + ")", "red", 1);
				}
			}

			catList[catList.count()] = cat;

			return cat;
		}

		string [string,string] categories;
		if(!file_to_map("chit_GearCategories.txt", categories))
			vprint("CHIT: chit_GearCategories.txt could not be loaded", "red", 1);
		foreach name,mods,attrs in categories
			newCategory(name, mods, attrs);

		foreach it in $items[] {
			foreach i,cat in catList {
				if(!to_boolean(cat.attributes["Manual", 0])) {
					float score = 0;
					foreach i,mod in cat.modifiers {
						if(mod.mod == "flatval")
							score += mod.multiplier;
						else
							score += equip_modifier(it, mod.mod) * mod.multiplier;
					}
					foreach attr,i,val in cat.attributes {
							switch(attr) {
								case "IsTrue":
									if(!boolean_modifier(it,val))
										score = -1;
									break;
							}
					}
					if(weapon_hands(it) > 1)
						score /= 2;
					if(score > 0)
						cat.list[it] = score;
				}
			}
		}
		foreach i,cat in catList {
			if(to_boolean(cat.attributes["Manual", 0])) {
				foreach i,mod in cat.modifiers
					cat.list[to_item(mod.mod)] = mod.multiplier;
			}
		}
	}

	foreach i,cat in catList {
		boolean ok = true;
		boolean force = false;
		foreach attr,i,val in cat.attributes {
			switch(attr) {
				case "PvP":
					if(to_boolean(val) != hippy_stone_broken())
						ok = false;
					break;
				case "Drunk":
					if(to_boolean(val) != (my_inebriety() > inebriety_limit()))
						ok = false;
					break;
				case "Mainstat":
					if(index_of(val, my_primestat()) < 0)
						ok = false;
					break;
				case "Quest":
					if(!qprop(val))
						ok = false;
					break;
				case "Bounty":
					if(index_of(get_property("currentEasyBountyItem"), val) < 0 &&
						 index_of(get_property("currentHardBountyItem"), val) < 0 &&
						 index_of(get_property("currentSpecialBountyItem"), val) < 0)
						ok = false;
					break;
				case "Path":
					if(my_path().name != val)
						ok = false;
					break;
				case "Force":
					force = to_boolean(val);
					break;
			}
			if(!ok)
				break;
		}
		if(ok) {
			if(force)
				forceSections[cat.name] = true;
			addGear(cat.list, cat.name);
		}
	}

	// manual favorites
	foreach i,fav in split_string(vars["chit.gear.favorites"], "\\s*(?<!\\\\)[,|]\\s*") {
		item it = to_item(fav.replace_string("\\,", ","));
		favGear[it] = true;
		addGear(it, "favorites");
	}
}

void pickerEdpiece() {
	buffer picker;
	picker.pickerStart("edpiece", "Adorn thy crown");

	string current = get_property("edPiece");

	void addJewel(string jewel, string desc, string icon) {
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

	addJewel("bear", "Musc +20, +2 Musc exp", "teddybear");
	addJewel("owl", "Myst +20, +2 Myst exp", "owl");
	addJewel("puma", "Moxie +20, +2 Moxie exp", "blackcat");
	addJewel("hyena", "+20 Monster Level", "lionface");
	addJewel("mouse", "+10% Items, +20% Meat", "mouseskull");
	addJewel("weasel", "Dodge first attack, 10-20 HP regen", "weasel");
	addJewel("fish", "Lets you breathe underwater", "fish");

	picker.addLoader("Cool jewels!");
	picker.append('</table></div>');
	chitPickers["edpiece"] = picker;
}

void pickerGAP() {
	buffer picker;
	picker.pickerStart("gap", "Activate a Superpower");

	void addSuperpower(string power, string desc, string icon, int duration) {
		string powerLink = '<a class="change" href="' + sideCommand("gap " + power) + '">';

		picker.append('<tr class="pickitem"><td class="icon">');
		picker.append(powerLink);
		picker.append('<img class="chit_icon" src="/images/itemimages/');
		picker.append(icon);
		picker.append('.gif" title="Activate Super ');
		picker.append(power);
		picker.append('" /></a></td><td colspan="2">');
		picker.append(powerLink);
		picker.append('<b>Activate</b> Super ');
		picker.append(power);
		picker.append('<br /><space class="descline">');
		picker.append(parseMods(desc, true));
		picker.append(' (');
		picker.append(duration);
		picker.append(' turns)</span></a></td></tr>');
	}

	addSuperpower("Skill", "Combat Skills/Spells cost 0 MP", "snowflakes", 5);
	addSuperPower("Structure", "+500 DA, +5 Prismatic resistance", "wallshield", 10);
	addSuperPower("Vision", "+25% Item Drops", "xrayspecs", 20);
	addSuperPower("Speed", "+100% Moxie", "fast", 20);
	addSuperPower("Accuracy", "+30% Crit Chance", "reticle", 10);

	picker.addLoader("Loading Superpowers...");
	picker.append('</table></div>');
	chitPickers["gap"] = picker;
}

void pickerForceUpgrade() {
	buffer picker;
	picker.pickerStart("theforce", "Pick an upgrade");

	void addUpgrade(int upgrade, string name, string desc, string icon) {
		string upgradeLink = '<a class="change" href="' + sideCommand('ashq visit_url("main.php?action=may4", false); visit_url("choice.php?pwd=&whichchoice=1386&option=' + upgrade.to_string() + '");') + '">';

		picker.append('<tr class="pickitem"><td class="icon">');
		picker.append(upgradeLink);
		picker.append('<img class="chit_icon" src="/images/itemimages/');
		picker.append(icon);
		picker.append('.gif" title="Install ');
		picker.append(name);
		picker.append(' (');
		picker.append(desc);
		picker.append(')" /></a></td><td colspan="2">');
		picker.append(upgradeLink);
		picker.append('<b>Install</b> ');
		picker.append(name);
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span></a></td></tr>');
	}

	addUpgrade(1, "Enhanced Kaiburr Crystal", "15-20 MP regen", "crystal");
	addUpgrade(2, "Purple Beam Crystal", "+20 Monster Level", "nacrystal1");
	addUpgrade(3, "Force Resistance Multiplier", "+3 Prismatic Res", "wonderwall");
	addUpgrade(4, "Empathy Chip", "+10 Familiar Weight", "spiritorb");

	picker.addLoader("Applying upgrade...");
	picker.append('</table></div>');
	chitPickers["theforce"] = picker;
}

void pickerPillKeeper() {
	buffer picker;
	picker.pickerStart("pillkeeper", "Pop a pill");

	void addPill(string pill, string desc, string command, string icon) {
		string pillLink = '<a class="change" href="' + sideCommand("pillkeeper " + command) + '">';

		picker.append('<tr class="pickitem"><td class="icon">');
		picker.append(pillLink);
		picker.append('<img class="chit_icon" src="/images/itemimages/');
		picker.append(icon);
		picker.append('.gif" title="Take ');
		picker.append(pill);
		picker.append(' (');
		picker.append(desc);
		picker.append(')" /></a></td><td colspan="2">');
		picker.append(pillLink);
		picker.append('<b>Take</b> ');
		picker.append(pill);
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span></a></td></tr>');
	}

	addPill("Explodinall", "Force all item drops from your next fight", "explode", "goldenlight");
	addPill("Extendicillin", "Double the duration of your next potion", "extend", "potion1");
	addPill("Sneakisol", "Force a non-combat", "noncombat", "clarabell");
	addPill("Rainbowolin", "Stupendous resistance to all elements (30 turns)", "element", "rrainbow");
	addPill("Hulkien", "+100% to all stats (30 turns)", "stat", "getbig");
	addPill("Fidoxene", "All your familiars are at least 20 lbs (30 turns)", "familiar", "pill5");
	addPill("Surprise Me", "Force a semi-rare. Even repeats!", "semirare", "spreadsheet");
	addPill("Telecybin", "Adventure Randomly! (30 turns)", "random", "calendar");

	picker.addLoader("Popping pills!");
	picker.append('</table></div>');
	chitPickers["pillkeeper"] = picker;
}

void pickerPowerfulGlove() {
	buffer picker;
	int batteryLeft = 100 - get_property("_powerfulGloveBatteryPowerUsed").to_int();
	picker.pickerStart("powerfulglove", "Cheat at life (" + batteryLeft + "% left)");

	void addCheat(skill cheat, string desc) {
		string cheatLink = '<a class="change" href="' + sideCommand("cast 1 " + cheat.to_string()) + '">';

		picker.append('<tr class="pickitem');
		if(cheat.combat) picker.append(' currentitem');
		picker.append('"><td class="icon"><a class="done" onclick=\'javascript:poop("desc_skill.php?whichskill=');
		picker.append(cheat.to_int());
		picker.append('&self=true","skill", 350, 300)\' href="#"><img class="chit_icon" src="/images/itemimages/');
		picker.append(cheat.image);
		picker.append('" title="Pop out skill description" /></a></td><td colspan="2">');
		if(!cheat.combat) {
			picker.append(cheatLink);
			picker.append('<b>ENTER</b> ');
		}
		picker.append(cheat.to_string());
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		if(cheat.combat) picker.append('<br />(Available in combat)');
		picker.append('</span></a></td></tr>');
	}

	addCheat($skill[CHEAT CODE: Invisible Avatar], "-10% combat rate for 10 turns (5% battery)");
	addCheat($skill[CHEAT CODE: Triple Size], "+200% all stats for 20 turns (5% battery)");
	if(batteryLeft >= 10)
		addCheat($skill[CHEAT CODE: Replace Enemy], "Fight something else from the same zone (10% battery)");
	addCheat($skill[CHEAT CODE: Shrink Enemy], "Cut enemy hp/attack/defense in half (5% battery)");

	picker.addLoader("Entering cheat code!");
	picker.append('</table></div>');
	chitPickers["powerfulglove"] = picker;
}

string retroHeroToIcon(string hero) {
	switch(hero) {
		case "muscle":
		case "vampire":
			return "retrocape1.gif";
		case "mysticality":
		case "heck":
			return "retrocape2.gif";
		case "moxie":
		case "robot":
			return "retrocape3.gif";
	}
	abort("Unrecognized hero " + hero);
	return "";
}

void pickerRetroSuperCapeMeta() {
	buffer picker;
	picker.pickerStart("retrosupercapemeta", "Switch up your cape");

	void addCombo(string name, string hero, string mode, boolean enabled) {
		boolean active = false;
		if(get_property("retroCapeSuperhero") == hero && get_property("retroCapeWashingInstructions") == mode) {
			enabled = false;
			active = true;
		}

		picker.append('<tr class="pickitem');
		if(!enabled) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(retroHeroToIcon(hero));
		picker.append('" /></td><td colspan="2">');
		if(active) {
			picker.append('<b>CURRENT</b>: ');
		}
		else {
			picker.append('<a class="change" href="');
			picker.append(sideCommand("retrocape " + hero + " " + mode));
			picker.append('"><b>CONFIGURE</b> to ');
		}
		picker.append(name);
		if(!active) picker.append('</a>');
		picker.append('</td></tr>');
	}

	string mainstatHero = my_primestat().to_string().to_lower_case();
	switch(my_primestat()) {
		case $stat[Muscle]: mainstatHero = "vampire"; break;
		case $stat[Mysticality]: mainstatHero = "heck"; break;
		case $stat[Moxie]: mainstatHero = "robot"; break;
	}
	addCombo("get mainstat exp", mainstatHero, "thrill", true);
	addCombo("yellow ray", "heck", "kiss", have_effect($effect[Everything Looks Yellow]) == 0);
	addCombo("purge evil", "vampire", "kill", true);
	addCombo("resist elements", "vampire", "hold", true);
	addCombo("spooky lantern", "heck", "kill", true);
	addCombo("stun enemies", "heck", "hold", true);

	picker.addLoader("Configuring your cape...");
	picker.append('</table></div>');
	chitPickers["retrosupercapemeta"] = picker;
}

void pickerRetroSuperCapeAll() {
	buffer pickerHero, pickerVampire, pickerHeck, pickerRobot;

	void addHero(string name, string desc, string picker) {
		pickerHero.append('<tr class="pickitem"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		pickerHero.append(retroHeroToIcon(picker));
		pickerHero.append('" /></td><td colspan="2"><a class="chit_launcher done" rel="chit_pickerretrosupercape');
		pickerHero.append(picker);
		pickerHero.append('" href="#"><b>PICK</b> ');
		pickerHero.append(name);
		pickerHero.append('<br /><span class="descline">');
		pickerHero.append(parseMods(desc, true));
		pickerHero.append('</span></a></td></tr>');
	}

	void addMode(buffer picker, string name, string desc, string hero, string nameShort, boolean parse) {
		boolean active = get_property("retroCapeSuperhero") == hero && get_property("retroCapeWashingInstructions") == nameShort;

		picker.append('<tr class="pickitem');
		if(active) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(retroHeroToIcon(hero));
		picker.append('" /></td><td colspan="2">');
		if(!active) {
			picker.append('<a class="change" href="');
			picker.append(sideCommand("retrocape " + hero + " " + nameShort));
			picker.append('"><b>PICK</b> ');
		}
		else {
			picker.append('<b>CURRENT</b>: ');
		}
		picker.append(name);
		picker.append('<br /><span class="descline">');
		picker.append(parse ? parseMods(desc, true) : desc);
		picker.append('</span>');
		if(active) picker.append('</a>');
		picker.append('</td></tr>');
	}

	// Hero picker
	pickerHero.pickerStart("retrosupercapeall", "Pick a hero");
	addHero("Vampire Slicer", "Muscle +30%, Maximum HP +50", "vampire");
	addHero("Heck General", "Mysticality +30%, Maximum MP +50", "heck");
	addHero("Robot Police", "Moxie +30%, Maximum HP/MP +25", "robot");
	pickerHero.addLoader("Picking mode...");
	pickerHero.append('</table></div>');
	chitPickers["retrosupercapeall"] = pickerHero;

	// Vampire picker
	pickerVampire.pickerStart("retrosupercapevampire", "Pick a mode");
	pickerVampire.addMode("Hold Me", "Serious Resistance to All Elements (+3)", "vampire", "hold", true);
	pickerVampire.addMode("Thrill Me", "+3 Muscle Stats Per Fight", "vampire", "thrill", true);
	pickerVampire.addMode("Kiss Me", "Allows vampiric smooching (HP drain)", "vampire", "kiss", false);
	pickerVampire.addMode("Kill Me", "Lets you instantly kill undead foes with a sword (reduces evil in Cyrpt)", "vampire", "kill", false);
	pickerVampire.addLoader("Configuring your cape...");
	pickerVampire.append('</table></div>');
	chitPickers["retrosupercapevampire"] = pickerVampire;

	// Heck picker
	pickerHeck.pickerStart("retrosupercapeheck", "Pick a mode");
	pickerHeck.addMode("Hold Me", "Stuns foes at the start of combat", "heck", "hold", false);
	pickerHeck.addMode("Thrill Me", "+3 Mysticality Stats Per Fight", "heck", "thrill", true);
	pickerHeck.addMode("Kiss Me", "Lets you unleash the Devil's kiss (100 turn cooldown yellow ray)", "heck", "kiss", false);
	pickerHeck.addMode("Kill Me", "A Heck Clown will make your spells spookier (Spooky lantern)", "heck", "kill", false);
	pickerHeck.addLoader("Configuring your cape...");
	pickerHeck.append('</table></div>');
	chitPickers["retrosupercapeheck"] = pickerHeck;

	// Robot picker
	pickerRobot.pickerStart("retrosupercaperobot", "Pick a mode");
	pickerRobot.addMode("Hold Me", "Allows you to handcuff opponents (Delevel attack)", "robot", "hold", false);
	pickerRobot.addMode("Thrill Me", "+3 Moxie Stats Per Fight", "robot", "thrill", true);
	pickerRobot.addMode("Kiss Me", "Enable a Sleaze attack", "robot", "kiss", false);
	pickerRobot.addMode("Kill Me", "Lets you perform a super-accurate attack with a gun (guaranteed crit)", "robot", "kill", false);
	pickerRobot.addLoader("Configuring your cape...");
	pickerRobot.append('</table></div>');
	chitPickers["retrosupercaperobot"] = pickerRobot;
}

string retroSupercapeCurrentSetupName() {
	string hero = get_property("retroCapeSuperhero");
	string mode = get_property("retroCapeWashingInstructions");

	switch(hero) {
		case "vampire": // muscle
			switch(mode) {
				case "hold": return "resistances";
				case "thrill": return my_primestat() == $stat[Muscle] ? "mainstat exp" : "mus exp";
				case "kiss": return "draining kiss";
				case "kill": return "purge evil";
			}
			break;
		case "heck": // mysticality
			switch(mode) {
				case "hold": return "stun foes";
				case "thrill": return my_primestat() == $stat[Mysticality] ? "mainstat exp" : "mys exp";
				case "kiss": return "yellow ray";
				case "kill": return "spooky lantern";
			}
			break;
		case "robot": // moxie
			switch(mode) {
				case "hold": return "handcuff";
				case "thrill": return my_primestat() == $stat[Moxie] ? "mainstat exp" : "mox exp";
				case "kiss": return "sleaze attack";
				case "kill": return "gun crit";
			}
			break;
	}

	return "???";
}

void pickerBackupCamera() {
	buffer picker;
	picker.pickerStart("backupcamera", "Configure your camera");

	void addSetting(string name, string desc, string command, string icon) {
		boolean active = get_property("backupCameraMode") == command;
		boolean needsVerb = !name.starts_with('<b>');

		picker.append('<tr class="pickitem');
		if(active) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(icon);
		picker.append('" /></td><td colspan="2">');
		if(active) {
			picker.append('<b>Current</b>: ');
		}
		else {
			picker.append('<a class="change" href="');
			picker.append(sideCommand("backupcamera " + command));
			picker.append('">');
			if(needsVerb) picker.append('<b>Toggle</b> to ');
		}
		picker.append(name);
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span>');
		if(!active) picker.append('</a>');
		picker.append('</td></tr>');
	}

	if(get_property("backupCameraReverserEnabled").to_boolean()) {
		addSetting("<b>Disable</b> reverser", "Make everything confusing", "reverser off", "backcamera.gif");
	}
	else {
		addSetting("<b>Enable</b> reverser", "Make everything look normal", "reverser on", "backcamera.gif");
	}
	addSetting("Infrared Spectrum", "+50% Meat Drops", "meat", "meat.gif");
	addSetting("Warning Beep", "+" + (min(3 * my_level(), 50).to_string()) + " ML (scales with level)", "ml", "angry.gif");
	addSetting("Maximum Framerate", "+100% Initiative", "init", "fast.gif");

	picker.addLoader("Configuring your camera...");
	picker.append('</table></div>');
	chitPickers["backupcamera"] = picker;
}

effect [int] getBeardOrder() {
	effect [int] baseBeardOrder = {
		$effect[Spectacle Moustache],
		$effect[Toiletbrush Moustache],
		$effect[Barbell Moustache],
		$effect[Grizzly Beard],
		$effect[Surrealist's Moustache],
		$effect[Musician's Musician's Moustache],
		$effect[Gull-Wing Moustache],
		$effect[Space Warlord's Beard],
		$effect[Pointy Wizard Beard],
		$effect[Cowboy Stache],
		$effect[Friendly Chops]
	};

	effect [int] beardOrder;
	int classId = my_class().to_int();
	int classIdMod = ((classId<=6)?classId:classId+1)% 6;
	for(int i = 0; i < 11; ++i) {
		int nextBeard = (classIdMod * i) % 11;
		beardOrder[i] = baseBeardOrder[nextBeard];
	}

	return beardOrder;
}

effect getCurrBeard() {
	foreach beard in $effects[
		Spectacle Moustache,
		Toiletbrush Moustache,
		Barbell Moustache,
		Grizzly Beard,
		Surrealist's Moustache,
		Musician's Musician's Moustache,
		Gull-Wing Moustache,
		Space Warlord's Beard,
		Pointy Wizard Beard,
		Cowboy Stache,
		Friendly Chops
	] {
		if(have_effect(beard) > 0) {
			return beard;
		}
	}
	return $effect[none];
}

int getCurrBeardNum() {
	foreach i,beard in getBeardOrder() {
		if(have_effect(beard) > 0) {
			return i;
		}
	}
	return -1;
}

int getLastBeardNum() {
	effect lastBeard = get_property("lastBeardBuff").to_effect();
	if(lastBeard == $effect[none]) {
		return 0;
	}
	foreach i,beard in getBeardOrder() {
		if(beard == lastBeard) {
			return i;
		}
	}
	return 0;
}

effect getNextBeard() {
	effect [int] beardOrder = getBeardOrder();
	int currBeardNum = getCurrBeardNum();
	if(currBeardNum == -1) {
		int lastBeardNum = getLastBeardNum();
		return beardOrder[(lastBeardNum + 1) % 11];
	}
	return beardOrder[(currBeardNum + 1) % 11];
}

// This isn't really a picker, it just uses the picker layout
void pickerFakeDaylightShavingsHelmet() {
	buffer picker;
	picker.pickerStart("fakebeard", "Check out beard ordering");

	void addBeard(effect beard) {
		picker.append('<tr class="pickitem');
		if(have_effect(beard) > 0)
			picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(beard.image);
		picker.append('" /></td><td colspan="2">');
		picker.append(beard.to_string());
		picker.append('<br /><span class="descline">');
		picker.append(parseMods(string_modifier(beard, "Evaluated Modifiers")));
		picker.append('</span></td></tr>');
	}

	effect [int] beardOrder = getBeardOrder();

	int beardStartNum = getCurrBeardNum();
	if(beardStartNum == -1) {
		// this works even if last beard is unknown because we want to start at 0 there
		// and it returns -1 in that case
		beardStartNum = (getLastBeardNum() + 1) % 11;
	}

	for(int i = 0; i < 11; ++i) {
		int beardToDisplay = (i + beardStartNum) % 11;
		addBeard(beardOrder[beardToDisplay]);
	}

	picker.append('</table></div>');
	chitPickers["fakebeard"] = picker;
}

int locketFightsRemaining() {
	string fought = get_property("_locketMonstersFought");
	if(fought.length() == 0) {
		return 3;
	}
	return max(3 - fought.split_string(",").count(), 0);
}

void pickerUnbrella() {
	buffer picker;
	picker.pickerStart("unbrella", "Reconfigure your unbrella");

	void addSetting(string name, string desc, string command, string icon) {
		boolean active = get_property("umbrellaState") == name;

		picker.append('<tr class="pickitem');
		if(active) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(icon);
		picker.append('" /></td><td colspan="2">');
		if(active) {
			picker.append('<b>Current</b>: ');
		}
		else {
			picker.append('<a class="change" href="');
			picker.append(sideCommand("umbrella " + command));
			picker.append('"><b>Configure</b> to be ');
		}
		picker.append(name);
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span>');
		if(!active) picker.append('</a>');
		picker.append('</td></tr>');
	}

	addSetting("broken", "+25% ML", "broken", "unbrella7.gif");
	addSetting("forward-facing", "+25 DR, Shield", "forward", "unbrella3.gif");
	addSetting("bucket style", "+25% Item Drop", "bucket", "unbrella5.gif");
	addSetting("pitchfork style", "+25 Weapon Damage", "pitchfork", "unbrella8.gif");
	addSetting("constantly twirling", "+25 Spell Damage", "twirling", "unbrella6.gif");
	addSetting("cocoon", "-10% combat", "cocoon", "unbrella1.gif");

	picker.addLoader("Reconfiguring your unbrella");
	picker.append('</table></div>');
	chitPickers["unbrella"] = picker;
}

void pickerSweatpants() {
	buffer picker;
	int sweat = get_property("sweat").to_int();
	int sweatboozeleft = 3 - get_property("_sweatOutSomeBoozeUsed").to_int();
	picker.pickerStart("sweatpants", "Sweat Magic (" + sweat + "% sweaty)");

	void addSweatSkill(skill sk, string desc, int cost) {
		string castLink = '<a class="change" href="' + sideCommand("cast 1 " + sk.to_string()) + '">';
		boolean noBooze = (sk == $skill[Sweat Out Some Booze])
			&& (get_property("_sweatOutSomeBoozeUsed").to_int() >= 3);
		boolean canCast = !sk.combat && cost <= sweat && !noBooze;

		picker.append('<tr class="pickitem');
		if(!canCast) picker.append(' currentitem');
		picker.append('"><td class="icon"><a class="done" onclick=\'javascript:');
		picker.append('poop("desc_skill.php?whichskill=');
		picker.append(sk.to_int());
		picker.append('&self=true","skill", 350, 300)\' href="#">');
		picker.append('<img class="chit_icon" src="/images/itemimages/');
		picker.append(sk.image);
		picker.append('" title="Pop out skill description" /></a></td>');
		picker.append('<td colspan="2">');
		if(canCast) {
			picker.append(castLink);
			picker.append('<b>Cast</b> ');
		}
		picker.append(sk.to_string());
		picker.append(' (');
		picker.append(cost);
		picker.append(' sweat)<br /><span class="descline">');
		picker.append(desc);
		if(sk.combat) picker.append('<br />(Available in combat)');
		if(noBooze) picker.append('<br />(Already used up for today)');
		else if(sweat < cost) picker.append('<br />(Not enough sweat!)');
		picker.append('</span></a></td></tr>');
	}

	addSweatSkill($skill[Sip Some Sweat], "Restore 50 MP", 5);
	addSweatSkill($skill[Drench Yourself in Sweat], "+100% Init for 5 turns", 15);
	addSweatSkill($skill[Sweat Out Some Booze], "Cleanse 1 liver (" + sweatboozeleft
		+ " left today)", 25);
	addSweatSkill($skill[Make Sweat-Ade], "Does what the skill name says", 50);
	addSweatSkill($skill[Sweat Flick], "Deals sweat sleaze damage", 1);
	addSweatSkill($skill[Sweat Spray], "Deal minor sleaze damage for the rest of combat", 3);
	addSweatSkill($skill[Sweat Flood], "Stun for 5 rounds", 5);
	addSweatSkill($skill[Sweat Sip], "Restore 50 MP", 5);

	picker.addLoader("Sweating the small stuff...");
	picker.append('</table></div>');
	chitPickers['sweatpants'] = picker;
}

void pickerJurassicParka() {
	buffer picker;
	string currMode = get_property("parkaMode");
	int yellowTurns = have_effect($effect[Everything Looks Yellow]);
	int spikesLeft = 5 - get_property("_spikolodonSpikeUses").to_int();
	picker.pickerStart('jurassicparka', "Change Parka Mode");

	void addMode(string name, string desc, string image) {
		string switchLink = '<a class="change" href="' + sideCommand("parka " + name) + '">';
		boolean current = currMode == name;

		picker.append('<tr class="pickitem');
		if(current) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(image);
		picker.append('" /></td><td colspan="2">');
		if(!current) {
			picker.append(switchLink);
			picker.append('<b>Change</b> to ');
		}
		else {
			picker.append('<b>Current</b>: ');
		}
		picker.append(name);
		picker.append(' mode<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span>');
		if(!current) picker.append('</a>');
		picker.append('</td></tr>');
	}

	addMode("kachungasaur", "Max HP +100%, +50% Meat Drop, +2 Cold Res", "jparka8.gif");
	addMode("dilophosaur", "+20 All Sleaze Damage, +2 Stench Res, Free Kill Yellow Ray ("
		+ (yellowTurns > 0 ? (yellowTurns + " adv until usable") : "ready") + ")", "jparka3.gif");
	addMode("spikolodon", "+" + min(3 * my_level(), 33) + " ML, +2 Sleaze Res, "
		+ (spikesLeft > 0 ? spikesLeft.to_string() : "no") + " non-com forces left", "jparka2.gif");
	addMode("ghostasaurus", "10 DR, +50 Max MP, +2 Spooky Res", "jparka1.gif");
	addMode("pterodactyl", "+5% noncom, +50% init, +2 Hot Res", "jparka9.gif");

	picker.addLoader("Pulling dino tab...");
	picker.append('</table></div>');
	chitPickers['jurassicparka'] = picker;
}

int dangerLevel(item it, slot s);

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
		picker.addItemIcon(it, "Click for item description", dangerLevel(it, s), modify_image);
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
		case $item[Kremlin's Greatest Briefcase]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="place.php?whichplace=kgb">Examine the briefcase.</a></td></tr>');
			break;
		case $item[FantasyRealm G. E. M.]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="place.php?whichplace=realm_fantasy">Visit FantasyRealm.</a></td></tr>');
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="shop.php?whichshop=fantasyrealm">Spend Rubees.</a></td></tr>');
			break;
		case $item[PirateRealm eyepatch]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="place.php?whichplace=realm_pirate">Visit PirateRealm.</a></td></tr>');
			break;
		case $item[latte lovers member's mug]:
			int refills = 3 - get_property("_latteRefillsUsed").to_int();
			if(refills > 0) {
				start_option(in_slot, true);
				picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
					'href="main.php?latte=1">Get a refill.</a></td></tr>');
			}
			break;
		case $item[Greatest American Pants]:
			if(get_property("_gapBuffs").to_int() < 5) {
				pickerGAP();
				start_option(in_slot, false);
				picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickergap" href="#">');
				picker.append('Activate Super Power (');
				picker.append(5 - get_property("_gapBuffs").to_int());
				picker.append(' left)</a></td></tr>');
			}
			break;
		case $item[Kramco Sausage-o-Matic&trade;]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="inventory.php?action=grind"><b>Grind</b> (' + available_amount($item[magical sausage casing]).formatInt() + ' casings available):<br />');
			picker.append(get_property("sausageGrinderUnits").to_int().formatInt() + " / " + (111 * (1 + get_property("_sausagesMade").to_int())).formatInt() + " units.<br />");
			picker.append(get_property("_sausagesEaten").to_int().formatInt() + "/23 sausages eaten today.<br />");
			picker.append(get_property("_sausageFights").to_int().formatInt() + " goblins encountered today.");
			picker.append('</a></td></tr>');
			break;
		case $item[Fourth of May Cosplay Saber]:
			if(get_property("_saberMod") == "0") {
				pickerForceUpgrade();
				start_option(in_slot, true);
				picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickertheforce" href="#">Install daily upgrade</a></td></tr>');
			}
			break;
		case $item[Beach Comb]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="main.php?comb=1"><b>Comb</b> beach</a></td></tr>');
			break;
		case $item[Eight Days a Week Pill Keeper]:
			if(!get_property("_freePillKeeperUsed").to_boolean() || (spleen_limit() - my_spleen_use() >= 3)) {
				pickerPillKeeper();
				start_option(in_slot, false);
				picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerpillkeeper" href="#">Pop a pill!</a></td></tr>');
			}
			break;
		case $item[Powerful Glove]:
			int batteryUsed = get_property("_powerfulGloveBatteryPowerUsed").to_int();
			if(batteryUsed < 100) {
				pickerPowerfulGlove();
				start_option(in_slot, false);
				picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerpowerfulglove" href="#">Enter a cheat code!</a></td></tr>');
			}
			break;
		case $item[Guzzlr tablet]:
			start_option(in_slot, false);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="inventory.php?tap=guzzlr"><b>Tap</b> tablet</a></td></tr>');
			break;
		case $item[Cargo Cultist Shorts]:
			if(!get_property("_cargoPocketEmptied").to_boolean()) {
				start_option(in_slot, false);
				string [int] pocketsEmptied = get_property("cargoPocketsEmptied").split_string(",");
				int pocketsLeft = 666 - pocketsEmptied.count();
				picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
					'href="inventory.php?action=pocket"><b>Pick</b> pocket (');
				picker.append(pocketsLeft);
				picker.append(' left)</a></td></tr>');
			}
			break;
		case $item[unwrapped knock-off retro superhero cape]:
			pickerRetroSuperCapeMeta();
			pickerRetroSuperCapeAll();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerretrosupercapemeta" href="#">Change to optimal setups!</a></td></tr>');
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerretrosupercapeall" href="#">Change to any setup! (currently ' + retroSupercapeCurrentSetupName() + ')</a></td></tr>');
			break;
		case $item[backup camera]:
			pickerBackupCamera();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerbackupcamera" href="#"><b>Configure</b> your camera (currently ' + get_property("backupCameraMode") + ')</a></td></tr>');
			break;
		case $item[Daylight Shavings Helmet]:
			pickerFakeDaylightShavingsHelmet();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerfakebeard" href="#"><b>Check</b> upcoming beards</a></td></tr>');
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane href="account_facialhair.php"><b>Adjust</b> your facial hair</a></td></tr>');
			break;
		case $item[combat lover's locket]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane href="inventory.php?reminisce=1"><b>Reminisce</b> about past loves</a></td></tr>');
			break;
		case $item[unbreakable umbrella]:
			pickerUnbrella();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerunbrella" href="#"><b>Reconfigure</b> your umbrella</a></td></tr>');
			break;
		case $item[designer sweatpants]:
			pickerSweatpants();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" ');
			picker.append('rel="chit_pickersweatpants" href="#"><b>Use</b> some sweat</a>');
			picker.append('</td></tr>');
			break;
		case $item[Jurassic Parka]:
			pickerJurassicParka();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" ');
			picker.append('rel="chit_pickerjurassicparka" href="#"><b>Pick</b> parka mode</a>');
			picker.append('</td></tr>');
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
		picker.append(gearName(in_slot, s));
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
		int danger_level = dangerLevel(it, s);
		string cmd;
		string action = "";
		string action_description = "";
		string cmd_override = "";

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
		} else if(foldable_amount(it, reason, false) > 0) {
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
		} else if(foldable_amount(it, reason, true) > 0) {
			item to_fold;
			foreach foldable, i in get_related(it, "fold")
				if(storage_amount(foldable) > 0) {
					to_fold = foldable;
					break;
				}
			action = "pull & fold";
			danger_level = 2;
			action_description += '(' + pulls_remaining() + ' left)';
			cmd = "pull " + to_fold + "; fold " + it + "; equip ";
		} else if(it == $item[pantogram pants] && available_amount(it) == 0 && item_amount($item[portable pantogram]) > 0) {
			action = "conjure";
			cmd_override = '/inv_use.php?pwd=' + my_hash() + '&which=3&whichitem=9573" target="mainpane';
		} else // no options were found, give up
			return false;

		any_options = true;
		displayedItems[it] = true;

		string command = sideCommand(cmd + s + " " + it);
		if(cmd_override != "")
			command = cmd_override;

		switch(vars["chit.gear.layout"]) {
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
				b.addItemIcon(it,gearName(it, s) + '&#013;Left click to ' + action + ' ' + action_description + '&#013;Right click for description',danger_level);
			else
				b.addItemIcon(it,'&#013;Right click for description',danger_level);
			if(take_action)
				b.append('</a>');
			b.append('</span>');
			break;

		case "oldschool":
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
			b.append(gearName(it, s));
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
			break;

		default:
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
			b.append(gearName(it, s));
			if(take_action)
				b.append('</a>');
			b.append('</div></div>');
			break;
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

			switch(vars["chit.gear.layout"]) {
			case "oldschool":
				break;
			case "minimal":
				temp.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">');
				temp.append(name);
				temp.append('</td></tr><tr class="pickitem chit_pickerblock"><td colspan="3">');
				break;
			default:
				temp.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">');
				temp.append(name);
				temp.append('</td></tr><tr class="pickitem chit_pickerblock"><td colspan="3"><div class="chit_flexcontainer">');
				break;
			}

			sort toDisplay by -list[value];

			int shown = 0;
			string amountOption = name.get_option("amount");
			int toShow = (amountOption == "all") ? -1 : to_int(amountOption);

			foreach i,it in toDisplay {
				if(temp.add_gear_option(it, name)) {
					shown += 1;
					if(toShow > 0 && shown >= toShow)
						break;
				}
			}

			switch(vars["chit.gear.layout"]) {
			case "oldschool":
				break;
			case "minimal":
				temp.append('</td></tr>');
				break;
			default:
				temp.append('</div></td></tr>');
				break;
			}

			if(shown > 0)
				picker.append(temp.to_string());
		}
	}

	string disp_str = vars["chit.gear.display." + (aftercore ? "aftercore" : "in-run")];
	foreach i,section in split_string(disp_str,", *") {
		string [int] spl = split_string(section,":");
		string sectionname = spl[0];
		string [string] options;
		if(spl.count() > 1) {
			for i from 1 to (spl.count() - 1) {
				string [int] optspl = split_string(spl[i]," ?= ?");
				if(optspl.count() == 2)
					options[optspl[0]] = optspl[1];
			}
		}
		float [item] list = recommendedGear[sectionname];
		add_gear_section(sectionname, list);
		forceSections[sectionname] = false;
	}

	foreach section,stillforce in forceSections {
		if(stillforce)
			add_gear_section(section, recommendedGear[section]);
	}

	// Which gear is more desirable?
	int gear_weight(item it) {
		float weight;

		switch(item_type(it)) {
		case "chefstaff":
			weight = equip_modifier(it, "Spell Damage Percent");  // They all have 10 power, so this number is a surrogate
			break;
		case "accessory":
			# weight = get_power(it) + equip_modifier(it, "Item Drop", 6) + equip_modifier(it, "Monster Level", my_level() < 13? 4: 0)
				# + (equip_modifier(it, "MP Regen Max") + equip_modifier(it, "MP Regen Min")) * 5;
			weight = get_power(it) + equip_modifier(it, "Item Drop") * 6 + equip_modifier(it, "Monster Level") * (my_level() < 13? 4: 0)
				+ (equip_modifier(it, "MP Regen Max") + equip_modifier(it, "MP Regen Min")) * 5;
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
			weight += equip_modifier(it, "MP Regen Max") + equip_modifier(it, "MP Regen Min");
			weight += equip_modifier(it, "Muscle") * 2;
			weight += equip_modifier(it, "Muscle Percent") * my_basestat($stat[Muscle]) / 50;
			break;
		case $stat[Mysticality]:
			weight += (equip_modifier(it, "MP Regen Max") + equip_modifier(it, "MP Regen Min")) * 2;
			weight += equip_modifier(it, "Spell Damage") * 3;
			weight += equip_modifier(it, "Spell Damage Percent");
			break;
		case $stat[Moxie]:
			if(weapon_type(it) != $stat[Moxie] && !(have_skill($skill[Tricky Knifework]) && item_type(it) == "knife"))
				weight *= 0.5;
			weight += equip_modifier(it, "Moxie") * 3;
			weight += equip_modifier(it, "Moxie Percent") * my_basestat($stat[Moxie]) / 33.3;
			break;
		}

		return weight;
	}

	// Find some best gear to recommend
	void add_inventory_section() {
		item [int] avail;
		foreach it in get_inventory()
			if(be_good(it) && can_equip(it) && good_slot(s, it) && !have_equipped(it) && !(vars["chit.gear.layout"] == "default" && displayedItems contains it))
				avail[ count(avail) ] = it;

		if(count(avail) > 0) {
			sort avail by -gear_weight(value);

			switch(vars["chit.gear.layout"]) {
			case "oldschool":
				break;
			case "minimal":
				picker.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">best inventory</td></tr><tr class="pickitem chit_pickerblock"><td colspan="3">');
				break;
			default:
				picker.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">best inventory</td></tr>');
				picker.append('<tr class="pickitem chit_pickerblock"><td colspan="3"><div class="chit_flexcontainer">');
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
			case "oldschool":
				break;
			case "minimal":
				picker.append('</td></tr>');
				break;
			default:
				picker.append('</div></td></tr>');
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


// slot needed for weapons being used in off-hand
int dangerLevel(item it, slot s) {
	switch(it) {
		case $item[Mega Gem]:
			return (qprop("questL11Palindome") ? 2 : -1);
		case $item[Talisman o' Namsilat]:
			if(qprop("questL11Palindome") && !get_property("currentHardBountyItem").contains_text("bit of wilted lettuce"))
				return 1;
			break;
		case $item[UV-resistant compass]: case $item[ornate dowsing rod]:
			if(get_property("desertExploration").to_int() < 100) {
				if(my_location() != $location[The Arid, Extra-Dry Desert])
					return 1;
			} else
				return 2;
			break;
		case $item[sea chaps]: case $item[sea cowboy hat]:
			if(get_property("lassoTraining") == "expertly")
				return 1;
			break;
		case $item[backup camera]:
			if(!get_property("backupCameraReverserEnabled").to_boolean()) {
				return 2;
			}
			break;
	}
	// latte reminder
	if(s == $slot[off-hand] && vars["chit.gear.lattereminder"].to_boolean() && my_location().latteDropAvailable()) {
		if(it != $item[latte lovers member's mug] && !it.isImportantOffhand())
			return 1;
	}

	// pirate hat reminder
	if(s == $slot[hat] && item_amount($item[PirateRealm party hat]) > 0 && equipped_amount($item[PirateRealm party hat]) == 0 && equipped_amount($item[PirateRealm eyepatch]) > 0) {
		if(it != $item[PirateRealm party hat])
			return 1;
	}
	item rlf = $item[Red Roger's red left foot];
	item rrf = $item[Red Roger's red right foot];
	// pirate foot reminder
	if($slots[acc1, acc2, acc3] contains s && item_amount(rlf) > 0 && item_amount(rrf) > 0 && equipped_amount(rlf) + equipped_amount(rrf) == 0 && equipped_amount($item[PirateRealm eyepatch]) > 0)
	{
		if(!($items[PirateRealm eyepatch, Red Roger's red left foot, Red Roger's red right foot] contains it))
			return 1;
	}
	return 0;
}

// Part of gear block that can be included in stats for a smaller footprint
void addGear(buffer result) {
	addFavGear();
	void addSlot(slot s) {
		string badSlot(string reason) {
			return '<span><img class="chit_icon" src="/images/itemimages/antianti.gif" title="' + reason + '"></span>';
		}

		switch(s) {
		case $slot[hat]:
			if(my_path().name == "You, Robot" && get_property("youRobotTop") != "4") {
				result.append(badSlot("Need Mannequin Head"));
				return;
			}
			break;
		case $slot[shirt]:
			if(!have_skill($skill[Torso Awareness]) && !have_skill($skill[Best Dressed])) {
				result.append(badSlot("Torso Unawareness"));
				return;
			}
			break;
		case $slot[weapon]:
			if(my_path().name == "You, Robot" && get_property("youRobotLeft") != "4") {
				result.append(badSlot("Need Vice Grips"));
				return;
			}
			break;
		case $slot[off-hand]:
			if(weapon_hands(equipped_item($slot[weapon])) > 1) {
				result.append('<span><a class="chit_launcher" rel="chit_pickergearoff-hand" href="#"><img class="chit_icon" src="/images/itemimages/antianti.gif" title="Not enough hands"></a></span>');
				pickerGear(s);
				return;
			}
			else if(my_path().name == "You, Robot" && get_property("youRobotRight") != "4") {
				result.append(badSlot("Need Omni-Claw"));
				return;
			}
			break;
		case $slot[pants]:
			if(my_path().name == "You, Robot" && get_property("youRobotBottom") != "4") {
				result.append(badSlot("Need Robo-Legs"));
				return;
			}
			break;
		}
		result.append('<span><a class="chit_launcher" rel="chit_pickergear');
		result.append(s);
		result.append('" href="#">');
		result.addItemIcon(equipped_item(s), s + ": " + gearName(equipped_item(s), s), dangerLevel(equipped_item(s), s));
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
	result.append('<tr><th class="label"><img  class="chit_walls_stretch" src="');
	result.append(imagePath);
	result.append('equipment.png">');
	result.append('<a class="visit" target="mainpane" href="./inventory.php?which=2">Gear</a></th></tr>');

	result.addGear();

	result.append('</tbody></table>');

	chitBricks["gear"] = result.to_string();
	chitTools["gear"] = "Gear|equipment.png";
}

