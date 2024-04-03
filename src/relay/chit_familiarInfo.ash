drop_info[familiar] bjornDrops = {
	$familiar[Grimstone Golem]: new drop_info('_grimstoneMaskDropsCrown', 1, 'mask'),
	$familiar[Grim Brother]: new drop_info('_grimFairyTaleDropsCrown', 2, 'fairy tale', 'fairy tales'),
	$familiar[Trick-or-Treating Tot]: new drop_info('_hoardedCandyDropsCrown', 3, 'candy', 'candies'),
	$familiar[Optimistic Candle]: new drop_info('_optimisticCandleDropsCrown', 3, 'glob of wax', 'globs of wax'),
	$familiar[Garbage Fire]: new drop_info('_garbageFireDropsCrown', 3, 'newpaper', 'newspapers'),
	$familiar[Twitching Space Critter]: new drop_info('_spaceFurDropsCrown', 1, 'fur'),
	$familiar[Machine Elf]: new drop_info('_abstractionDropsCrown', 25, 'abstraction', 'abstractions'),
	$familiar[Adventurous Spelunker]: new drop_info('_oreDropsCrown', 6, 'non-quest ore', 'non-quest ores'),
	$familiar[Puck Man]: new drop_info('_yellowPixelDropsCrown', 25, 'yellow pixel', 'yellow pixels'),
	$familiar[Ms. Puck Man]: new drop_info('_yellowPixelDropsCrown', 25, 'yellow pixel', 'yellow pixels'),
	$familiar[Warbear Drone]: new drop_info('', LIMIT_INFINITE, 'whosits'),
	$familiar[Li'l Xenomorph]: new drop_info('', LIMIT_INFINITE, 'isotopes'),
	$familiar[Pottery Barn Owl]: new drop_info('', LIMIT_INFINITE, 'volcanic ash'),
	$familiar[Party Mouse]: new drop_info('', LIMIT_INFINITE, 'decent-good booze'),
	$familiar[Yule Hound]: new drop_info('', LIMIT_INFINITE, 'candy cane'),
	$familiar[Gluttonous Green Ghost]: new drop_info('', LIMIT_INFINITE, 'burritos'),
	$familiar[Hunchbacked Minion]: new drop_info('', LIMIT_INFINITE, 'brain or bone'),
	$familiar[Attention-Deficit Demon]: new drop_info('', LIMIT_INFINITE, 'bad food'),
	$familiar[Piano Cat]: new drop_info('', LIMIT_INFINITE, 'bad booze'),
	$familiar[Golden Monkey]: new drop_info('', LIMIT_INFINITE, 'gold nuggets'),
	$familiar[Robot Reindeer]: new drop_info('', LIMIT_INFINITE, 'holiday snacks'),
	$familiar[Ancient Yuletide Troll]: new drop_info('', LIMIT_INFINITE, 'holiday snacks'),
	$familiar[Sweet Nutcracker]: new drop_info('', LIMIT_INFINITE, 'holiday snacks'),
	$familiar[BRICKO chick]: new drop_info('', LIMIT_INFINITE, 'BRICKO brick'),
	$familiar[Cotton Candy Carnie]: new drop_info('', LIMIT_INFINITE, 'cotton candy pinches'),
	$familiar[Untamed Turtle]: new drop_info('', LIMIT_INFINITE, 'turtle bits'),
	$familiar[Astral Badger]: new drop_info('', LIMIT_INFINITE, 'shrooms'),
	$familiar[Green Pixie]: new drop_info('', LIMIT_INFINITE, 'bottles of tequila'),
	$familiar[Angry Goat]: new drop_info('', LIMIT_INFINITE, 'goat cheese pizzas'),
	$familiar[Adorable Seal Larva]: new drop_info('', LIMIT_INFINITE, 'elemental nuggets'),
	$familiar[Frozen Gravy Fairy]: new drop_info('', LIMIT_INFINITE, 'cold nuggets'),
	$familiar[Stinky Gravy Fairy]: new drop_info('', LIMIT_INFINITE, 'stench nuggets'),
	$familiar[Sleazy Gravy Fairy]: new drop_info('', LIMIT_INFINITE, 'sleaze nuggets'),
	$familiar[Spooky Gravy Fairy]: new drop_info('', LIMIT_INFINITE, 'spooky nuggets'),
	$familiar[Flaming Gravy Fairy]: new drop_info('', LIMIT_INFINITE, 'hot nuggets'),
	$familiar[Reassembled Blackbird]: new drop_info('', LIMIT_INFINITE, 'blackberries'),
	$familiar[Reanimated Reanimator]: new drop_info('', LIMIT_INFINITE, 'hot wings or skulls'),
	$familiar[Stocking Mimic]: new drop_info('', LIMIT_INFINITE, 'simple candy'),
};

item snapperPhylumToDrop(phylum phy) {
	switch (phy) {
		case $phylum[beast]: return $item[patch of extra-warm fur];
		case $phylum[bug]: return $item[a bug's lymph];
		case $phylum[constellation]: return $item[micronova];
		case $phylum[construct]: return $item[industrial lubricant];
		case $phylum[demon]: return $item[infernal snowball];
		case $phylum[dude]: return $item[human musk];
		case $phylum[elemental]: return $item[livid energy];
		case $phylum[elf]: return $item[peppermint syrup];
		case $phylum[fish]: return $item[fish sauce];
		case $phylum[goblin]: return $item[guffin];
		case $phylum[hippy]: return $item[organic potpourri];
		case $phylum[hobo]: return $item[beggin' cologne];
		case $phylum[horror]: return $item[powdered madness];
		case $phylum[humanoid]: return $item[vial of humanoid growth hormone];
		case $phylum[mer-kin]: return $item[mer-kin eyedrops];
		case $phylum[orc]: return $item[boot flask];
		case $phylum[penguin]: return $item[envelope full of meat];
		case $phylum[pirate]: return $item[Shantix&trade;];
		case $phylum[plant]: return $item[goodberry];
		case $phylum[slime]: return $item[extra-strength goo];
		case $phylum[undead]: return $item[unfinished pleasure];
		case $phylum[weird]: return $item[non-Euclidean angle];
		default: return $item[none];
	}
}

void picker_snapper() {
	buffer picker;
	picker.pickerStart("snapper", "Guide me!");

	void addPhylum(phylum phy, string phylumPlural, string desc) {
		if(phylumPlural == "")
			phylumPlural = phy.to_string() + "s";

		item get = snapperPhylumToDrop(phy);
		picker.pickerSelectionOption(phylumPlural, 'Get ' + get.plural + '<br />' + desc, 'snapper ' + phy,
			itemimage(phy.image), phy.to_string() == get_property('redSnapperPhylum'));
	}

	addPhylum($phylum[beast], "", "Potion, 20 turns of Superhuman Cold Resistance");
	addPhylum($phylum[bug], "", "Spleen size 1, 60 turns of HP +100% and 8-10 HP Regen");
	addPhylum($phylum[constellation], "", "Combat item, yellow ray");
	addPhylum($phylum[construct], "", "Spleen size 1, 30 turns of +150% init");
	addPhylum($phylum[demon], "", "Potion, 20 turns of Superhuman Hot Resistance");
	addPhylum($phylum[dude], "", "Combat item, all day banish (first 3 free)");
	addPhylum($phylum[elemental], "elementals", "Spleen size 1, 60 turns of +50% MP and 3-5 MP Regen");
	addPhylum($phylum[elf], "elves", "Potion, 20 turns of +50% Candy Drops");
	addPhylum($phylum[fish], "fish", "Spleen size 1, 30 turns of Fishy");
	addPhylum($phylum[goblin], "", "Food size 3, awesome quality");
	addPhylum($phylum[hippy], "hippies", "Potion, 20 turns of Superhuman Stench Resistance");
	addPhylum($phylum[hobo], "", "Spleen size 1, 60 turns of +100% Meat");
	addPhylum($phylum[horror], "", "Combat item, free kill (up to 5 a day)");
	addPhylum($phylum[humanoid], "", "Spleen size 1, 30 turns of +50% Muscle Gains");
	addPhylum($phylum[mer-kin], "mer-kin", "Potion, 20 turns of +30% Underwater Item Drops");
	addPhylum($phylum[orc], "", "Booze size 3, awesome quality");
	addPhylum($phylum[penguin], "", "Usable for ~1k meat");
	addPhylum($phylum[pirate], "", "Spleen size 1, 30 turns of +50% Moxie Gains");
	addPhylum($phylum[plant], "", "Combat item, full HP recovery");
	addPhylum($phylum[slime], "", "Potion, 20 turns of Superhuman Sleaze Resistance");
	addPhylum($phylum[undead], "undead", "Potion, 20 turns of Superhuman Spooky Resistance");
	addPhylum($phylum[weird], "weirdos", "Spleen size 1, 30 turns of +50% Mysticality Gains");

	picker.pickerFinish("Changing guidance...");
}

chit_info getFamiliarInfo(familiar f, slot s) {
	boolean isStandardFam = s == $slot[familiar] && my_path() != $path[Pocket Familiars];
	item famsEquip = familiar_equipped_equipment(f);

	chit_info info;
	info.image = itemimage(f.image);

	if(isStandardFam) {
		drop_info[int] drops;

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
							case 'PvP':
								info.addToDesc('PvP (' + get_property('_shrubCharge') + '/20)');
								break;
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
				if(!can_interact() && (available_amount($item[grimstone mask]) + available_amount($item[ornate dowsing rod])) == 0) {
					info.dangerLevel = DANGER_GOOD;
				}
				break;
			case $familiar[Grim Brother]:
				if(!get_property('_grimBuff').to_boolean()) {
					info.addExtra(extraInfoLink('talk', attrmap {
						'target': 'mainpane',
						'href': 'familiar.php?action=chatgrim&pwd=' + my_hash(),
					}));
				}
				break;
			case $familiar[Optimistic Candle]:
				drops[drops.count()] = new drop_info('optimisticCandleProgress', -30, 'wax', 'wax');
				break;
			case $familiar[Garbage Fire]:
				drops[drops.count()] = new drop_info('garbageFireProgress', -30, 'garbage');
				break;
			case $familiar[Machine Elf]: {
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
			case $familiar[Puck Man]:
			case $familiar[Ms. Puck Man]:
				info.addToDesc(item_amount($item[Yellow Pixel]) + ' yellow pixels');
				info.addExtra(extraInfoLink('mystic', attrmap {
					'class': 'visit',
					'target': 'mainpane',
					'title': 'Visit the Crackpot Mystic',
					'href': 'shop.php?whichshop=mystic',
				}));
				break;
			case $familiar[Reassembled Blackbird]:
			case $familiar[Reconstituted Crow]: {
				string blackForestState = get_property('questL11Black');
				if((blackForestState == 'started' || blackForestState == 'step1')
					&& (item_amount($item[reassembled blackbird]) + item_amount($item[reconstituted crow])) == 0) {
					info.dangerLevel = DANGER_GOOD;
				}
				else {
					info.dangerLevel = DANGER_DANGEROUS;
				}
				break;
			}
			case $familiar[Reanimated Reanimator]:
				if(get_property('_badlyRomanticArrows').to_int() == 0) {
					info.addToDesc('Wink available');
					info.incDrops(DROPS_ALL);
				}
				info.addExtra(extraInfoLink('chat', attrmap {
					'target': 'mainpane',
					'href': 'main.php?talktoreanimator=1',
				}));
				foreach part in $strings[Arm, Leg, Skull, Wing, WeirdPart] {
					int count = get_property('reanimator' + part + 's').to_int();
					if(count > 0) {
						info.addToDesc(count + ' ' + (part == 'WeirdPart' ? 'Weird Part' : part) + (count == 1 ? '' : 's'));
					}
				}
				break;
			case $familiar[Stocking Mimic]:
				drops[drops.count()] = new drop_info('_bagOfCandy', LIMIT_BOOL, 'candy bag');
				break;
			case $familiar[Gelatinous Cubeling]: {
				int progress = get_property('cubelingProgress').to_int();
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
				boolean statsDontMatter = my_path() != $path[The Source];
				drops[drops.count()] = new drop_info('_turkeyMuscle', 5, 'mus', 'mus', statsDontMatter);
				drops[drops.count()] = new drop_info('_turkeyMyst', 5, 'mys', 'mys', statsDontMatter);
				drops[drops.count()] = new drop_info('_turkeyMoxie', 5, 'mox', 'mox', statsDontMatter);
				break;
			}
			case $familiar[Steam-Powered Cheerleader]: {
				int steamPercent = ceil(to_float(get_property('_cheerleaderSteam')) / 2);
				drops[drops.count()] = new drop_info('', steamPercent, '% steam');
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
				drops[drops.count()] = new drop_info('rockinRobinProgress', -30, 'egg', 'egg');
				break;
			case $familiar[Intergnat]: {
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
				int spaceJellyfishDrops = get_property('_spaceJellyfishDrops').to_int();
				info.addToDesc(spaceJellyfishDrops + ' jelly sucked');
				if(my_level() >= 11 && my_class().to_int() < 7) {
					drops[drops.count()] = new drop_info('_seaJellyHarvested', LIMIT_BOOL, 'Sea jelly');
					if(!get_property('_seaJellyHarvested').to_boolean()) {
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
				drops[drops.count()] = new drop_info('xoSkeleltonXProgress', -9, 'X', 'Xs', true);
				drops[drops.count()] = new drop_info('xoSkeleltonOProgress', -9, 'O', 'Os', true);
				drops[drops.count()] = new drop_info('_xoHugsUsed', 11, 'hug', 'hugs');
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
				drops[drops.count()] = new drop_info('_godLobsterFights', 3, 'challenge', 'challenges');
				if(get_property('_godLobsterFights').to_int() < 3) {
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
			case $familiar[Red-Nosed Snapper]: {
				info.addExtra(extraInfoPicker('snapper', 'guide me!'));
				string phylumName = get_property('redSnapperPhylum');
				if(phylumName != '') {
					info.addToDesc('Following ' + phylumName);
					item currDrop = snapperPhylumToDrop(phylumName.to_phylum());
					drops[drops.count()] = new drop_info('redSnapperProgress', -11, currDrop, currDrop.plural);
				}
				else {
					info.addToDesc('Following nothing');
				}
				break;
			}
			case $familiar[Ghost of Crimbo Commerce]: {
				string ghostItem = get_property('commerceGhostItem');
				if(ghostItem != '') {
					info.addExtra(extraInfoLink('shop', attrmap {
						'class': 'visit',
						'target': 'mainpane',
						'href': 'mall.php?justitems=0&pudnuggler=%22' + ghostItem.url_encode() + '%22',
						'title': 'Go shopping for ' + ghostItem,
					}));
				}
				drops[drops.count()] = new drop_info('commerceGhostCombats', -10, 'mall ask');
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
				break;
			}
			case $familiar[Pair of Stomping Boots]: {
				drops[drops.count()] = new drop_info('bootsCharged', LIMIT_BOOL_INVERTED, 'stomp');
				drops[drops.count()] = new drop_info('_banderRunaways', (familiar_weight(f) + weight_adjustment()) / 5, 'free run', 'free runs');
				break;
			}
			case $familiar[frumious bandersnatch]: {
				drops[drops.count()] = new drop_info('_banderRunaways', (familiar_weight(f) + weight_adjustment()) / 5, 'free run', 'free runs');
				boolean knowOde = have_skill($skill[The Ode to Booze]);
				boolean haveOde = have_effect($effect[Ode to Booze]) > 0;
				if(knowOde && !haveOde) {
					info.addToDesc('Need Ode');
					info.addExtra(extraInfoLink('ode up', attrmap {
						'class': 'visit',
						'href': sideCommand('cast 1 The Ode to Booze'),
						'title': 'Cast The Ode to Booze for free runs',
					}));
				}
				else if(haveOde) {
					info.addToDesc('Can run');
				}
				else {
					info.addToDesc('Need Ode :(');
				}
				break;
			}
			case $familiar[Comma Chameleon]: {
				string currForm = get_property('commaFamiliar');
				if(currForm != '') {
					info.addToDesc('Currently ' + currForm);
				}
				break;
			}
		}

		if(f.drops_limit > 0) {
			int dropsLeft = f.drops_limit - f.drops_today;
			if(f.drop_item != $item[none]) {
				drops[drops.count()] = new drop_info('', f.drops_limit, f.drop_item, f.drop_item.plural, false, true, dropsLeft);
			}
			else {
				string plural = f.drop_name;
				if(plural.substring(plural.length() - 1) != 's') {
					plural += 's';
				}
				drops[drops.count()] = new drop_info('', f.drops_limit, f.drop_name, plural, false, true, dropsLeft);
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
	else if($slots[buddy-bjorn, crown-of-thrones] contains s && bjornDrops contains f) {
		info.addDrop(bjornDrops[f]);
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
