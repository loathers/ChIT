chit_info getEffectInfo(effect eff);

// elementchart1.gif or elementchart2.gif are valid values for img
void addElementMap(buffer result, string img) {
	result.append('<img src="');
	result.append(imagePath);
	result.append(img);

	if     (have_effect($effect[Spirit of Peppermint]) > 0) result.append("cold");
	else if(have_effect($effect[Spirit of Bacon Grease]) > 0) result.append("sleaze");
	else if(have_effect($effect[Spirit of Garlic]) > 0) result.append("stench");
	else if(have_effect($effect[Spirit of Cayenne]) > 0) result.append("hot");
	else if(have_effect($effect[Spirit of Wormwood]) > 0) result.append("spooky");

	result.append('.gif" width="190" height="190"');
	if(have_skill($skill[Flavour of Magic])) {
		result.append(' alt="Cast Flavour of Magic" usemap="#flavmap">');
		result.append('<map id="flavmap" name="flavmap"><area shape="circle" alt="Sleaze" title="Spirit of Bacon Grease (Sleaze)" coords="86,33,22" href="');
		result.append(sideCommand('cast spirit of bacon grease'));
		result.append('" /><area shape="circle" alt="Cold" title="Spirit of Peppermint (Cold)" coords="156,84,22" href="');
		result.append(sideCommand('cast spirit of peppermint'));
		result.append('" /><area shape="circle" alt="Spooky" title="Spirit of Wormwood (Spooky)" coords="133,155,22" href="');
		result.append(sideCommand('cast spirit of wormwood'));
		result.append('" /><area shape="circle" alt="Hot" title="Spirit of Cayenne (Hot)" coords="39,155,22" href="');
		result.append(sideCommand('cast spirit of cayenne'));
		result.append('" /><area shape="circle" alt="Stench" title="Spirit of Garlic (Stench)" coords="25,84,22" href="');
		result.append(sideCommand('cast spirit of garlic'));
		result.append('" /><area shape="circle" alt="Cancel Flavour of Magic" title="Cancel Flavour of Magic" coords="86,95,22" href="');
		result.append(sideCommand('cast spirit of nothing'));
		result.append('" /></map>');
	} else
		result.append('>');
}

boolean lacksFlavour() {
	for i from 167 to 171
		if(have_effect(to_effect(i)) > 0) return false;
	return have_skill($skill[flavour of magic]) && be_good($skill[flavour of magic]);
}

void picker_flavour() {
	if(chitPickers contains "flavour") {
		return;
	}

	buffer picker;
	picker.pickerStart("flavour", "Cast Flavour of Magic");

	picker.append('<tr class="pickitem"><td>');
	picker.addElementMap("elementchart2");
	picker.append('</td></tr>');

	picker.pickerFinish("Spiriting flavours...");
}

boolean lacksHairdo() {
	foreach e in $effects[[1553]Slicked-Back Do, Pompadour, Cowlick, Fauxhawk]
		if(have_effect(e) > 0) return false;
	return have_skill($skill[Check Mirror]);
}

boolean isDriving() {
	foreach eff in $effects[Driving Obnoxiously, Driving Stealthily, Driving Wastefully, Driving Safely, Driving Recklessly, Driving Intimidatingly, Driving Quickly, Driving Observantly, Driving Waterproofly] {
		if(have_effect(eff) > 0) {
			return true;
		}
	}
	return false;
}

void picker_asdon() {
	if(chitPickers contains "asdon") {
		return;
	}

	buffer picker;
	picker.pickerStart("asdon", "Drive Differently! (" + get_fuel() + " fuel)");

	void addDriving(effect style) {
		boolean current = have_effect(style) > 0;
		boolean canDo = !current && get_fuel() >= 37;
		string name = style.to_string().split_string(" ")[1];
		if(current) {
			name = '<b>Currently Driving</b> ' + name;
		}

		picker.pickerEffectOption('Drive', name, style, '', 30,
			sideCommand('asdonmartin drive ' + name.to_lower_case()), canDo);
	}

	foreach eff in $effects[Driving Obnoxiously, Driving Stealthily, Driving Wastefully, Driving Safely, Driving Recklessly, Driving Intimidatingly, Driving Quickly, Driving Observantly, Driving Waterproofly] {
		addDriving(eff);
	}

	picker.pickerGenericOption('Visit', 'your workshed', '', '', 'campground.php?action=workshed',
		true, itemimage($item[Asdon Martin keyfob (on ring)].image), attrmap {}, attrmap {
			'class': 'change visit done',
			'target': 'mainpane',
		}
	);

	if(isDriving()) {
		picker.pickerGenericOption('Stop', 'driving', '', '', sideCommand('asdonmartin drive clear'),
			true, itemimage('antianti.gif'), attrmap {}, attrmap {
				'class': 'change',
			}
		);
	}

	picker.pickerFinish("Adjusting driving style...");
}

