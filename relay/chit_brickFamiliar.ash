// The familiar picker was the invention of soolar.

void pickerFamiliarGear(familiar myfam, item famitem, boolean isFed) {

	int [item] allmystuff = get_inventory();
	string [item] addeditems;
	buffer picker;

	// All generic Familiar Equipment, including Mr. Store Foldables and summonables
	static {
		item [int] generic;
		foreach it in $items[]
			if(it.item_type() == "familiar equipment" && string_modifier(it, "Modifiers").contains_text("Generic")) {
				if(count(get_related(it, "fold")) > 0)
					generic[ count(generic) + 1000 ] = it; 	// Separate foldables from the rest for later reference
				else
					generic[ count(generic) ] = it;
			}
	}
	
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
		case $item[kill screen]:
			return "More randomness!";
		case $item[orange boxing gloves]:case $item[blue pumps]:
			return "Find more yellow pixels";
		case $item[filthy child leash]:
			return "Passive stench damage";
		}
		
		if(famitem != $item[none]) {
			string mod = parseMods(string_modifier(famitem,"Evaluated Modifiers"));
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

	boolean [item] hiddengear;
	foreach i,famequip in split_string(vars["chit.familiar.hiddengear"], "\\s*(?<!\\\\),\\s*")
		hiddengear[to_item(famequip)] = true;
	
	void addEquipment(item it, string cmd) {
		if (!(addeditems contains it) && (!(hiddengear contains it) || equipped_amount(it) > 0)) {
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
					hover = "Equip Clancy with his " + it.to_string();
					cli = "use "+it;
					break;
				default:	
					hover = "Equip " + it.to_string();
					cli = "equip familiar "+it;
			}
			picker.append('<tr class="pickitem"><td class="');
			picker.append(cmd);
			picker.append('"><a class="change" href="');
			picker.append(sideCommand(cli));
			picker.append('" title="');
			picker.append(hover);
			picker.append('">');
			picker.append(fam_equip(action, it));
			picker.append('</a></td><td class="icon"><a class="change" oncontextmenu="descitem(');
			picker.append(it.descid);
			picker.append(',0,event); return false;" href="');
			picker.append(sideCommand(cli));
			picker.append('" title="');
			picker.append(hover);
			picker.append('&#013;Right click for description"><img src="/images/itemimages/');
			picker.append(it.image);
			picker.append('"></a></td></tr>');
			addeditems[it] = to_string(it);
		}
	}

	string sadMessage(string it, string fam) {
		string famname = my_path() == "Avatar of Boris"? "Clancy": myfam.name;
		return "You don't have any "+it+" for your " + fam + ".<br><br>Poor "+famname;
	}
	
	void pickerSnowsuit() {
		buffer picker;
		picker.pickerStart("snowsuit", "Tailor the Snow Suit");
		
		string current = get_property("snowsuit");
		
		void addFace(buffer buf, string face, string desc1, string desc2, string icon, boolean drops) {
			string faceLink = '<a class="change" href="' + sideCommand("snowsuit " + face) + '">';
			
			picker.append('<tr class="pickitem');
			if(face == current) picker.append(' currentitem');
			picker.append('"><td class="icon">');
			if(face != current) picker.append(faceLink);
			picker.append('<img class="chit_icon');
			if(drops) picker.append(' hasdrops');
			picker.append('" src="/images/itemimages/');
			picker.append(icon);
			picker.append('.gif" title="');
			if(face == current) picker.append('Current: ');
			else picker.append('Add ');
			picker.append(desc1);
			picker.append(' ');
			picker.append(desc2);
			picker.append('" />');
			if(face != current) picker.append('</a>');
			picker.append('</td><td colspan="2">');
			if(face != current) {
				picker.append(faceLink);
				picker.append('<b>Switch</b> to ');
			}
			else picker.append('<b>Current</b>: ');
			picker.append(desc1);
			picker.append('<br /><span class="descline">');
			picker.append(desc2);
			picker.append('</span>');
			if(face != current) picker.append('</a>');
			picker.append('</td></tr>');
		}
		
		picker.addFace("eyebrows", "Angry Eyebrows", "(Familiar does physical damage)", "snowface1", false);
		picker.addFace("smirk", "an Ice-Cold Smirk", "(Familiar does cold damage)", "snowface2", false);
		picker.addFace("nose", "a Sensitive Carrot Nose", "(+10% item drops, can drop carrot nose)", "snowface3", to_int(get_property("_carrotNoseDrops")) < 3);
		picker.addFace("goatee", "an Entertaining Goatee", "(Heals 1-20 HP after combat)", "snowface4", false);
		picker.addFace("hat", "a Magical Hat", "(Restores 1-10 MP after combat)", "snowface5", false);
		
		picker.addLoader("Rearranging your familiar's face!");
		picker.append('</table></div>');
		chitPickers["snowsuit"] = picker;
	}
	
	void pickEquipment() {

		// First add a decorate link if you are using a Snow Suit
		if(equipped_item($slot[familiar]) == $item[Snow Suit]) {
			pickerSnowsuit();
			string suiturl = '<a class="chit_launcher done" rel="chit_pickersnowsuit" href="#" title="Decorate your Snow Suit\'s face">';
			int faceIndex = index_of(chitSource["familiar"], "itemimages/snow");
			string face = substring(chitSource["familiar"], faceIndex + 11, faceIndex + 24);
			if(have_effect($effect[SOME PIGS]) > 0)
				face = "snowsuit.gif";
			picker.append('<tr class="pickitem"><td class="fold">');
			picker.append(suiturl);
			picker.append('Decorate Snow Suit<br /><span class="descline">Choose a Face</span></a></td><td class="icon">');
			picker.append(suiturl);
			picker.append('<img src="/images/itemimages/');
			picker.append(face);
			picker.append('"></a></td></tr>');
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
		if(havecommon) {
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
			} else if (n > 999) {
				foreach foldable in get_related(piece, "fold") {
					if (available_amount(foldable) > 0 ) {
						addEquipment(piece, "fold");
						break;
					}
				}
			}
		}
		if(my_familiar() == $familiar[Trick-or-Treating Tot])
			foreach piece in $items[li'l eyeball costume, li'l candy corn costume, li'l robot costume, li'l knight costume, li'l liberty costume, li'l unicorn costume]
				if(available_amount(piece) == 0 && npc_price(piece) > 0 && npc_price(piece) <= my_meat())
					addEquipment(piece, "retrieve");

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
	
	picker.pickerStart("famgear", "Equip Thy Familiar Well");
	
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

int checkDrops(string counter_prop, int limit) {
	return limit - to_int(get_property(counter_prop));
}

int hasBjornDrops(familiar f) {
	switch(f) {
		case $familiar[grimstone golem]: return checkDrops("_grimstoneMaskDropsCrown",1);
		case $familiar[grim brother]: return checkDrops("_grimFairyTaleDropsCrown",2);
		case $familiar[trick-or-treating tot]: return checkDrops("_hoardedCandyDropsCrown",3);
		case $familiar[optimistic candle]: return checkDrops("_optimisticCandleDropsCrown",3);
		case $familiar[garbage fire]: return checkDrops("_garbageFireDropsCrown",3);
		case $familiar[twitching space critter]: return checkDrops("_spaceFurDropsCrown",1);
	}
	
	return 0;
}

// TODO: Move this function to chit_brickGear.ash
int hasDrops(item it) {
	switch(it) {
		case $item[V for Vivala mask]: return 10 - to_int(get_property("_vmaskAdv"));
		case $item[mayfly bait necklace]: return 30 - to_int(get_property("_mayflySummons"));
		case $item[buddy bjorn]: return hasBjornDrops(my_bjorned_familiar());
		case $item[crown of thrones]: return hasBjornDrops(my_enthroned_familiar());
		case $item[pantsgiving]: return 10 - to_int(get_property("_pantsgivingCrumbs"));
		// not exactly drops per se, but it's still beneficial to have these on until you max the counter
		case $item[stinky cheese eye]: case $item[stinky cheese sword]: case $item[stinky cheese diaper]: case $item[stinky cheese wheel]: case $item[Staff of Queso Escusado]:
			return max(100 - to_int(get_property("_stinkyCheeseCount")), 0);
		// also not exactly drops per se, but... yep
		case $item[bone abacus]:
			return max(1000 - to_int(get_property("boneAbacusVictories")), 0);
		case $item[The Jokester's gun]:
			if(get_property("_firedJokestersGun").to_boolean() == false)
				return 1;
			break;
		case $item[navel ring of navel gazing]:
		case $item[Greatest American Pants]:
			int runs = to_int(get_property("_navelRunaways"));
			if(runs < 9) return 9 - runs;
			break;
		case $item[protonic accelerator pack]:
			int turnsToGhost = to_int(get_property("nextParanormalActivity")) - total_turns_played();
			string ghostLoc = get_property("ghostLocation");
			if(ghostLoc != "" || turnsToGhost <= 0)
				return 1;
			break;
		case $item[Kremlin's Greatest Briefcase]:
			int darts = 3 - to_int(get_property("_kgbTranquilizerDartUses"));
			int drinks = 3 - to_int(get_property("_kgbDispenserUses"));
			int clicks = max(22 - to_int(get_property("_kgbClicksUsed")), 0);
			return darts + drinks + clicks;
		case $item[deceased crimbo tree]:
			int needles = to_int(get_property("_garbageTreeCharge"));
			return needles;
		case $item[broken champagne bottle]:
			int ounces = to_int(get_property("_garbageChampagneCharge"));
			return ounces;
		case $item[makeshift garbage shirt]:
			int scraps = to_int(get_property("_garbageShirtCharge"));
			return scraps;
		case $item[mafia middle finger ring]:
			if(get_property("_mafiaMiddleFingerRingUsed").to_boolean() == false)
				return 1;
			break;
		case $item[FantasyRealm G. E. M.]:
			matcher m = create_matcher("(\\d+) hours? remaining", chitSource["fantasyRealm"]);
			if(find(m)) {
				int hours = m.group(1).to_int();
				return hours;
			}
			break;
	}
	
	return 0;
}

// Set familiar image, including path to image. Some familiar images are purposefully changed, others need to be normalized.
string familiar_image(familiar f) {
	switch(f) {
	case $familiar[none]: return "/images/itemimages/antianti.gif";
	case $familiar[Fancypants Scarecrow]: return "/images/itemimages/pantscrow2.gif";
	case $familiar[Disembodied Hand]: return "/images/itemimages/dishand.gif";
	case $familiar[Mad Hatrack]: return "/images/itemimages/hatrack.gif";
	
	case $familiar[Crimbo Shrub]:  // Get rid of that Gollywog look!
		if(to_boolean(vars["chit.familiar.anti-gollywog"]))
			return imagePath + 'crimboshrub_fxx_ckb.gif';
		break;
	
	case $familiar[Happy Medium]:
		switch(f.image) {
			case "medium_1.gif": return imagePath + 'medium_blue.gif';
			case "medium_2.gif": return imagePath + 'medium_orange.gif';
			case "medium_3.gif": return imagePath + 'medium_red.gif';
		}
		break;
	}
	return '/images/itemimages/' + f.image;
}

int NO_MODIFY = 0;
int MODIFY = 1;
int FORCE_MODIFY = 2; // Some items only want to be modified in special cases, like the edpiece

string item_image(item it, int modify_image)
{
	if(it == $item[none])
		return '/images/itemimages/blank.gif';

	if(modify_image != NO_MODIFY)
	{
		switch(it)
		{
			case $item[Buddy Bjorn]:
				if(my_bjorned_familiar() != $familiar[none])
					return familiar_image(my_bjorned_familiar());
				break;
			case $item[Crown of Thrones]:
				if(my_enthroned_familiar() != $familiar[none])
					return familiar_image(my_enthroned_familiar());
				break;
		}
	}
	
	if(modify_image == FORCE_MODIFY)
	{
		switch(it)
		{
			case $item[The Crown of Ed the Undying]:
				switch(get_property("edPiece"))
				{
					case "bear": return '/images/itemimages/teddybear.gif';
					case "owl": return '/images/itemimages/owl.gif';
					case "puma": return '/images/itemimages/blackcat.gif';
					case "hyena": return '/images/itemimages/lionface.gif';
					case "mouse": return '/images/itemimages/mouseskull.gif';
					case "weasel": return '/images/itemimages/weasel.gif';
					case "fish": return '/images/itemimages/fish.gif';
				}
				break;
		}
	}

	return '/images/itemimages/' + it.image;
}

string item_image(item it)
{
	return item_image(it, MODIFY);
}

void addItemIcon(buffer result, item it, string title, int danger_level, int modify_image) {
	result.append('<img class="chit_icon');
	if(hasDrops(it) > 0)
		result.append(' hasdrops');
		
	if(danger_level == 1)
		result.append(' warning');
	else if(danger_level > 1)
		result.append(' danger');
	else if(danger_level < 0)
		result.append(' good');
	
	result.append('" src="');
	result.append(item_image(it, modify_image));
	result.append('" title="');
	result.append(title);
	result.append('" />');
}
void addItemIcon(buffer result, item it, string title, int danger_level, boolean modify_image) {
	addItemIcon(result,it,title,danger_level,modify_image ? MODIFY : NO_MODIFY);
}
void addItemIcon(buffer result, item it, string title, int danger_level) {
	addItemIcon(result,it,title,danger_level,true);
}
void addItemIcon(buffer result, item it, string title) {
	addItemIcon(result,it,title,0);
}

int hasDrops(familiar f) {
	int drops = 0;
	
	if(f.drops_limit > 0)
		drops += f.drops_limit - f.drops_today;
	
	return drops;
}

boolean need_drop(familiar f) {
	if(!can_interact())
		switch(f) {
		case $familiar[Grimstone Golem]:
			return available_amount($item[grimstone mask]) + available_amount($item[ornate dowsing rod]) == 0;
		case $familiar[Angry Jung Man]:
			return available_amount($item[psychoanalytic jar])
				+ available_amount($item[jar of psychoses (The Crackpot Mystic)])
				+ available_amount($item[digital key]) == 0;
		case $familiar[Gelatinous Cubeling]: return in_hardcore();
		}
	return true;
}

// status: hasdrops (blue border), alldrops (purple border), danger (red border), good (green border)
// good is intended to say BRING THIS WITH YOU RIGHT NOW NO MATTER WHAT, just about
// danger is obviously meant to say DO NOT USE THIS FAMILIAR RIGHT NOW
// hasdrops means there's limited stuff to gain today, so it'd be a good idea to bring it
// alldrops means it hasn't dropped ANY of its stuff, or has some really valuable daily resource available

int STATUS_NORMAL = 0;
int STATUS_HASDROPS = 1;
int STATUS_ALLDROPS = 2;
int STATUS_GOOD = 3;
int STATUS_DANGER = 4;

int iconInfoSpecial(familiar f, buffer iconInfo) {
	switch(f) {
	case $familiar[Fist Turkey]:
		int statsLeft = 15 - to_int(get_property("_turkeyMuscle")) - to_int(get_property("_turkeyMyst")) - to_int(get_property("_turkeyMoxie"));
		if(statsLeft > 0) {
			iconInfo.append(", ");
			iconInfo.append(statsLeft);
			iconInfo.append(" stat");
			if(statsLeft != 1)
				iconInfo.append("s");
			// The stats are nice, but they don't warrant highlighting outside of The Source, where they're super important.
			if(my_path() == "The Source")
				return STATUS_HASDROPS;
			else
				return STATUS_NORMAL;
		}
		break;
	case $familiar[Steam-Powered Cheerleader]:
		int steamPercent = ceil(to_float(get_property("_cheerleaderSteam")) / 2);
		if(steamPercent > 0) {
			iconInfo.append(steamPercent);
			iconInfo.append("% steam");
			if(steamPercent > 50)
				return STATUS_ALLDROPS;
			return STATUS_HASDROPS;
		}
		break;
	case $familiar[Slimeling]:
		float fullness = to_float(get_property("slimelingFullness"));
		if(fullness > 0) {
			iconInfo.append(", ~");
			iconInfo.append(fullness);
			iconInfo.append(" fullness");
		}
		int stacksDue = to_int(get_property("slimelingStacksDue"));
		int stacksDropped = to_int(get_property("slimelingStacksDropped"));
		if(stacksDue > 0 && stacksDue > stacksDropped) {
			iconInfo.append(", ");
			iconInfo.append(stacksDropped);
			iconInfo.append("/");
			iconInfo.append(stacksDue);
			iconInfo.append(" stacks dropped");
			if(stacksDropped == 0)
				return STATUS_ALLDROPS;
			return STATUS_HASDROPS;
		}
		break;
	case $familiar[gelatinous cubeling]:
		boolean needPole = available_amount($item[eleven-foot pole]) < 1;
		boolean needRing = available_amount($item[ring of detect boring doors]) < 1;
		boolean needPick = available_amount($item[pick-o-matic lockpicks]) < 1;
		if(needPole)
			iconInfo.append("Pole, ");
		if(needRing)
			iconInfo.append("Ring, ");
		if(needPick)
			iconInfo.append("Pick");
		if(needPole || needRing || needPole)
			return STATUS_ALLDROPS;
		break;
	case $familiar[Crimbo Shrub]:
		switch(get_property("shrubGifts")) {
		case "yellow":
			if(have_effect($effect[Everything Looks Yellow]) > 0)
				break;
			iconInfo.append("Ready to fire!");
			return STATUS_ALLDROPS;
		case "meat":
			if(have_effect($effect[Everything Looks Red]) > 0)
				break;
			iconInfo.append("Ready to fire!");
			return STATUS_ALLDROPS;
		case "": // If Crimbo Shrub has not yet been set up this ascension
			iconInfo.append("Needs to be decorated!");
			return STATUS_ALLDROPS;
		}
		break;
	case $familiar[Rockin' Robin]:
		if(get_property("rockinRobinProgress").to_int() > 24) {
			iconInfo.append("Egg soon!");
			return STATUS_ALLDROPS;
		}
		break;
	case $familiar[Optimistic Candle]:
		if(get_property("optimisticCandleProgress").to_int() > 24) {
			iconInfo.append("Wax soon!");
			return STATUS_ALLDROPS;
		}
		break;
	case $familiar[Garbage Fire]:
		if(get_property("garbageFireProgress").to_int() > 24) {
			iconInfo.append("Garbage soon!");
			return STATUS_ALLDROPS;
		}
		break;
	case $familiar[Intergnat]:
		int status = STATUS_NORMAL;
		string demon = get_property("demonName12");
		if(length(demon) < 5 || substring(demon,0,5) != "Neil ") {
			iconInfo.append("Demon name unknown");
			status = STATUS_HASDROPS;
		}
		else {
			iconInfo.append("Demon name is ");
			iconInfo.append(demon);
		}
		if(!can_interact()) {
			if(available_amount($item[scroll of ancient forbidden unspeakable evil]) == 0) {
				iconInfo.append(",\n    Need AFUE scroll");
				status = STATUS_HASDROPS;
			}
			if(available_amount($item[thin black candle]) < 3) {
				if(!iconInfo.contains_text("Need AFUE scroll"))
					iconInfo.append(",\n    Need ");
				else
					iconInfo.append(", Need ");
				iconInfo.append(to_string(3 - available_amount($item[thin black candle])));
				iconInfo.append(" more candles");
				status = STATUS_HASDROPS;
			}
		}
		return status;
	case $familiar[Reanimated Reanimator]:
		if(get_property("_badlyRomanticArrows").to_int() == 0) {
			iconInfo.append("Wink available");
			return STATUS_ALLDROPS;
		}
		break;
	case $familiar[Space Jellyfish]:
		int spaceJellyfishDrops = to_int(get_property("_spaceJellyfishDrops"));
		iconInfo.append(spaceJellyfishDrops+" jelly sucked");
		if(!get_property("_seaJellyHarvested").to_boolean() && my_level() >= 11 && my_class().to_int() < 7) {
			iconInfo.append(", Sea jelly available");
			return STATUS_ALLDROPS;
		}
		if(spaceJellyfishDrops == 0)
			return STATUS_ALLDROPS;
		if(spaceJellyfishDrops < 3)
			return STATUS_HASDROPS;
		break;
	case $familiar[XO Skeleton]:
		int hugs = 11 - get_property("_xoHugsUsed").to_int();
		if(hugs > 0) {
			iconInfo.append(hugs + " hug" + (hugs == 1 ? "" : "s"));
			return STATUS_HASDROPS;
		}
		break;
	case $familiar[God Lobster]:
		int godfights = 3 - get_property("_godLobsterFights").to_int();
		if(godfights > 0) {
			iconInfo.append(godfights + " challenge" + (godfights == 1 ? "" : "s"));
			return STATUS_HASDROPS;
		}
		break;
	}
	return STATUS_NORMAL;
}

// isBjorn also applies for the crown, just for the sake of a shorter name
void addFamiliarIcon(buffer result, familiar f, boolean isBjorn, boolean title, string reason) {
	boolean pokeFam = (my_path() == "Pocket Familiars");
	familiar is100 = $familiar[none];
	if(!isBjorn)
		is100 = to_familiar(to_int(get_property("singleFamiliarRun")));
	
	buffer iconInfo;
	int status = STATUS_NORMAL;

	int dropsLeft = isBjorn ? hasBjornDrops(f) : hasDrops(f);
	if(pokeFam && !isBjorn)
		dropsLeft = 0;
	
	if(dropsLeft > 0) {
		iconInfo.append(dropsLeft);
		iconInfo.append(" ");
		if(f.drop_item != $item[none])
			iconInfo.append(dropsLeft > 1 ? f.drop_item.plural : f.drop_item);
		else {
			if(f.drop_name != "") {
				iconInfo.append(f.drop_name);
				if(dropsLeft > 1)
					iconInfo.append("s");
			} else switch(f) {
				case $familiar[trick-or-treating tot]:
					if(dropsLeft > 1) iconInfo.append("candies");
					else iconInfo.append("candy");
					break;
				case $familiar[optimistic candle]:
					iconInfo.append("wax");
					break;
				case $familiar[garbage fire]:
					iconInfo.append("newspaper");
					if(dropsLeft > 1) iconInfo.append("s");
					break;
				case $familiar[twitching space critter]:
					iconInfo.append("fur");
					break;
			}
		}
		
		if(f.drops_today == 0 && need_drop(f))
			status = STATUS_ALLDROPS;
		else
			status = STATUS_HASDROPS;
	}
	
	if(!isBjorn && !pokeFam) {
		int fightsLeft = f.fights_limit - f.fights_today;
		if(fightsLeft > 0)
		{
			status = STATUS_ALLDROPS;
			iconInfo.append(", ");
			iconInfo.append(fightsLeft);
			iconInfo.append(" fight");
			if(fightsLeft != 1)
				iconInfo.append("s");
		}
		
		int specialStatus = iconInfoSpecial(f, iconInfo);
		if(specialStatus > status)
			status = specialStatus;
	}
	
	if(reason != "") {
		iconInfo.append(", recommended for ");
		iconInfo.append(reason);
	}
	
	string blackForestState = get_property("questL11Black");
	// You should probably bring a bird with you if you don't have a hatchling and you're looking for the black market
	if(!isBjorn && !pokeFam && (f == $familiar[Reassembled Blackbird] || f == $familiar[Reconstituted Crow])) {
		if((blackForestState == "started" || blackForestState == "step1") && (item_amount($item[reassembled blackbird]) + item_amount($item[reconstituted crow])) == 0) 
			status = STATUS_GOOD;
		else
			status = STATUS_DANGER;
	}
	
	if(is100 != $familiar[none]) {
		if(is100 != f)
			status = STATUS_DANGER;
		else
			status = STATUS_GOOD;
	}
	
	result.append('<img class="chit_icon');
	switch(status) {
	case STATUS_HASDROPS:
		result.append(' hasdrops');
		break;
	case STATUS_ALLDROPS:
		result.append(' alldrops');
		break;
	case STATUS_GOOD:
		result.append(' good');
		break;
	case STATUS_DANGER:
		result.append(' danger');
		break;
	}
	result.append('" src="');
	result.append(familiar_image(f));
	if(title) {
		result.append('" title="');
		result.append(f.name);
		result.append(' (the ');
		result.append(f);
		result.append(')');
		string info = to_string(iconInfo);
		if(info != "") {
			result.append(' (');
			if(char_at(info,0) != ",")
				result.append(info);
			else
				result.append(substring(info,2));
			result.append(')');
		}
	}
	result.append('" />');
}

void addFamiliarIcon(buffer result, familiar f, boolean isBjorn, boolean title) {
	addFamiliarIcon(result, f, isBjorn, title, "");
}

void addFamiliarIcon(buffer result, familiar f, boolean isBjorn) {
	addFamiliarIcon(result, f, isBjorn, true);
}

void addFamiliarIcon(buffer result, familiar f) {
	addFamiliarIcon(result, f, false);
}

void pickerFamiliar(familiar current, string cmd, string display)
{
	familiar is100 = to_familiar(to_int(get_property("singleFamiliarRun")));
	// if this isn't the main familiar picker we don't care about 100% runs
	if(cmd != "familiar")
		is100 = $familiar[none];

	buffer picker;
	picker.pickerStart(cmd, display);
	
	if(is100 != $familiar[none])
	{
		picker.append('<tr class="pickitem"><td colspan="3">Careful, you are currently in a 100% run with ');
		picker.append(is100.name);
		picker.append(', your ');
		picker.append(is100);
		picker.append('</td></tr>');
	}
	
	boolean anyIcons = false;
	boolean [familiar] famsAdded;
	
	boolean tryAddFamiliar(familiar f, string reason) {
		if(f == current)
			return true;
		if(have_familiar(f) && be_good(f) && !famsAdded[f]) {
			if(!anyIcons) {
				picker.append('<tr class="pickitem chit_pickerblock"><td colspan="3">');
				anyIcons = true;
			}
			picker.append('<span><a class="change" href="');
			picker.append(sideCommand(cmd + ' ' + f));
			picker.append('">');
			picker.addFamiliarIcon(f, cmd != "familiar", true, reason);
			picker.append('</a></span>');
			famsAdded[f] = true;
			return true;
		}
		return famsAdded[f];
	}
	
	boolean tryAddFamiliar(familiar f) {
		return tryAddFamiliar(f, "");
	}
	
	foreach f in favorite_familiars()
		tryAddFamiliar(f);
		
	boolean recIf(boolean condition, familiar fam, string reason) {
		if(condition) return tryAddFamiliar(fam, reason);
		return false;
	}
	
	void recIf(boolean condition, boolean [familiar] fams, string reason) {
		if(condition) {
			foreach fam in fams {
				if(recIf(condition, fam, reason))
					return;
			}
		}
	}
		
	// Familiars recommended for quests
	string nsQuest = get_property("questL13Final");
	boolean needSkinHelper = (nsQuest == "step6" && available_amount($item[beehive]) < 1);
	string orcChasm = get_property("questL09Topping");
	boolean highlandsTime = (orcChasm == "step1" || orcChasm == "step2");
	
	if(cmd == "familiar") { 
		string blackForestState = get_property("questL11Black");
		boolean needGuide = (($strings[started, step1] contains blackForestState) && (item_amount($item[reassembled blackbird]) + item_amount($item[reconstituted crow])) == 0);
		recIf(needGuide, $familiars[Reconstituted Crow, Reassembled Blackbird], "black forest");
		
		// Probably incomplete list of reasons you'd want the purse rat
		boolean [familiar] mlFams = $familiars[Purse Rat]; // There's only one atm that I know of but who knows what the future holds
		// Typical tavern, you might want to bring the purse rat to up rat king chance
		recIf(get_property("questL03Rat") == "step1", mlFams, "rat kings");
		recIf(to_int(get_property("cyrptCrannyEvilness")) > 26, mlFams, "ghuol whelps");
		recIf(highlandsTime && to_float(get_property("oilPeakProgress")) > 0, mlFams, "oil peak");
		recIf(available_amount($item[unstable fulminate]) > 0, mlFams, "wine bomb");
		
		// Maybe incomplete list of reasons you'd want an init familiar
		boolean [familiar] initFams = $familiars[Xiblaxian Holo-Companion, Oily Woim];
		recIf(to_int(get_property("cyrptAlcoveEvilness")) > 26, initFams, "modern zmobie");
		recIf(highlandsTime && ((to_int(get_property("twinPeakProgress")) & 7) == 7) && (initiative_modifier() < 40), initFams, "twin peaks");
		recIf(nsQuest != "unstarted" && to_int(get_property("nsContestants1")) < 0, initFams, "init test");
		
		// The Imitation Crab is incredibly useful for tower killing the wall of skin
		recIf(needSkinHelper, $familiars[Imitation Crab, Sludgepuppy, Mini-Crimbot, Warbear Drone], "wall of skin");
		
		boolean [familiar] resFams = $familiars[Exotic Parrot];
		boolean kitchenTime = get_property("questM20Necklace") == "started" && to_int(get_property("writingDesksDefeated")) == 0 && get_property("chateauMonster") != "writing desk";
		boolean cantTakeTheHeat = numeric_modifier("Hot Resistance") < 9 || numeric_modifier("Stench Resistance") < 9; // or the stench...
		recIf(kitchenTime && cantTakeTheHeat, resFams, "haunted kitchen");
		string trapper = get_property("questL08Trapper");
		recIf((trapper == "step3" || trapper == "step4") && numeric_modifier("Cold Resistance") < 5, resFams, "misty peak");
		recIf(highlandsTime && to_int(get_property("booPeakProgress")) > 0, resFams, "surviving a-boo clues");
		recIf(nsQuest == "step4", resFams, "hedge maze");
		
		recIf(get_property("questM03Bugbear") == "step2", $familiars[Flaming Gravy Fairy, Frozen Gravy Fairy, Stinky Gravy Fairy, Sleazy Gravy Fairy, Spooky Gravy Fairy], "felonia");
	}
	else {
		// Recommendations for the crown/bjorn
		recIf(needSkinHelper, $familiars[Frumious Bandersnatch, Howling Balloon Monkey, Baby Mutant Rattlesnake, Mutant Cactus Bud], "wall of skin");
	}
	
	if(anyIcons)
		picker.append('</td></tr>');
	
	int danger_level = 0;
	if(is100 != $familiar[none])
		danger_level = (is100 == current) ? 2 : -1;
	picker.append('<tr class="pickitem"><td class="icon"><a target=mainpane class="visit done" href="familiar.php">');
	picker.addItemIcon($item[Familiar-Gro&trade; Terrarium], "Visit your terrarium", danger_level);
	picker.append('</a></td>');
	
	picker.append('<td class="icon"><a target=charpane class="change" href="'+sideCommand("familiar none")+'">');
	picker.append('<img src='+familiar_image($familiar[none])+' title="Use no familiar" />');
	picker.append('</a></td>');
	
	picker.append('<td colspan="2"><a target=mainpane class="visit done" href="familiar.php">');
	picker.append('Visit Your Terrarium');
	picker.append('</a></td></tr>');
	picker.addLoader("Changing familiar...");
	picker.append('</table></div>');
	chitPickers[cmd] = picker;
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
	
	void addCompanion(buffer result, skill s, boolean gotfood) {
		string hover = "Play with " + s +"<br />";
		if(gotfood)
			hover += "<span class='descline'>Costs "+mp_cost(s)+" mp and <br />1 "+companion[s]+" (have "+item_amount(companion[s])+")";
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
	picker.pickerStart("companion", "Summon thy Companion");
	
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

string servant_ability(servant s, int lvl) {
	switch(lvl) {
	case 1: return s.level1_ability;
	case 7: return s.level7_ability;
	case 14: return s.level14_ability;
	case 21: return s.level21_ability;
	}
	return "";
}

void pickerServant() {
	void addServant(buffer result, servant s) {
		string url = sideCommand("servant " + s);
		result.append('<tr class="pickitem"><td class="inventory"><a class="change" href="');
		result.append(url);
		result.append('"><b>');
		result.append(s);
		result.append('</b>');
		foreach i in $ints[1, 7, 14] {
			result.append('<br /><span style="color:');
			if(s.level >= i)
				result.append('blue');
			else
				result.append('gray');
			result.append('">');
			result.append(s.servant_ability(i));
			result.append("</span>");
		}
		result.append('</span></a></td><td class="icon"><a class="change" href="');
		result.append(url);
		result.append('"><img src="/images/itemimages/');
		result.append(s.image);
		result.append('"></a></td></tr>');
	}

	buffer picker;
	picker.pickerStart("servant", "Put thy Servant to Work");
	picker.addLoader("Summoning Servant...");
	boolean sad = true;
	foreach s in $servants[]
		if(have_servant(s) && my_servant() != s) {
			picker.addServant(s);
			sad = false;
		}
	if(sad) {
		if(my_servant() == $servant[none])
			picker.addSadFace("You haven't yet released any servants to obey your whims.<br /><br />How sad.");
		else
			picker.addSadFace("Poor " + my_servant().name + " has no other servants for company.");
	}
	
	// Link to Servant's Quarters
	picker.append('<tr class="pickitem"><td colspan=2 class="make"><a class="change" style="border-top: 1px solid gray; padding: 3px 0px 3px 0px;" onclick="javascript:location.reload();" target=mainpane href="place.php?whichplace=edbase&action=edbase_door"><b>Go to the Servant\'s Quarters</b></a></td></tr>');
	
	picker.append('</table></div>');
	
	chitPickers["servants"] = picker;
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
	result.append('<a class="chit_launcher" rel="chit_pickerfamgear" href="#">');
	result.append('<img src="/images/itemimages/' );
	result.append(equipimage);
	result.append('">');
	result.append('</a></td>');
	result.append('</tr>');
	
	result.append('</table>');
	chitBricks["familiar"] = result;

	//Add Equipment Picker
	pickerFamiliarGear($familiar[none], familiar_equipped_equipment(my_familiar()), false);
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
	result.append('<a class="chit_launcher" rel="chit_pickercompanion" href="#">');
	result.append('<img src="images/adventureimages/' );
	result.append(famimage);
	result.append('"></a></td>');
	result.append('<td class="info"><a class="chit_launcher" rel="chit_pickercompanion" href="#">');
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

# <p><font size=2><b>Servant:</b><br /><a href="/place.php?whichplace=edbase&action=edbase_door" target="mainpane">Bakthenamen the 1 level Cat</a><br /><a href="/place.php?whichplace=edbase&action=edbase_door" target="mainpane"><img border=0 src="//images.kingdomofloathing.com/itemimages/edserv1.gif" /></a></font></p>
void FamEd() {
	buffer result;
	void bake(int lvl, string name, servant type, string img) {
		result.append('<table id="chit_familiar" class="chit_brick nospace">');
		result.append('<tr><th title="Servant Level">');
		if(type != $servant[none]) {
			result.append('Lvl.&nbsp;');
			result.append(lvl);
		}
		result.append('</th><th colspan="2" title="Servant"><a title="');
		result.append(name);
		result.append('" target=mainpane href="/place.php?whichplace=edbase&action=edbase_door">');
		result.append(name);
		if(type != $servant[none]) {
			result.append(", the ");
			result.append(type);
		}
		result.append('</a></th></tr>');
		
		result.append('<tr><td class="icon" title="Servant">');
		result.append('<a class="chit_launcher" rel="chit_pickerservant" href="#">');
		result.append('<img title="Release thy Servant" src=');
		result.append(img);
		result.append('></a></td>');
		if(type != $servant[none]) {
			result.append('<td class="info"><a class="chit_launcher" rel="chit_pickerservant" href="#"><span style="color:blue;font-weight:bold">');
			foreach i in $ints[1, 7, 14]
				if(lvl >= i) {
					result.append(type.servant_ability(i));
					result.append('<br>');
				}
			result.append('</span></a></td>');
		} else {
			result.append('<td class="info"><a target=mainpane href="/place.php?whichplace=edbase&action=edbase_door"><span style="color:blue;font-weight:bold">(Click to release<br>a Servant)</span></a></td>');
		}
		result.append('</tr></table>');
	}
	
	matcher id = create_matcher('mainpane">.+? src="([^"]+)"', chitSource["familiar"]);
	if(id.find())
		bake(my_servant().level, my_servant().name, my_servant(), id.group(1));
	else
		bake(0, "No Servant", $servant[none], "/images/itemimages/blank.gif");
	
	chitBricks["familiar"] = result;
	pickerServant();
}

# <b><a href="famteam.php" target="mainpane" style="text-decoration:none">Active Team</a></b><br /><br /><img align="absmiddle" src=/images/itemimages/familiar32.gif>&nbsp;6655321 (Lvl 4)<br /><img align="absmiddle" src=/images/itemimages/familiar34.gif>&nbsp;Baxanne (Lvl 4)<br /><img align="absmiddle" src=/images/itemimages/familiar20.gif>&nbsp;Bufferson (Lvl 5)<br /><br /><a href="famteam.php" target="mainpane">Manage Team</a>
void FamPoke()
{
	buffer result;
	result.append('<table id="chit_familiar" class="chit_brick nospace"><tr>');
	result.append('<th colspan="2"><a href="famteam.php" target="mainpane" title="Manage Team">Active Team</a></th></tr>');
	void addPokeFam(familiar f)
	{
		int getStrength()
		{
			if(f == $familiar[none])
				return 0;
			switch(f.poke_level)
			{
				case 1: return 1;
				case 2: return f.poke_level_2_power;
				case 3: return f.poke_level_3_power;
				case 4: case 5: return f.poke_level_4_power;
				default: return 0;
			}
		}
		int getHP()
		{
			if(f == $familiar[none])
				return 0;
			switch(f.poke_level)
			{
				case 1: return 2;
				case 2: return f.poke_level_2_hp;
				case 3: return f.poke_level_3_hp;
				case 4: case 5: return f.poke_level_4_hp;
				default: return 0;
			}
		}
		result.append('<tr');
		result.append('><td class="icon">');
		result.addFamiliarIcon(f, false, false);
		result.append('</td><td>');
		result.append(f.name);
		result.append(' (Lvl ');
		result.append(f.poke_level);
		result.append(')<br />');
		for(int i = 0; i < getStrength(); ++i)
			result.append('<img style="height:20px;width:20px" src="/images/itemimages/blacksword.gif" />');
		for(int i = 0; i < getHP(); ++i)
			result.append('<img style="height:20px;width:20px" src="/images/itemimages/blackheart.gif" />');
		if(f.poke_attribute.contains_text("Armor"))
			result.append('<img style="height:20px;width:20px" src="/images/itemimages/whiteshield.gif" />');
		if(f.poke_attribute.contains_text("Regenerating"))
			result.append('<img style="height:20px;width:20px" src="/images/itemimages/plus.gif" />');
		if(f.poke_attribute.contains_text("Smart"))
			result.append('<img style="height:20px;width:20px" src="/images/itemimages/spectacles.gif" />');
		if(f.poke_attribute.contains_text("Spiked"))
			result.append('<img style="height:20px;width:20px" src="/images/itemimages/spikycollar.gif" />');
		result.append('</td></tr>');
	}
	matcher famMatcher = create_matcher("itemimages/(.*?\\.gif)", chitSource["familiar"]);
	while(find(famMatcher))
	{
		familiar f = $familiar[none];
		foreach fam in $familiars[]
		{
			if(fam.image == famMatcher.group(1))
			{
				f = fam;
				break;
			}
		}
		addPokeFam(f);
	}
	result.append('</table>');
	chitBricks["familiar"] = result;

}

void bakeFamiliar() {

	// Special Challenge Path Familiar-ish things
	switch(my_path()) {
	case "Avatar of Boris": FamBoris(); return;
	case "Avatar of Jarlsberg": FamJarlsberg(); return;
	case "Avatar of Sneaky Pete": FamPete(); return;
	case "Actually Ed the Undying": FamEd(); return;
	case "License to Adventure": return;
	case "Pocket Familiars": FamPoke(); return;
	}

	string source = chitSource["familiar"];

	string famname = "Familiar";
	string famtype = '<a target=mainpane href="familiar.php" class="familiarpick">(None)</a>';
	string equipimage = "blank.gif";
	string equiptype, actortype, famweight, info, famstyle, charges, chargeTitle;
	boolean isFed = source.contains_text('</a></b>, the <i>extremely</i> well-fed <b>');
	string weight_title = "Buffed Weight";
	string name_followup = "";
	
	familiar myfam = my_familiar();
	item famitem = $item[none];

	if(myfam != $familiar[none]) {
		famtype = to_string(myfam);
		actortype = famtype;
		if(myfam == $familiar[Fancypants Scarecrow])
			famtype = "Fancy Scarecrow"; // Name is too long when there's info added
		// Put the mumming trunk icon before the familiar type name
		matcher mummingmatcher = create_matcher('<a target="mainpane" href="/inv_use\\.php\\?whichitem=9592.*?</a>', source);
		if(find(mummingmatcher))
			famtype = group(mummingmatcher) + " " + famtype;
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
	if (myfam != $familiar[none]) {
		famweight = to_string(familiar_weight(myfam) + weight_adjustment());
	}

	// Get familiar specific info
	switch(myfam) {
	case $familiar[Mad Hatrack]:
	case $familiar[Fancypants Scarecrow]:
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
		break;
	case $familiar[Reanimated Reanimator]:
		name_followup += ' (<a target=mainpane href="main.php?talktoreanimator=1">chat</a>)';
		buffer wink;
		iconInfoSpecial(myfam,wink);
		info = wink;
		break;
	case $familiar[Grim Brother]:
		if(source.contains_text(">talk</a>)"))
			name_followup += ' (<a target=mainpane href="familiar.php?action=chatgrim&pwd='+my_hash()+'">talk</a>)';
		break;
	case $familiar[Crimbo Shrub]:
		if(get_property("_shrubDecorated") == "false")
			name_followup += ' (<a target=mainpane href="inv_use.php?pwd='+my_hash()+'&which=3&whichitem=7958">decorate</a>)';
		buffer mods;
		foreach shrub in $strings[shrubTopper, shrubLights, shrubGarland, shrubGifts] {
			string decoration = get_property(shrub);
			if(length(decoration) > 0) {
				if(length(mods) > 0)
					mods.append(", ");
				mods.append(decoration);
			}
		}
		if(info != "")
			mods = mods.replace_string("PvP", "PvP: "+info.replace_string(" charges", ""));
		info = parseMods(mods);
		if(get_property("shrubGifts") == "yellow")
			info = info.replace_string(", Yellow", ", <span style='color:#999933'>Yellow</span>");
		else if(get_property("shrubGifts") == "meat")
			info = info.replace_string("Meat", "<span style='color:#FE2E2E'>Meat</span>");
		break;
	case $familiar[Mini-Crimbot]:
		if(source.contains_text(">configure</a>)"))
			switch(get_property("crimbotChassis")) {
			case 'Low-Light Operations Frame':
				info = 'Block, ';
				break;
			case 'Smile-O-Matic':
				info = 'Stats, ';
				break;
			case 'Music Box Box':
				info = 'Spooky Damage, ';
				break;
			case 'Chewing Unit':
				info = 'Meat, ';
				break;
			}
			switch(get_property("crimbotArm")) {
			case 'T8-ZR Pacification Delivery System':
				info += 'MP, ';
				break;
			case '4.077 Field Medic Syringe':
				info += 'HP, ';
				break;
			case 'Frostronic Hypercoil':
				info += 'Cold Damage, ';
				break;
			case 'STAL-1 UltraFist':
				info += 'Physical Damage, ';
				break;
			}
			switch(get_property("crimbotPropulsion")) {
			case 'V-TOP Frictionless Monocycle Wheel':
				info += 'Initiative';
				break;
			case 'X-1 Hover Rocket':
				info += 'Hot Damage';
				break;
			case 'Lambada-Class Dancing Legs':
				info += 'Items';
				break;
			case 'T-NMN Tank Treads':
				info += 'Delevel';
				break;
			}
			info = '<a target=mainpane title="Configure your Mini-Crimbot" href="main.php?action=minicrimbot">'
				+ (info == ""? "configure": parseMods(info)) + '</a>';
		break;
	case $familiar[Puck Man]: case $familiar[Ms. Puck Man]:
		info = '<a class="visit blue-link" target="mainpane" title="Visit the Crackpot Mystic" href="shop.php?whichshop=mystic">' + to_string(item_amount($item[Yellow Pixel])) + ' yellow pixels</a>, ' + info;
		break;
	case $familiar[Machine Elf]:
		string isBlue = "";
		int thought = item_amount($item[abstraction: thought]);
		int action = item_amount($item[abstraction: action]);
		int sensation = item_amount($item[abstraction: sensation]);
		if(thought > 0 && action > 0 && sensation > 0)
			isBlue = " blue-link";
		info = '<a class="visit' + isBlue + '" target="mainpane" title="DMT mixing: '
			+ thought + ' item, ' + action + ' weight, ' + sensation + ' init'
			+ ' possible" href="place.php?whichplace=dmt">' + myFam.fights_today + '/' + myFam.fights_limit + ' combats</a>, '
			+ myFam.drops_today + '/'  + myFam.drops_limit + ' snowglobe';
		break;
	case $familiar[Intergnat]:
		if(item_amount($item[BACON]) > 0) {
			if(length(info) > 0)
				info = ", " + info;
			
			info = '<a class="visit blue-link" target="mainpane" title="Internet Meme Shop" href="shop.php?whichshop=bacon&pwd='+my_hash()+'">' + to_string(item_amount($item[BACON])) + ' BACON</a>' + info;
		}
		string demon = get_property("demonName12");
		if(length(demon) < 5 || substring(demon,0,5) != "Neil ")
			info += (length(info) > 0? ', ':'') + '<span title="You haven\'t discovered the full name of the Intergnat demon yet this ascension">Demon?</span>';
		if(!can_interact() && available_amount($item[scroll of ancient forbidden unspeakable evil]) == 0)
			info += (length(info) > 0? ', ':'') + "AFUE scroll";
		if(!can_interact() && available_amount($item[thin black candle]) < 3)
			info += (length(info) > 0? ', ':'') + to_string(3 - available_amount($item[thin black candle])) + " candles";
		break;
	case $familiar[Fist Turkey]:
		int muscgains = to_int(get_property("_turkeyMuscle"));
		int mystgains = to_int(get_property("_turkeyMyst"));
		int moxgains = to_int(get_property("_turkeyMoxie"));
		info += ', <span title="' + muscgains + '/5 musc, ' + mystgains  + '/5 myst, ' + moxgains + '/5 moxie">' + (muscgains + mystgains + moxgains) + '/15 stats</span>';
		break;
	case $familiar[Nosy Nose]:
		info = get_property("nosyNoseMonster");
		if(info == "") info = "Nothing Sniffed";
		break;
	case $familiar[Gelatinous Cubeling]:
		buffer b;
		iconInfoSpecial(myfam, b);
		info = b;
		break;
	case $familiar[Space Jellyfish]:
		if(!get_property("_seaJellyHarvested").to_boolean() && my_level() >= 11 && my_class().to_int() < 7)
			info += ', <a class="visit blue-link" target="mainpane" title="To the sea!" href="'
				+ (get_property("questS01OldGuy") == "unstarted"? 'oldman.php': 'place.php?whichplace=thesea&action=thesea_left2')
				+ '">Sea jelly available</a>';
		break;
	case $familiar[XO Skeleton]:
		int xs = item_amount($item[X]);
		int os = item_amount($item[O]);
		int hugs = 11 - get_property("_xoHugsUsed").to_int();
		string xprog = get_property("xoSkeleltonXProgress");
		string yprog = get_property("xoSkeleltonOProgress");
		info = '<a class="visit" target="mainpane" title="eXpend some Xes and blOw some Os!" '
			+ 'href="shop.php?whichshop=xo">' +  xs + (xs == 1 ? ' X' : " Xes") + ' (' + xprog + '/9), '
			+ os + (os == 1 ? ' O' : " Os") + ' (' + yprog + '/9)</a>';
		if(hugs > 0)
			info = hugs + " hug" + (hugs == 1 ? "" : "s") + ", " + info;
		break;
	case $familiar[God Lobster]:
		int godfights = 3 - get_property("_godLobsterFights").to_int();
		if(godfights > 0)
			info += '<a target=mainpane href="main.php?fightgodlobster=1" title="Challenge the God Lobster">'
				+ godfights + " challenge" + (godfights == 1 ? "" : "s") + '</a>';
		break;
	case $familiar[Cat Burglar]:
		if(source.index_of('<a target=mainpane href=main.php?heist=1>heist time!</a>') != -1)
			info = '<a target=mainpane href=main.php?heist=1>heist time!</a>';
		break;
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
			if(famitem == $item[Snow Suit] && have_effect($effect[SOME PIGS]) == 0) {
				int snowface = index_of(source, "itemimages/snow");
				equipimage = substring(source, snowface + 11, snowface + 24);
				info += (length(info) == 0? "": ", ") + get_property("_carrotNoseDrops")+"/3 carrots";
			} else
				equipimage = famitem.image;
		}
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
	string hover_famicon = "Pick a familiar";

	//Extra goodies for 100% runs
	boolean protect = false;
	familiar is100 = to_familiar(to_int(get_property("singleFamiliarRun")));
	if (is100 != $familiar[none]) {
		if (myfam == is100) {
			famstyle = famstyle + "color:green;";
			if (vars["chit.familiar.protect"] == "true") {
				hover = "Don't ruin your 100% run!";
				hover_famicon = hover;
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
	
	//Add base weight to weight title
	int base_weight = familiar_weight(myfam);
	weight_title += " (Base Weight: " + base_weight + " lb";
	if(base_weight > 1) weight_title += "s";
	weight_title += ")";
	
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
		result.append('<th title="' + hover + '">' + famname);
	} else {
		result.append('<th><a target=mainpane href="familiar.php" class="familiarpick" title="' + hover + '">' + famname + '</a>');
	}
	result.append(name_followup + '</th>');
	if (charges == "") {
		result.append('<th width="30">&nbsp;</th>');
	} else {
		result.append('<th width="30" title="' + chargeTitle + '">' + charges + '</th>');
	}
	result.append('</tr><tr>');
	result.append('<td class="icon" title="' + hover_famicon + '">');
	if (protect) {
		result.addFamiliarIcon(myfam, false, false);
	} else {
		result.append('<a href="#" class="chit_launcher" rel="chit_pickerfamiliar">');
		result.addFamiliarIcon(myfam, false, false);
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
		result.append('<a class="chit_launcher" rel="chit_pickerfamgear" href="#">');
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
		pickerFamiliarGear(myfam, famitem, isFed);
	}
	
	pickerFamiliar(myfam, "familiar", "Change familiar");
}
