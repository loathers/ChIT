void picker_snapper() {
	buffer picker;
	picker.pickerStart("snapper", "Guide me!");

	void addPhylum(phylum phy, string phylumPlural, item get, string desc) {
		if(phylumPlural == "")
			phylumPlural = phy.to_string() + "s";

		string phyLinkName = (phy == $phylum[mer-kin]) ? "merkin" : phy.to_string();
		string guideLink = '<a class="change" href="' + sideCommand("ashq visit_url('familiar.php?action=guideme&pwd'); visit_url('choice.php?pwd&whichchoice=1396&option=1&cat=" + phyLinkName + "')") + '">';

		picker.append('<tr class="pickitem"><td class="icon"><a class="done" href="#" oncontextmenu="descitem(');
		picker.append(get.descid);
		picker.append(',0,event); return false;" onclick="descitem(');
		picker.append(get.descid);
		picker.append(',0,event)"><img class="chit_icon" src="/images/itemimages/');
		picker.append(phy.image);
		picker.append('" title="Click for item description of snapper drop" /></a></td><td colspan="2">');
		picker.append(guideLink);
		picker.append('<b>Guide</b> me towards ');
		picker.append(phylumPlural);
		picker.append('<br /><span class="descline">');
		picker.append(desc);
		picker.append('</span></a></td></tr>');
	}

	addPhylum($phylum[beast], "", $item[patch of extra-warm fur], "Potion, 20 turns of Superhuman Cold Resistance");
	addPhylum($phylum[bug], "", $item[a bug's lymph], "Spleen size 1, 60 turns of HP +100% and 8-10 HP Regen");
	addPhylum($phylum[constellation], "", $item[micronova], "Combat item, yellow ray");
	addPhylum($phylum[construct], "", $item[industrial lubricant], "Spleen size 1, 30 turns of +150% init");
	addPhylum($phylum[demon], "", $item[infernal snowball], "Potion, 20 turns of Superhuman Hot Resistance");
	addPhylum($phylum[dude], "", $item[human musk], "Combat item, all day banish (first 3 free)");
	addPhylum($phylum[elemental], "elementals", $item[livid energy], "Spleen size 1, 60 turns of +50% MP and 3-5 MP Regen");
	addPhylum($phylum[elf], "elves", $item[peppermint syrup], "Potion, 20 turns of +50% Candy Drops");
	addPhylum($phylum[fish], "fish", $item[fish sauce], "Spleen size 1, 30 turns of Fishy");
	addPhylum($phylum[goblin], "", $item[guffin], "Food size 3, awesome quality");
	addPhylum($phylum[hippy], "hippies", $item[organic potpourri], "Potion, 20 turns of Superhuman Stench Resistance");
	addPhylum($phylum[hobo], "", $item[beggin' cologne], "Spleen size 1, 60 turns of +100% Meat");
	addPhylum($phylum[horror], "", $item[powdered madness], "Combat item, free kill (up to 5 a day)");
	addPhylum($phylum[humanoid], "", $item[vial of humanoid growth hormone], "Spleen size 1, 30 turns of +50% Muscle Gains");
	addPhylum($phylum[mer-kin], "mer-kin", $item[mer-kin eyedrops], "Potion, 20 turns of +30% Underwater Item Drops");
	addPhylum($phylum[orc], "", $item[boot flask], "Booze size 3, awesome quality");
	addPhylum($phylum[penguin], "", $item[envelope full of meat], "Usable for ~1k meat");
	addPhylum($phylum[pirate], "", $item[Shantix&trade;], "Spleen size 1, 30 turns of +50% Moxie Gains");
	addPhylum($phylum[plant], "", $item[goodberry], "Combat item, full HP recovery");
	addPhylum($phylum[slime], "", $item[extra-strength goo], "Potion, 20 turns of Superhuman Sleaze Resistance");
	addPhylum($phylum[undead], "undead", $item[unfinished pleasure], "Potion, 20 turns of Superhuman Spooky Resistance");
	addPhylum($phylum[weird], "weirdos", $item[non-Euclidean angle], "Spleen size 1, 30 turns of +50% Mysticality Gains");

	picker.pickerFinish("Changing guidance...");
}

chit_info getFamiliarInfo(familiar f, slot s) {
	boolean isStandardFam = s == $slot[familiar] && my_path() != $path[Pocket Familiars];
	item famsEquip = familiar_equipped_equipment(f);

	chit_info info;
	info.image = itemimage(f.image);

	if(isStandardFam) {
		drop_info[int] drops;

		if(f.drops_limit > 0) {
			int dropsLeft = f.drops_limit - f.drops_today;
			if(dropsLeft > 0) {
				if(f.drop_item != $item[none]) {
					drops[drops.count()] = new drop_info('', dropsLeft, f.drop_item, f.drop_item.plural);
				}
				else {
					drops[drops.count()] = new drop_info('', dropsLeft, f.drop_name, f.drop_name + 's');
				}
			}
		}

		if(f.fights_limit > 0) {
			int fightsLeft = f.fights_limit - f.fights_today;
			if(fightsLeft > 0) {
				drops[drops.count()] = new drop_info('', fightsLeft, 'fight', 'fights');
			}
		}

		info.addDrops(drops);
	}

	void addBjornDrop(drop_info di) {
		if(s != $slot[buddy-bjorn] && s != $slot[crown-of-thrones]) {
			return;
		}
		info.addDrop(di);
	}

	void addInfBjornDrop(string name) {
		addBjornDrop(new drop_info('', LIMIT_INFINITE, name));
	}

	switch(f) {
		case $familiar[none]:
			info.image = itemimage('antianti.gif');
			break;

		// these three change appearance to whatever they have equipped
		// we already show that separately, so turn them back
		case $familiar[Fancypants Scarecrow]:
			info.image = itemimage('pantscrow2.gif');
			// intentional fallthrough
		case $familiar[Mad Hatrack]: {
			if(info.image != itemimage('pantscrow2.gif')) {
				info.image = itemimage('hatrack.gif');
			}
			if(famsEquip == $item[none]) {
				break;
			}
			matcher m = create_matcher('^(.*?), cap (.*?)$', string_modifier(famsEquip, 'Familiar Effect'));
			if(find(m)) {
				info.addExtra(extraInfoEquipFam(m.group(1).replace_string('x', ' x '), m.group(2)));
			}
			else {
				info.addExtra(extraInfoEquipFam('Unknown Effect', '?'));
			}
			break;
		}
		case $familiar[Disembodied Hand]:
			info.image = itemimage('dishand.gif');
			break;
		case $familiar[Crimbo Shrub]:
			if(to_boolean(vars['chit.familiar.anti-gollywog'])) {
				info.image = imagePath + 'crimboshrub_fxx_ckb.gif';
			}
			foreach part in $strings[shrubTopper, shrubLights, shrubGarland, shrubGifts] {
				string deco = get_property(part);
				if(deco != '') {
					switch(deco) {
						case 'yellow':
							info.addToDesc('<span style="color:#999933">Yellow</span>');
							break;
						case 'meat':
							info.addToDesc('<span style="color:#FE2E2E">Meat</span>');
							break;
						// TODO: Something about PvP?
						default:
							info.addToDesc(deco);
							break;
					}
				}
			}
			switch(get_property('shrubGifts')) {
				case 'yellow':
					if(have_effect($effect[Everything Looks Yellow]) == 0) {
						info.addToDesc('Ready to fire!');
						info.incDrops(DROPS_ALL);
					}
					break;
				case 'meat':
					if(have_effect($effect[Everything Looks Red]) == 0) {
						info.addToDesc('Ready to fire!');
						info.incDrops(DROPS_ALL);
					}
					break;
				case '':
					info.addToDesc('Needs to be decorated');
					info.incDrops(DROPS_ALL);
					info.addExtra(extraInfoLink('decorate', attrmap {
						'target': 'mainpane',
						'href': 'inv_use.php?pwd=' + my_hash() + '&which=3&whichitem=7958',
					}));
					break;
			}
			break;
		case $familiar[Happy Medium]:
			switch(f.image) {
				case 'medium_1.gif':
					info.image = imagePath + 'medium_blue.gif';
					break;
				case 'medium_2.gif':
					info.image = imagePath + 'medium_orange.gif';
					break;
				case 'medium_3.gif':
					info.image = imagePath + 'medium_red.gif';
					break;
			}
			break;
		case $familiar[Grimstone Golem]:
			addBjornDrop(new drop_info('_grimstoneMaskDropsCrown', 1, 'mask'));
			if(!can_interact() && (available_amount($item[grimstone mask]) + available_amount($item[ornate dowsing rod])) == 0) {
				info.dangerLevel = DANGER_GOOD;
			}
			break;
		case $familiar[Grim Brother]:
			addBjornDrop(new drop_info('_grimFairyTaleDropsCrown', 2, 'fairy tale', 'fairy tales'));
			if(!get_property('_grimBuff').to_boolean()) {
				info.addExtra(extraInfoLink('talk', attrmap {
					'target': 'mainpane',
					'href': 'familiar.php?action=chatgrim&pwd=' + my_hash(),
				}));
			}
			break;
		case $familiar[Trick-or-Treating Tot]:
			addBjornDrop(new drop_info('_hoardedCandyDropsCrown', 3, 'candy', 'candies'));
			break;
		case $familiar[Optimistic Candle]:
			addBjornDrop(new drop_info('_optimisticCandleDropsCrown', 3, 'glob of wax', 'globs of wax'));
			if(isStandardFam) {
				info.addDrop(new drop_info('optimisticCandleProgress', -30, 'wax', 'wax'));
			}
			break;
		case $familiar[Garbage Fire]:
			addBjornDrop(new drop_info('_garbageFireDropsCrown', 3, 'newpaper', 'newspapers'));
			if(isStandardFam) {
				info.addDrop(new drop_info('garbageFireProgress', -30, 'garbage'));
			}
			break;
		case $familiar[Twitching Space Critter]:
			addBjornDrop(new drop_info('_spaceFurDropsCrown', 1, 'fur'));
			break;
		case $familiar[Machine Elf]: {
			addBjornDrop(new drop_info('_abstractionDropsCrown', 25, 'abstraction', 'abstractions'));
			if(!isStandardFam) {
				break;
			}
			int thought = item_amount($item[abstraction: thought]);
			int action = item_amount($item[abstraction: action]);
			int sensation = item_amount($item[abstraction: sensation]);
			string linkClass = 'visit';
			if(thought > 0 && action > 0 && sensation > 0) {
				linkClass += ' blue-link';
			}
			info.addExtra(extraInfoLink('DMT', attrmap {
				'class': linkClass,
				'target': 'mainpane',
				'title': 'DMT mixing: ' + thought + ' item, ' + action + ' weight, ' + sensation + ' init possible',
				'href': 'place.php?whichplace=dmt',
			}));
			info.addToDesc('dupe ' + (get_property('lastDMTDuplication').to_int() >= my_ascensions() ? 'used' : 'available'));
			break;
		}
		case $familiar[Adventurous Spelunker]:
			addBjornDrop(new drop_info('_oreDropsCrown', 6, 'non-quest ore', 'non-quest ores'));
			break;
		case $familiar[Puck Man]:
		case $familiar[Ms. Puck Man]:
			addBjornDrop(new drop_info('_yellowPixelDropsCrown', 25, 'yellow pixel', 'yellow pixels'));
			info.addToDesc(item_amount($item[Yellow Pixel]) + ' yellow pixels');
			info.addExtra(extraInfoLink('mystic', attrmap {
				'class': 'visit',
				'target': 'mainpane',
				'title': 'Visit the Crackpot Mystic',
				'href': 'shop.php?whichshop=mystic',
			}));
			break;
		case $familiar[Warbear Drone]:
			addInfBjornDrop('whosits');
			break;
		case $familiar[Li'l Xenomorph]:
			addInfBjornDrop('isotopes');
			break;
		case $familiar[Pottery Barn Owl]:
			addInfBjornDrop('volcanic ash');
			break;
		case $familiar[Party Mouse]:
			addInfBjornDrop('decent-good booze');
			break;
		case $familiar[Yule Hound]:
			addInfBjornDrop('candy cane');
			break;
		case $familiar[Gluttonous Green Ghost]:
			addInfBjornDrop('burritos');
			break;
		case $familiar[Reassembled Blackbird]:
		case $familiar[Reconstituted Crow]: {
			addInfBjornDrop('blackberries');
			string blackForestState = get_property('questL11Black');
			if(isStandardFam) {
				if((blackForestState == 'started' || blackForestState == 'step1')
					&& (item_amount($item[reassembled blackbird]) + item_amount($item[reconstituted crow])) == 0) {
					info.dangerLevel = DANGER_GOOD;
				}
				else {
					info.dangerLevel = DANGER_DANGEROUS;
				}
			}
			break;
		}
		case $familiar[Hunchbacked Minion]:
			addInfBjornDrop('brain or bone');
			break;
		case $familiar[Reanimated Reanimator]:
			addInfBjornDrop('hot wings or skulls');
			if(get_property('_badlyRomanticArrows').to_int() == 0) {
				info.addToDesc('Wink available');
				info.incDrops(DROPS_ALL);
			}
			info.addExtra(extraInfoLink('chat', attrmap {
				'target': 'mainpane',
				'href': 'main.php?talktoreanimator=1',
			}));
			break;
		case $familiar[Attention-Deficit Demon]:
			addInfBjornDrop('bad food');
			break;
		case $familiar[Piano Cat]:
			addInfBjornDrop('bad booze');
			break;
		case $familiar[Golden Monkey]:
			addInfBjornDrop('gold nuggets');
			break;
		case $familiar[Robot Reindeer]:
		case $familiar[Ancient Yuletide Troll]:
		case $familiar[Sweet Nutcracker]:
			addInfBjornDrop('holiday snacks');
			break;
		case $familiar[Stocking Mimic]:
			addInfBjornDrop('simple candy');
			if(!isStandardFam) {
				break;
			}
			info.addDrop(new drop_info('_bagOfCandy', LIMIT_BOOL, 'candy bag'));
			break;
		case $familiar[BRICKO chick]:
			addInfBjornDrop('BRICKO brick');
			break;
		case $familiar[Cotton Candy Carnie]:
			addInfBjornDrop('cotton candy pinches');
			break;
		case $familiar[Untamed Turtle]:
			addInfBjornDrop('turtle bits');
			break;
		case $familiar[Astral Badger]:
			addInfBjornDrop('shrooms');
			break;
		case $familiar[Green Pixie]:
			addInfBjornDrop('bottles of tequila');
			break;
		case $familiar[Angry Goat]:
			addInfBjornDrop('goat cheese pizzas');
			break;
		case $familiar[Adorable Seal Larva]:
			addInfBjornDrop('elemental nuggets');
			break;
		case $familiar[Frozen Gravy Fairy]:
			addInfBjornDrop('cold nuggets');
			break;
		case $familiar[Stinky Gravy Fairy]:
			addInfBjornDrop('stench nuggets');
			break;
		case $familiar[Sleazy Gravy Fairy]:
			addInfBjornDrop('sleaze nuggets');
			break;
		case $familiar[Spooky Gravy Fairy]:
			addInfBjornDrop('spooky nuggets');
			break;
		case $familiar[Flaming Gravy Fairy]:
			addInfBjornDrop('hot nuggets');
			break;
		case $familiar[Gelatinous Cubeling]: {
			if(!isStandardFam) {
				break;
			}
			int progress = get_property('cubelingProgress').to_int();
			drop_info [int] drops;
			if(progress < 6) {
				drops[drops.count()] = new drop_info('', LIMIT_BOOL_INVERTED, 'pole');
			}
			if(progress < 9) {
				drops[drops.count()] = new drop_info('', LIMIT_BOOL_INVERTED, 'ring');
			}
			if(progress < 12) {
				drops[drops.count()] = new drop_info('', LIMIT_BOOL_INVERTED, 'pick');
				if(in_hardcore()) {
					info.dangerLevel = DANGER_GOOD;
				}
			}
			info.addDrops(drops);
			break;
		}
		case $familiar[Melodramedary]: {
			buffer weirdoDiv;
			weirdoDiv.addImg('/images/otherimages/camelfam_left.gif', attrmap { 'border': '0' });
			for(int i = 0; i < f.familiar_weight() / 5; ++i) {
				weirdoDiv.addImg('/images/otherimages/camelfam_middle.gif', attrmap { 'border': '0' });
			}
			weirdoDiv.addImg('/images/otherimages/camelfam_right.gif', attrmap { 'border': '0' });
			info.weirdoDivContents = weirdoDiv;
			if(get_property('camelSpit').to_int() >= 100) {
				info.addToDesc('Ready to spit!');
				info.incDrops(DROPS_ALL);
			}
			break;
		}
		case $familiar[Left-Hand Man]: {
			matcher leftyMatcher = create_matcher('<div style="position: relative; height: 50px; width: 30px" >(.+?)</div>', chitSource["familiar"]);
			if(leftyMatcher.find()) {
				info.weirdoDivContents = leftyMatcher.group(1);
			}
			break;
		}
		case $familiar[Fist Turkey]: {
			if(!isStandardFam) {
				break;
			}
			boolean statsMatter = my_path() == $path[The Source];
			info.addDrops(drops_info {
				new drop_info('_turkeyMuscle', 5, 'mus', 'mus', statsMatter),
				new drop_info('_turkeyMyst', 5, 'mys', 'mys', statsMatter),
				new drop_info('_turkeyMoxie', 5, 'mox', 'mox', statsMatter),
			});
			break;
		}
		case $familiar[Steam-Powered Cheerleader]: {
			if(!isStandardFam) {
				break;
			}
			int steamPercent = ceil(to_float(get_property('_cheerleaderSteam')) / 2);
			info.addDrop(new drop_info('', steamPercent, '% steam'));
			if(steamPercent > 50) {
				info.incDrops(DROPS_ALL);
			}
			break;
		}
		case $familiar[Slimeling]: {
			drops_info drops;
			float fullness = to_float(get_property('slimelingFullness'));
			if(fullness > 0) {
				drops[drops.count()] = new drop_info('', fullness, 'approx fullness');
			}
			int stacksDue = to_int(get_property('slimelingStacksDue'));
			int stacksDropped = to_int(get_property('slimelingStacksDropped'));
			if(stacksDue > stacksDropped) {
				drops[drops.count()] = new drop_info('', stacksDue - stacksDropped, 'stack', 'stacks');
				if(stacksDropped == 0) {
					info.incDrops(DROPS_ALL);
				}
			}
			break;
		}
		case $familiar[Rockin' Robin]:
			if(isStandardFam) {
				info.addDrop(new drop_info('rockinRobinProgress', -30, 'egg', 'egg'));
			}
			break;
		case $familiar[Intergnat]: {
			if(!isStandardFam) {
				break;
			}
			string demon = get_property('demonName12');
			if(demon.length() < 5 || demon.substring(0, 5) != 'Neil ') {
				info.addToDesc('Demon name unknown');
				info.incDrops(DROPS_ALL);
			}
			else {
				info.addToDesc('Demon name is ' + demon);
			}
			// you can't just buy demon summoning mats off the mall
			if(!can_interact()) {
				if(available_amount($item[scroll of ancient forbidden unspeakable evil]) == 0) {
					info.addToDesc('need AFUE scroll');
					info.incDrops(DROPS_SOME);
				}
				if(available_amount($item[thin black candle]) < 3) {
					info.addToDesc('need ' + (3 - available_amount($item[thin black candle])) + ' more candles');
					info.incDrops(DROPS_SOME);
				}
			}
			int baconAmount = item_amount($item[BACON]);
			info.addExtra(extraInfoLink(baconAmount + ' BACON', attrmap {
				'class': 'visit',
				'target': 'mainpane',
				'title': 'Internet Meme Shop',
				'href': 'shop.php?whichshop=bacon&pwd=' + my_hash(),
			}));
			break;
		}
		case $familiar[Space Jellyfish]: {
			if(!isStandardFam) {
				break;
			}
			int spaceJellyfishDrops = get_property('_spaceJellyfishDrops').to_int();
			info.addToDesc(spaceJellyfishDrops + ' jelly sucked');
			if(my_level() >= 11 && my_class().to_int() < 7) {
				boolean seaAvail = info.addDrop(new drop_info('_seaJellyHarvested', LIMIT_BOOL, 'Sea jelly'));
				if(seaAvail) {
					info.addExtra(extraInfoLink('sea', attrmap {
						'class': 'visit',
						'target': 'mainpane',
						'title': 'To the sea!',
						'href': get_property('questS01OldGuy') == 'unstarted' ? 'oldman.php' :
							'place.php?whichplace=thesea&action=thesea_left2',
					}));
				}
			}
			if(spaceJellyfishDrops == 0) {
				info.incDrops(DROPS_ALL);
			}
			else if(spaceJellyfishDrops < 3) {
				info.incDrops(DROPS_SOME);
			}
			break;
		}
		case $familiar[XO Skeleton]: {
			if(!isStandardFam) {
				break;
			}
			info.addDrops(drops_info {
				new drop_info('xoSkeleltonXProgress', -9, 'X'),
				new drop_info('xoSkeleltonOProgress', -9, 'O'),
				new drop_info('_xoHugsUsed', 11, 'hug', 'hugs'),
			});
			int xs = item_amount($item[X]);
			int os = item_amount($item[O]);
			if(xs + os > 0) {
				info.addExtra(extraInfoLink('xo store', attrmap {
					'class': 'visit',
					'target': 'mainpane',
					'title': 'eXpend some Xes and blOw some Os!',
					'href': 'shop.php?whichshop=xo&pwd=' + my_hash(),
				}));
			}
			info.addToDesc(xs + ' Xs');
			info.addToDesc(os + ' Os');
			break;
		}
		case $familiar[God Lobster]: {
			if(!isStandardFam) {
				break;
			}
			boolean challengesLeft = info.addDrop(new drop_info('_godLobsterFights', 3, 'challenge', 'challenges'));
			if(challengesLeft) {
				info.addExtra(extraInfoLink('challenge', attrmap {
					'class': 'visit',
					'target': 'mainpane',
					'href': 'main.php?fightgodlobster=1&pwd=' + my_hash(),
					'title': 'Challenge the God Lobster',
				}));
			}
			break;
		}
		case $familiar[Mini-Adventurer]:
			if(get_property('miniAdvClass').to_int() == 0) {
				info.addToDesc('No class selected!');
				info.incDrops(DROPS_ALL);
			}
			break;
		case $familiar[Shorter-Order Cook]:
			if(!isStandardFam) {
				break;
			}
			info.addDrop(new drop_info('_shortOrderCookCharge', have_equipped($item[blue plate]) ? -9 : -11, 'short drop'));
			break;
		case $familiar[Mini-Crimbot]:
			info.addExtra(extraInfoLink('configure', attrmap {
				'target': 'mainpane',
				'title': 'Configure your Mini-Crimbo',
				'href': 'main.php?action=minicrimbot',
			}));
			switch(get_property('crimbotChassis')) {
				case 'Low-Light Operations Frame':
					info.addToDesc('Block');
					break;
				case 'Smile-O-Matic':
					info.addToDesc('Stats');
					break;
				case 'Music Box Box':
					info.addToDesc('Spooky Damage');
					break;
				case 'Chewing Unit':
					info.addToDesc('Meat');
					break;
			}
			switch(get_property('crimbotArm')) {
				case 'T8-ZR Pacification Delivery System':
					info.addToDesc('MP');
					break;
				case '4.077 Field Medic Syringe':
					info.addToDesc('HP');
					break;
				case 'Frostronic Hypercoil':
					info.addToDesc('Cold Damage');
					break;
				case 'STAL-1 UltraFist':
					info.addToDesc('Physical Damage');
					break;
			}
			switch(get_property('crimbotPropulsion')) {
				case 'V-TOP Frictionless Monocycle Wheel':
					info.addToDesc('Initiative');
					break;
				case 'X-1 Hover Rocket':
					info.addToDesc('Hot Damage');
					break;
				case 'Lambada-Class Dancing Legs':
					info.addToDesc('Items');
					break;
				case 'T-NMN Tank Treads':
					info.addToDesc('Delevel');
					break;
			}
			if(info.desc != '') {
				info.desc = parseMods(info.desc);
			}
			break;
		case $familiar[Nosy Nose]: {
			string sniffa = get_property('nosyNoseMonster');
			if(sniffa == '') {
				info.addToDesc('Nothing Sniffed');
			}
			else {
				info.addToDesc(sniffa + ' Sniffed');
			}
			break;
		}
		case $familiar[Cat Burglar]:
			if(get_property('catBurglarBankHeists').to_int() > 0) {
				info.addExtra(extraInfoLink('heist', attrmap {
					'class': 'visit',
					'target': 'mainpane',
					'href': 'main.php?heist=1',
				}));
			}
			break;
		case $familiar[Robortender]: {
			string [int] roboDrinks = get_property('_roboDrinks').split_string(',');
			float lepLev = 1;
			foreach i,s in roboDrinks {
				switch(s) {
					case 'literal grasshopper': info.addToDesc('+3 musc/com'); break;
					case 'eighth plague': info.addToDesc('+5 musc/com'); break;
					case 'double entendre': info.addToDesc('0.5xFairy'); break;
					case 'single entendre': info.addToDesc('1xFairy'); break;
					case 'Phlegethon': info.addToDesc('hot damage'); break;
					case 'reverse Tantalus': info.addToDesc('hot damage!'); break;
					case 'Siberian sunrise': info.addToDesc('cold damage'); break;
					case 'elemental caipiroska': info.addToDesc('cold damage!'); break;
					case 'mentholated wine': info.addToDesc('candy'); break;
					case 'Feliz Navidad': info.addToDesc('candy!'); break;
					case 'low tide martini': info.addToDesc('aquatic'); break;
					case 'Bloody Nora': info.addToDesc('aquatic!'); break;
					case 'shroomtini': info.addToDesc('+3 mox/com'); break;
					case 'moreltini': info.addToDesc('+5 mox/com'); break;
					case 'morning dew': info.addToDesc('mp'); break;
					case 'hell in a bucket': info.addToDesc('mp!'); break;
					case 'whiskey squeeze': info.addToDesc('junk'); break;
					case 'Newark': info.addToDesc('junk!'); break;
					case 'great old fashioned': info.addToDesc('spooky damage'); break;
					case 'R\'lyeh': info.addToDesc('spooky damage!'); break;
					case 'Gnomish sagngria': info.addToDesc('phys damage'); break;
					case 'Gnollish sangria': info.addToDesc('phys damage!'); break;
					case 'vodka stinger': info.addToDesc('stench damage'); break;
					case 'vodka barracuda': info.addToDesc('stench damage!'); break;
					case 'extremely slippery nipple': info.addToDesc('hp'); break;
					case 'Mysterious Island iced tea': info.addToDesc('hp!'); break;
					case 'piscatini': lepLev = 1.5; break;
					case 'drive-by shooting': lepLev = 2; break;
					case 'Churchill': info.addToDesc('sleaze damage'); break;
					case 'gunner\'s daughter': info.addToDesc('sleaze damage!'); break;
					case 'soilzerac': info.addToDesc('+3 myst/com'); break;
					case 'dirt julep': info.addToDesc('+5 myst/com'); break;
					case 'London frog': info.addToDesc('0.5xPotato'); break;
					case 'Simepore slime': info.addToDesc('1xPotato'); break;
					case 'nothingtini': info.addToDesc('delevels'); break;
					case 'Phil Collins': info.addToDesc('delevels!'); break;
				}
			}
			if(floor(lepLev) == lepLev) {
				info.addToDesc(floor(lepLev) + 'xLep');
			}
			else {
				info.addToDesc(lepLev + 'xLep');
			}
			break;
		}
		case $familiar[Red-Nosed Snapper]:
			info.addExtra(extraInfoPicker('snapper', 'guide me!'));
			break;
		case $familiar[Ghost of Crimbo Commerce]: {
			if(!isStandardFam) {
				break;
			}
			string ghostItem = get_property('commerceGhostItem');
			if(ghostItem != '') {
				info.addExtra(extraInfoLink('shop', attrmap {
					'class': 'visit',
					'target': 'mainpane',
					'href': 'mall.php?justitems=0&pudnuggler=%22' + ghostItem.url_encode() + '%22',
					'title': 'Go shopping for ' + ghostItem,
				}));
			}
			info.addDrop(new drop_info('commerceGhostCombats', -10, 'mall ask'));
			break;
		}
		case $familiar[Reagnimated Gnome]: {
			int gnomeAdv = get_property('_gnomeAdv').to_int();
			if(gnomeAdv > 0) {
				info.addToDesc(gnomeAdv + ' adv gained');
			}
			break;
		}
		case $familiar[Temporal Riftlet]: {
			int riftletAdv = get_property('_riftletAdv').to_int();
			if(riftletAdv > 0) {
				info.addToDesc(riftletAdv + ' adv gained');
			}
			break;
		}
		case $familiar[Vampire Vintner]:
			if(available_amount($item[1950 Vampire Vintner wine]) > 0) {
				info.addToDesc('Already have wine!');
				info.dangerLevel = DANGER_WARNING;
			}
			break;
		case $familiar[grey goose]: {
			if(!isStandardFam) {
				break;
			}
			int famweight = familiar_weight(f);
			info.addToDesc(famweight + (famweight > 1 ? 'lbs' : 'lb'));
			int target = max(famweight + 1, 6);
			if(famweight < 20) {
				int expToGo = target**2 - f.experience;
				int combats = ceil(expToGo / (numeric_modifier('Familiar Experience') + 1));
				string toAdd = expToGo + ' exp ';
				if(combats != expToGo) {
					toAdd += ' <span title="gaining '
					+ floor(numeric_modifier('Familiar Experience')) + ' fam exp per combat">(' + combats
					+ ' fight' + (combats > 1 ? 's' : '') + ')</span>';
				}
				toAdd += ' to ' + target + 'lbs';
				info.addToDesc(toAdd);
			}
		}
		case $familiar[Pair of Stomping Boots]: {
			boolean haveStomp = info.addDrop(new drop_info('bootsCharged', LIMIT_BOOL_INVERTED, 'stomp'));
			if(haveStomp) {
				info.name += ' (GO)';
			}
			break;
		}
	}

	if(info.weirdoDivContents != '') {
		info.weirdoTag = f.to_string().to_lower_case().replace_string(' ', '');
	}

	familiar fam100 = get_property('singleFamiliarRun').to_int().to_familiar();
	if(s == $slot[familiar] && fam100 != $familiar[none]) {
		info.dangerLevel = f == fam100 ? DANGER_GOOD : DANGER_DANGEROUS;
	}

	return info;
}

chit_info getFamiliarInfo(familiar f) {
	return getFamiliarInfo(f, $slot[familiar]);
}
