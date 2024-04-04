// 1 = giger
// 2 = food
// 3 = alive
// 4 = damage
// 5 = meat
// 6 = no song

int currBoombox() {
	switch(get_property("boomBoxSong")) {
		case "Eye of the Giger": return 1;
		case "Food Vibrations": return 2;
		case "Remainin' Alive": return 3;
		case "These Fists Were Made for Punchin'": return 4;
		case "Total Eclipse of Your Meat": return 5;
		default: return 6;
	}
}

string boomboxSong(int boomboxNum) {
	switch(boomboxNum) {
		case 1: return "Eye of the Giger";
		case 2: return "Food Vibrations";
		case 3: return "Remainin' Alive";
		case 4: return "These Fists Were Made for Punchin'";
		case 5: return "Total Eclipse of Your Meat";
		default: return "Silence";
	}
}

// the thing the boombox does that's not in boomBoxSong
string boomboxBonus(int boomboxNum) {
	switch(boomboxNum) {
		case 1: return "+" + my_level() + " Spooky Damage";
		case 2: return "+30% Food Drops, 3-5 MP Regen";
		case 3: return "+" + my_level() + " DR";
		case 4: return "+" + my_level() + " Weapon Damage";
		case 5: return "+30% Meat Drop";
		default: return "No Effect";
	}
}

string boomboxSingAlong(int boomboxNum) {
	switch(boomboxNum) {
		case 1: return "Drains HP & MP by 5% of Maximum HP, +2-3 Substats";
		case 2: return "Next spell cast deals additional damage";
		case 3: return "Delevel 15% of monster's attack value";
		case 4: return "" + my_level() + " Prismatic Damage";
		case 5: return "+25 Base Meat Drop";
		default: return "No Effect";
	}
}

item boomboxItem(int boomboxNum) {
	switch(boomboxNum) {
		case 1: return $item[Nightmare Fuel];
		case 2: return $item[Special Seasoning];
		case 3: return $item[Shielding Potion];
		case 4: return $item[Punching Potion];
		case 5: return $item[Gathered Meat-Clip];
		default: return $item[SongBoom&trade; BoomBox];
	}
}

string boomboxImage(int boomboxNum) {
	return "/images/itemimages/" + boomboxItem(boomboxNum).image;
}

void addBoomboxSong(buffer result, int num) {
	string desc = parseMods(boomboxBonus(num));
	if(boomboxItem(num) != $item[SongBoom&trade; BoomBox]) {
		desc += '<br />Sing Along: ' + boomboxSingAlong(num);
		desc += '<br />Drop: ' + boomboxItem(num);
		if(item_amount(boomboxItem(num)) > 0) {
			desc += ' (' + item_amount(boomboxItem(num)) + ')';
		}
	}
	result.pickerSelectionOption(boomboxSong(num), desc, 'boombox ' + num,
		boomboxImage(num), num == currBoombox());
}

void pickerBoombox() {
	buffer picker;
	picker.pickerStart("boombox", "Choose a Soundtrack! (" + get_property("_boomBoxSongsLeft") + " remaining)");

	for(int i = 1; i <= 6; ++i)
		picker.addBoomboxSong(i);

	picker.pickerFinish("Choosing a soundtrack...");
}

void bakeBoombox() {
	// Nothing to do if you don't have the boombox
	if ($item[SongBoom&trade; BoomBox].item_amount() == 0)
		return;

	pickerBoombox();

	buffer result;
	int num = currBoombox();
	int drop_charge = 11 - get_property("_boomBoxFights").to_int();

	result.append('<table id="chit_boombox" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="4"><img class="chit_walls_stretch" src="');
	result.append(imagePath);
	result.append('music.png">');
	result.append('<a class="visit" target="mainpane" ');
	result.append('href="inv_use.php?which=3&whichitem=9919&pwd=' + my_hash() +'">SongBoom&trade; BoomBox</a></th></tr><tr>');

	result.append('<td class="icon" title="Current Song"><img src="' + boomboxImage(num) + '" /></td>');
	result.append('<td class="info" colspan="3"><a title="Pick a new song" class="chit_launcher" rel="chit_pickerboombox"><b>' + boomboxSong(num) + '</b><br />');
	result.append(parseMods(boomboxBonus(num)) + '</a><br />');
	result.append(drop_charge + ' fights to next drop <br />');

	result.append('</tr></tbody></table>');

	chitBricks["boombox"] = result.to_string();
}
