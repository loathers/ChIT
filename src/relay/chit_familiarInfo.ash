chit_info getFamiliarInfo(familiar f, slot s) {
	chit_info info;
	info.image = itemimage(f.image);

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
	}

	return info;
}

chit_info getFamiliarInfo(familiar f) {
	return getFamiliarInfo(f, $slot[familiar]);
}