boolean lacksHolorecord() {
	foreach eff in $effects[
		Power\, Man,
		Shrieking Weasel,
		Superdrifting,
		Drunk and Avuncular,
		Ministrations in the Dark,
		Lucky Struck,
		Record Hunger,
	] {
		if(have_effect(eff) > 0) {
			return false;
		}
	}

	return chit_available($item[Wrist-Boy]) > 0;
}

void picker_holorecord() {
	if(chitPickers contains "holorecord") {
		return;
	}

	effect nowPlaying = $effect[none];
	foreach eff in $effects[
		Power\, Man,
		Shrieking Weasel,
		Superdrifting,
		Drunk and Avuncular,
		Ministrations in the Dark,
		Lucky Struck,
		Record Hunger,
	] {
		if(have_effect(eff) > 0) {
			nowPlaying = eff;
			break;
		}
	}

	buffer picker;
	picker.pickerStart("holorecord", "Play some tunes on your Wrist-Boy");

	void addRecord(item holorecord) {
		effect eff = effect_modifier(holorecord, "effect");
		chit_info info = getEffectInfo(eff);
		int price = npc_price(holorecord);
		boolean active = info.count != 0;
		int copies = item_amount(holorecord);
		boolean canDo = (price > 0 && my_meat() >= price) || copies > 0;
		if(!canDo) {
			if(price == 0) {
				info.desc += '<br />Not Unlocked';
			}
			else if(price > my_meat()) {
				info.desc += '<br />Can\'t Afford';
			}
		}
		else if(copies > 0) {
			info.desc += '<br />' + copies + (copies > 1 ? ' copies' : ' copy');
		}
		else {
			info.desc += '<br />' + price + ' meat';
		}
		string cmd = 'use 1 ' + holorecord;
		if(nowPlaying != $effect[none]) {
			cmd = 'shrug ' + nowPlaying + '; ' + cmd;
		}

		picker.pickerEffectOption(active ? 'Extend' : 'Play', info.name, eff, info.desc, canDo ? 10 : 0, sideCommand(cmd), canDo);
	}

	foreach holorecord in $items[
		Power-Guy 2000 holo-record,
		Shrieking Weasel holo-record,
		Superdrifter holo-record,
		EMD holo-record,
		Lucky Strikes holo-record,
		The Pigs holo-record,
		Drunk Uncles holo-record,
	] {
		addRecord(holorecord);
	}

	picker.pickerFinish("Putting in the new record...");
}

effect [int] availableExpressions() {
	static effect [int] expressions;
	static boolean done = false;

	if(!done) {
		foreach sk in $skills[] {
			if(have_skill(sk) && be_good(sk) && sk.expression) {
				expressions[expressions.count()] = to_effect(sk);
			}
		}
		done = true;
	}

	return expressions;
}

boolean lacksExpression() {
	boolean hasAny = false;

	foreach i, eff in availableExpressions() {
		hasAny = true;
		if(have_effect(eff) > 0) {
			return false;
		}
	}

	return hasAny;
}

void picker_expression() {
	if(chitPickers contains "expression") {
		return;
	}

	buffer picker;
	picker.pickerStart("expression", "Express Yourself!");

	void addExpression(effect expression) {
		boolean current = have_effect(expression) > 0;
		picker.pickerEffectFromSkillOption("express", expression, !current);
	}

	foreach i, expression in availableExpressions() {
		addExpression(expression);
	}

	picker.pickerFinish("Expressing Yourself...");
}

