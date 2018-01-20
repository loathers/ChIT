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
	string link = "";
	string linkend = "";
	if(num != currHorse()) {
		link = '<a class="change" href="' + sideCommand("horsery " + num) + '">';
		linkend = '</a>';
	}
	result.append('<tr class="pickitem');
	if(num == currHorse()) result.append(' currentitem');
	result.append('"><td class="icon">');
	result.append(link);
	result.append('<img class="chit_icon" src="' + horseImage(num) + '" width="40px" height="40px" />');
	result.append(linkend);
	result.append('</td><td>');
	result.append(link);
	if(num == currHorse())
		result.append("<b>Current:</b> ");
	else
		result.append("<b>Hostle</b> a ");
	result.append(horseName(num));
	result.append(' Horse<br /><span class="descline">');
	result.append(parseMods(horseBonus(num)));
	result.append('</span>');
	result.append(linkend);
	result.append('</td></tr>');
}

void pickerHorse() {
	buffer picker;
	picker.pickerStart("horsery", "Hostle a horse!");

	for(int i = 1; i <= 4; ++i)
		picker.addHorse(i);

	picker.addLoader("Hostling your horse...");
	picker.append('</table></div>');
	chitPickers["horsery"] = picker;
}

void bakeHorsery() {
	// Nothing to do if you don't have the horsery
	if(get_property("horseryAvailable").to_boolean() != true)
		return;

	pickerHorse();

	buffer result;
	int num = currHorse();

	result.append('<table id="chit_horsery" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="4"><a class="visit" target="mainpane" ');
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
