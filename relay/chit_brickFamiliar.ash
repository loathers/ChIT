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
	
	void pickEquipment() {

		// First add a decorate link if you are using a Snow Suit
		if(equipped_item($slot[familiar]) == $item[Snow Suit]) {
			string suiturl = '<a target=mainpane class="change" href="inventory.php?pwd='+my_hash()+'&action=decorate" title="Decorate your Snow Suit\'s face">';
			int faceIndex = index_of(chitSource["familiar"], "itemimages/snow");
			string face = substring(chitSource["familiar"], faceIndex + 11, faceIndex + 24);
			if(have_effect($effect[SOME PIGS]) > 0)
				face = "snowsuit.gif";
			picker.append('<tr class="pickitem"><td class="fold">');
			picker.append(suiturl);
			picker.append('Decorate Snow Suit<br /><span style="color:#707070">Choose a Face</span></a></td><td class="icon">');
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
	}
	
	return 0;
}

int hasDrops(item it) {
	switch(it) {
		case $item[buddy bjorn]: return hasBjornDrops(my_bjorned_familiar());
		case $item[crown of thrones]: return hasBjornDrops(my_enthroned_familiar());
		case $item[pantsgiving]: return 10 - to_int(get_property("_pantsgivingCrumbs"));
		// not exactly drops per se, but it's still beneficial to have these on until you max the counter
		case $item[stinky cheese eye]: case $item[stinky cheese sword]: case $item[stinky cheese diaper]: case $item[stinky cheese wheel]: case $item[Staff of Queso Escusado]:
			return max(100 - to_int(get_property("_stinkyCheeseCount")), 0);
		// also not exactly drops per se, but... yep
		case $item[bone abacus]:
			return max(1000 - to_int(get_property("boneAbacusVictories")), 0);
	}
	
	return 0;
}

