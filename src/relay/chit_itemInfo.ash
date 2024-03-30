/*****************************************************
	Edpiece support
*****************************************************/
string edpieceToImage(string edpiece) {
	switch(edpiece) {
		case 'bear': return itemimage('teddybear.gif');
		case 'owl': return itemimage('owl.gif');
		case 'puma': return itemimage('blackcat.gif');
		case 'hyena': return itemimage('lionface.gif');
		case 'mouse': return itemimage('mouseskill.gif');
		case 'weasel': return itemimage('weasel.gif');
		case 'fish': return itemimage('fish.gif');
	}
	return itemimage($item[The Crown of Ed the Undying].image);
}

void picker_edpiece() {
	buffer picker;
	picker.pickerStart('edpiece', 'Adorn thy crown');

	string current = get_property('edPiece');

	void addJewel(string jewel, string desc) {
		picker.pickerSelectionOption('a golden ' + jewel, desc,
			'edpiece ' + jewel, edpieceToImage(jewel),  jewel == current);
	}

	addJewel('bear', 'Musc +20, +2 Musc exp');
	addJewel('owl', 'Myst +20, +2 Myst exp');
	addJewel('puma', 'Moxie +20, +2 Moxie exp');
	addJewel('hyena', '+20 Monster Level');
	addJewel('mouse', '+10% Items, +20% Meat');
	addJewel('weasel', 'Dodge first attack, 10-20 HP regen');
	addJewel('fish', 'Lets you breathe underwater');

	picker.pickerFinish('Cool jewels!');
}

/*****************************************************
	Daylight Shavings Helmet support
*****************************************************/
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
	effect lastBeard = get_property('lastBeardBuff').to_effect();
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