effect [int] availableSongs() {
	static effect [int] songs;
	static boolean done = false;

	if(!done) {
		foreach eff in $effects[] {
			skill sk = to_skill(eff);
			if(eff.song && have_skill(sk) && be_good(sk)) {
				chit_info info = getEffectInfo(eff, true, true);
				if(info.type == "hobop" && (get_property(sk.dailylimitpref).to_int() >= sk.dailylimit || my_level() < 15)) {
					continue;
				}
				songs[songs.count()] = eff;
			}
		}
		done = true;
	}

	return songs;
}

int lackingSongs() {
	int songsInHead = 0;
	int songsAvailable = availableSongs().count();
	int songsKnownInHead = 0;
	int songSlots = (boolean_modifier("Four Songs") ? 4 : 3) + numeric_modifier("Additional Song");

	// not using availableSongs for this because theoretically a hookah
	// could give you a song you don't know.
	foreach eff in $effects[] {
		if(eff.song && have_effect(eff) > 0) {
			songsInHead += 1;
			if(have_skill(to_skill(eff)) && be_good(to_skill(eff))) {
				songsKnownInHead += 1;
			}
		}
	}

	return min(songSlots - songsInHead, songsAvailable - songsKnownInHead);
}

void picker_atsong(effect toShrug) {
	string pickerName = "atsong";
	string shrugPart = "";
	if(toShrug != $effect[none]) {
		pickerName += toShrug.to_int();
		shrugPart = "uneffect " + toShrug + "; ";
	}

	if(chitPickers contains pickerName) {
		return;
	}

	buffer picker;
	picker.pickerStart(pickerName, toShrug == $effect[none]
		? "Get some music in that head"
		: "Replace " + toShrug.name + " with...");

	foreach i, song in availableSongs() {
		boolean active = have_effect(song) > 0;
		picker.pickerEffectFromSkillOption('play', song, !active);
	}

	picker.pickerFinish("Getting a song caught in your head");
}

void picker_atsong() {
	picker_atsong($effect[none]);
}

effect [int] availableDreadSongs() {
	effect [int] res;

	foreach eff in $effects[Song of the North, Song of Slowness, Song of Starch, Song of Sauce, Song of Bravado] {
		skill sk = to_skill(eff);
		if(have_skill(sk) && be_good(sk)) {
			res[res.count()] = eff;
		}
	}

	return res;
}

boolean lacksDreadSong() {
	foreach eff in $effects[Song of the North, Song of Slowness, Song of Starch, Song of Sauce, Song of Bravado] {
		if(have_effect(eff) > 0) {
			return false;
		}
	}

	return availableDreadSongs().count() > 0;
}

void picker_dreadsong() {
	if(chitPickers contains "dreadsong") {
		return;
	}

	buffer picker;
	picker.pickerStart("dreadsong", "Sing a Dreadful Song");

	foreach i, dsong in availableDreadSongs() {
		boolean current = have_effect(dsong) > 0;
		picker.pickerEffectFromSkillOption('sing', dsong, !current);
	}

	picker.pickerFinish("Singing a Dreadful Song...");
}

effect [int] availableShanties() {
	static effect [int] shanties;
	static boolean done = false;

	if(!done) {
		foreach sk in $skills[] {
			if(have_skill(sk) && be_good(sk) && sk.shanty) {
				shanties[shanties.count()] = to_effect(sk);
			}
		}
		done = true;
	}

	return shanties;
}

boolean lacksShanty() {
	boolean canShanty = false;

	foreach i, ef in availableShanties() {
		// if there's anything here, you have at least one valid shanty
		canShanty = true;
		if(have_effect(ef) > 0) {
			return false;
		}
	}

	return canShanty;
}

void picker_shanty() {
	if(chitPickers contains "shanty") {
		return;
	}

	buffer picker;
	picker.pickerStart("shanty", "Sing a Shanty");

	void addShanty(effect shanty) {
		boolean current = have_effect(shanty) > 0;
		picker.pickerEffectFromSkillOption('sing', shanty, !current);
	}

	foreach i, shanty in availableShanties() {
		addShanty(shanty);
	}

	picker.pickerFinish("Singing a Shanty...");
}

