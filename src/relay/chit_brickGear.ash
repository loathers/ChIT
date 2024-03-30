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


// done
string gearName(item it, slot s) {
	string name = to_string(it);
	string notes = "";

	switch(it) {
		case $item[V for Vivala mask]:
		case $item[replica V for Vivala mask]:
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
		case $item[replica navel ring of navel gazing]:
			name = (it == $item[replica navel ring of navel gazing]) ? "replica navel ring" : "navel ring";
			// no break intentionally
		case $item[Greatest American Pants]:
		case $item[replica Greatest American Pants]:
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
		case $item[replica Powerful Glove]:
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
		case $item[replica Cargo Cultist Shorts]:
			boolean pocketEmptied = get_property("_cargoPocketEmptied").to_boolean();
			if(!pocketEmptied)
				notes = "pocket pickable";
			break;
		case $item[backup camera]:
			// 5 extra uses in You, Robot
			int backupsLeft = (my_path().id == 41 ? 16 : 11) - get_property("_backUpUses").to_int();
			string backupMonster = get_property("lastCopyableMonster");
			notes = backupsLeft + " backups left: " + (backupMonster == "" ? "nothing yet" : backupMonster);
			if(!get_property("backupCameraReverserEnabled").to_boolean()) {
				notes += ", REVERSER NOT ENABLED!";
			}
			break;
		case $item[familiar scrapbook]:
			notes = get_property("scrapbookCharges") + " scraps";
			break;
		case $item[industrial fire extinguisher]:
		case $item[replica industrial fire extinguisher]:
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
		case $item[replica designer sweatpants]:
			int sweat = max(min(100, get_property("sweat").to_int()), 0);
			int sweatboozeleft = 3 - get_property("_sweatOutSomeBoozeUsed").to_int();
			notes += sweat + "% sweaty";
			if(sweatboozeleft > 0) {
				notes += ", " + sweatboozeleft + " booze sweats";
			}
			break;
		case $item[Jurassic Parka]:
		case $item[replica Jurassic Parka]:
			string parkaMode = get_property("parkaMode");
			if(parkaMode.length() > 0) {
				notes += parkaMode + " mode";
			}
			break;
		case $item[cursed monkey's paw]:
			int wishesUsed = get_property("_monkeyPawWishesUsed").to_int();
			if(wishesUsed >=0 && wishesUsed < 5) {
				notes += (5 - wishesUsed) + " wishes left";
			}
			else if(wishesUsed >= 5) {
				notes += "no wishes left";
			}
			break;
		case $item[Cincho de Mayo]:
		case $item[replica Cincho de Mayo]:
			int cinch = 100 - get_property("_cinchUsed").to_int();
			notes += (cinch > 0 ? cinch.to_string() : "no") + " cinch";
			break;
		case $item[august scepter]:
		case $item[replica august scepter]:
			int augSkillsCast = get_property("_augSkillsCast").to_int();
			int augSkillsCastable = 5;
			if(can_interact()) {
				++augSkillsCastable;
				if(get_property("_augTodayCast").to_boolean()) {
					++augSkillsCast;
				}
			}
			notes += augSkillsCast + "/" + augSkillsCastable + " used";
			break;
		case $item[carnivorous potted plant]:
			int plantFreeKills = get_property("_carnivorousPottedPlantWins").to_int();
			notes = plantFreeKills + " free kills [" +  (1.0 / (20.0 + plantFreeKills) * 100) + "% swallow chance]";
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
		record modifier_value {
			float multiplier;
			string mod;
		};
		record gear_category {
			float [item] list;
			string name;
			modifier_value [int] modifiers;
			string [string, int] attributes;
		};
		gear_category [int] catList;
		gear_category newCategory(string name, string mods, string attrs) {
			gear_category cat;
			cat.name = name;
			foreach i,mod in mods.split_string(" *, *") {
				string [int] split = mod.split_string(" *\\* *");
				modifier_value curr;
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

void pickerCincho() {
	int cinch = 100 - get_property("_cinchUsed").to_int();

	buffer picker;
	picker.pickerStart('cincho', "Use some cinch (" + cinch + " available)");

	void addSkill(skill sk, string imageSuffix, string desc, int cinchCost) {
		boolean canUse = cinch >= cinchCost && !sk.combat;

		picker.append('<tr class="pickitem');
		if(!canUse) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/cincho');
		picker.append(imageSuffix);
		picker.append('.gif" /></td><td colspan="2">');
		if(canUse) {
			picker.append('<a class="change" href="');
			picker.append(sideCommand("cast " + sk.to_string()));
			picker.append('"><b>Cincho:</b> ');
		}
		else {
			picker.append('Cincho: ');
		}
		picker.append(sk.to_string().substring(8));
		picker.append(' (');
		picker.append(cinchCost);
		picker.append(' cinch)<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span>');
		if(canUse) picker.append('</a>');
		picker.append('</td></tr>');
	}

	addSkill($skill[Cincho: Confetti Extravaganza], "confetti", "Double substats from this fight, but get smacked", 5);
	addSkill($skill[Cincho: Dispense Salt and Lime], "lime", "Triples stat gain from next drink", 25);
	addSkill($skill[Cincho: Fiesta Exit], "exit", "Force a noncom", 60);
	addSkill($skill[Cincho: Party Foul], "swear", "Damage, weaken, and stun", 5);
	addSkill($skill[Cincho: Party Soundtrack], "music", "30 adv +5lbs", 25);
	addSkill($skill[Cincho: Projectile Piñata], "candy", "Damage, stun, get candy", 5);

	picker.pickerFinish("Using Cinch...");
}

void pickerAugust() {
	int used = get_property("_augSkillsCast").to_int();
	int usable = 5;
	int today = today_to_string().to_int() % 100;
	if(can_interact()) {
		++usable;
		if(get_property("_augTodayCast").to_boolean()) {
			++used;
		}
	}

	buffer picker;
	picker.pickerStart('august', "Celebrate some holidays (" + used + "/" + usable + " used)");

	void addSkill(skill sk, int num, string desc) {
		boolean canUse = !get_property("_aug" + num + "Cast").to_boolean();
		picker.append('<tr class="pickitem');
		if(!canUse) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(sk.image);
		picker.append('" /></td><td colspan="2">');
		if(canUse) {
			picker.append('<a class="change" target=mainpane href="runskillz.php?action=Skillz&whichskill=');
			picker.append(sk.to_int());
			picker.append('&pwd=');
			picker.append(my_hash());
			picker.append('"><b>Celebrate</b> ');
		}
		picker.append(sk.name);
		if(can_interact() && num == today) {
			picker.append(' (free today)');
		}
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span>');
		if(canUse) {
			picker.append('</a>');
		}
		picker.append('</td></tr>');
	}

	addSkill($skill[Aug. 1st: Mountain Climbing Day!], 1, "30 adv effect that gives bonuses in mountains.");
	addSkill($skill[Aug. 2nd: Find an Eleven-Leaf Clover Day], 2, "Become Lucky!");
	addSkill($skill[Aug. 3rd: Watermelon Day!], 3, "Acquire 1 watermelon (big food that gives seeds).");
	addSkill($skill[Aug. 4th: Water Balloon Day!], 4, "Acquire 3 water balloons (usable for effect/trophy).");
	addSkill($skill[Aug. 5th: Oyster Day!], 5, "Acquire 3 random oyster eggs.");
	addSkill($skill[Aug. 6th: Fresh Breath Day!], 6, "30 adv effect +moxie +combat.");
	addSkill($skill[Aug. 7th: Lighthouse Day!], 7, "30 adv effect +item +meat.");
	addSkill($skill[Aug. 8th: Cat Day!], 8, "Free fight a random cat.");
	addSkill($skill[Aug. 9th: Hand Holding Day!], 9, "1 use of a minor olfaction.");
	addSkill($skill[Aug. 10th: World Lion Day!], 10, "30 adv effect that lets you banish for its duration.");
	addSkill($skill[Aug. 11th: Presidential Joke Day!], 11, "50 x level mys substats.");
	addSkill($skill[Aug. 12th: Elephant Day!], 12, "50 x level mus substats.");
	addSkill($skill[Aug. 13th: Left/Off Hander's Day!], 13, "30 adv effect doubling power of off-hands.");
	addSkill($skill[Aug. 14th: Financial Awareness \ Day!], 14, "Pay 100 x level meat for 150 x level meat.");
	addSkill($skill[Aug. 15th: Relaxation Day!], 15, "Restore hp/mp, get booze ingredients.");
	addSkill($skill[Aug. 16th: Roller Coaster Day!], 16, "-1 fullness, 30 adv effect of +food drops.");
	addSkill($skill[Aug. 17th: Thriftshop Day!], 17, "Coupon for 1 item 1000 meat or less.");
	addSkill($skill[Aug. 18th: Serendipity Day!], 18, "30 adv effect of getting random stuff.");
	addSkill($skill[Aug. 19th: Honey Bee Awareness Day!], 19, "30 adv effect of sometimes fighting bees.");
	addSkill($skill[Aug. 20th: Mosquito Day!], 20, "30 adv effect of hp regen.");
	addSkill($skill[Aug. 21st: Spumoni Day!], 21, "20 x level all substats.");
	addSkill($skill[Aug. 22nd: Tooth Fairy Day!], 22, "Free fight a tooth golem.");
	addSkill($skill[Aug. 23rd: Ride the Wind Day!], 23, "50 x level mox substats.");
	addSkill($skill[Aug. 24th: Waffle Day!], 24, "Acquire 3 waffles (food/monster swap combat item).");
	addSkill($skill[Aug. 25th: Banana Split Day!], 25, "Acquire 1 banana spit (food that gives banana).");
	addSkill($skill[Aug. 26th: Toilet Paper Day!], 26, "Acquire 1 handful of toilet paper (removes a negative effect).");
	addSkill($skill[Aug. 27th: Just Because Day!], 27, "20 adv of 3 random good effects.");
	addSkill($skill[Aug. 28th: Race Your Mouse Day!], 28, "Acquire melting fam equip based on current fam.");
	addSkill($skill[Aug. 29th: More Herbs, Less Salt \ Day!], 29, "Acquire 3 bottles of Mrs. Rush (boosts substats from food).");
	addSkill($skill[Aug. 30th: Beach Day!], 30, "Acquire 1 baywatch (melting +7adv/+2fites/-2mp cost acc).");
	addSkill($skill[Aug. 31st: Cabernet Sauvignon \ Day!], 31, "Acquire 2 bottles of Cabernet Sauvignon (booze that helps find booze).");

	picker.pickerFinish("Celebrating a holiday...");
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
			picker_edpiece();
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
		case $item[replica over-the-shoulder Folder Holder]:
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
				picker_gap();
				start_option(in_slot, false);
				picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickergap" href="#">');
				picker.append('Activate Super Power (');
				picker.append(5 - get_property("_gapBuffs").to_int());
				picker.append(' left)</a></td></tr>');
			}
			break;
		case $item[Kramco Sausage-o-Matic&trade;]:
		case $item[replica Kramco Sausage-o-Matic&trade;]:
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="visit done" target=mainpane ' +
				'href="inventory.php?action=grind"><b>Grind</b> (' + available_amount($item[magical sausage casing]).formatInt() + ' casings available):<br />');
			picker.append(get_property("sausageGrinderUnits").to_int().formatInt() + " / " + (111 * (1 + get_property("_sausagesMade").to_int())).formatInt() + " units.<br />");
			picker.append(get_property("_sausagesEaten").to_int().formatInt() + "/23 sausages eaten today.<br />");
			picker.append(get_property("_sausageFights").to_int().formatInt() + " goblins encountered today.");
			picker.append('</a></td></tr>');
			break;
		case $item[Fourth of May Cosplay Saber]:
		case $item[replica Fourth of May Cosplay Saber]:
			if(get_property("_saberMod") == "0") {
				picker_theforce();
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
				picker_pillkeeper();
				start_option(in_slot, false);
				picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerpillkeeper" href="#">Pop a pill!</a></td></tr>');
			}
			break;
		case $item[Powerful Glove]:
		case $item[replica Powerful Glove]:
			int batteryUsed = get_property("_powerfulGloveBatteryPowerUsed").to_int();
			if(batteryUsed < 100) {
				picker_powerfulglove();
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
		case $item[replica Cargo Cultist Shorts]:
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
			picker_retrosupercapemeta();
			picker_retrosupercapeall();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerretrosupercapemeta" href="#">Change to optimal setups!</a></td></tr>');
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerretrosupercapeall" href="#">Change to any setup! (currently ' + retroSupercapeCurrentSetupName() + ')</a></td></tr>');
			break;
		case $item[backup camera]:
			picker_backupcamera();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerbackupcamera" href="#"><b>Configure</b> your camera (currently ' + get_property("backupCameraMode") + ')</a></td></tr>');
			break;
		case $item[Daylight Shavings Helmet]:
			picker_fakebeard();
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
			picker_unbrella();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" rel="chit_pickerunbrella" href="#"><b>Reconfigure</b> your umbrella</a></td></tr>');
			break;
		case $item[designer sweatpants]:
		case $item[replica designer sweatpants]:
			picker_sweatpants();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" ');
			picker.append('rel="chit_pickersweatpants" href="#"><b>Use</b> some sweat</a>');
			picker.append('</td></tr>');
			break;
		case $item[Jurassic Parka]:
		case $item[replica Jurassic Parka]:
			picker_jurassicparka();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" ');
			picker.append('rel="chit_pickerjurassicparka" href="#"><b>Pick</b> parka mode</a>');
			picker.append('</td></tr>');
			break;
		case $item[cursed monkey's paw]:
			int wishesUsed = get_property("_monkeyPawWishesUsed").to_int();
			if(wishesUsed >= 0 && wishesUsed < 5) {
				skill currSkill = monkeyPawSkill(wishesUsed);
				skill nextSkill = monkeyPawSkill(wishesUsed + 1);
				start_option(in_slot, true);
				picker.append('<td colspan="2"><a class="visit done" target=mainpane href="main.php?pwd=');
				picker.append(my_hash());
				picker.append('&action=cmonk"><b>Wish</b> for an item or effect<br /><span class="descline">Current skill: ');
				picker.append(currSkill);
				picker.append(' (');
				picker.append(monkeyPawSkillDesc(currSkill));
				picker.append(')<br />Next skill: ');
				picker.append(nextSkill);
				picker.append(' (');
				picker.append(monkeyPawSkillDesc(nextSkill));
				picker.append(')</a></td></tr>');
			}
			break;
		case $item[Cincho de Mayo]:
		case $item[replica Cincho de Mayo]:
			int restsTaken = get_property("_cinchoRests").to_int();
			int cinchToGain = min(30, max(5, 30 - 5 * (restsTaken - 4)));
			int freeRestsLeft = total_free_rests() - get_property("timesRested").to_int();
			pickerCincho();
			start_option(in_slot, true);
			picker.append('<td colspan="2"><a class="chit_launcher done" ');
			picker.append('rel="chit_pickercincho" href="#"><b>Use</b> some cinch<br /><span class="descline">');
			picker.append(get_property("_cinchoRests"));
			picker.append(' rests taken, will gain ');
			picker.append(cinchToGain);
			picker.append(', ');
			picker.append(freeRestsLeft > 0 ? freeRestsLeft.to_string() : 'no');
			picker.append(' free rests left</span></a>');
			picker.append('</td></tr>');
			break;
		case $item[august scepter]:
		case $item[replica august scepter]:
			int augUsed = get_property("_augSkillsCast").to_int();
			int augUsable = 5;
			if(can_interact()) {
				++augUsable;
				if(get_property("_augTodayCast").to_boolean()) {
					++augUsed;
				}
			}
			if(augUsed >= augUsable) {
				break;
			}
			pickerAugust();
			start_option(in_slot, true);
			int todayNum = today_to_string().to_int() % 100;
			picker.append('<td colspan="2"><a class="chit_launcher done" ');
			picker.append('rel="chit_pickeraugust" href="#"><b>Celebrate</b> some holidays');
			string [int] descStuff;
			int [int] usedToday;
			for(int i = 1; i <= 31; ++i) {
				if(get_property("_aug" + i + "Cast").to_boolean()) {
					usedToday[usedToday.count()] = i;
				}
			}
			if(usedToday.count() > 0) {
				buffer usedTodayStr;
				usedTodayStr.append('Used today: ');
				for(int i = 0; i < usedToday.count(); ++i) {
					if(i != 0) {
						usedTodayStr.append(", ");
					}
					usedTodayStr.append(usedToday[i]);
					if(usedToday[i] == todayNum) {
						usedTodayStr.append(" (free)");
					}
				}
				descStuff[descStuff.count()] = usedTodayStr.to_string();
			}
			if(can_interact() && !get_property("_augTodayCast").to_boolean()) {
				descStuff[descStuff.count()] = todayNum + " free today";
			}
			if(descStuff.count() > 0) {
				picker.append('<br /><span class="descline">');
				for(int i = 0; i < descStuff.count(); ++i) {
					if(i != 0) {
						picker.append(', ');
					}
					picker.append(descStuff[i]);
				}
				picker.append('</span>');
			}
			picker.append('</a></td></tr>');
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
		picker.addSadFace("You have nothing " + (equipped_item(s) == $item[none]? "": "else ") + "available. Poor you :(");

	picker.addLoader("Adding to favorites...", "addfav");
	picker.addLoader("Removing from favorites...", "delfav");
	picker.pickerFinish("Changing " + s + "...");
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

