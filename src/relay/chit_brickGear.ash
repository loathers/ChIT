// The original version of the Gear Brick (including pickerGear and bakeGear) was written by soolar

boolean [item] favGear;
boolean [item] favGearWeirdFam;
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
	foreach favType in $strings[favorites, favorites.weirdFam] {
		string favVarName = "chit.gear." + favType;
		foreach i,fav in split_string(vars[favVarName], "\\s*(?<!\\\\)[,|]\\s*") {
			item it = to_item(fav.replace_string("\\,", ","));
			(favType == 'favorites.weirdFam' ? favGearWeirdFam : favGear)[it] = true;
			addGear(it, favType);
		}
	}
}

int dangerLevel(item it, slot s);

void pickerGear(slot s) {
	item in_slot = equipped_item(s);
	chit_info info = getItemInfo(in_slot);
	boolean take_action = true; // This is un-set if there's a reason to do nothing (such as not enough hands)
	boolean weirdFamMode = false;
	slot famSlot = $slot[none];
	if(s == $slot[familiar]) {
		chit_info famInfo = getFamiliarInfo(my_familiar());
		foreach i,extra in famInfo.extra {
			if(extra.extraType == EXTRA_EQUIPFAM) {
				famSlot = to_slot(extra.str1);
				if(extra.str2.to_boolean())
					weirdFamMode = true;
			}
		}
	}

	buffer picker;
	picker.pickerStart("gear" + s, "Change " + s + (s == $slot[familiar] ? " gear" : ""));

	boolean good_slot(slot checked_slot, item it) {
		if(to_slot(it) == checked_slot) return true;
		if(s == $slot[familiar]) {
			if(famSlot != $slot[none] && famSlot == to_slot(it))
				return true;
		}
		switch(checked_slot) {
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
	void start_option(item it) {
		# any_options = true;
		picker.append('<tr class="pickitem"><td class="icon">');
		picker.addItemIcon(it, '', false, DANGER_GOOD, 'a', attrmap {
			'class': 'done',
			'href': '#',
			'oncontextmenu': 'descitem(' + it.descid + ',0,event); return false;',
			'onclick': 'descitem(' + it.descid + '0,event); return false;',
		}, weirdFamMode);
		picker.append('</td>');
	}

	foreach i, extra in info.extra {
		string descid = in_slot.descid;
		string image = extra.image;
		item foldFrom = $item[none];
		if(extra.extraType == EXTRA_FOLD) {
			foreach it in get_related(in_slot, 'fold') {
				if(it != in_slot) {
					foldFrom = it;
					break;
				}
			}
			descid = foldFrom.descid;
			if(image == '') {
				image = itemimage(foldFrom.image);
			}
		}
		if(image == '') {
			image = itemimage(in_slot.image);
		}
		picker.tagStart('tr', attrmap { 'class': 'pickitem' });
		picker.tagStart('td', attrmap { 'class': 'icon' });
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
		picker.tagStart('a', attrmap {
			'onclick': 'descitem(' + descid + ',0,event); return false;',
			'href': '#',
		});
		picker.addImg(image, attrmap {
			'class': imgClass,
			'title': 'Click for item description',
		});
		picker.tagFinish('a');
		picker.tagFinish('td');
		picker.tagStart('td', attrmap { 'colspan': '2' });
		if(extra.extraType == EXTRA_PICKER) {
			string pickerFunc = 'picker_' + extra.str1;
			call void pickerFunc();
			picker.tagStart('a', attrmap {
				'class': 'chit_launcher done',
				'rel': 'chit_picker' + extra.str1,
				'href': '#',
			});
			picker.append(extra.str2);
			picker.tagFinish('a');
		}
		else if(extra.extraType == EXTRA_FOLD) {
			picker.tagStart('a', attrmap {
				'class': 'change',
				'href': sideCommand('fold ' + foldFrom.to_string()),
			});
			picker.append(extra.str1);
			picker.tagFinish('a');
		}
		else if(extra.extraType == EXTRA_LINK) {
			picker.tagStart('a', extra.attrs);
			picker.append(extra.str1);
			if(extra.str2 != '') {
				picker.tagSelfClosing('br');
				picker.tagStart('span', attrmap { 'class': 'descline' });
				picker.append(extra.str2);
				picker.tagFinish('span');
			}
			picker.tagFinish('a');
		}
		picker.tagFinish('td');
		picker.tagFinish('tr');
	}

	// give configurable gear some love if it's in slot
	item fold_from(item original) {
		foreach it in get_related(in_slot, "fold")
			if(it != in_slot)
				return it;
		return $item[none];
	}

	void add_favorite_button(buffer result, item it) {
		result.append('<a class="change chit_favbutton" href="');
		if((weirdFamMode ? favGearWeirdFam : favGear) contains it) {
			result.append(sideCommand("chit_changeFav.ash (remove, " + it + ", "
				+ (weirdFamMode ? "weirdFam" : "") + ")"));
			result.append('" rel="delfav"><img src="');
			result.append(imagePath);
			result.append('control_remove_red.png"></a>');
		} else {
			result.append(sideCommand("chit_changeFav.ash (add, " + it + ", "
				+ (weirdFamMode ? "weirdFam" : "") + ")"));
			result.append('" rel="addfav"><img src="');
			result.append(imagePath);
			result.append('control_add_blue.png"></a>');
		}
	}

	// option to unequip current item, or blurb about the slot being empty
	if(in_slot != $item[none]) {
		buffer favButton;
		favButton.add_favorite_button(in_slot);
		picker.pickerItemOption(in_slot, 'unequip', info.name, info.desc, '',
			sideCommand('unequip ' + s), true, favButton);
	} else {
		picker.append('<tr class="pickitem"><td colspan="3">');
		if(s == $slot[off-hand] && weapon_hands(equipped_item($slot[weapon])) > 1) {
			picker.append("You can't equip an off-hand item with a ");
			picker.append(weapon_hands(equipped_item($slot[weapon])));
			picker.append("-handed weapon equipped!");
			take_action = false;
		} else if(s == $slot[hat] && my_path() == $path[Hat Trick]) {
			picker.append("You have ");
			int hat_count = 0;
			foreach it in $items[] {
				if(it.to_slot() == $slot[hat]) {
					hat_count += equipped_amount(it);
				}
			}
			picker.append(hat_count);
			picker.append(" hat");
			if(hat_count != 1) {
				picker.append("s");
			}
			picker.append(" equipped, but I ain't showin' all'at, sorry.");
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
		chit_info optionInfo = getItemInfo(it);
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
			b.tagStart('div', attrmap {
				'class': 'chit_flexitem',
				'style': 'order:' + danger_level + ';',
			});
			b.addItemIcon(it, action + ' ' + action_description + ' ', false, danger_level, 'a', attrmap {
				'oncontextmenu': 'descitem(' + it.descid + ',0,event); return false;',
				'href': command,
				'class': 'change',
			}, weirdFamMode);
			b.tagFinish('div');
			break;

		case "oldschool":
			b.append('<tr class="pickitem"><td class="icon">');
			b.addItemIcon(it, '', false, DANGER_GOOD, 'a', attrmap {
				'oncontextmenu': 'descitem(' + it.descid + ',0,event); return false;',
				'onclick': 'descitem(' + it.descid + ',0,event); return false;',
				'href': '#',
			}, weirdFamMode);
			b.append('</td><td>');
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
			b.append(namedesc(optionInfo));
			if(!reason.starts_with("favorites")) {
				b.append(' [');
				b.append(reason);
				b.append(']');
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
			b.append(';"><div>');

			b.addItemIcon(it, '', false, DANGER_GOOD, 'a', attrmap {
				'oncontextmenu': 'descitem(' + it.descid + ',0,event); return false;',
				'onclick': 'descitem(' + it.descid + ',0,event); return false',
				'href': '#',
			}, weirdFamMode);
			b.append('</div><div style="max-width:160px;">');
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
			b.append(namedesc(optionInfo));
			if(take_action)
				b.append('</a>');
			b.append('</div></div>');
			break;
		}

		return true;
	}

	void add_gear_section(string name, float [item] list) {
		if(weirdFamMode && name != 'favorites.weirdFam')
			return;
		string dispName = name.split_string('\\.')[0];
		item [int] toDisplay;
		foreach it in list
			if(it != $item[none] && good_slot(s, it) && in_slot != it
				&& (my_path() != $path[Hat Trick] || s != $slot[hat] || equipped_amount(it) == 0)
				&& !(vars["chit.gear.layout"] == "default" && displayedItems contains it))
					toDisplay[ count(toDisplay) ] = it;

		if(count(toDisplay) > 0) {
			buffer temp;

			switch(vars["chit.gear.layout"]) {
			case "oldschool":
				break;
			default:
				temp.append('<tr class="pickitem" style="background-color:blue;color:white;font-weight:bold;"><td colspan="3">');
				temp.append(dispName);
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
		if(sectionname == 'favorites' && weirdFamMode) {
			sectionname += '.weirdFam';
		}
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

			// For minimal, space isn't an issue so show ten. Otherwise If there are recommended options, show only 5 additional items
			int amount = vars["chit.gear.layout"] == "minimal"? 9
				: any_options? 4: 9;
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

	if(!weirdFamMode)
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
		result.append('<span>');
		result.addItemIcon(equipped_item(s), s + ": ", false, DANGER_GOOD, 'a', attrmap {
			'class': 'chit_launcher',
			'rel': 'chit_pickergear' + s,
			'href': '#',
		});
		result.append('</span>');
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