chit_info getEffectInfo(effect eff, boolean avoidRecursion, boolean span) {
	chit_info info;
	info.name = eff.name;
	info.image = itemimage(eff.image);
	info.count = have_effect(eff);

	switch(eff) {
		// AT Songs
		case $effect[The Moxious Madrigal]:
			info.name = "Moxious Madrigal";
			info.type = "at";
			break;
		case $effect[The Magical Mojomuscular Melody]:
			info.name = "Mojomuscular Melody";
			info.type = "at";
			break;
		case $effect[Cletus's Canticle of Celerity]:
			info.name = "Canticle of Celerity";
			info.type = "at";
			break;
		case $effect[Power Ballad of the Arrowsmith]:
			info.name = "Power Ballad";
			info.type = "at";
			break;
		case $effect[Jackasses' Symphony of Destruction]:
			info.name = "Jackasses'";
			info.type = "at";
			break;
		case $effect[Fat Leon's Phat Loot Lyric]:
			info.name = "Phat Loot";
			info.type = "at";
			break;
		case $effect[Brawnee's Anthem of Absorption]:
			info.name = "Brawnee's";
			info.type = "at";
			break;
		case $effect[Psalm of Pointiness]:
			info.name = "Pointiness";
			info.type = "at";
			break;
		case $effect[Stevedave's Shanty of Superiority]:
			info.name = "Shanty of Superiority";
			info.type = "at";
			break;
		case $effect[Aloysius' Antiphon of Aptitude]:
			info.name = "Antiphon";
			info.type = "at";
			break;
		case $effect[The Sonata of Sneakiness]:
			info.name = "Sonata of Sneakiness";
			info.type = "at";
			break;
		case $effect[Carlweather's Cantata of Confrontation]:
			info.name = "Cantata of Confrontation";
			info.type = "at";
			break;
		case $effect[Ur-Kel's Aria of Annoyance]:
			info.name = "Urkel's";
			info.type = "at";
			break;
		case $effect[Inigo's Incantation of Inspiration]:
			info.name = "Inigo's";
			info.desc = "One Free Craft/Five Turns";
			info.type = "at";
			break;
		case $effect[Rolando's Rondo of Resisto]:
			info.name = "Rondo of Resisto";
			info.type = "at";
			break;
		case $effect[Paul's Passionate Pop Song]:
			info.name = "Passionate Pop Song";
			info.type = "at";
			break;
		case $effect[Dirge of Dreadfulness]:
		case $effect[Polka of Plenty]:
		case $effect[Cringle's Curative Carol]:
		case $effect[Donho's Bubbly Ballad]:
			info.type = "at";
			break;
		case $effect[Ode to Booze]:
			info.type = "at";
			info.desc = "+1 Adv/Inebriety From Booze";
			break;
		// hobopolis at songs
		case $effect[The Ballad of Richie Thingfinder]:
			info.name = "Thingfinder";
			info.type = "hobop";
			break;
		case $effect[Benetton's Medley of Diversity]:
			info.name = "Benetton's";
			info.type = "hobop";
			break;
		case $effect[Elron's Explosive Etude]:
			info.name = "Elron's";
			info.type = "hobop";
			break;
		case $effect[Chorale of Companionship]:
		case $effect[Prelude of Precision]:
			info.type = "hobop";
			break;
		// TT Buffs
		case $effect[Jingle Jangle Jingle]:
			info.name = "Jingle Bells";
			info.type = "tt";
			break;
		case $effect[Curiosity of Br'er Tarrypin]:
			info.name = "Curiosity";
			info.type = "tt";
			break;
		case $effect[Ghostly Shell]:
		case $effect[Tenacity of the Snapper]:
		case $effect[Empathy]:
		case $effect[Reptilian Fortitude]:
		case $effect[Astral Shell]:
		case $effect[Thoughtful Empathy]:
			info.type = "tt";
			break;
		case $effect[Blessing of the War Snapper]:
		case $effect[Blessing of She-Who-Was]:
		case $effect[Blessing of the Storm Tortoise]:
		case $effect[Grand Blessing of the War Snapper]:
		case $effect[Grand Blessing of She-Who-Was]:
		case $effect[Grand Blessing of the Storm Tortoise]: {
			boolean isGrand = info.name.starts_with("Grand");
			int speedUps = 0;
			foreach it in $items[bakelite badge, Ouija Board\, Ouija Board, spirit bell] {
				if(equipped_amount(it) > 0) {
					// Ouija Board, Ouija Board only works in the off-hand, not on lefty
					if(it == $item[Ouija Board\, Ouija Board] && equipped_item($slot[off-hand]) != it)
						continue;
					++speedUps;
				}
			}
			int totalNeededToUpgrade() {
				switch(speedUps) {
				case 0: return isGrand ? 100 : 30; // 70 from grand to glorious
				case 1: return isGrand ? 60 : 20; // 40 from grand to glorious
				case 2: return isGrand ? 50 : 15; // 35 from grand to glorious
				case 3: return isGrand ? 40 : 10; // TODO: Confirm this
				default: return isGrand ? 30 : 5; // This is not yet reachable, just future-proofing
				}
			}
			int turnsSoFar = get_property("turtleBlessingTurns").to_int();
			info.name += ' <span title="This number may be inaccurate if you wear blessing speedup items for part of the process but not all">(' +
				turnsSoFar + '/' + totalNeededToUpgrade() + ')</span>';
			if(speedUps >= 3) {
				info.name += '<br><span class="efmods">(This is a guess. Please send confirmation for or against to Soolar the Second (#2463557))</span>';
			}
			break;
		}
		// SC Effects
		case $effect[Rage of the Reindeer]:
		case $effect[Musk of the Moose]:
		case $effect[Snarl of the Timberwolf]:
		case $effect[A Few Extra Pounds]:
			info.type = "sc";
			break;
		case $effect[Iron Palms]:
			info.type = "sc";
			info.desc = "Swords Are Clubs";
			info.addExtra(extraInfoCmd("cast Iron Palm Technique"));
			break;
		// PM Effects
		case $effect[Springy Fusilli]:
		case $effect[Leash of Linguini]:
			info.type = "pm";
			break;
		case $effect[Spirit of Bacon Grease]:
			info.type = "pm";
			info.customStyle = "color:blueviolet;font-style:italic";
			info.addExtra(extraInfoPicker("flavour", ""));
			break;
		case $effect[Spirit of Cayenne]:
			info.type = "pm";
			info.customStyle = "color:red;font-style:italic";
			info.addExtra(extraInfoPicker("flavour", ""));
			break;
		case $effect[Spirit of Peppermint]:
			info.type = "pm";
			info.customStyle = "color:blue;font-style:italic";
			info.addExtra(extraInfoPicker("flavour", ""));
			break;
		case $effect[Spirit of Garlic]:
			info.type = "pm";
			info.customStyle = "color:green;font-style:italic";
			info.addExtra(extraInfoPicker("flavour", ""));
			break;
		case $effect[Spirit of Wormwood]:
			info.type = "pm";
			info.customStyle = "color:grey;font-style:italic";
			info.addExtra(extraInfoPicker("flavour", ""));
			break;
		// SA Buffs/Effects
		case $effect[Antibiotic Saucesphere]:
			info.name = "Antibiotic Sauce";
			info.type = "sa";
			break;
		case $effect[Elemental Saucesphere]:
			info.name = "Elemental Sauce";
			info.type = "sa";
			break;
		case $effect[Jalape&ntilde;o Saucesphere]:
			info.name = "Jalape&ntilde;o";
			info.type = "sa";
			break;
		case $effect[Scarysauce]:
			info.type = "sa";
			break;
		case $effect[[1457]Blood Sugar Sauce Magic]:
		case $effect[[1458]Blood Sugar Sauce Magic]:
			info.name = "Blood Sugar Sauce";
			info.type = "sa";
			info.addExtra(extraInfoCmd("cast Blood Sugar Sauce Magic"));
			break;
		// DB Effect lol
		case $effect[Smooth Movements]:
			info.type = "db";
			break;
		// Dread songs
		case $effect[Song of the North]:
		case $effect[Song of Slowness]:
		case $effect[Song of Starch]:
		case $effect[Song of Sauce]:
		case $effect[Song of Bravado]:
			info.type = "dread";
			info.addExtra(extraInfoPicker("dreadsong", ""));
			break;
		// AoB Songs
		case $effect[Song of Accompaniment]:
			info.type = "aob";
			info.name = "Accompaniment";
			break;
		case $effect[Song of Cockiness]:
			info.type = "aob";
			info.name = "Cockiness";
			break;
		case $effect[Song of Solitude]:
			info.type = "aob";
			info.name = "Solitude";
			break;
		case $effect[Song of Fortune]:
			info.type = "aob";
			info.name = "Fortune";
			break;
		case $effect[Song of Battle]:
			info.type = "aob";
			info.name = "Battle";
			break;
		case $effect[Song of the Glorious Lunch]:
			info.type = "aob";
			break;
		// AoJ Spheres
		case $effect[Coffeesphere]:
			info.type = "aoj";
			break;
		case $effect[Oilsphere]:
			info.type = "aoj";
			break;
		case $effect[Gristlesphere]:
			info.type = "aoj";
			break;
		case $effect[Chocolatesphere]:
			info.type = "aoj";
			break;
		// AWoL Walks
		case $effect[Cautious Prowl]:
			info.type = "awol";
			break;
		case $effect[Prideful Strut]:
			info.type = "awol";
			break;
		case $effect[Leisurely Amblin']:
			info.type = "awol";
			break;
		// Asdonmartin
		case $effect[Driving Wastefully]:
			info.type = "asdon";
			info.desc = "Oil Peak pressure reduction";
			break;
		case $effect[Driving Obnoxiously]:
		case $effect[Driving Stealthily]:
		case $effect[Driving Safely]:
		case $effect[Driving Recklessly]:
		case $effect[Driving Intimidatingly]:
		case $effect[Driving Quickly]:
		case $effect[Driving Observantly]:
		case $effect[Driving Waterproofly]:
			info.type = "asdon";
			break;
		// Holorecords
		case $effect[Drunk and Avuncular]:
			info.type = "holorecord";
			info.desc = "Booze gives +100% more Adventures";
			break;
		case $effect[Record Hunger]:
			info.type = "holorecord";
			info.desc = "Food gives +100% more Adventures";
			break;
		case $effect[Power, Man]:
		case $effect[Shrieking Weasel]:
		case $effect[Superdrifting]:
		case $effect[Ministrations in the Dark]:
		case $effect[Lucky Struck]:
			info.type = "holorecord";
			break;
		case $effect[Everything Looks Blue]:
			info.type = "elx";
			info.customStyle = "color:blue";
			break;
		case $effect[Everything Looks Red]:
			info.type = "elx";
			info.customStyle = "color:red";
			break;
		case $effect[Everything Looks Yellow]:
			info.type = "elx";
			info.customStyle = "color:olive";
			break;
		case $effect[Everything Looks Green]:
			info.type = "elx";
			info.customStyle = "color:green";
			break;
		case $effect[Everything Looks Purple]:
			info.type = "elx";
			info.customStyle = "color:purple";
			break;
		case $effect[Everything looks Beige]:
			info.type = "elx";
			info.customStyle = "color:burlywood";
			break;
		case $effect[Everything looks Red, White and Blue]:
			info.type = "elx";
			break;
		// Juju Mask
		case $effect[Gaze of the Lightning God]:
			info.customStyle = "color:blue";
			break;
		case $effect[Gaze of the Trickster God]:
			info.customStyle = "color:green";
			break;
		case $effect[Gaze of the Volcano God]:
			info.customStyle = "color:red";
			break;
		// Sniff sniff
		case $effect[On the Trail]:
			info.desc = get_property("olfactedMonster");
			break;
		// HELP I CAN'T SEE
		case $effect[Temporary Blindness]:
			info.customStyle = "background-color:black; color:white";
			break;
		// Effects that pertain to a location and link there
		case $effect[Shape of...Mole!]:
			info.addExtra(extraInfoLink("", attrmap {
				"href": "adventure.php?snarfblat=177",
				"title": "Adventure at Mt. Molehill",
			}));
			break;
		case $effect[Transpondent]:
			info.addExtra(extraInfoLink("", attrmap {
				"href": "spaaace.php?arrive=1",
				"title": "Visit Spaaace",
			}));
			break;
		case $effect[Absinthe-Minded]:
			info.addExtra(extraInfoLink("", attrmap {
				"href": "place.php?whichplace=wormwood",
				"title": "Check out the Wormwood",
			}));
			break;
		case $effect[Down the Rabbit Hole]:
			info.addExtra(extraInfoLink("", attrmap {
				"href": "place.php?whichplace=rabbithole",
				"title": "Go on down the rabbit hole",
			}));
			break;
		case $effect[Dis Abled]:
			info.addExtra(extraInfoLink("", attrmap {
				"href": "suburbandis.php",
				"title": "Visit suburban Dis",
			}));
			break;
		// Holy cow, shorten this nonsense
		case $effect[Video... Games?]:
			info.desc = "EVERYTHING +5";
			break;
		// Even now we await his return
		case $effect[Eldritch Attunement]:
			info.desc = "Tentacles every fight";
			break;
		// Vampyre Forms
		case $effect[Wolf Form]:
			info.addExtra(extraInfoCmd("cast Wolf Form"));
			info.addExtra(extraInfoLink("", attrmap {
				"href": sideCommand("cast Wolf Form"),
				"title": "Toggle Wolf Form",
			}));
			break;
		case $effect[Mist Form]:
			info.addExtra(extraInfoCmd("cast Mist Form"));
			break;
		case $effect[Bats Form]:
			info.addExtra(extraInfoCmd("cast Flock of Bats Form"));
			break;
		// Other random junk
		case $effect[Knob Goblin Perfume]:
			info.desc = "!";
			break;
		case $effect[Bored With Explosions]: {
			matcher wafe = create_matcher(":([^:]+):walk away from explosion:", get_property("banishedMonsters"));
			if(wafe.find()) {
				info.desc = wafe.group(1);
			} else {
				info.desc = "You're just over them";
			}
			break;
		}
		case $effect[Citizen of a Zone]:
			info.name = "Citizen of " + get_property("_citizenZone");
			break;
		case $effect[Offhand Remarkable]: {
			string mods = "";
			if(equipped_item($slot[off-hand]).to_slot() == $slot[off-hand]) {
				mods += string_modifier(equipped_item($slot[off-hand]), "Evaluated Modifiers");
			}
			if(my_familiar() == $familiar[Left-Hand Man] && equipped_item($slot[familiar]).to_slot() == $slot[off-hand]) {
				string famMods = string_modifier(equipped_item($slot[familiar]), "Evaluated Modifiers");
				if(mods != "" && famMods != "") {
					string modsFinal = mods;
					foreach i, mod in famMods.split_string(", ") {
						matcher modParse = create_matcher('([^,:]+): ([+-]?\\d+|"[^"]+")', mod);
						if(modParse.find()) {
							string modName = modParse.group(1);
							string modVal = modParse.group(2);
							matcher origParse = create_matcher(modName + ': ([+-]?\\d+|"[^"]+")', mods);
							if(origParse.find()) {
								if(modVal.starts_with('"')) {
									if(origParse.group(1) != modVal) {
										modsFinal += ', ' + modName + ': ' + origParse.group(1);
									}
								} else {
									int sumVal = modVal.to_int() + origParse.group(1).to_int();
									modsFinal = modsFinal.replace_string(origParse.group(0), modName + ': ' + sumVal);
								}
							} else {
								modsFinal += ', ' + modParse.group(0);
							}
						} else {
							modsFinal += ', ' + mod;
						}
					}
					mods = modsFinal;
				} else {
					mods = famMods;
				}
			}
			info.desc = '<span title="This might not be entirely accurate when nonstandard mods are involved">'
				+ parseMods(mods, span) + '</span>';
			break;
		}
	}

	// could do this above but it'd be SO MUCH REPEAT CODE
	if(eff.song && info.count > 0 && !avoidRecursion) {
		picker_atsong(eff);
		info.addExtra(extraInfoPicker("MANUAL:atsong" + eff.to_int(), ''));
	}

	if(eff.to_skill().expression) {
		info.type = "expression";
		info.addExtra(extraInfoPicker("expression", ""));
	}

	if(info.type == "asdon") {
		info.addExtra(extraInfoPicker("asdon", ""));
	}

	// checks for in case you got it via hookah and can't do them yourself
	if(eff.to_skill().shanty && availableShanties().count() > 0) {
		info.type = "shanty";
		info.addExtra(extraInfoPicker("shanty", ""));
	}

	string [string] classmap = {
		"at": "accordion.gif",
		"sc": "club.gif",
		"tt": "turtle.gif",
		"sa": "saucepan.gif",
		"pm": "pastaspoon.gif",
		"db": "discoball.gif",
	};

	if(info.type != "" && index_of(cvars["chit.effects.classicons"], info.type) > -1 && (classmap contains info.type)) {
		info.image = classmap[info.type];
	}

	if(info.desc == "") {
		info.desc = parseMods(string_modifier(eff, "Evaluated Modifiers"), span);
	} else if(info.desc == "!") {
		info.desc = "";
	}

	return info;
}

chit_info getEffectInfo(effect eff, boolean avoidRecursion) {
	return getEffectInfo(eff, avoidRecursion, true);
}

chit_info getEffectInfo(effect eff) {
	return getEffectInfo(eff, false);
}

// all lacks must have exactly one extra
chit_info [int] lackedEffects() {
	chit_info [int] res;

	void addLackWithPicker(string name, string type, string picker, string image) {
		chit_info lack;
		lack.name = name;
		lack.image = image;
		lack.type = type;
		lack.addExtra(extraInfoPicker(picker, ""));
		res[res.count()] = lack;
	}

	int fillableSongSlots = lackingSongs();
	if(fillableSongSlots > 0) {
		addLackWithPicker(fillableSongSlots + " song slot" + (fillableSongSlots > 1 ? "s" : ""),
			"at", "atsong", itemimage("notes.gif"));
	}

	if(lacksDreadSong()) {
		addLackWithPicker("Dreadful Silence", "dread", "dreadsong", itemimage("notes.gif"));
	}

	if(lacksExpression()) {
		addLackWithPicker("Expressionless", "expression", "expression", itemimage("abs5.gif"));
	}

	if(lacksShanty()) {
		addLackWithPicker("Not Shantying", "shanty", "shanty", itemimage("notes.gif"));
	}

	if(lacksHolorecord()) {
		addLackWithPicker("Peace and Quiet", "holorecord", "holorecord",
			itemimage($item[Wrist-Boy].image));
	}

	if(get_workshed() == $item[Asdon Martin keyfob (on ring)] && be_good($item[Asdon Martin keyfob (on ring)]) && !isDriving()) {
		addLackWithPicker("Not Driving", "asdon", "asdon",
			itemimage($item[Asdon Martin keyfob (on ring)].image));
	}

	if(lacksFlavour()) {
		addLackWithPicker("Choose a Flavour", "pm", "flavour", itemimage("flavorofmagic.gif"));
		res[res.count() - 1].count = -1;
	}

	void addLack(effect eff) {
		chit_info info = getEffectInfo(eff);
		info.name = "Lack of " + info.name;
		info.desc = "";
		info.count = -1;
		res[res.count()] = info;
	}

	effect bloodSugarEff = my_class() == $class[Sauceror] ? $effect[[1458]Blood Sugar Sauce Magic]
		: $effect[[1457]Blood Sugar Sauce Magic];
	if(have_skill($skill[Blood Sugar Sauce Magic]) && be_good($skill[Blood Sugar Sauce Magic]) && have_effect(bloodSugarEff) == 0) {
		addLack(bloodSugarEff);
	}

	void checkLackWithSkill(skill sk, effect eff) {
		if(have_skill(sk) && be_good(sk) && have_effect(eff) == 0) {
			addLack(eff);
		}
	}

	checkLackWithSkill($skill[Iron Palm Technique], $effect[Iron Palms]);

	if(my_class() == $class[Vampyre]) {
		checkLackWithSkill($skill[Wolf Form], $effect[Wolf Form]);
		checkLackWithSkill($skill[Mist Form], $effect[Mist Form]);
		checkLackWithSkill($skill[Flock of Bats Form], $effect[Bats Form]);
	}

	return res;
}

void addEffectIcon(buffer result, effect eff, string titlePrefix, boolean popupDescOnClick, string wrappingElement, attrmap wrappingElementAttrs) {
	chit_info info = getEffectInfo(eff, true);

	result.addInfoIcon(info, info.name, info.desc, popupDescOnClick ? ("eff('" + eff.descid +
		"'); return false;") : '', wrappingElement, wrappingElementAttrs);
}
