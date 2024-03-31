chit_info getFamiliarInfo(familiar f, slot s) {
	chit_info info;
	info.image = itemimage(f.image);

	if(s == $slot[familiar] && f.drops_limit > 0) {
		int dropsLeft = f.drops_limit - f.drops_today;
		if(dropsLeft > 0) {
			if(f.drop_item != $item[none]) {
				info.addDrop(new drop_info('', dropsLeft, f.drop_item, f.drop_item.plural));
			}
			else {
				info.addDrop(new drop_info('', dropsLeft, f.drop_name, f.drop_name + 's'));
			}
		}

		int fightsLeft = f.fights_limit - f.fights_today;
		if(fightsLeft > 0) {
			info.addDrop(new drop_info('', fightsLeft, 'fight', 'fights'));
		}
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
			break;
		case $familiar[Disembodied Hand]:
			info.image = itemimage('dishand.gif');
			break;
		case $familiar[Mad Hatrack]:
			info.image = itemimage('hatrack.gif');
			break;

		case $familiar[Crimbo Shrub]:
			if(to_boolean(vars['chit.familiar.anti-gollywog']))
				info.image = imagePath + 'crimboshrub_fxx_ckb.gif';
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
			break;
		case $familiar[Trick-or-Treating Tot]:
			addBjornDrop(new drop_info('_hoardedCandyDropsCrown', 3, 'candy', 'candies'));
			break;
		case $familiar[Optimistic Candle]:
			addBjornDrop(new drop_info('_optimisticCandleDropsCrown', 3, 'glob of wax', 'globs of wax'));
			break;
		case $familiar[Garbage Fire]:
			addBjornDrop(new drop_info('_garbageFireDropsCrown', 3, 'newpaper', 'newspapers'));
			break;
		case $familiar[Twitching Space Critter]:
			addBjornDrop(new drop_info('_spaceFurDropsCrown', 1, 'fur'));
			break;
		case $familiar[Machine Elf]:
			addBjornDrop(new drop_info('_abstractionDropsCrown', 25, 'abstraction', 'abstractions'));
			break;
		case $familiar[Adventurous Spelunker]:
			addBjornDrop(new drop_info('_oreDropsCrown', 6, 'non-quest ore', 'non-quest ores'));
			break;
		case $familiar[Puck Man]:
			addBjornDrop(new drop_info('_yellowPixelDropsCrown', 25, 'yellow pixel', 'yellow pixels'));
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
		case $familiar[Reconstituted Crow]:
			addInfBjornDrop('blackberries');
			break;
		case $familiar[Hunchbacked Minion]:
			addInfBjornDrop('brain or bone');
			break;
		case $familiar[Reanimated Reanimator]:
			addInfBjornDrop('hot wings or skulls');
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
