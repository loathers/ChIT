// Brick for some source terminal interaction, by soolar

record source_skill {
	skill s;
	string skill_desc;
};

boolean [string] chips;

source_skill getSourceSkill(string edu) {
	boolean isSource = my_path() == "The Source";
	
	source_skill sskill;
	switch(edu) {
		case "digitize.edu":
			sskill.s = $skill[Digitize];
			int max_uses = 1;
			if(chips["TRAM"]) max_uses += 1;
			if(chips["TRIGRAM"]) max_uses += 1;
			int uses = max_uses - to_int(get_property("_sourceTerminalDigitizeUses"));
			sskill.skill_desc = "Create wandering copies (" + uses + "/" + max_uses + " left)";
			break;
		case "extract.edu":
			sskill.s = $skill[Extract];
			sskill.skill_desc = "Extract source essence";
			break;
		case "compress.edu":
			sskill.s = $skill[Compress];
			sskill.skill_desc = "25% HP damage + stagger 1/fight";
			break;
		case "duplicate.edu":
			sskill.s = $skill[Duplicate];
			int dupes = to_int(get_property("_sourceTerminalDuplicateUses"));
			if(isSource) sskill.skill_desc = "Triple a monster (" + (5 - dupes) + "/5 left)";
			else sskill.skill_desc = "Double a monster (" + (1 - dupes) + "/1 left)";
			break;
		case "portscan.edu":
			sskill.s = $skill[Portscan];
			if(isSource) sskill.skill_desc = "Force a source agent next turn";
			else sskill.skill_desc = "Force a government agent next turn";
			sskill.skill_desc += " (" + (3 - to_int(get_property("_sourceTerminalPortscanUses"))) + "/3 left)";
			break;
		case "turbo.edu":
			sskill.s = $skill[Turbo];
			sskill.skill_desc = "Recover 1000 mp, then overheat";
			break;
	}
	return sskill;
}

void addSourceSkillChoice(buffer result, string edu, boolean first) {
	source_skill sskill = getSourceSkill(edu);
	boolean isActive = (get_property("sourceTerminalEducate1") == edu || get_property("sourceTerminalEducate2") == edu);
	
	result.append('<tr class="pickitem');
	if(isActive) result.append(' currentitem');
	result.append('"><td class="icon"><a class="done" href="#" oncontextmenu="skill(');
	result.append(to_int(sskill.s));
	result.append('); return false;" onclick="skill(');
	result.append(to_int(sskill.s));
	result.append(')"><img class="chit_icon');
	if(isActive) result.append(' hasdrops');
	result.append('" src="/images/itemimages/');
	result.append(sskill.s.image);
	result.append('" title="Click for skill description" /></a></td><td>');
	if(isActive)
		result.append('<b>Current:</b> ');
	else {
		string cmd = 'terminal educate ' + (first ? edu : get_property("sourceTerminalEducate1")) + ";terminal educate " + (!first ? edu : get_property("sourceTerminalEducate2"));
		result.append('<a class="change" href="');
		result.append(sideCommand(cmd));
		result.append('"><b>Educate</b> ');
	}
	result.append(sskill.s);
	result.append('<br /><span class="descline">');
	result.append(sskill.skill_desc);
	result.append('</span>');
	if(!isActive) result.append('</a>');
	result.append('</td></tr>');
}

void pickerSourceSkills(int i) {
	buffer picker;
	picker.pickerStart("sourceskills" + i, "Educate yourself");
	
	foreach _,edu in split_string(get_property("sourceTerminalEducateKnown"), ",")
		picker.addSourceSkillChoice(edu, i == 1);
	
	picker.addLoader("Downloading knowledge...");
	picker.append('</table></div>');
	chitPickers["sourceskills" + i] = picker;
}

void addSourceSkillDisplay(buffer result, string edu, int i) {
	source_skill sskill = getSourceSkill(edu);
	
	result.append('<td class="icon"><a class="done" href="#" oncontextmenu="skill(');
	result.append(to_int(sskill.s));
	result.append('); return false;" onclick="skill(');
	result.append(to_int(sskill.s));
	result.append(')"><img class="chit_icon" src="/images/itemimages/');
	result.append(sskill.s.image);
	result.append('" title="Click for skill description" /></td><td><a class="chit_launcher" rel="chit_pickersourceskills');
	result.append(i);
	result.append('" href="#"><b>Skill #');
	result.append(i);
	result.append(':</b><br />');
	result.append(sskill.s);
	result.append('</a></td>');
	
	pickerSourceSkills(i);
}

void bakeSource() {
	// Nothing to do if you don't have the terminal
	if(get_campground()[$item[Source terminal]] != 1 || !be_good($item[Source terminal]))
		return;
	
	foreach i,chip in split_string(get_property("sourceTerminalChips"), ",")
		chips[chip] = true;
	
	buffer result;
	
	result.append('<table id="chit_source" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="4"><a class="visit" target="mainpane" href="./campground.php?action=terminal"><img src="');
	result.append(imagePath);
	result.append('application_xp_terminal.png" />Source Terminal</a></th></tr><tr>');
	
	result.addSourceSkillDisplay(get_property("sourceTerminalEducate1"), 1);
	result.addSourceSkillDisplay(get_property("sourceTerminalEducate2"), 2);
	
	result.append('</tr></tbody></table>');

	chitBricks["source"] = result.to_string();
	chitTools["source"] = "Source Terminal|application_xp_terminal.png";
}
