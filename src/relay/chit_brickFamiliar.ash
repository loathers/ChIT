// The familiar picker was the invention of soolar.

void pickerLEDCandle() {
	buffer picker;
	picker.pickerStart("ledcandle", "Change lights");

	void addOption(string name, string desc, string value, string img) {
		boolean isActive = get_property("ledCandleMode") == value;

		picker.append('<tr class="pickitem');
		if(isActive) picker.append(' currentitem');
		picker.append('"><td class="icon">');
		picker.append('<img class="chit_icon" src="/images/itemimages/' + img + '" />');
		picker.append('</td><td colspan="2">');
		if(!isActive) picker.append('<a class="change" href="' + sideCommand("jillcandle " + value) + '">');
		picker.append('<b>Select</b> the ' + name + ' Light<br /><span class="descline">' + desc + '</span>');
		if(!isActive) picker.append('</a>');
		picker.append('</td></tr>');
	}

	addOption("Disco Ball", "1.5x Fairy (item)", "disco", "discoball.gif");
	addOption("Ultraviolet", "1.5x Leprechaun (meat)", "ultraviolet", "goldenlight.gif");
	addOption("Reading", "1.5x Sombreroball (stats)", "reading", "borgonette.gif");
	addOption("Red", "50% combat action rate (normally 25%)", "red light", "crystal.gif");

	picker.pickerFinish("Fiddling with your light...");
}

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
			if(famitem == $item[Snow Suit])
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
		string famname = my_path().name == "Avatar of Boris"? "Clancy": myfam.name;
		return "You don't have any " + it + " for your " + fam + ".<br><br>Poor " + famname + ".";
	}

	void pickerSnowsuit() {
		buffer picker;
		picker.pickerStart("snowsuit", "Tailor the Snow Suit");

		string current = get_property("snowsuit");

		void addFace(buffer buf, string face, string desc1, string desc2, string icon, boolean drops) {
			string imgClass = 'chit_icon';
			if(drops) {
				imgClass += ' hasdrops';
			}
			picker.pickerSelectionOption(desc1, desc2, 'snowsuit ' + face, itemimage(icon + '.gif'),
				face == current, true, attrmap { 'class': imgClass });
		}

		picker.addFace("eyebrows", "Angry Eyebrows", "(Familiar does physical damage)", "snowface1", false);
		picker.addFace("smirk", "an Ice-Cold Smirk", "(Familiar does cold damage)", "snowface2", false);
		picker.addFace("nose", "a Sensitive Carrot Nose", "(+10% item drops, can drop carrot nose)", "snowface3", to_int(get_property("_carrotNoseDrops")) < 3);
		picker.addFace("goatee", "an Entertaining Goatee", "(Heals 1-20 HP after combat)", "snowface4", false);
		picker.addFace("hat", "a Magical Hat", "(Restores 1-10 MP after combat)", "snowface5", false);

		picker.pickerFinish("Rearranging your familiar's face!");
	}

	void pickEquipment() {

		// First add a decorate link if you are using a Snow Suit
		if(equipped_item($slot[familiar]) == $item[Snow Suit]) {
			pickerSnowsuit();
			string suiturl = '<a class="chit_launcher done" rel="chit_pickersnowsuit" href="#" title="Decorate your Snow Suit\'s face">';
			picker.append('<tr class="pickitem"><td class="fold">');
			picker.append(suiturl);
			picker.append('Decorate Snow Suit<br /><span class="descline">Choose a Face</span></a></td><td class="icon">');
			picker.append(suiturl);
			picker.append('<img src="/images/itemimages/');
			switch(get_property("snowsuit")) {
				case "eyebrows": picker.append("snowface1"); break;
				case "smirk": picker.append("snowface2"); break;
				case "nose": picker.append("snowface3"); break;
				case "goatee": picker.append("snowface4"); break;
				case "hat": picker.append("snowface5"); break;
				default: picker.append("snowsuit"); break;
			}
			picker.append('.gif"></a></td></tr>');
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
			string [int] equipmap = split_string(pref, "\\|");
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

	if(available_amount($item[tiny stillsuit]) > 0) {
		picker.append('<tr class="pickitem">');
		picker.append('<td class="action" colspan="2">');
		picker.append('<a class="done" target="mainpane" href="inventory.php?action=distill&pwd=' + my_hash() + '">');
		picker.append("Check Tiny Stillsuit");
		picker.append('</a></td></tr>');
	}

	if(equipped_amount($item[LED candle]) > 0) {
		pickerLEDCandle();
		picker.append('<tr class="pickitem">');
		picker.append('<td class="action" colspan="2">');
		picker.append('<a class="chit_launcher" rel="chit_pickerledcandle" href="#">');
		picker.append("Adjust LED candle");
		picker.append('</a></td></tr>');
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
		case $familiar[Left-Hand Man]:
			picker.addLoader("Changing Off-hands...");
			pickSlot("off-hands");
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("off-hands", myfam));
			break;
		case $familiar[comma chameleon]:
			picker.addLoader("Changing Equipment...");
			pickChameleon();
			if(count(addeditems) == 0) picker.addSadFace(sadMessage("equipment", myfam));
			break;
		case $familiar[Ghost of Crimbo Carols]:
		case $familiar[Ghost of Crimbo Cheer]:
		case $familiar[Ghost of Crimbo Commerce]:
			picker.addSadFace(myfam.name + " is too incorporeal for equipment.<br><br>Poor " + myfam.name + ".");
			break;
		case $familiar[none]:
			if(my_path().name == "Avatar of Boris") {
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
	picker.pickerFinish();
}

void pickerFamiliar(familiar current, string cmd, string display)
{
	familiar is100 = to_familiar(to_int(get_property("singleFamiliarRun")));
	// if this isn't the main familiar picker we don't care about 100% runs
	if(cmd != "familiar")
		is100 = $familiar[none];

	slot correspondingSlot =
		cmd == 'familiar' ? $slot[familiar]
		: cmd == 'bjornify' ? $slot[buddy-bjorn]
		: cmd == 'enthrone' ? $slot[crown-of-thrones]
		: $slot[none];

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

	foreach i, rec in getFamRecs(correspondingSlot)
		tryAddFamiliar(rec.f, rec.reason);

	if(anyIcons)
		picker.append('</td></tr>');

	int danger_level = 0;
	if(is100 != $familiar[none])
		danger_level = (is100 == current) ? 2 : -1;
	picker.append('<tr class="pickitem"><td class="icon"><a target=mainpane class="visit done" href="familiar.php">');
	picker.addItemIcon($item[Familiar-Gro&trade; Terrarium], "Visit your terrarium");
	picker.append('</a></td>');

	picker.append('<td class="icon"><a target=charpane class="change" href="'+sideCommand("familiar none")+'">');
	picker.append('<img src='+getFamiliarInfo($familiar[none]).image+' title="Use no familiar" />');
	picker.append('</a></td>');

	picker.append('<td colspan="2"><a target=mainpane class="visit done" href="familiar.php">');
	picker.append('Visit Your Terrarium');
	picker.append('</a></td></tr>');

	picker.pickerFinish("Changing familiar...");
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

	picker.pickerFinish("Summoning Companion...");
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

	picker.pickerFinish("Summoning Servant...");
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
	matcher companion = create_matcher('images/(.*?\\.gif).*?<b>([^<]*[^<\\s])\\s*</b><br>([^<]*).*?<br>(.*?font>)', chitSource["familiar"]);
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

string ensorceleeDescription(string kolProvided) {
	boolean cloake = have_equipped($item[vampyric cloake]);
	monster ensorcelee = get_property("ensorcelee").to_monster();
	int ensorceleeLevel = get_property("ensorceleeLevel").to_int();

	switch(ensorcelee.monster_phylum()) {
		case $phylum[beast]:
			float meatDropBonus = min(max(10, ensorceleeLevel.to_float() / 2.5), 300);
			if(cloake) {
				meatDropBonus *= 1.25;
			}
			return "+" + meatDropBonus.to_int() + "% Meat Drops";
		case $phylum[bug]:
			float itemDropBonus = min(max(10, ensorceleeLevel.to_float() / 5), 300);
			if(cloake) {
				itemDropBonus *= 1.25;
			}
			return "+" + itemDropBonus.to_int() + "% Item Drops";
		default:
			return kolProvided;
	}
}

# Thanks to Cannonfire40 for FamVampyre!
# <p><font size=2><b>Ensorcelee:</b><br><img src=https://d2uyhvukfffg5a.cloudfront.net/adventureimages/olivers_gob.gif><br>Amelia Raven<br><font color=blue><b>Blocks the first attack of each combat</font>
void FamVampyre() {
	if(!have_skill($skill[Ensorcel]))
		return;
	buffer result;
	void bake(string name, string desc, string img) {
		result.append('<table id="chit_familiar" class="chit_brick nospace"><tbody>');
		result.append('<tr><th class="label" colspan="4" title="Ensorcelee">');
		result.append('Ensorcelee');
		result.append('</th></tr>');
		result.append('<tr><td title="Your Ensorcelee"><img src="' + img + '" width="50px" height="50px" /></td>');
		result.append('<td class="info" colspan="3">');
		if (name == "") {
			result.append('You have no ensorcelee, go get one!');
		} else {
			result.append(name + ' (level ' + get_property("ensorceleeLevel") + ')');
			result.append('<br>');
			result.append('<font color=blue>'+desc+'</font>');
		}
		result.append('</td>');
		result.append('</tr>');
		result.append('</tbody></table>');
	}

	matcher id = create_matcher('https://d2uyhvukfffg5a.cloudfront.net/(.+?)><br>(.+?)<br><font color=blue><b>(.+?)</font>', chitSource["familiar"]);
	if(id.find())
		bake(id.group(2), ensorceleeDescription(id.group(3)), "/images/"+id.group(1));
	else
		bake("", "", "/images/itemimages/blank.gif");

	chitBricks["familiar"] = result;
}

void bakeFamiliar() {

	// Special Challenge Path Familiar-ish things
	switch(my_path().name) {
	case "Avatar of Boris": FamBoris(); return;
	case "Avatar of Jarlsberg": FamJarlsberg(); return;
	case "Avatar of Sneaky Pete": FamPete(); return;
	case "Actually Ed the Undying": FamEd(); return;
	case "License to Adventure": return;
	case "Pocket Familiars": FamPoke(); return;
	case "Dark Gyffte": FamVampyre(); return;  // FIXME: Actual path name "Darke Gyffte", workaround for mafia for now.
	case "Darke Gyffte": FamVampyre(); return;
	case "You, Robot":
		if(get_property("youRobotTop") != "2") {
			// can't use familiars in this path without a bird cage
			return;
		}
		break;
	}

	string source = chitSource["familiar"];

	string famname = "Familiar";
	string famtype = '<a target=mainpane href="familiar.php" class="familiarpick">(None)</a>';
	string equipimage = "blank.gif";
	string equiptype, actortype, famweight, info, famstyle, charges, chargeTitle;
	boolean isFed = source.contains_text('</a></b>, the <i>extremely</i> well-fed <b>');
	string weight_title = "Buffed Weight";
	string name_followup = "";
	string mummingicon = "";

	familiar myfam = my_familiar();
	chit_info famInfo = getFamiliarInfo(myfam);
	item famitem = $item[none];

	foreach i, extra in famInfo.extra {
		buffer followbuffer;
		switch(extra.extraType) {
			case EXTRA_PICKER:
				string pickerFunc = 'picker_' + extra.str1;
				call void pickerFunc();
				followbuffer.tagStart('a', attrmap {
					'class': 'chit_launcher',
					'rel': 'chit_picker' + extra.str1,
					'href': '#',
				});
				followbuffer.append(extra.str2);
				followbuffer.tagFinish('a');
				break;
			case EXTRA_LINK:
				followbuffer.tagStart('a', extra.attrs);
				followbuffer.append(extra.str1);
				followbuffer.tagFinish('a');
				break;
			case EXTRA_EQUIPFAM:
			// todo
				break;
			default:
				abort('not there yet');
		}
		string followstr = followbuffer;
		if(followstr != '') {
			// only one of the followup type extras is supported at once atm
			if(name_followup != '') {
				print('Found a second name_followup attempt for fam ' + myfam, 'red');
			}
			name_followup = ' (' + followstr + ')';
		}
	}

	if(myfam != $familiar[none]) {
		famtype = to_string(myfam);
		actortype = famtype;
		if(myfam == $familiar[Fancypants Scarecrow])
			famtype = "Fancy Scarecrow"; // Name is too long when there's info added
		// Put the mumming trunk icon before the familiar type name
		matcher mummingmatcher = create_matcher('<a target="mainpane" href="/inv_use\\.php\\?whichitem=9592.*?</a>', source); #"
		if(find(mummingmatcher))
			mummingicon = group(mummingmatcher);
	}

	//Get Familiar Name
	matcher nameMatcher = create_matcher("<b><font size=2>(.*?)</a></b>, the", source);
	if (find(nameMatcher)){
		famname = group(nameMatcher, 1);
	}

	// Default mafia markup
	if(famInfo.desc == '') {
		matcher dropMatcher = create_matcher("<b>Familiar:</b>\\s*(\?:<br>)?\\s*\\((.*?)\\)</font>", source);
		if (find(dropMatcher)){
			famInfo.desc = group(dropMatcher, 1).replace_string("<br>", ", ");
		}
	}

	// zootomist cares a lot about familiar weight for grafting.
	// however, once level 12, this no longer matters.
	// also grey goose already shows similar info
	if(my_path() == $path[Z is for Zootomist] && my_level() < 12 && myfam != $familiar[grey goose]) {
		int goalWeight = my_level() + 2;
		int goalExp = goalWeight * goalWeight;
		float expToGo = goalExp - myfam.experience;
		int expRate = 1 + numeric_modifier('Familiar Experience');
		int combats = ceil(expToGo / expRate);
		buffer zootInfo;
		if(expToGo > 0) {
			zootInfo.append('<span title="');
			zootInfo.append(combats);
			zootInfo.append(' combats to go at a rate of ');
			zootInfo.append(expRate);
			zootInfo.append(' exp per combat">');
			zootInfo.append(ceil(expToGo));
			zootInfo.append(' exp to graft</span>');
		}
		else {
			zootInfo.append('<a target="mainpane" href="place.php?whichplace=graftinglab">can graft</a>');
		}
		famInfo.desc = zootInfo.to_string() + (famInfo.desc == '' ? '' : ', ') + famInfo.desc;
	}

	//Get Familiar Weight
	if (myfam != $familiar[none]) {
		// familiar_weight($familiar) returns the current experience based weight
		// weight_adjustment() returns the current bonuses from equipment & buffs etc.
		// fam.soup_weight tracks how much extra intrinsic weight the familiar has added from TTT soup (resets on ascension)
		famweight = to_string(familiar_weight(myfam) + weight_adjustment() + myfam.soup_weight);
	}

	//Get equipment info
	if(myfam == $familiar[Comma Chameleon]) {
		famitem = $item[none];
		equiptype = to_string(famitem);
		matcher actorMatcher = create_matcher("</b\> pound (.*?),", source);
		if (find(actorMatcher)) {
			actortype = group(actorMatcher, 1);
			equipimage = to_familiar(actortype).image;
		}
	} else {
		famitem = familiar_equipped_equipment(my_familiar());
		if(famitem != $item[none]) {
			equipimage = famitem.image;
		}
		switch(famitem) {
			case $item[Snow Suit]:
				if(have_effect($effect[SOME PIGS]) == 0) {
					switch(get_property("snowsuit")) {
						case "eyebrows": equipimage = "snowface1.gif"; break;
						case "smirk": equipimage = "snowface2.gif"; break;
						case "nose": equipimage = "snowface3.gif"; break;
						case "goatee": equipimage = "snowface4.gif"; break;
						case "hat": equipimage = "snowface5.gif"; break;
					}
					//info += (length(info) == 0? "": ", ") + get_property("_carrotNoseDrops")+"/3 carrots";
				}
				break;
			case $item[miniature crystal ball]:
				//info += (length(info) == 0 ? "" : ", ") + '<a class="visit" target="mainpane" href="inventory.php?ponder=1">ponder</a>';
				break;
			case $item[Mayflower bouquet]:
				//info += (length(info) == 0 ? "" : ", ") + get_property("_mayflowerDrops") + " flowers";
				break;
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
	if (famInfo.desc != "") {
		famInfo.desc = '<br><span style="color:#606060;font-weight:normal">(' + famInfo.desc + ')</span>';
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
	result.append('<th width="40">');
	result.append(mummingicon);
	result.append('</th><th><span title="'+ weight_title +'" style="color:blue">' + famweight + ' lb </span>');

	if (protect) {
		result.append('<span title="' + hover + '">' + famtype);
	} else {
		result.append('<span><a target=mainpane href="familiar.php" class="familiarpick" title="' + hover + '">' + famtype + '</a>');
	}
	result.append(name_followup + '</span></th>');
	if (charges == "") {
		result.append('<th width="30">&nbsp;</th>');
	} else {
		result.append('<th width="30" title="' + chargeTitle + '">' + charges + '</th>');
	}
	result.append('</tr><tr>');
	result.append('<td class="');
	if(famInfo.weirdoTag != '') result.append('weird');
	result.append('icon" title="' + hover_famicon + '">');
	if (protect) {
		result.addFamiliarIcon(myfam, false, false);
	} else {
		result.append('<a href="#" class="chit_launcher" rel="chit_pickerfamiliar">');
		result.addFamiliarIcon(myfam, false, false);
		result.append('</a>');
	}
	result.append('</td>');
	result.append('<td class="info" style="' + famstyle + '"><a title="Familiar Haiku" class="hand" onclick="fam(' + to_int(myfam) + ')" origin-level="third-party"/>' + famname + '</a>' + famInfo.desc + '</td>');
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

	if (base_weight < getFamMaxLevel(myfam)) {
		int nextGoal = 0;
		int prevGoal = 0;

		for (int i = 2; i <= getFamMaxLevel(myfam); ++i) {
			nextGoal = i * i;
			if (nextGoal > myfam.experience) {
				prevGoal = i == 2 ? 0 : (i - 1) * (i - 1);
				break;
			}
		}

		int current = myfam.experience - prevGoal;
		int limit = nextGoal - prevGoal;

		result.append('<tr><td colspan=3 class="progress">' + progressCustom(current, limit, "exp to level " + (familiar_weight(myfam) + 1), 0, true) + '</td></tr>');
	}

	result.append('</table>');
	chitBricks["familiar"] = result;

	//Add Equipment Picker
	if (myfam != $familiar[none]) {
		pickerFamiliarGear(myfam, famitem, isFed);
	}

	pickerFamiliar(myfam, "familiar", "Change familiar");
}