// Set familiar image, including path to image. Some familiar images are purposefully changed, others need to be normalized.
string familiar_image(familiar f) {
	switch(f) {
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

string item_image(item it, boolean modify_image)
{
	if(it == $item[none])
		return '/images/itemimages/blank.gif';

	if(modify_image)
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

	return '/images/itemimages/' + it.image;
}

string item_image(item it)
{
	return item_image(it, true);
}

void addItemIcon(buffer result, item it, string title, int danger_level, boolean modify_image) {
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
void addItemIcon(buffer result, item it, string title, int danger_level) {
	addItemIcon(result,it,title,danger_level,true);
}
void addItemIcon(buffer result, item it, string title) {
	addItemIcon(result,it,title,0);
}

int hasDrops(familiar f) {
	if(f == $familiar[gelatinous cubeling]) {
		return 3 - (min(available_amount($item[eleven-foot pole]),1) +
			min(available_amount($item[ring of detect boring doors]),1) +
			min(available_amount($item[pick-o-matic lockpicks]),1));
	} else if(f == $familiar[Rockin' Robin] && get_property("rockinRobinProgress").to_int() > 24)
		return 1;
	if(f.fights_limit > 0)
		return f.drops_limit - f.drops_today + f.fights_limit - f.fights_today;
	
	return f.drops_limit - f.drops_today;
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

// isBjorn also applies for the crown, just for the sake of a shorter name
void addFamiliarIcon(buffer result, familiar f, boolean isBjorn, boolean title) {
	familiar is100 = $familiar[none];
	if(!isBjorn)
		is100 = to_familiar(to_int(get_property("singleFamiliarRun")));

	int dropsLeft = isBjorn ? hasBjornDrops(f) : hasDrops(f);
	result.append('<img class="chit_icon');
	if(dropsLeft > 0) {
		if(f.drops_today == 0 && need_drop(f) || (f.fights_limit > 0 && f.fights_today < f.fights_limit))
			result.append(' alldrops');
		else
			result.append(' hasdrops');
	} if(is100 != $familiar[none]) {
		if(is100 != f)
			result.append(' danger');
		else
			result.append(' good');
	}
	result.append('" src="');
	result.append(familiar_image(f));
	if(title) {
		result.append('" title="');
		result.append(f.name);
		result.append(' (the ');
		result.append(f);
		result.append(')');
		string dropName = f.drop_name;
		if(dropName == "" && f.drop_item != $item[none])
			dropName = "drop";
		if(dropsLeft > 1 && dropName.length() > 1 && dropName.char_at(dropName.length() - 1) != "s")
			dropName += "s";
		if(dropsLeft > 0)
			result.append(' (' + dropsLeft + ' ' + dropName + ' remaining)');
	}
	result.append('" />');
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
  
	if(favorite_familiars().count() > 0)
	{
		picker.append('<tr class="pickitem chit_pickerblock"><td colspan="3">');
		foreach f in favorite_familiars()
		{
			if(f != current && f != my_familiar())
			{
				picker.append('<span><a class="change" href="');
				picker.append(sideCommand(cmd + ' ' + f));
				picker.append('">');
				picker.addFamiliarIcon(f, cmd != "familiar");
				picker.append('</a></span>');
			}
		}
		picker.append('</td></tr>');
	}

	int danger_level = 0;
	if(is100 != $familiar[none])
		danger_level = (is100 == current) ? 2 : -1;
	picker.append('<tr class="pickitem"><td class="icon"><a target=mainpane class="visit done" href="familiar.php">');
	picker.addItemIcon($item[Familiar-Gro&trade; Terrarium], "Visit your terrarium", danger_level);
	picker.append('</a></td><td colspan="2"><a target=mainpane class="visit done" href="familiar.php">');
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

void bakeFamiliar() {

	// Special Challenge Path Familiar-ish things
	switch(my_path()) {
	case "Avatar of Boris": FamBoris(); return;
	case "Avatar of Jarlsberg": FamJarlsberg(); return;
	case "Avatar of Sneaky Pete": FamPete(); return;
	case "Actually Ed the Undying": FamEd(); return;
	}

	string source = chitSource["familiar"];

	string famname = "Familiar";
	string famtype = '<a target=mainpane href="familiar.php" class="familiarpick">(None)</a>';
	string equipimage = "blank.gif";
	string equiptype, actortype, famweight, info, famstyle, charges, chargeTitle;
	boolean isFed = false;
	string weight_title = "Buffed Weight";
	string name_followup = "";
	
	familiar myfam = my_familiar();
	item famitem = $item[none];

	if(myfam != $familiar[none]) {
		famtype = to_string(myfam);
		actortype = famtype;
		if(myfam == $familiar[Fancypants Scarecrow])
			famtype = "Fancy Scarecrow"; // Name is too long when there's info added
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
			if(famitem == $item[Snow Suit] && have_effect($effect[SOME PIGS]) == 0) {
				int snowface = index_of(source, "itemimages/snow");
				equipimage = substring(source, snowface + 11, snowface + 24);
				info += (length(info) == 0? "": ", ") + get_property("_carrotNoseDrops")+"/3 carrots";
			} else
				equipimage = famitem.image;
		}
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
		else if(get_property("shrubGifts") == "red")
			info = info.replace_string(", Red", ", <span style='color:#FE2E2E'>Red</span>");
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
			info = '<a target=mainpane title="Configure your Mini-Crimbot" href="main.php?action=minicrimbot">' + parseMods(info) + '</a>';
		break;
	case $familiar[Puck Man]: case $familiar[Ms. Puck Man]:
		info = '<a class="visit blue-link" target="mainpane" title="Visit the Crackpot Mystic" href="shop.php?whichshop=mystic">' + to_string(item_amount($item[Yellow Pixel])) + ' yellow pixels</a>, ' + info;
		break;
	case $familiar[Machine Elf]:
		info = '<a class="visit blue-link" target="mainpane" title="The Deep Machine Tunnels" href="place.php?whichplace=dmt">' + myFam.fights_today + '/' + myFam.fights_limit + ' combats</a>, '
			+ myFam.drops_today + '/'  + myFam.drops_limit + ' snowglobe';
		break;
	case $familiar[Intergnat]:
		if(item_amount($item[BACON]) > 0) {
			if(length(info) > 0)
				info = ", " + info;
			info = '<a class="visit blue-link" target="mainpane" title="Internet Meme Shop" href="shop.php?whichshop=bacon&pwd='+my_hash()+'">' + to_string(item_amount($item[BACON])) + ' BACON</a>' + info;
		}
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
