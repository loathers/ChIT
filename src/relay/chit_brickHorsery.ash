// 0 = no horse
// 1 = normal horse
// 2 = dark horse
// 3 = crazy horse
// 4 = pale horse

int currHorse() {
	switch(get_property("_horsery")) {
		case "normal horse": return 1;
		case "dark horse": return 2;
		case "crazy horse": return 3;
		case "pale horse": return 4;
		default: return 0;
	}
}

string horseName(int horseNum) {
	switch(horseNum) {
		case 1: return "Normal";
		case 2: return "Dark";
		case 3: return "Crazy";
		case 4: return "Pale";
		default: return "No";
	}
}

// the thing the horse does that's not in _horsery
string horseBonus(int horseNum) {
	switch(horseNum) {
		case 1: return "HP/MP Regen, Initiative: +10";
		case 2: return "Extra Meat, Combat Rate: -5";
		case 3: return "Random Buffs, Muscle: " + get_property("_horseryCrazyMus") + "%, Mysticality: " +
			get_property("_horseryCrazyMys") + "%, Moxie: " + get_property("_horseryCrazyMox") + "%";
		case 4: return "Spooky Damage, Prismatic Resistance +1";
		default: return "Nothing";
	}
}

string horseImage(int horseNum) {
	buffer res;
	res.append("/images/adventureimages/horse_");
	res.append(horseName(horseNum).to_lower_case());
	res.append(".gif");
	return res.to_string();
}

void addHorse(buffer result, int num) {
	// I don't THINK there's a way to check if we're on our free hostle of the day...
	result.pickerSelectionOption('a ' + horseName(num) + ' Horse', parseMods(horseBonus(num)), 'horsery ' + num,
		horseImage(num), num == currHorse(), true, attrmap { 'width': '40px', 'height': '40px' });
}

void pickerHorse() {
	buffer picker;
	picker.pickerStart("horsery", "Hostle a horse!");

	for(int i = 1; i <= 4; ++i)
		picker.addHorse(i);

	picker.pickerFinish("Hostling your horse...");
}

void bakeHorsery() {
	// Nothing to do if you don't have the horsery
	if(get_property("horseryAvailable").to_boolean() != true || !is_unrestricted($item[Horsery contract]))
		return;

	pickerHorse();

	buffer result;
	int num = currHorse();

	result.append('<table id="chit_horsery" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="4"><img  class="chit_walls_stretch" src="');
	result.append(imagePath);
	result.append('horse2.png">');
	result.append('<a class="visit" target="mainpane" ');
	result.append('href="place.php?whichplace=town_right&action=town_horsery">Horsery</a></th></tr><tr>');

	if(num == 0) {
		result.append('<td><a class="chit_launcher" rel="chit_pickerhorsery">You have no horse, go get one!</a></td>');
	}
	else {
		result.append('<td class="icon" title="Your Horse"><img src="' + horseImage(num) + '" /></td>');
		result.append('<td class="info" colspan="3"><a class="chit_launcher" rel="chit_pickerhorsery"><b>' + horseName(num) + ' Horse</b><br />');
		result.append(parseMods(horseBonus(num)) + '</a></td>');
	}

	result.append('</tr></tbody></table>');

	chitBricks["horsery"] = result.to_string();
}