string beardToShorthand(effect beard) {
	string [effect] shorthands = {
		$effect[Spectacle Moustache]: 'item/spooky',
		$effect[Toiletbrush Moustache]: 'ML/stench',
		$effect[Barbell Moustache]: 'mus/gear',
		$effect[Grizzly Beard]: 'mp reg/cold',
		$effect[Surrealist's Moustache]: 'mys/food',
		$effect[Musician's Musician's Moustache]: 'mox/booze',
		$effect[Gull-Wing Moustache]: 'init/hot',
		$effect[Space Warlord's Beard]: 'wpn dmg/crit',
		$effect[Pointy Wizard Beard]: 'spl dmg/crit',
		$effect[Cowboy Stache]: 'rng dmg/hp/mp',
		$effect[Friendly Chops]: 'meat/sleaze'
	};

	return shorthands[beard];
}

/*****************************************************
	cursed monkey's paw support
*****************************************************/
skill monkeyPawSkill(int wishesUsed) {
	switch(wishesUsed) {
		case 0: return $skill[Monkey Slap];
		case 1: return $skill[Monkey Tickle];
		case 2: return $skill[Evil Monkey Eye];
		case 3: return $skill[Monkey Peace Sign];
		case 4: return $skill[Monkey Point];
		case 5: return $skill[Monkey Punch];
		default: return $skill[none];
	}
}

string monkeyPawSkillDesc(skill sk) {
	switch(sk) {
		case $skill[Monkey Slap]: return 'Batter up-like';
		case $skill[Monkey Tickle]: return 'Delevel';
		case $skill[Evil Monkey Eye]: return '<span class="modSpooky">Spooky damage</span> + delevel';
		case $skill[Monkey Peace Sign]: return 'Heal';
		case $skill[Monkey Point]: return 'Olfaction-like';
		case $skill[Monkey Punch]: return 'Physical damage';
		default: return '';
	}
}

/*****************************************************
	combat lover's locket support
*****************************************************/
int locketFightsRemaining() {
	string fought = get_property('_locketMonstersFought');
	if(fought.length() == 0) {
		return 3;
	}
	return max(3 - fought.split_string(',').count(), 0);
}

/*****************************************************
	retrocape support
*****************************************************/
string retroHeroToIcon(string hero) {
	switch(hero) {
		case 'muscle':
		case 'vampire':
			return 'retrocape1.gif';
		case 'mysticality':
		case 'heck':
			return 'retrocape2.gif';
		case 'moxie':
		case 'robot':
			return 'retrocape3.gif';
	}
	abort('Unrecognized hero ' + hero);
	return '';
}

string retroSupercapeCurrentSetupName() {
	string hero = get_property('retroCapeSuperhero');
	string mode = get_property('retroCapeWashingInstructions');

	switch(hero) {
		case 'vampire': // muscle
			switch(mode) {
				case 'hold': return 'resistances';
				case 'thrill': return my_primestat() == $stat[Muscle] ? 'mainstat exp' : 'mus exp';
				case 'kiss': return 'draining kiss';
				case 'kill': return 'purge evil';
			}
			break;
		case 'heck': // mysticality
			switch(mode) {
				case 'hold': return 'stun foes';
				case 'thrill': return my_primestat() == $stat[Mysticality] ? 'mainstat exp' : 'mys exp';
				case 'kiss': return 'yellow ray';
				case 'kill': return 'spooky lantern';
			}
			break;
		case 'robot': // moxie
			switch(mode) {
				case 'hold': return 'handcuff';
				case 'thrill': return my_primestat() == $stat[Moxie] ? 'mainstat exp' : 'mox exp';
				case 'kiss': return 'sleaze attack';
				case 'kill': return 'gun crit';
			}
			break;
	}

	return '???';
}

void picker_retrosupercapemeta() {
	buffer picker;
	picker.pickerStart('retrosupercapemeta', 'Switch up your cape');

	void addCombo(string name, string hero, string mode, boolean enabled) {
		boolean active = false;
		if(get_property('retroCapeSuperhero') == hero && get_property('retroCapeWashingInstructions') == mode) {
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
			picker.append(sideCommand('retrocape ' + hero + ' ' + mode));
			picker.append('"><b>CONFIGURE</b> to ');
		}
		picker.append(name);
		if(!active) picker.append('</a>');
		picker.append('</td></tr>');
	}

	string mainstatHero = my_primestat().to_string().to_lower_case();
	switch(my_primestat()) {
		case $stat[Muscle]: mainstatHero = 'vampire'; break;
		case $stat[Mysticality]: mainstatHero = 'heck'; break;
		case $stat[Moxie]: mainstatHero = 'robot'; break;
	}
	addCombo('get mainstat exp', mainstatHero, 'thrill', true);
	addCombo('yellow ray', 'heck', 'kiss', have_effect($effect[Everything Looks Yellow]) == 0);
	addCombo('purge evil', 'vampire', 'kill', true);
	addCombo('resist elements', 'vampire', 'hold', true);
	addCombo('spooky lantern', 'heck', 'kill', true);
	addCombo('stun enemies', 'heck', 'hold', true);

	picker.pickerFinish('Configuring your cape...');
}

void picker_retrosupercapeall() {
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
		boolean active = get_property('retroCapeSuperhero') == hero && get_property('retroCapeWashingInstructions') == nameShort;

		picker.append('<tr class="pickitem');
		if(active) picker.append(' currentitem');
		picker.append('"><td class="icon"><img class="chit_icon" src="/images/itemimages/');
		picker.append(retroHeroToIcon(hero));
		picker.append('" /></td><td colspan="2">');
		if(!active) {
			picker.append('<a class="change" href="');
			picker.append(sideCommand('retrocape ' + hero + ' ' + nameShort));
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
	pickerHero.pickerStart('retrosupercapeall', 'Pick a hero');
	addHero('Vampire Slicer', 'Muscle +30%, Maximum HP +50', 'vampire');
	addHero('Heck General', 'Mysticality +30%, Maximum MP +50', 'heck');
	addHero('Robot Police', 'Moxie +30%, Maximum HP/MP +25', 'robot');
	pickerHero.pickerFinish('Picking mode...');

	// Vampire picker
	pickerVampire.pickerStart('retrosupercapevampire', 'Pick a mode');
	pickerVampire.addMode('Hold Me', 'Serious Resistance to All Elements (+3)', 'vampire', 'hold', true);
	pickerVampire.addMode('Thrill Me', '+3 Muscle Stats Per Fight', 'vampire', 'thrill', true);
	pickerVampire.addMode('Kiss Me', 'Allows vampiric smooching (HP drain)', 'vampire', 'kiss', false);
	pickerVampire.addMode('Kill Me', 'Lets you instantly kill undead foes with a sword (reduces evil in Cyrpt)', 'vampire', 'kill', false);
	pickerVampire.pickerFinish('Configuring your cape...');

	// Heck picker
	pickerHeck.pickerStart('retrosupercapeheck', 'Pick a mode');
	pickerHeck.addMode('Hold Me', 'Stuns foes at the start of combat', 'heck', 'hold', false);
	pickerHeck.addMode('Thrill Me', '+3 Mysticality Stats Per Fight', 'heck', 'thrill', true);
	pickerHeck.addMode('Kiss Me', 'Lets you unleash the Devil\'s kiss (100 turn cooldown yellow ray)', 'heck', 'kiss', false);
	pickerHeck.addMode('Kill Me', 'A Heck Clown will make your spells spookier (Spooky lantern)', 'heck', 'kill', false);
	pickerHeck.pickerFinish('Configuring your cape...');

	// Robot picker
	pickerRobot.pickerStart('retrosupercaperobot', 'Pick a mode');
	pickerRobot.addMode('Hold Me', 'Allows you to handcuff opponents (Delevel attack)', 'robot', 'hold', false);
	pickerRobot.addMode('Thrill Me', '+3 Moxie Stats Per Fight', 'robot', 'thrill', true);
	pickerRobot.addMode('Kiss Me', 'Enable a Sleaze attack', 'robot', 'kiss', false);
	pickerRobot.addMode('Kill Me', 'Lets you perform a super-accurate attack with a gun (guaranteed crit)', 'robot', 'kill', false);
	pickerRobot.pickerFinish('Configuring your cape...');
}

/*****************************************************
	utility functions
*****************************************************/
void addToDesc(item_info info, string toAdd) {
	if(info.desc != '') {
		info.desc += ', ';
	}
	info.desc += toAdd;
}

// if limit is 0, the prop is a total rather than something to subtract from limit
int LIMIT_TOTAL = 0;
// if limit is -1, the prop is a boolean and you have 1 left to come if false
int LIMIT_BOOL = -1;
// if limit is -2, the prop is a boolean and you have 1 left to come if true
int LIMIT_BOOL_INVERTED = -2;

record drop_info {
	// if propName is '', limit is instead how many are left
	string propName;
	int limit;
	string singular;
	// if this is '', use singular for plural as well
	// because of how new works, can just be left off for those cases
	string plural;
};

typedef drop_info[int] drops_info;

void addDrops(item_info info, drop_info[int] drops) {
	string toAdd = '';
	boolean onlyBoolProps = true;
	foreach i, drop in drops {
		int left = 0;
		if(drop.limit == LIMIT_BOOL) {
			if(!get_property(drop.propName).to_boolean()) {
				left = 1;
			}
		}
		else if(drop.limit == LIMIT_BOOL_INVERTED) {
			if(get_property(drop.propName).to_boolean()) {
				left = 1;
			}
		}
		else if(drop.limit == LIMIT_TOTAL) {
			onlyBoolProps = false;
			left = get_property(drop.propName).to_int();
		}
		else if(drop.propName != '') {
			onlyBoolProps = false;
			left = drop.limit - get_property(drop.propName).to_int();
		}
		else {
			onlyBoolProps = false;
			left = drop.limit;
		}

		if(left > 0) {
			if(toAdd != '') {
				toAdd += '/';
			}
			if(drop.limit >= 0) {
				toAdd += left;
			}
			if(drop.plural == '') {
				drop.plural = drop.singular;
			}
			if(drop.singular.substring(0, 1) != '%') {
				toAdd += ' ';
			}
			toAdd += (left == 1) ? drop.singular : drop.plural;
		}
	}
	if(toAdd != '') {
		toAdd += onlyBoolProps ? ' available' : ' left';
		info.addToDesc(toAdd);
		info.hasDrops = true;
	}
}

familiar_info getFamiliarInfo(familiar f);

void addDrop(item_info info, drop_info drop) {
	info.addDrops(drops_info { drop });
}

void addExtra(item_info info, extra_info extra) {
	info.extra[info.extra.count()] = extra;
}

/*****************************************************
	Misc pickers
*****************************************************/
void pickerFamiliar(familiar f, string cmd, string title);

void picker_bjornify() {
	pickerFamiliar(my_bjorned_familiar(), 'bjornify', 'Change bjorned buddy :D');
}

void picker_enthrone() {
	pickerFamiliar(my_enthroned_familiar(), 'enthrone', 'Put a familiar on your head :D');
}

void picker_gap() {
	buffer picker;
	picker.pickerStart('gap', 'Activate a Superpower');

	void addSuperpower(effect power, string desc, int duration) {
		string href = sideCommand('gap ' + power.to_string().substring(6));
		picker.pickerEffectOption('Activate', power, desc, duration, href, true);
	}

	addSuperpower($effect[Super Skill], 'Combat Skills/Spells cost 0 MP', 5);
	addSuperPower($effect[Super Structure], '', 10);
	addSuperPower($effect[Super Vision], '', 20);
	addSuperPower($effect[Super Speed], '', 20);
	addSuperPower($effect[Super Accuracy], '', 10);

	picker.pickerFinish('Loading Superpowers...');
}

void picker_theforce() {
	buffer picker;
	picker.pickerStart('theforce', 'Pick an upgrade');

	void addUpgrade(int upgrade, string name, string desc, string icon) {
		picker.pickerGenericOption('Install', name, desc, '',
			sideCommand('ashq visit_url("main.php?action=may4", false); visit_url("choice.php?pwd=&whichchoice=1386&option=' + upgrade.to_string() + '");'),
			true, itemimage(icon + '.gif'));
	}

	addUpgrade(1, 'Enhanced Kaiburr Crystal', '15-20 MP regen', 'crystal');
	addUpgrade(2, 'Purple Beam Crystal', '+20 Monster Level', 'nacrystal1');
	addUpgrade(3, 'Force Resistance Multiplier', '+3 Prismatic Res', 'wonderwall');
	addUpgrade(4, 'Empathy Chip', '+10 Familiar Weight', 'spiritorb');

	picker.pickerFinish('Applying upgrade...');
}

void picker_pillkeeper() {
	buffer picker;
	picker.pickerStart('pillkeeper', 'Pop a pill');

	void addPill(string pill, string desc, string command, string icon) {
		picker.pickerGenericOption('Take', pill, desc, '', sideCommand('pillkeeper ' + command), true, itemimage(icon + '.gif'));
	}

	addPill('Explodinall', 'Force all item drops from your next fight', 'explode', 'goldenlight');
	addPill('Extendicillin', 'Double the duration of your next potion', 'extend', 'potion1');
	addPill('Sneakisol', 'Force a non-combat', 'noncombat', 'clarabell');
	addPill('Rainbowolin', 'Stupendous resistance to all elements (30 turns)', 'element', 'rrainbow');
	addPill('Hulkien', '+100% to all stats (30 turns)', 'stat', 'getbig');
	addPill('Fidoxene', 'All your familiars are at least 20 lbs (30 turns)', 'familiar', 'pill5');
	addPill('Surprise Me', 'Force a semi-rare. Even repeats!', 'semirare', 'spreadsheet');
	addPill('Telecybin', 'Adventure Randomly! (30 turns)', 'random', 'calendar');

	picker.pickerFinish('Popping pills!');
}

void picker_powerfulglove() {
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

	picker.pickerFinish("Entering cheat code...");
}

void picker_backupcamera() {
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

	picker.pickerFinish("Configuring your camera...");
}

/*****************************************************
	The bulky function itself
*****************************************************/
item_info getItemInfo(item it, slot relevantSlot) {
	item_info info;
	info.name = it.to_string();
	info.image = it.image;

	switch(it) {
		case $item[Buddy Bjorn]: {
			familiar_info bjornInfo = getFamiliarInfo(my_bjorned_familiar());
			info.image = bjornInfo.image;
			info.addDrop(new drop_info('', bjornInfo.bjornDropsLeft, bjornInfo.bjornDropName));
			info.addExtra(extraInfoPicker('bjornify', 'Pick a buddy to bjornify!'));
			break;
		}
		case $item[Crown of Thrones]: {
			familiar_info crownInfo = getFamiliarInfo(my_enthroned_familiar());
			info.image = crownInfo.image;
			info.addDrop(new drop_info('', crownInfo.bjornDropsLeft, crownInfo.bjornDropName));
			info.addExtra(extraInfoPicker('enthrone', 'Pick a buddy to enthrone!'));
			break;
		}
		case $item[Mega Gem]:
			info.dangerLevel = DANGER_GOOD;
			if(qprop('questL11Palindome')) {
				info.dangerLevel = DANGER_DANGEROUS;
				info.addToDesc('palindome cleared');
			}
			break;
		case $item[UV-resistant compass]:
		case $item[ornate dowsing rod]:
			if(get_property('desertExploration').to_int() < 100) {
				if(my_location() != $location[The Arid, Extra-Dry Desert]) {
					info.dangerLevel = DANGER_WARNING;
					info.addToDesc('not at desert');
				}
				else {
					info.dangerLevel = DANGER_GOOD;
				}
			}
			else {
				info.dangerLevel = DANGER_DANGEROUS;
				info.addToDesc('desert done');
			}
			break;
		case $item[sea chaps]:
		case $item[sea cowboy hat]:
			if(get_property('lassoTraining') == 'expertly') {
				info.dangerLevel = DANGER_WARNING;
				info.addToDesc('training complete');
			}
			break;
		case $item[backup camera]:
			string backupMonster = get_property('lastCopyableMonster');
			if(backupMonster == '') {
				backupMonster = 'nothing yet';
			}
			string toAdd = ' (' + backupMonster + ')';
			info.addDrop(new drop_info('_backupUses', my_path() == $path[You, Robot] ? 16 : 11,
				'backup' + toAdd, 'backups' + toAdd));
			if(!get_property('backupCameraReverserEnabled').to_boolean()) {
				info.dangerLevel = DANGER_DANGEROUS;
				info.addToDesc('REVERSER NOT ENABLED!');
			}
			info.addExtra(extraInfoPicker('backupcamera', 'Configure your camera (currently '
				+ get_property('backupCameraMode') + ')'));
			break;
		case $item[V for Vivala mask]:
		case $item[replica V for Vivala mask]:
			info.addDrop(new drop_info('_vmaskAdv', 10, 'adv'));
			break;
		case $item[mayfly bait necklace]:
			info.addDrop(new drop_info('_mayflySummons', 30, 'summon', 'summons'));
			break;
		case $item[pantsgiving]:
			info.addDrops(drops_info {
				new drop_info('_pantsgivingCrumbs', 10, 'crumb', 'crumbs'),
				new drop_info('_pantsgivingBanish', 5, 'banish', 'banishes'),
			});
			break;
		case $item[amulet of extreme plot significance]:
			info.name = 'amulet of plot significance';
			break;
		case $item[encrypted micro-cassette recorder]:
			info.name = 'micro-cassette recorder';
			break;
		case $item[stinky cheese eye]:
		case $item[stinky cheese sword]:
		case $item[stinky cheese diaper]:
		case $item[stinky cheese wheel]:
		case $item[Staff of Queso Escusado]: {
			drops_info drops;
			if(it == $item[stinky cheese eye]) {
				drops[drops.count()] = new drop_info('_stinkyCheeseBanisherUsed', LIMIT_BOOL, 'banish');
			}
			drops[drops.count()] = new drop_info('_stinkyCheeseCount', 100, 'stink');
			info.addDrops(drops);
			break;
		}
		case $item[bone abacus]:
			info.addDrop(new drop_info('boneAbacusVictories', 1000, 'fight', 'fights'));
			break;
		case $item[navel ring of navel gazing]:
		case $item[replica navel ring of navel gazing]:
			info.name = 'navel ring';
			// intentional fallthrough
		case $item[Greatest American Pants]:
		case $item[replica Greatest American Pants]: {
			int runs = get_property('_navelRunaways').to_int();
			if(runs < 3) {
				info.addToDesc('100% free run');
				info.hasDrops = true;
			}
			else if(runs < 6) {
				info.addToDesc('80% free run');
			}
			else if(runs < 9) {
				info.addToDesc('50% free run');
			}
			else {
				info.addToDesc('20% free run');
			}
			if(info.name != 'navel ring') {
				info.addDrop(new drop_info('_gapBuffs', 5, 'super power', 'super powers'));
				if(get_property('_gapBuffs').to_int() < 5) {
					info.addExtra(extraInfoPicker('gap', 'Activate Super Power.'));
				}
			}
			break;
		}
		case $item[Kremlin's Greatest Briefcase]:
			info.addDrops(drops_info {
				new drop_info('_kgbTranquilizerDartUses', 3, 'dart', 'darts'),
				new drop_info('_kgbDispenserUses', 3, 'drink', 'drinks'),
				new drop_info('_kgbClicksUsed', 22, 'click', 'clicks'),
			});
			info.addExtra(extraInfoGenericLink('Examine the briefcase.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'place.php?whichplace=kgb',
			}));
			break;
		case $item[deceased crimbo tree]:
			info.addDrop(new drop_info('garbageTreeCharge', LIMIT_TOTAL, 'needle', 'needles'));
			break;
		case $item[broken champagne bottle]:
			info.addDrop(new drop_info('garbageChampagneCharge', LIMIT_TOTAL, 'ounce', 'ounces'));
			break;
		case $item[makeshift garbage shirt]:
			info.addDrop(new drop_info('garbageShirtCharge', LIMIT_TOTAL, 'scrap', 'scraps'));
			break;
		case $item[FantasyRealm G. E. M.]: {
			matcher m = create_matcher('(\\d+) hours? remaining', chitSource['fantasyRealm']);
			if(find(m)) {
				int hours = m.group(1).to_int();
				info.addDrop(new drop_info('', hours, 'hour', 'hours'));
			}
			info.addExtra(extraInfoGenericLink('Visit FantasyRealm.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'place.php?whichplace=realm_fantasy',
			}));
			info.addExtra(extraInfoGenericLink('Spend Rubees.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'shop.php?whichshop=fantasyrealm',
			}));
			break;
		}
		case $item[latte lovers member's mug]:
			info.name = 'latte';
			info.addDrops(drops_info {
				new drop_info('_latteRefillsUsed', 3, 'refill', 'refills'),
				new drop_info('_latteBanishUsed', LIMIT_BOOL, 'throw'),
				new drop_info('_latteCopyUsed', LIMIT_BOOL, 'share'),
				new drop_info('_latteDrinkUsed', LIMIT_BOOL, 'gulp'),
			});
			if(get_property('_latteRefillsUsed').to_int() < 3) {
				info.addExtra(extraInfoGenericLink('Get a refill.', attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'main.php?latte=1',
				}));
			}
			break;
		case $item[Lil' Doctor&trade; bag]:
			info.addDrops(drops_info {
				new drop_info('_otoscopeUsed', 3, 'otoscope', 'otoscopes'),
				new drop_info('_reflexHammerUsed', 3, 'hammer', 'hammers'),
				new drop_info('_chestXRayUsed', 3, 'x-ray', 'x-rays'),
			});
			break;
		case $item[Red Roger's red left foot]:
			info.addToDesc('island');
			break;
		case $item[Red Roger's red right foot]:
			info.addToDesc('sailing');
			break;
		case $item[Fourth of May Cosplay Saber]:
		case $item[replica Fourth of May Cosplay Saber]: {
			boolean unmodded = get_property('_saberMod') == '0';
			info.addDrops(drops_info {
				new drop_info('', unmodded ? 1 : 0, 'saber mod'),
				new drop_info('_saberForceUses', 5, 'force', 'forces'),
			});
			if(unmodded) {
				info.addExtra(extraInfoPicker('theforce', 'Install daily upgrade'));
			}
			break;
		}
		case $item[Beach Comb]:
			info.addDrop(new drop_info('_freeBeachWalksUsed', 11, 'free comb', 'free combs'));
			info.addExtra(extraInfoGenericLink('Comb the beach', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'main.php?comb=1',
			}));
			break;
		case $item[Powerful Glove]:
		case $item[replica Powerful Glove]:
			info.addDrop(new drop_info('_powerfulGloveBatteryPowerUsed', 100, '% battery'));
			if(get_property('_powerfulGloveBatteryPowerUsed').to_int() < 100) {
				info.addExtra(extraInfoPicker('powerfulglove', 'Enter a cheat code!'));
			}
			break;
		case $item[[10462]fire flower]:
			info.name = 'fire flower';
			break;
		case $item[vampyric cloake]:
			info.addDrop(new drop_info('_vampyreCloakeFormUses', 10, 'tranformation', 'transformations'));
			break;
		case $item[Cargo Cultist Shorts]:
		case $item[replica Cargo Cultist Shorts]:
			info.addDrop(new drop_info('_cargoPocketEmptied', LIMIT_BOOL, 'pocket'));
			if(!get_property('_cargoPocketEmptied').to_boolean()) {
				string[int] pocketsEmptied = get_property('cargoPocketsEmptied').split_string(',');
				int pocketsLeft = 666 - pocketsEmptied.count();
				info.addExtra(extraInfoGenericLink('Pick a pocket', attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'inventory.php?action=pocket',
				}));
			}
			break;
		case $item[familiar scrapbook]:
			info.addDrop(new drop_info('scrapbookCharges', LIMIT_TOTAL, 'scrap', 'scraps'));
			break;
		case $item[industrial fire extinguisher]:
		case $item[replica industrial fire extinguisher]:
			info.addDrop(new drop_info('_fireExtinguisherCharge', LIMIT_TOTAL, '%'));
			break;
		case $item[mafia thumb ring]: {
			int thumbAdvs = get_property('_mafiaThumbRingAdvs').to_int();
			if(thumbAdvs > 0) {
				info.addToDesc(thumbAdvs + ' adv gained');
			}
			break;
		}
		case $item[Daylight Shavings Helmet]: {
			effect nextBeard = getNextBeard();
			if(nextBeard != $effect[none]) {
				info.addToDesc(beardToShorthand(nextBeard) + (getCurrBeard() != $effect[none] ? ' next' : ' due'));
			}
			break;
		}
		case $item[cursed magnifying glass]:
			info.addToDesc(get_property('cursedMagnifyingGlassCount') + '/13 charge');
			info.addDrop(new drop_info('_voidFreeFights', 5, 'free'));
			break;
		case $item[combat lover's locket]:
			info.addDrop(new drop_info('', locketFightsRemaining(), 'reminiscence', 'reminiscences'));
			break;
		case $item[unbreakable umbrella]:
			info.addToDesc(get_property('umbrellaState'));
			break;
		case $item[June cleaver]: {
			int juneFights = get_property('_juneCleaverFightsLeft').to_int();
			if(juneFights == 0) {
				info.hasDrops = true;
				info.addToDesc('noncom now!');
			}
			else {
				info.addToDesc(juneFights + ' to noncom');
			}
			break;
		}
		case $item[designer sweatpants]:
		case $item[replica designer sweatpants]:
			info.addDrops(drops_info {
				new drop_info('sweat', LIMIT_TOTAL, '% sweat'),
				new drop_info('_sweatOutSomeBoozeUsed', 3, 'booze sweat', 'booze sweats'),
			});
			break;
		case $item[Jurassic Parka]:
		case $item[replica Jurassic Parka]: {
			string parkaMode = get_property('parkaMode');
			if(parkaMode.length() > 0) {
				info.addToDesc(parkaMode + ' mode');
			}
			break;
		}
		case $item[cursed monkey's paw]: {
			info.addDrop(new drop_info('_monkeyPawWishesUsed', 5, 'wish', 'wishes'));
			int wishesUsed = max(0, min(5, get_property('_monkeyPawWishesUsed').to_int()));
			info.image = itemimage('monkeypaw' + wishesUsed + '.gif');
			break;
		}
		case $item[Cincho de Mayo]:
		case $item[replica Cincho de Mayo]:
			info.addDrop(new drop_info('_cinchUsed', 100, 'cinch'));
			break;
		case $item[august scepter]:
		case $item[replica august scepter]: {
			drops_info drops = { new drop_info('_augSkillsCast', 5, 'skill', 'skills') };
			if(can_interact()) {
				drops[drops.count()] = new drop_info('_augTodayCast', LIMIT_BOOL, 'today');
			}
			info.addDrops(drops);
			break;
		}
		case $item[carnivorous potted plant]: {
			int kills = get_property('_carnivorousPottedPlantWins').to_int();
			info.addToDesc(kills + ' free kills [' + (1.0 / (20.0 + kills) * 100) + '% swallow chance]');
			break;
		}
		case $item[The Crown of Ed the Undying]: {
			string currPiece = get_property('edPiece');
			if(currPiece == '') {
				currPiece = 'none';
			}
			info.addExtra(extraInfoPicker('edpiece','Change decoration (currently ' + currPiece + ')',
				edpieceToImage(currPiece)));
			break;
		}
		case $item[Jarlsberg's pan]:
			info.addExtra(extraInfoFoldable('Shake Portal Open'));
			break;
		case $item[Jarlsberg's pan (Cosmic portal mode)]:
			info.addExtra(extraInfoFoldable('Shake Portal Closed'));
			break;
		case $item[Boris's Helm]:
			info.addExtra(extraInfoFoldable('Twist Horns Askew'));
			break;
		case $item[Boris's Helm (askew)]:
			info.addExtra(extraInfoFoldable('Untwist Horns'));
			break;
		case $item[Sneaky Pete's leather jacket]:
			info.addExtra(extraInfoFoldable('Pop Collar Aggressively'));
			break;
		case $item[Sneaky Pete's leather jacket (collar popped)]:
			info.addExtra(extraInfoFoldable('Unpop Collar'));
			break;
			/* relevant foldable code
			item other = fold_from(in_slot);
			start_option(other, true);
			picker.append('<td colspan="2"><a class="change" href="');
			picker.append(sideCommand("fold " + other));
			picker.append('">');
			picker.append(cmd);
			picker.append('</a></td></tr>');
			*/
		case $item[over-the-shoulder Folder Holder]:
		case $item[replica over-the-shoulder Folder Holder]:
			info.addExtra(extraInfoGenericLink('Manage your folders.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?action=useholder',
			}));
			break;
		case $item[fish hatchet]:
			string floundryText = 'Get Wood';
			// intentional fallthrough
		case $item[codpiece]:
			if(floundryText == '') floundryText = 'Wring Out';
			// intentional fallthrough one more time
		case $item[bass clarinet]:
			if(floundryText == '') floundryText = 'Drain Spit';
			if(!get_property('_floundryItemUsed').to_boolean()) {
				info.addExtra(extraInfoGenericLink(floundryText, attrmap {
					'class': 'change',
					'href': sideCommand('use 1 ' + it.to_string() + '; equip '
						+ relevantSlot.to_string() + ' ' + it.to_string()),
				}));
			}
			break;
		case $item[PirateRealm eyepatch]:
			info.addExtra(extraInfoGenericLink('Spend Rubees.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'place.php?whichplace=realm_pirate',
			}));
			break;
		case $item[Kramco Sausage-o-Matic&trade;]:
		case $item[replica Kramco Sausage-o-Matic&trade;]: {
			string linkText = 'Grind (' + available_amount($item[magical sausage casing]).formatInt()
				+ ' casings available):<br />' + get_property('sausageGrinderUnits').to_int().formatInt()
				+ '/' + (111 * (1 + get_property('_sausagesMage').to_int())).formatInt()
				+ ' units.<br />' + get_property('_sausageFights').to_int().formatInt()
				+ ' goblins encountered today.';
			info.addExtra(extraInfoGenericLink(linkText, attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?action=grind',
			}));
		}
		case $item[Eight Days a Week Pill Keeper]:
			info.addDrop(new drop_info('_freePillKeeperUsed', LIMIT_BOOL, 'free pill'));
			if(!get_property('_freePillKeeperUsed').to_boolean() || (spleen_limit() - my_spleen_use() >= 3)) {
				info.addExtra(extraInfoPicker('pillkeeper', 'Pop a pill!'));
			}
			break;
		case $item[Guzzlr tablet]:
			info.addExtra(extraInfoGenericLink('Tap tablet', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?tap=guzzlr',
			}));
			break;
		case $item[unwrapped knock-off retro superhero cape]:
			info.addExtra(extraInfoPicker('retrosupercapemeta', 'Change to optimal setups!'));
			info.addExtra(extraInfoPicker('retrosupercapeall', 'Change to any setup!'));
			info.addToDesc(retroSupercapeCurrentSetupName());
			break;
	}

	// latte reminder
	if(relevantSlot == $slot[off-hand] && vars['chit.gear.lattereminder'].to_boolean() &&
		my_location().latteDropAvailable() && it != $item[latte lovers member's mug] &&
		!it.isImportantOffhand() && info.dangerLevel < DANGER_WARNING) {
		info.dangerLevel = DANGER_WARNING;
	}

	// pirate hat reminder
	if(relevantSlot == $slot[hat] && item_amount($item[PirateRealm party hat]) > 0 &&
		equipped_amount($item[PirateRealm party hat]) == 0 && equipped_amount($item[PirateRealm eyepatch]) > 0
		&& info.dangerLevel < DANGER_WARNING) {
		info.dangerLevel = DANGER_WARNING;
	}

	// pirate foot reminder
	item rlf = $item[Red Roger's red left foot];
	item rrf = $item[Red Roger's red right foot];
	if($slots[acc1, acc2, acc3] contains relevantSlot && item_amount(rlf) > 0 && item_amount(rrf) > 0
		&& equipped_amount(rlf) + equipped_amount(rrf) == 0 && equipped_amount($item[PirateRealm eyepatch]) > 0
		&& !($items[PirateRealm eyepatch, Red Roger's red left foot, Red Roger's red right foot] contains it)
		&& info.dangerLevel < DANGER_WARNING) {
		info.dangerLevel = DANGER_WARNING;
	}

	return info;
}

item_info getItemInfo(item it) {
	return getItemInfo(it, to_slot(it));
}
