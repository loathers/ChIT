/*****************************************************
	Edpiece support
*****************************************************/
string edpieceToImage(string edpiece) {
	switch(edpiece) {
		case 'bear': return itemimage('teddybear.gif');
		case 'owl': return itemimage('owl.gif');
		case 'puma': return itemimage('blackcat.gif');
		case 'hyena': return itemimage('lionface.gif');
		case 'mouse': return itemimage('mouseskull.gif');
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
			'edpiece ' + jewel, edpieceToImage(jewel), jewel == current);
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
boolean [effect] beardList = $effects[
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
];

effect [int] getBeardOrder() {
	effect [int] baseBeardOrder;
	foreach beard in beardList {
		baseBeardOrder[baseBeardOrder.count()] = beard;
	}
	effect [int] beardOrder;
	int classId = my_class().to_int();
	int classIdMod = ((classId<=6)?classId:(classId+1))% 6;
	if(classIdMod == 0) {
		classIdMod = 6;
	}
	for(int i = 0; i < 11; ++i) {
		int nextBeard = (classIdMod * i) % 11;
		beardOrder[i] = baseBeardOrder[nextBeard];
	}

	return beardOrder;
}

effect getCurrBeard() {
	foreach beard in beardList {
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
	switch(beard) {
		case $effect[Spectacle Moustache]: return 'item/spooky';
		case $effect[Toiletbrush Moustache]: return 'ML/stench';
		case $effect[Barbell Moustache]: return 'mus/gear';
		case $effect[Grizzly Beard]: return 'mp reg/cold';
		case $effect[Surrealist's Moustache]: return 'mys/food';
		case $effect[Musician's Musician's Moustache]: return 'mox/booze';
		case $effect[Gull-Wing Moustache]: return 'init/hot';
		case $effect[Space Warlord's Beard]: return 'wpn dmg/crit';
		case $effect[Pointy Wizard Beard]: return 'spl dmg/crit';
		case $effect[Cowboy Stache]: return 'rng dmg/hp/mp';
		case $effect[Friendly Chops]: return 'meat/sleaze';
		default: return '';
	}
}

// This isn't really a picker, it just uses the picker layout
void picker_fakebeard() {
	buffer picker;
	picker.pickerStart('fakebeard', 'Check out beard ordering');

	void addBeard(effect beard) {
		picker.pickerEffectOption('', beard, '', 0, '', have_effect(beard) == 0);
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

	picker.pickerFinish();
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
			return itemimage('retrocape1.gif');
		case 'mysticality':
		case 'heck':
			return itemimage('retrocape2.gif');
		case 'moxie':
		case 'robot':
			return itemimage('retrocape3.gif');
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

	void addCombo(string name, string hero, string mode, boolean enabled, string desc) {
		boolean active = false;
		if(get_property('retroCapeSuperhero') == hero && get_property('retroCapeWashingInstructions') == mode) {
			active = true;
		}

		picker.pickerSelectionOption(name, desc, 'retrocape ' + hero + ' ' + mode,
			retroHeroToIcon(hero), active, enabled);
	}

	string mainstatHero = my_primestat().to_string().to_lower_case();
	switch(my_primestat()) {
		case $stat[Muscle]: mainstatHero = 'vampire'; break;
		case $stat[Mysticality]: mainstatHero = 'heck'; break;
		case $stat[Moxie]: mainstatHero = 'robot'; break;
	}
	addCombo('get mainstat exp', mainstatHero, 'thrill', true, '+3 exp');
	addCombo('yellow ray', 'heck', 'kiss', have_effect($effect[Everything Looks Yellow]) == 0, 'Unleash the Devil\'s Kiss');
	addCombo('purge evil', 'vampire', 'kill', true, 'requires a sword');
	addCombo('resist elements', 'vampire', 'hold', true, parseMods('Prismatic Resistance +3'));
	addCombo('spooky lantern', 'heck', 'kill', true, 'duplicates spell damage as spooky');
	addCombo('stun enemies', 'heck', 'hold', true, 'at combat start');

	picker.pickerFinish('Configuring your cape...');
}

void picker_retrosupercapeall() {
	buffer pickerHero, pickerVampire, pickerHeck, pickerRobot;

	void addHero(string name, string desc, string picker) {
		pickerHero.pickerPickerOption(name, parseMods(desc), '', 'retrosupercape' + picker, retroHeroToIcon(picker));
	}

	void addMode(buffer picker, string name, string desc, string hero, string nameShort, boolean parse) {
		boolean active = get_property('retroCapeSuperhero') == hero && get_property('retroCapeWashingInstructions') == nameShort;

		picker.pickerSelectionOption(name, parse ? parseMods(desc) : desc,
			'retrocape ' + hero + ' ' + nameShort, retroHeroToIcon(hero), active);
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
	apriling band helmet support
*****************************************************/
boolean [effect] aprilingBandSongs = $effects[
	Apriling Band Patrol Beat,
	Apriling Band Battle Cadence,
	Apriling Band Celebration Bop,
];

boolean [item] aprilingBandSectionInstruments = $items[
	Apriling band saxophone,
	Apriling band quad tom,
	Apriling band tuba,
	Apriling band staff,
	Apriling band piccolo,
];

string [item] aprilingBandSectionInstrumentProps = {
	$item[Apriling band saxophone]: '_aprilBandSaxophoneUses',
	$item[Apriling band quad tom]: '_aprilBandTomUses',
	$item[Apriling band tuba]: '_aprilBandTubaUses',
	$item[Apriling band staff]: '_aprilBandStaffUses',
	$item[Apriling band piccolo]: '_aprilBandPiccoloUses',
};

string [item] aprilingBandSectionInstrumentAbilities = {
	$item[Apriling band saxophone]: 'Get Lucky!',
	$item[Apriling band quad tom]: 'Free fight a sandworm',
	$item[Apriling band tuba]: 'Force a noncom',
	$item[Apriling band staff]: 'Get a random effect',
	$item[Apriling band piccolo]: 'Give current fam +40 exp',
};

int aprilingBandSectionsEnrolled() {
	return get_property('_aprilBandInstruments').to_int();
}

void picker_aprilbandsong() {
	buffer picker;
	picker.pickerStart('aprilbandsong', 'Conduct the Band');

	int choiceNum = 1;
	foreach eff in aprilingBandSongs {
		string cmd = 'ashq visit_url("inventory.php?pwd=' + my_hash() + '&action=apriling"); '
			+ 'visit_url("choice.php?pwd=' + my_hash() + '&whichchoice=1526&option=' + choiceNum + '");';
		picker.pickerEffectOption('Conduct', 'the ' + eff, eff, '', -1, sideCommand(cmd), have_effect(eff) == 0);
		++choiceNum;
	}

	picker.pickerFinish('Conducting the Band...');
}

void picker_aprilbandsection() {
	buffer picker;
	picker.pickerStart('aprilbandsection', 'Join a Section (' + (2 - aprilingBandSectionsEnrolled())
		+ ' left)');

	void sectionOption(item it, string section, int choiceNum) {
		string cmd = 'ashq visit_url("inventory.php?pwd=' + my_hash() + '&action=apriling"); '
			+ 'visit_url("choice.php?pwd=' + my_hash() + '&whichchoice=1526&option=' + choiceNum + '");';
		string desc = parseMods(string_modifier(it, 'Evaluated Modifiers')) + '<br />'
			+ aprilingBandSectionInstrumentAbilities[it] + ' 3x per day';
		boolean have = available_amount(it) > 0;
		string name = 'the ' + section;
		if(have) {
			name = '<b>Joined</b> ' + name;
		}
		picker.pickerItemOption(it, 'Join', name, desc, '', sideCommand(cmd), !have);
	}

	sectionOption($item[Apriling band saxophone], 'sax section', 4);
	sectionOption($item[Apriling band quad tom], 'percussion section', 5);
	sectionOption($item[Apriling band tuba], 'tuba section', 6);
	sectionOption($item[Apriling band staff], 'drum majors', 7);
	sectionOption($item[Apriling band piccolo], 'piccolo section', 8);

	picker.pickerFinish('Joining a Section...');
}

/*****************************************************
	Candy Cane Sword support
*****************************************************/
int CCSWORD_NONE = 0;
int CCSWORD_UNLIMITED = 1;
int CCSWORD_LIFETIME = 2;
int CCSWORD_DAILY = 3;

// no propSuffix for unlimited
record CCSwordZoneInfo {
	string propSuffix;
	boolean isImportant;
	int type;
	string desc;
};

boolean canDo(CCSwordZoneInfo ccscInfo) {
	if(ccscInfo.type == CCSWORD_UNLIMITED) {
		return true;
	}
	else if(ccscInfo.type == CCSWORD_NONE) {
		return false;
	}

	string prop = 'candyCaneSword' + ccscInfo.propSuffix;
	if(ccscInfo.type == CCSWORD_DAILY) {
		prop = '_' + prop;
	}
	return !get_property(prop).to_boolean();
}

CCSwordZoneInfo getCCSwordZoneInfo(location l) {
	switch(l) {
		// new CCSwordZoneInfo('Lyle', false, CCSWORD_DAILY, 'peppermint rush'); no location to associate
		case $location[The Sleazy Back Alley]: return new CCSwordZoneInfo('BackAlley', true, CCSWORD_DAILY, 'clover');
		case $location[The Overgrown Lot]: return new CCSwordZoneInfo('OvergrownLot', false, CCSWORD_DAILY, 'herbs');
		case $location[Madness Bakery]: return new CCSwordZoneInfo('MadnessBakery', false, CCSWORD_DAILY, 'peppermint donut');
		case $location[The Haunted Bedroom]: return new CCSwordZoneInfo('HauntedBedroom', false, CCSWORD_DAILY, 'lucky-ish pill');
		case $location[The Haunted Library]: return new CCSwordZoneInfo('HauntedLibrary', false, CCSWORD_DAILY, 'sword + substats');
		case $location[The Shore\, Inc. Travel Agency]: return new CCSwordZoneInfo('Shore', true, CCSWORD_LIFETIME, '2 scrip, stats, buff');
		case $location[The Black Forest]: return new CCSwordZoneInfo('BlackForest', true, CCSWORD_LIFETIME, 'exploration progress');
		case $location[The Spooky Forest]: return new CCSwordZoneInfo('SpookyForest', false, CCSWORD_DAILY, 'fruits');
		case $location[The Daily Dungeon]: return new CCSwordZoneInfo('Daily Dungeon', true, CCSWORD_LIFETIME, 'fat loot token');
		case $location[South of the Border]: return new CCSwordZoneInfo('SouthOfTheBorder', false, CCSWORD_DAILY, 'fam exp buff');
		case $location[The Penultimate Fantasy Airship]: return new CCSwordZoneInfo('', false, CCSWORD_UNLIMITED, 'sgeea and stuff');
		case $location[The Castle in the Clouds in the Sky (Basement)]:
			return new CCSwordZoneInfo('', false, CCSWORD_UNLIMITED, 'bit of meat and stats');
		case $location[A Mob of Zeppelin Protesters]: return new CCSwordZoneInfo('', true, CCSWORD_UNLIMITED, 'double sleaze removal');
		case $location[The Copperhead Club]: return new CCSwordZoneInfo('CopperheadClub', true, CCSWORD_LIFETIME, 'diamond and gong cut');
		case $location[Inside the Palindome]:
			if(get_property('questL11Palindome') == 'finished') {
				return new CCSwordZoneInfo('Palindome', false, CCSWORD_DAILY, 'papayas');
			}
			break;
		case $location[The eXtreme Slope]: return new CCSwordZoneInfo('', false, CCSWORD_UNLIMITED, 'eXtreme route help');
		case $location[An Overgrown Shrine (Northeast)]: return new CCSwordZoneInfo('OvergrownShrine', false, CCSWORD_DAILY, '100xLevel meat (free)');
		case $location[The Hidden Apartment Building]: return new CCSwordZoneInfo('ApartmentBuilding', true, CCSWORD_LIFETIME, '+1 curse level (free)');
		case $location[The Hidden Bowling Alley]: return new CCSwordZoneInfo('BowlingAlley', true, CCSWORD_LIFETIME, '-1 ball needed');
		// is this daily or lifetime? Mafia property has no _ but wiki says daily...
		case $location[The Defiled Cranny]: return new CCSwordZoneInfo('DefiledCranny', false, CCSWORD_LIFETIME, '-11 evil (NOT free)');
		case $location[Wartime Hippy Camp (Frat Disguise)]:
		case $location[Wartime Frat House (Hippy Disguise)]:
			// there are properties for the individual noncoms but if you've used one you wouldn't be verge of war
			// any more, so just treat it unlimited
			return new CCSwordZoneInfo('', true, CCSWORD_UNLIMITED, 'easy war start');
		case $location[The "Fun" House]: return new CCSwordZoneInfo('FunHouse', false, CCSWORD_LIFETIME, '+25% clownosity');
	}
	return new CCSwordZoneInfo('', false, CCSWORD_NONE, '');
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

	void addUpgrade(string upgrade, string name, string desc, string icon) {
		picker.pickerGenericOption('Install', name, desc, '', sideCommand('saber ' + upgrade),
			true, itemimage(icon + '.gif'));
	}

	addUpgrade('mp', 'Enhanced Kaiburr Crystal', '15-20 MP regen', 'crystal');
	addUpgrade('ml', 'Purple Beam Crystal', '+20 Monster Level', 'nacrystal1');
	addUpgrade('resistance', 'Force Resistance Multiplier', '+3 Prismatic Res', 'wonderwall');
	addUpgrade('familiar', 'Empathy Chip', '+10 Familiar Weight', 'spiritorb');

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
	int batteryLeft = 100 - get_property('_powerfulGloveBatteryPowerUsed').to_int();
	picker.pickerStart('powerfulglove', 'Cheat at life (' + batteryLeft + '% left)');

	void addCheat(skill cheat, string desc, int battery) {
		picker.pickerSkillOption(cheat, desc, battery + '% battery', battery <= batteryLeft);
	}

	addCheat($skill[CHEAT CODE: Invisible Avatar], '-10% combat rate for 10 turns', 5);
	addCheat($skill[CHEAT CODE: Triple Size], '+200% all stats for 20 turns', 5);
	addCheat($skill[CHEAT CODE: Replace Enemy], 'Fight something else from the same zone', 10);
	addCheat($skill[CHEAT CODE: Shrink Enemy], 'Cut enemy hp/attack/defense in half', 5);

	picker.pickerFinish('Entering cheat code...');
}

void picker_backupcamera() {
	buffer picker;
	picker.pickerStart('backupcamera', 'Configure your camera');

	void addSetting(string name, string desc, string command, string icon) {
		boolean active = get_property('backupCameraMode') == command;
		picker.pickerSelectionOption(name, desc, 'backupcamera ' + command, itemimage(icon), active);
	}

	addSetting('Infrared Spectrum', '+50% Meat Drops', 'meat', 'meat.gif');
	addSetting('Warning Beep', '+' + (min(3 * my_level(), 50).to_string()) + ' ML (scales with level)', 'ml', 'angry.gif');
	addSetting('Maximum Framerate', '+100% Initiative', 'init', 'fast.gif');

	picker.pickerFinish('Configuring your camera...');
}

void picker_unbrella() {
	buffer picker;
	picker.pickerStart('unbrella', 'Reconfigure your unbrella');

	void addSetting(string name, string desc, string command, string icon) {
		boolean active = get_property('umbrellaState') == name;
		picker.pickerSelectionOption(name, desc, 'umbrella ' + command, itemimage(icon), active);
	}

	addSetting('broken', '+25% ML', 'broken', 'unbrella7.gif');
	addSetting('forward-facing', '+25 DR, Shield', 'forward', 'unbrella3.gif');
	addSetting('bucket style', '+25% Item Drop', 'bucket', 'unbrella5.gif');
	addSetting('pitchfork style', '+25 Weapon Damage', 'pitchfork', 'unbrella8.gif');
	addSetting('constantly twirling', '+25 Spell Damage', 'twirling', 'unbrella6.gif');
	addSetting('cocoon', '-10% combat', 'cocoon', 'unbrella1.gif');

	picker.pickerFinish('Reconfiguring your unbrella');
}

void picker_sweatpants() {
	buffer picker;
	int sweat = get_property('sweat').to_int();
	int sweatboozeleft = 3 - get_property('_sweatOutSomeBoozeUsed').to_int();
	picker.pickerStart('sweatpants', 'Sweat Magic (' + sweat + '% sweaty)');

	void addSweatSkill(skill sk, string desc, int cost) {
		boolean noBooze = (sk == $skill[Sweat Out Some Booze])
			&& (get_property('_sweatOutSomeBoozeUsed').to_int() >= 3);
		boolean canCast = !sk.combat && cost <= sweat && !noBooze;

		if(noBooze) {
			desc += '<br />(Already used up for today)';
		}
		else if(sweat < cost) {
			desc += '<br />(Not enough sweat!)';
		}

		picker.pickerSkillOption(sk, desc, cost + ' sweat', canCast);
	}

	addSweatSkill($skill[Sip Some Sweat], 'Restore 50 MP', 5);
	addSweatSkill($skill[Drench Yourself in Sweat], '+100% Init for 5 turns', 15);
	addSweatSkill($skill[Sweat Out Some Booze], 'Cleanse 1 liver (' + sweatboozeleft
		+ ' left today)', 25);
	addSweatSkill($skill[Make Sweat-Ade], 'Does what the skill name says', 50);
	addSweatSkill($skill[Sweat Flick], 'Deals sweat sleaze damage', 1);
	addSweatSkill($skill[Sweat Spray], 'Deal minor sleaze damage for the rest of combat', 3);
	addSweatSkill($skill[Sweat Flood], 'Stun for 5 rounds', 5);
	addSweatSkill($skill[Sweat Sip], 'Restore 50 MP', 5);

	picker.pickerFinish('Sweating the small stuff...');
}

void picker_jurassicparka() {
	buffer picker;
	string currMode = get_property('parkaMode');
	int yellowTurns = have_effect($effect[Everything Looks Yellow]);
	int spikesLeft = 5 - get_property('_spikolodonSpikeUses').to_int();
	picker.pickerStart('jurassicparka', 'Change Parka Mode');

	void addMode(string name, string desc, string image) {
		boolean current = currMode == name;
		picker.pickerSelectionOption(name + ' mode', desc, 'parka ' + name, itemimage(image), current);
	}

	addMode('kachungasaur', 'Max HP +100%, +50% Meat Drop, +2 Cold Res', 'jparka8.gif');
	addMode('dilophosaur', '+20 All Sleaze Damage, +2 Stench Res, Free Kill Yellow Ray ('
		+ (yellowTurns > 0 ? (yellowTurns + ' adv until usable') : 'ready') + ')', 'jparka3.gif');
	addMode('spikolodon', '+' + min(3 * my_level(), 33) + ' ML, +2 Sleaze Res, '
		+ (spikesLeft > 0 ? spikesLeft.to_string() : 'no') + ' non-com forces left', 'jparka2.gif');
	addMode('ghostasaurus', '10 DR, +50 Max MP, +2 Spooky Res', 'jparka1.gif');
	addMode('pterodactyl', '+5% noncom, +50% init, +2 Hot Res', 'jparka9.gif');

	picker.pickerFinish('Pulling dino tab...');
}

void picker_cincho() {
	int cinch = 100 - get_property('_cinchUsed').to_int();

	buffer picker;
	picker.pickerStart('cincho', 'Use some cinch (' + cinch + ' available)');

	void addSkill(skill sk, string desc, int cinchCost) {
		picker.pickerSkillOption(sk, desc, cinchCost + ' cinch', cinch >= cinchCost);
	}

	addSkill($skill[Cincho: Confetti Extravaganza], 'Double substats from this fight, but get smacked', 5);
	addSkill($skill[Cincho: Dispense Salt and Lime], 'Triples stat gain from next drink', 25);
	addSkill($skill[Cincho: Fiesta Exit], 'Force a noncom', 60);
	addSkill($skill[Cincho: Party Foul], 'Damage, weaken, and stun', 5);
	addSkill($skill[Cincho: Party Soundtrack], '30 adv +5lbs', 25);
	addSkill($skill[Cincho: Projectile Piñata], 'Damage, stun, get candy', 5);

	picker.pickerFinish('Using Cinch...');
}

void picker_august() {
	int used = get_property('_augSkillsCast').to_int();
	int usable = 5;
	int today = today_to_string().to_int() % 100;
	if(can_interact()) {
		++usable;
		if(get_property('_augTodayCast').to_boolean()) {
			++used;
		}
	}

	buffer picker;
	picker.pickerStart('august', 'Celebrate some holidays (' + used + '/' + usable + ' used)');

	void addSkill(skill sk, int num, string desc) {
		boolean canUse = !get_property('_aug' + num + 'Cast').to_boolean();
		picker.pickerSkillOption(sk, desc, (can_interact() && num == today) ? 'free today' : '', canUse);
	}

	addSkill($skill[Aug. 1st: Mountain Climbing Day!], 1, '30 adv effect that gives bonuses in mountains.');
	addSkill($skill[Aug. 2nd: Find an Eleven-Leaf Clover Day], 2, 'Become Lucky!');
	addSkill($skill[Aug. 3rd: Watermelon Day!], 3, 'Acquire 1 watermelon (big food that gives seeds).');
	addSkill($skill[Aug. 4th: Water Balloon Day!], 4, 'Acquire 3 water balloons (usable for effect/trophy).');
	addSkill($skill[Aug. 5th: Oyster Day!], 5, 'Acquire 3 random oyster eggs.');
	addSkill($skill[Aug. 6th: Fresh Breath Day!], 6, '30 adv effect +moxie +combat.');
	addSkill($skill[Aug. 7th: Lighthouse Day!], 7, '30 adv effect +item +meat.');
	addSkill($skill[Aug. 8th: Cat Day!], 8, 'Free fight a random cat.');
	addSkill($skill[Aug. 9th: Hand Holding Day!], 9, '1 use of a minor olfaction.');
	addSkill($skill[Aug. 10th: World Lion Day!], 10, '30 adv effect that lets you banish for its duration.');
	addSkill($skill[Aug. 11th: Presidential Joke Day!], 11, '50 x level mys substats.');
	addSkill($skill[Aug. 12th: Elephant Day!], 12, '50 x level mus substats.');
	addSkill($skill[Aug. 13th: Left/Off Hander's Day!], 13, '30 adv effect doubling power of off-hands.');
	addSkill($skill[Aug. 14th: Financial Awareness \ Day!], 14, 'Pay 100 x level meat for 150 x level meat.');
	addSkill($skill[Aug. 15th: Relaxation Day!], 15, 'Restore hp/mp, get booze ingredients.');
	addSkill($skill[Aug. 16th: Roller Coaster Day!], 16, '-1 fullness, 30 adv effect of +food drops.');
	addSkill($skill[Aug. 17th: Thriftshop Day!], 17, 'Coupon for 1 item 1000 meat or less.');
	addSkill($skill[Aug. 18th: Serendipity Day!], 18, '30 adv effect of getting random stuff.');
	addSkill($skill[Aug. 19th: Honey Bee Awareness Day!], 19, '30 adv effect of sometimes fighting bees.');
	addSkill($skill[Aug. 20th: Mosquito Day!], 20, '30 adv effect of hp regen.');
	addSkill($skill[Aug. 21st: Spumoni Day!], 21, '20 x level all substats.');
	addSkill($skill[Aug. 22nd: Tooth Fairy Day!], 22, 'Free fight a tooth golem.');
	addSkill($skill[Aug. 23rd: Ride the Wind Day!], 23, '50 x level mox substats.');
	addSkill($skill[Aug. 24th: Waffle Day!], 24, 'Acquire 3 waffles (food/monster swap combat item).');
	addSkill($skill[Aug. 25th: Banana Split Day!], 25, 'Acquire 1 banana spit (food that gives banana).');
	addSkill($skill[Aug. 26th: Toilet Paper Day!], 26, 'Acquire 1 handful of toilet paper (removes a negative effect).');
	addSkill($skill[Aug. 27th: Just Because Day!], 27, '20 adv of 3 random good effects.');
	addSkill($skill[Aug. 28th: Race Your Mouse Day!], 28, 'Acquire melting fam equip based on current fam.');
	addSkill($skill[Aug. 29th: More Herbs, Less Salt \ Day!], 29, 'Acquire 3 bottles of Mrs. Rush (boosts substats from food).');
	addSkill($skill[Aug. 30th: Beach Day!], 30, 'Acquire 1 baywatch (melting +7adv/+2fites/-2mp cost acc).');
	addSkill($skill[Aug. 31st: Cabernet Sauvignon \ Day!], 31, 'Acquire 2 bottles of Cabernet Sauvignon (booze that helps find booze).');

	picker.pickerFinish('Celebrating a holiday...');
}

void picker_alliedradio() {
	int usable = 3 - max(min(get_property('_alliedRadioDropsUsed').to_int(), 3), 0);
	boolean intelUsed = get_property("_alliedRadioMaterielIntel").to_boolean();
	boolean wildsunUsed = get_property("_alliedRadioWildsunBoon").to_boolean();

	buffer picker;
	picker.pickerStart('alliedradio', 'Radio for backup (' + usable + ' left)');

	void addOption(string name, string desc, string icon, boolean usable) {
		picker.pickerGenericOption('radio for', name, desc, '', sideCommand('ashq allied_radio("' + name + '");'),
			usable, itemimage(icon + '.gif'));
	}

	addOption('rations', 'size-1 epic food', 'skelration', true);
	addOption('fuel', 'size-1 epic booze', 'skelgascan', true);
	addOption('ordnance', 'combat item', 'skelgrenade', true);
	addOption('materiel intel', parseEff($effect[Materiel Intel]) + ' (10 adv, 1/day)', 'dinseybrain', !intelUsed);
	addOption('salary', '15 Chroner', 'chroner', true);
	addOption('sniper support', 'force a noncom', 'bountyrifle', true);
	addOption('radio', 'pocket wish for radio', 'radiopackradio', true);
	addOption('ellipsoidtine', parseEff($effect[Ellipsoidtined]) + ' (30 adv)', 'circle', true);
	addOption('wildsun boon', parseEff($effect[Wildsun Boon]) + ' (100 adv, 1/day)', 'sun', !wildsunUsed);

	picker.pickerGenericOption('radio', 'for something else', 'manual entry link', '',
		'inventory.php?action=requestdrop&pwd=' + my_hash(), true, itemimage('radiopack.gif'), attrmap {}, attrmap {
				'class': 'visit done',
				'target': 'mainpane',
			});

	picker.pickerFinish('Radioing for whatever...');
}

void picker_ledcandle() {
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

void picker_snowsuit() {
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

/*****************************************************
	The bulky function itself
*****************************************************/
chit_info getFamiliarInfo(familiar f, slot s);

chit_info getItemInfo(item it, slot relevantSlot, boolean stripHtml, boolean includeMods, boolean weirdFamMode) {
	chit_info info;
	info.name = it.to_string();
	info.image = itemimage(it.image);
	string extraMods = '';

	switch(it) {
		case $item[none]:
			info.image = itemimage('blank.gif');
			break;
		case $item[Buddy Bjorn]: {
			if(my_bjorned_familiar() != $familiar[none]) {
				chit_info bjornInfo = getFamiliarInfo(my_bjorned_familiar(), $slot[buddy-bjorn]);
				info.image = bjornInfo.image;
				if(bjornInfo.desc != '') {
					info.addToDesc(bjornInfo.desc);
				}
				info.incDrops(bjornInfo.hasDrops);
			}
			info.addExtra(extraInfoPicker('bjornify', '<b>Pick</b> a buddy to bjornify!'));
			break;
		}
		case $item[Crown of Thrones]: {
			if(my_enthroned_familiar() != $familiar[none]) {
				chit_info crownInfo = getFamiliarInfo(my_enthroned_familiar(), $slot[crown-of-thrones]);
				info.image = crownInfo.image;
				if(crownInfo.desc != '') {
					info.addToDesc(crownInfo.desc);
				}
				info.incDrops(crownInfo.hasDrops);
			}
			info.addExtra(extraInfoPicker('enthrone', '<b>Pick</b> a buddy to enthrone!'));
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
			info.addDrop(new drop_info('_backUpUses', my_path() == $path[You, Robot] ? 16 : 11,
				'backup' + toAdd, 'backups' + toAdd));
			if(!get_property('backupCameraReverserEnabled').to_boolean()) {
				info.dangerLevel = DANGER_DANGEROUS;
				info.addToDesc('REVERSER NOT ENABLED!');
				info.addExtra(extraInfoLink('<b>Enable</b> reverser', attrmap {
					'class': 'change',
					'href': sideCommand('backupcamera reverser on'),
				}));
			}
			else {
				info.addExtra(extraInfoLink('<b>Disable</b> reverser', 'not recommended', attrmap {
					'class': 'change',
					'href': sideCommand('backupcamera reverser off'),
				}));
			}
			info.addExtra(extraInfoPicker('backupcamera', '<b>Configure</b> your camera (currently '
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
				info.incDrops(DROPS_ALL);
			}
			else if(runs < 6) {
				info.addToDesc('80% free run');
				info.incDrops(DROPS_SOME);
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
					info.addExtra(extraInfoPicker('gap', '<b>Activate</b> Super Power.'));
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
			info.addExtra(extraInfoLink('<b>Examine</b> the briefcase.', attrmap {
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
			info.addExtra(extraInfoLink('<b>Visit</b> FantasyRealm.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'place.php?whichplace=realm_fantasy',
			}));
			info.addExtra(extraInfoLink('<b>Spend</b> Rubees.', attrmap {
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
				info.addExtra(extraInfoLink('<b>Get</b> a refill.', attrmap {
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
				info.addExtra(extraInfoPicker('theforce', '<b>Install</b> daily upgrade'));
			}
			break;
		}
		case $item[Beach Comb]:
			info.addDrop(new drop_info('_freeBeachWalksUsed', 11, 'free comb', 'free combs'));
			info.addExtra(extraInfoLink('<b>Comb</b> the beach', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'main.php?comb=1',
			}));
			break;
		case $item[Powerful Glove]:
		case $item[replica Powerful Glove]:
			info.addDrop(new drop_info('_powerfulGloveBatteryPowerUsed', 100, '% battery'));
			if(get_property('_powerfulGloveBatteryPowerUsed').to_int() < 100) {
				info.addExtra(extraInfoPicker('powerfulglove', '<b>Enter</b> a cheat code!'));
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
				info.addExtra(extraInfoLink('<b>Pick</b> a pocket', attrmap {
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
				info.incDrops(DROPS_ALL);
			}
			info.addExtra(extraInfoPicker('fakebeard', '<b>Check</b> upcoming beards'));
			info.addExtra(extraInfoLink('<b>Adjust</b> your facial hair', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'account_facialhair.php',
			}));
			break;
		}
		case $item[cursed magnifying glass]:
			info.addToDesc(get_property('cursedMagnifyingGlassCount') + '/13 charge');
			info.addDrop(new drop_info('_voidFreeFights', 5, 'free'));
			break;
		case $item[combat lover's locket]:
			info.addDrop(new drop_info('', locketFightsRemaining(), 'reminiscence', 'reminiscences'));
			info.addExtra(extraInfoLink('<b>Reminisce</b> about past loves', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?reminisce=1',
			}));
			break;
		case $item[unbreakable umbrella]: {
			string state = get_property('umbrellaState');
			info.addToDesc(state);
			info.addExtra(extraInfoPicker('unbrella', '<b>Reconfigure</b> your umbrella'));
			switch(state) {
				case 'broken': info.image = itemimage('unbrella7.gif'); break;
				case 'forward-facing': info.image = itemimage('unbrella3.gif'); break;
				case 'bucket style': info.image = itemimage('unbrella5.gif'); break;
				case 'pitchfork style': info.image = itemimage('unbrella8.gif'); break;
				case 'constantly twirling': info.image = itemimage('unbrella6.gif'); break;
				case 'cocoon': info.image = itemimage('unbrella1.gif'); break;
				default: print('Invalid umbrellaState ' + state + '???', 'red'); break;
			}
			break;
		}
		case $item[June cleaver]: {
			int juneFights = get_property('_juneCleaverFightsLeft').to_int();
			if(juneFights == 0) {
				info.incDrops(DROPS_ALL);
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
			info.addExtra(extraInfoPicker('sweatpants', '<b>Use</b> some sweat'));
			break;
		case $item[Jurassic Parka]:
		case $item[replica Jurassic Parka]: {
			string parkaMode = get_property('parkaMode');
			if(parkaMode.length() > 0) {
				info.addToDesc(parkaMode + ' mode');
			}
			info.addExtra(extraInfoPicker('jurassicparka', '<b>Pick</b> parka mode'));
			switch(parkamode) {
				case 'kachungasaur': info.image = itemimage('jparka8.gif'); break;
				case 'dilophosaur': info.image = itemimage('jparka3.gif'); break;
				case 'spikolodon': info.image = itemimage('jparka2.gif'); break;
				case 'ghostasaurus': info.image = itemimage('jparka1.gif'); break;
				case 'pterodactyl': info.image = itemimage('jparka9.gif'); break;
			}
			break;
		}
		case $item[cursed monkey's paw]: {
			info.addDrop(new drop_info('_monkeyPawWishesUsed', 5, 'wish', 'wishes'));
			int wishesUsed = max(0, min(5, get_property('_monkeyPawWishesUsed').to_int()));
			info.image = itemimage('monkeypaw' + wishesUsed + '.gif');
			if(wishesUsed < 5) {
				skill currSkill = monkeyPawSkill(wishesUsed);
				skill nextSkill = monkeyPawSkill(wishesUsed + 1);
				string linkText = '<b>Wish</b> for an item or effect<br />'
					+ '<span class="descline">Current skill: ' + currSkill + ' (' + monkeyPawSkillDesc(currSkill) + ')<br />'
					+ 'Next skill: ' + nextSkill + ' (' + monkeyPawSkillDesc(nextSkill) + ')</span>';
				info.addExtra(extraInfoLink(linkText, attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'main.php?pwd=' + my_hash() + '&action=cmonk',
				}, itemimage('monkeypaw' + (wishesUsed + 1) + '.gif')));
			}
			break;
		}
		case $item[Cincho de Mayo]:
		case $item[replica Cincho de Mayo]: {
			info.addDrop(new drop_info('_cinchUsed', 100, 'cinch used'));
			int restsTaken = get_property('_cinchoRests').to_int();
			int cinchToGain = min(30, max(5, 30 - 5 * (restsTaken - 4)));
			int freeRestsLeft = total_free_rests() - get_property('timesRested').to_int();
			info.addExtra(extraInfoPicker('cincho', '<b>Use</b> some cinch<br /><span class="descline">'
				+ restsTaken + ' rests taken, will gain ' + cinchToGain + ', '
				+ (freeRestsLeft > 0 ? freeRestsLeft.to_string() : 'no') + ' free rests left</span>'));
			break;
		}
		case $item[august scepter]:
		case $item[replica august scepter]: {
			drops_info drops = { new drop_info('_augSkillsCast', 5, 'skill', 'skills') };
			if(can_interact()) {
				drops[drops.count()] = new drop_info('_augTodayCast', LIMIT_BOOL, 'today\'s freebie');
			}
			info.addDrops(drops);
			int [int] usedToday;
			for(int i = 1; i <= 31; ++i) {
				if(get_property('_aug' + i + 'Cast').to_boolean()) {
					usedToday[usedToday.count()] = i;
				}
			}
			int todayNum = today_to_string().to_int() % 100;
			string [int] descStuff;
			if(usedToday.count() > 0) {
				buffer usedTodayStr;
				usedTodayStr.append('Used today: ');
				for(int i = 0; i < usedToday.count(); ++i) {
					if(i != 0) {
						usedTodayStr.append(', ');
					}
					usedTodayStr.append(usedToday[i]);
					if(can_interact() && usedToday[i] == todayNum) {
						usedTodayStr.append(' (free)');
					}
				}
				descStuff[descStuff.count()] = usedTodayStr.to_string();
			}
			if(can_interact() && !get_property('_augTodayCast').to_boolean()) {
				descStuff[descStuff.count()] = todayNum + ' free today';
			}
			string pickerText = '<b>Celebrate</b> some holidays';
			if(descStuff.count() > 0) {
				pickerText += '<br /><span class="descline">';
				for(int i = 0; i < descStuff.count(); ++i) {
					if(i != 0) {
						pickerText += ', ';
					}
					pickerText += descStuff[i];
				}
				pickerText += '</span>';
			}
			info.addExtra(extraInfoPicker('august', pickerText));
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
			extraMods = ', ' + string_modifier('Edpiece:' + currPiece, 'Evaluated Modifiers');
			info.addExtra(extraInfoPicker('edpiece','<b>Change</b> decoration (currently ' + currPiece + ')',
				edpieceToImage(currPiece)));
			break;
		}
		case $item[Jarlsberg's pan]:
			info.addExtra(extraInfoFoldable('<b>Shake</b> Portal Open'));
			break;
		case $item[Jarlsberg's pan (Cosmic portal mode)]:
			info.addExtra(extraInfoFoldable('<b>Shake</b> Portal Closed'));
			break;
		case $item[Boris's Helm]:
			info.addExtra(extraInfoFoldable('<b>Twist</b> Horns Askew'));
			break;
		case $item[Boris's Helm (askew)]:
			info.addExtra(extraInfoFoldable('<b>Untwist</b> Horns'));
			break;
		case $item[Sneaky Pete's leather jacket]:
			info.addExtra(extraInfoFoldable('<b>Pop</b> Collar Aggressively'));
			break;
		case $item[Sneaky Pete's leather jacket (collar popped)]:
			info.addExtra(extraInfoFoldable('<b>Unpop</b> Collar'));
			break;
		case $item[over-the-shoulder Folder Holder]:
		case $item[replica over-the-shoulder Folder Holder]:
			info.addExtra(extraInfoLink('<b>Manage</b> your folders.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?action=useholder',
			}));
			foreach s in $slots[folder1, folder2, folder3, folder4, folder5] {
				string evm = string_modifier(equipped_item(s), "Evaluated Modifiers");
				if(evm != '') {
					extraMods += ", " + evm;
				}
			}
			break;
		case $item[fish hatchet]:
		case $item[codpiece]:
		case $item[bass clarinet]:
			string floundryText = '';
			string dropName = '';
			switch(it) {
				case $item[fish hatchet]:
					floundryText = '<b>Get</b> Wood';
					dropName = 'bridge wood';
					break;
				case $item[codpiece]:
					floundryText = '<b>Wring</b> Out';
					dropName = "bubblin' crude";
					break;
				case $item[bass clarinet]:
					floundryText = '<b>Drain</b> Spit';
					dropName = 'white pixels';
					break;
				default:
					print('wtf happened, ' + it + ' is not a floundry item', 'red');
					break;
			}
			info.addDrop(new drop_info('_floundryItemUsed', LIMIT_BOOL, dropName));
			if(!get_property('_floundryItemUsed').to_boolean()) {
				info.addExtra(extraInfoLink(floundryText, attrmap {
					'class': 'change',
					'href': sideCommand('use 1 ' + it.to_string() + '; equip '
						+ relevantSlot.to_string() + ' ' + it.to_string()),
				}));
			}
			break;
		case $item[PirateRealm eyepatch]:
			info.addExtra(extraInfoLink('<b>Spend</b> Fun.', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'place.php?whichplace=realm_pirate',
			}));
			break;
		case $item[Kramco Sausage-o-Matic&trade;]:
		case $item[replica Kramco Sausage-o-Matic&trade;]: {
			string linkText = '<b>Grind</b> (' + available_amount($item[magical sausage casing]).formatInt()
				+ ' casings available):<br />' + get_property('sausageGrinderUnits').to_int().formatInt()
				+ '/' + (111 * (1 + get_property('_sausagesMage').to_int())).formatInt()
				+ ' units.<br />' + get_property('_sausageFights').to_int().formatInt()
				+ ' goblins encountered today.';
			info.addExtra(extraInfoLink(linkText, attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?action=grind',
			}));
			break;
		}
		case $item[Eight Days a Week Pill Keeper]:
			info.addDrop(new drop_info('_freePillKeeperUsed', LIMIT_BOOL, 'free pill'));
			if(!get_property('_freePillKeeperUsed').to_boolean() || (spleen_limit() - my_spleen_use() >= 3)) {
				info.addExtra(extraInfoPicker('pillkeeper', '<b>Pop</b> a pill!'));
			}
			break;
		case $item[Guzzlr tablet]:
			info.addExtra(extraInfoLink('<b>Tap</b> tablet', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'inventory.php?tap=guzzlr',
			}));
			break;
		case $item[unwrapped knock-off retro superhero cape]:
			info.addExtra(extraInfoPicker('retrosupercapemeta', '<b>Change</b> to optimal setups!'));
			info.addExtra(extraInfoPicker('retrosupercapeall', '<b>Change</b> to any setup!'));
			info.addToDesc(retroSupercapeCurrentSetupName());
			info.image = retroHeroToIcon(get_property('retroCapeSuperhero'));
			break;
		case $item[The Jokester's gun]:
			info.addDrop(new drop_info('_firedJokestersGun', LIMIT_BOOL, 'firing'));
			break;
		case $item[protonic accelerator pack]: {
			int turnsToGhost = get_property('nextParanormalActivity').to_int() - total_turns_played();
			string ghostLoc = get_property('ghostLocation');
			if(ghostLoc != '') {
				info.addToDesc('ghost at ' + ghostLoc);
				info.incDrops(DROPS_ALL);
			}
			else if(turnsToGhost <= 0) {
				info.addToDesc('ghost due');
				info.incDrops(DROPS_SOME);
			}
			else {
				info.addToDesc('ghost in ' + turnsToGhost);
			}
			break;
		}
		case $item[mafia middle finger ring]:
			info.addDrop(new drop_info('_mafiaMiddleFingerRingUsed', LIMIT_BOOL, 'banish'));
			break;
		case $item[&quot;I Voted!&quot; sticker]: {
			int turnsPlayed = total_turns_played();
			int turnsToFight = (12 - (turnsPlayed % 11)) % 11;
			if(turnsToFight == 0 && turnsPlayed != get_property('lastVoteMonsterTurn').to_int()) {
				boolean isFree = get_property('_voteFreeFights').to_int() < 3;
				info.addToDesc(isFree ? 'free vote monster due' : 'vote monster due');
				info.incDrops(isFree ? DROPS_ALL : DROPS_SOME);
			}
			else {
				if(turnsToFight == 0) {
					turnsToFight = 11;
				}
				info.addToDesc('vote monster in ' + turnsToFight);
			}
			break;
		}
		case $item[Apriling Band Helmet]:
			drops_info drops;
			if(total_turns_played() >= get_property('nextAprilBandTurn').to_int()) {
				info.addExtra(extraInfoPicker('aprilbandsong', '<b>Change</b> the marching song'));
				drops[drops.count()] = new drop_info('', 1, 'song change', '', false, false, 0, true);
			}
			else {
				info.addToDesc((get_property('nextAprilBandTurn').to_int() - total_turns_played()) + ' adv to song change');
			}
			if(aprilingBandSectionsEnrolled() < 2) {
				info.addExtra(extraInfoPicker('aprilbandsection', '<b>Join</b> a section'));
				drops[drops.count()] = new drop_info('_aprilBandInstruments', 2, 'section enroll', 'section enrolls');
			}
			info.addDrops(drops);
			foreach inst in aprilingBandSectionInstruments {
				if(item_amount(inst) + equipped_amount(inst) > 0) {
					int playsLeft = 3 - get_property(aprilingBandSectionInstrumentProps[inst]).to_int();
					if(playsLeft > 0) {
						info.addExtra(extraInfoLink('<b>Play</b> ' + inst,
							aprilingBandSectionInstrumentAbilities[inst] + ' (' + playsLeft + ' left)',
							attrmap {
								'class': 'visit done',
								'target': 'mainpane',
								'href': 'inventory.php?pwd=' + my_hash() + '&iid=' + inst.to_int() + '&action=aprilplay',
							}, itemimage(inst.image)));
					}
				}
			}
			break;
		case $item[Apriling band saxophone]:
		case $item[Apriling band quad tom]:
		case $item[Apriling band tuba]:
		case $item[Apriling band staff]:
		case $item[Apriling band piccolo]: {
			boolean hasPlays = info.addDrop(new drop_info(aprilingBandSectionInstrumentProps[it], 3, 'play', 'plays'));
			if(hasPlays) {
				info.addExtra(extraInfoLink('<b>Play</b> ' + it, aprilingBandSectionInstrumentAbilities[it], attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'inventory.php?pwd=' + my_hash() + '&iid=' + it.to_int() + '&action=aprilplay',
				}));
			}
			break;
		}
		case $item[Everfull Dart Holster]: {
			int thrown = get_property('dartsThrown').to_int();
			int skillLevel = floor(square_root(thrown));
			int nextLevelReq = (skillLevel + 1) ** 2;
			int toNextLevel = nextLevelReq - thrown;
			int dartsLeft = get_property('_dartsLeft').to_int();
			int accuracy = 25;
			int cooldown = 50;
			int capacity = 3;
			string [int] perks = get_property('everfullDartPerks').split_string(',');
			foreach i, perk in perks {
				switch(perk) {
					case 'You are less impressed by bullseyes':
					case 'Bullseyes do not impress you much':
						cooldown -= 10;
						break;
					case '25% Better bullseye targeting':
					case '25% More Accurate bullseye targeting':
					case '25% better chance to hit bullseyes':
						accuracy += 25;
						break;
					case 'Expand your dart capacity by 1':
						// this string is used twice instead of with variants
						capacity += 1;
						break;
				}
			}
			if(skillLevel < 1) {
				info.addToDesc('unskilled');
			}
			else {
				info.addToDesc(skillLevel + ' skill');
			}
			info.addToDesc(toNextLevel + ' to improve');
			if(skillLevel > 0) {
				// darts left is 0 until you've gone in to combat with them, so just don't show yet
				info.addToDesc(dartsLeft + '/' + capacity + ' darts');
			}
			if(have_effect($effect[Everything looks red]) == 0) {
				info.addToDesc(accuracy + '% bullseye chance, ' + cooldown + ' adv cooldown');
				info.incDrops(accuracy == 100 ? DROPS_ALL : DROPS_SOME);
			}
			break;
		}
		case $item[candy cane sword cane]: {
			info.addDrops(drops_info {
				new drop_info('_surprisinglySweetSlashUsed', 11, 'slash', 'slashes'),
				new drop_info('_surprisinglySweetStabUsed', 11, 'stab', 'stabs'),
			});
			CCSwordZoneInfo ccscInfo = getCCSwordZoneInfo(my_location());
			if(ccscInfo.canDo()) {
				info.addToDesc('use here for ' + ccscInfo.desc);
				if(ccscInfo.isImportant) {
					info.dangerLevel = DANGER_GOOD;
				}
				else {
					info.incDrops(DROPS_SOME);
				}
			}
			break;
		}
		case $item[Roman Candelabra]: {
			drops_info rockets;
			string[int] gradient;
			if(have_effect($effect[Everything looks blue]) == 0) {
				rockets[rockets.count()] = new drop_info('', 1, '<span style="color:blue">mp</span>', '',
					true, false, 0, true);
				gradient[gradient.count()] = 'blue';
			}
			if(have_effect($effect[Everything looks red]) == 0) {
				rockets[rockets.count()] = new drop_info('', 1, '<span style="color:red">stats</span>', '',
					true, false, 0, true);
				gradient[gradient.count()] = 'red';
			}
			if(have_effect($effect[Everything looks yellow]) == 0) {
				rockets[rockets.count()] = new drop_info('', 1, '<span style="color:olive">ray</span>', '',
					true, false, 0, true);
				gradient[gradient.count()] = 'olive';
			}
			if(have_effect($effect[Everything looks green]) == 0) {
				rockets[rockets.count()] = new drop_info('', 1, '<span style="color:green">run</span>', '',
					true, false, 0, true);
				gradient[gradient.count()] = 'green';
			}
			if(have_effect($effect[Everything looks purple]) == 0) {
				rockets[rockets.count()] = new drop_info('', 1, '<span style="color:purple">copy</span>',
					'', true, false, 0, true);
				gradient[gradient.count()] = 'purple';
			}
			info.addDrops(rockets);
			if(rockets.count() > 0) {
				info.desc += ' available';
				string gradientStr = '';
				int angleStep = 360 / gradient.count();
				foreach i,color in gradient {
					gradientStr += color;
					if(i != 0) {
						gradientStr += ' ' + (i * angleStep) + 'deg';
					}
					if(i != gradient.count() - 1) {
						gradientStr += ' ' + ((i + 1) * angleStep) + 'deg, ';
					}
				}
				info.customStyle = 'border-style: solid; border-width: 2px !important; border-image: conic-gradient(' +
					gradientStr + ') 1 !important;';
			}
			break;
		}
		case $item[bat wings]: {
			info.addDrops(drops_info {
				new drop_info('_batWingsFreeFights', 5, 'free fight', 'free fights'),
				new drop_info('_batWingsRestUsed', 11, 'rest', 'rests'),
				new drop_info('_batWingsCauldronUsed', 11, 'cauldron', 'cauldrons', true),
				new drop_info('_batWingsSwoopUsed', 11, 'swoop', 'swoops'),
			});
			if(get_property('_batWingsRestUsed').to_int() < 11) {
				info.addExtra(extraInfoLink('<b>Rest</b> upside down with your bat wings',
					'restores 1000 hp/mp', attrmap {
						'class': 'change',
						'href': sideCommand('cast 1 Rest upside down'),
					}
				));
			}
			break;
		}
		case $item[Allied Radio Backpack]: {
			info.addDrop(new drop_info('_alliedRadioDropsUsed', 3, 'radio request', 'radio requests'));
			if(get_property('_alliedRadioDropsUsed').to_int() < 3) {
				info.addExtra(extraInfoPicker('alliedradio', '<b>radio for</b> backup'));
			}
			break;
		}
		case $item[prismatic beret]: {
			info.addDrops(drops_info {
				new drop_info('_beretBuskingUses', 5, 'busk', 'busks'),
				new drop_info('_beretBlastUses', 11, 'blast', 'blasts', true),
				new drop_info('_beretBoastUses', 11, 'boast', 'boasts', true),
			});
			if(get_property('_beretBuskingUses').to_int() < 5) {
				buffer buskResult;
				buskResult.append('Currently: ');
				foreach eff, turns in beret_busking_effects() {
					if(eff == $effect[none]) {
						buskResult.append(turns);
						buskResult.append(' meat');
					} else {
						buskResult.append(', ');
						buskResult.append(eff);
						buskResult.append(' (');
						buskResult.append(turns);
						buskResult.append(' adv)');
					}
				}
				info.addExtra(extraInfoLink('<b>Busk</b> for meat and buffs',
					buskResult.to_string(), attrmap {
						'class': 'visit done',
						'target': 'mainpane',
						'href': 'runskillz.php?action=Skillz&whichskill=7565&targetplayer=' + my_id()
							+ '&pwd=' + my_hash() + '&quantity=1',
					}
				));
			}
			break;
		}
		case $item[Peridot of Peril]: {
			info.addDrop(new drop_info('_perilsForeseen', 3, 'peril', 'perils'));
			if(get_property('_perilsForeseen').to_int() < 3) {
				info.addExtra(extraInfoLink('<b>Foresee</b> peril', 'gives them a fruit', attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'inventory.php?pwd=' + my_hash() + '&action=foresee',
				}));
			}
			break;
		}
		case $item[April Shower Thoughts shield]: {
			drops_info drops = { new drop_info('_aprilShowerGlobsCollected', LIMIT_BOOL, 'shower', 'showers') };
			if(have_skill($skill[Northern Explosion])) {
				drops[drops.count()] = new drop_info('_aprilShowerNorthernExplosion', LIMIT_BOOL,
					'northern explosion ray', 'northern explosion rays');
			}
			if(have_skill($skill[Simmer])) {
				drops[drops.count()] = new drop_info('_aprilShowerSimmer', LIMIT_BOOL, 'free simmer', 'free simmers');
			}
			if(have_skill($skill[Disco Nap])) {
				drops[drops.count()] = new drop_info('_aprilShowerDiscoNap', 5, 'mp disco nap', 'mp disco naps');
			}
			info.addDrops(drops);
			if(!get_property('_aprilShowerGlobsCollected').to_boolean()) {
				info.addExtra(extraInfoLink('<b>Shower</b> off', 'collect daily globs', attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'inventory.php?action=shower&pwd=' + my_hash(),
				}));
			}
			break;
		}
		case $item[McHugeLarge duffel bag]: {
			if(available_amount($item[McHugeLarge right pole]) < 1) {
				info.addToDesc('openable');
				info.incDrops(DROPS_ALL);
				info.addExtra(extraInfoLink('<b>Open</b> your duffel bag', 'collect skis and poles', attrmap {
					'class': 'visit done',
					'target': 'mainpane',
					'href': 'inventory.php?action=skiduffel&pwd=' + my_hash(),
				}));
			}
			break;
		}
		case $item[McHugeLarge left pole]: {
			info.addDrop(new drop_info('_mcHugeLargeSlashUses', 3, 'slash', 'slashes'));
			break;
		}
		case $item[McHugeLarge left ski]: {
			info.addDrop(new drop_info('_mcHugeLargeAvalancheUses', 3, 'avalanche', 'avalanches'));
			break;
		}
		case $item[McHugeLarge right ski]: {
			info.addDrop(new drop_info('_mcHugeLargeSkiPlowUses', 11, 'ski plow', 'ski plows', true));
			break;
		}
		case $item[M&ouml;bius ring]: {
			info.addToDesc(my_paradoxicity() + ' paradoxicity');
			break;
		}
		case $item[your cowboy boots]: {
			foreach s in $slots[bootskin, bootspur] {
				string evm = string_modifier(equipped_item(s), "Evaluated Modifiers");
				if(evm != '') {
					extraMods += ", " + evm;
				}
			}
			break;
		}
		case $item[card sleeve]: {
			string evm = string_modifier(equipped_item($slot[card-sleeve]), "Evaluated Modifiers");
			if(evm != '') {
				extraMods += ", " + evm;
			}
			break;
		}
		case $item[scratch 'n' sniff sword]:
		case $item[scratch 'n' sniff crossbow]: {
			info.addExtra(extraInfoLink('<b>Bedazzle</b> your weapon', 'swap stickers', attrmap {
				'class': 'visit done',
				'target': 'mainpane',
				'href': 'bedazzle.php',
			}));
			string other = it == $item[scratch 'n' sniff sword] ? 'crossbow' : 'sword';
			item otherIt = it == $item[scratch 'n' sniff sword]
				? $item[scratch 'n' sniff crossbow]
				: $item[scratch 'n' sniff sword];
			info.addExtra(extraInfoLink('<b>Swap</b> to a ' + other, 'change damage type', attrmap {
				'class': 'change',
				'href': sideCommand('fold ' + otherIt + '; equip ' + relevantSlot + ' ' + otherIt),
			}));
			void applySticker(item sticker, int value, boolean [modifier] mods) {
				int count = 0;
				foreach st in $slots[sticker1, sticker2, sticker3] {
					if(equipped_item(st) == sticker) {
						++count;
					}
				}
				if(count > 0) {
					foreach mod in mods {
						extraMods += ', ' + mod + ': +' + (count * value);
					}
				}
			}
			applySticker($item[scratch 'n' sniff unicorn sticker], 25,
				$modifiers[Item Drop]);
			applySticker($item[scratch 'n' sniff apple sticker], 2,
				$modifiers[Experience]);
			applySticker($item[scratch 'n' sniff UPC sticker], 25,
				$modifiers[Meat Drop]);
			applySticker($item[scratch 'n' sniff wrestler sticker], 10,
				$modifiers[Muscle Percent, Mysticality Percent, Moxie Percent]);
			applySticker($item[scratch 'n' sniff dragon sticker], 3,
				$modifiers[Hot Damage, Cold Damage, Stench Damage, Spooky Damage, Sleaze Damage]);
			applySticker($item[scratch 'n' sniff rock band sticker], 20,
				$modifiers[Weapon Damage, Spell Damage]);
			break;
		}
		case $item[LED candle]: {
			info.addExtra(extraInfoPicker('ledcandle', '<b>Adjust</b> LED candle'));
			break;
		}
		case $item[bag of many confections]: {
			info.addDrop(new drop_info('', LIMIT_INFINITE, 'candy', 'candies', true));
			break;
		}
		case $item[tiny costume wardrobe]: {
			if(my_familiar() == $familiar[doppelshifter]) {
				extraMods = ', Fam Weight +25';
			} else {
				info.addToDesc('random transformations');
			}
			break;
		}
		case $item[school spirit socket set]: {
			info.addToDesc('keeps more steam in');
			break;
		}
		case $item[flask of embalming fluid]: {
			info.addToDesc('helps collect body parts');
			break;
		}
		case $item[orange boxing gloves]:
		case $item[blue pumps]: {
			info.addToDesc('find more yellow pixels');
			break;
		}
		case $item[Snow Suit]: {
			info.addDrop(new drop_info('_carrotNoseDrops', 3, 'carrot', 'carrots'));
			info.addExtra(extraInfoPicker('snowsuit', '<b>Decorate</b> Snow Suit'));
			switch(get_property('snowsuit')) {
				case 'eyebrows': info.image = itemimage('snowface1.gif'); break;
				case 'smirk': info.image = itemimage('snowface2.gif'); break;
				case 'nose': info.image = itemimage('snowface3.gif'); break;
				case 'goatee': info.image = itemimage('snowface4.gif'); break;
				case 'hat': info.image = itemimage('snowface5.gif'); break;
			}
			break;
		}
	}

	// latte reminder
	if(relevantSlot == $slot[off-hand] && vars['chit.gear.lattereminder'].to_boolean() &&
		my_location().latteDropAvailable() && it != $item[latte lovers member's mug] &&
		!it.isImportantOffhand() && be_good($item[latte lovers member's mug])) {
		if(info.dangerLevel < DANGER_WARNING) {
			info.dangerLevel = DANGER_WARNING;
		}
		info.addToDesc('latte ingredient available');
	}

	// sword cane reminder
	if(relevantSlot == $slot[weapon] && vars['chit.gear.ccswordcanereminder'].to_boolean()
		&& it != $item[candy cane sword cane] && be_good($item[candy cane sword cane])) {
		CCSwordZoneInfo ccscInfo = getCCSwordZoneInfo(my_location());
		if(ccscInfo.isImportant && ccscInfo.canDo()) {
			if(info.dangerLevel < DANGER_WARNING) {
				info.dangerLevel = DANGER_WARNING;
			}
			info.addToDesc('sword cane useful here');
		}
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

	if(stripHtml) {
		matcher htmlRemover = create_matcher('<[^>]+>', info.desc);
		info.desc = htmlRemover.replace_all('');
	}

	if(vars['chit.display.popovers'].to_boolean() && includeMods) {
		string parsedMods = parseItem(it, extraMods, weirdFamMode);
		if(parsedMods != '') {
			if(info.desc != '') {
				info.addToDesc('&nbsp;');
			}
			info.addToDesc(parsedMods);
		}
	}

	return info;
}

chit_info getItemInfo(item it, slot relevantSlot, boolean stripHtml, boolean includeMods) {
	return getItemInfo(it, relevantSlot, stripHtml, includeMods, false);
}

chit_info getItemInfo(item it, slot relevantSlot, boolean stripHtml) {
	return getItemInfo(it, relevantSlot, stripHtml, false);
}

chit_info getItemInfo(item it, slot relevantSlot) {
	return getItemInfo(it, relevantSlot, false);
}

chit_info getItemInfo(item it) {
	return getItemInfo(it, to_slot(it));
}

void addItemIcon(buffer result, item it, string titlePrefix, boolean popupDescOnClick,
	int upDanger, string wrappingElement, attrmap wrappingElementAttrs,
	boolean weirdFamMode) {
	chit_info info = getItemInfo(it, to_slot(it), false, true, weirdFamMode);
	if(upDanger > info.dangerLevel) {
		info.dangerLevel = upDanger;
	}
	result.addInfoIcon(info, titlePrefix + info.name, info.desc,
		popupDescOnClick ? ('descitem(' + it.descid + ',0,event); return false;') : '',
		wrappingElement, wrappingElementAttrs);
}

void addItemIcon(buffer result, item it, string titlePrefix, boolean popupDescOnClick,
	int upDanger, string wrappingElement, attrmap wrappingElementAttrs) {
	addItemIcon(result, it, titlePrefix, popupDescOnClick, upDanger,
		wrappingElement, wrappingElementAttrs, false);
}

void addItemIcon(buffer result, item it, string titlePrefix,
	boolean popupDescOnClick) {
	addItemIcon(result, it, titlePrefix, popupDescOnClick, DANGER_GOOD, '', attrmap {});
}

void addItemIcon(buffer result, item it, string title) {
	addItemIcon(result, it, title, false);
}

void addItemIcon(buffer result, item it) {
	addItemIcon(result, it, '');
}
