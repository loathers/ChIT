// Brick for some source terminal interaction, by soolar

record source_skill {
	skill s;
	string skill_desc;
	int max_uses;
	int rem_uses;
};

boolean [string] chips;

source_skill getSourceSkill(string edu) {
	boolean isSource = my_path() == "The Source";
	
	source_skill sskill;
	switch(edu) {
		case "digitize.edu":
			sskill.s = $skill[Digitize];
			sskill.max_uses = 1;
			if(chips["TRAM"]) sskill.max_uses += 1;
			if(chips["TRIGRAM"]) sskill.max_uses += 1;
			sskill.rem_uses = sskill.max_uses - to_int(get_property("_sourceTerminalDigitizeUses"));
			sskill.skill_desc = "Create wandering copies";
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
			sskill.max_uses = isSource ? 5 : 1;
			sskill.rem_uses = sskill.max_uses - dupes;
			sskill.skill_desc = isSource ? "Triple a monster" : "Double a monster";
			break;
		case "portscan.edu":
			sskill.s = $skill[Portscan];
			sskill.skill_desc = isSource ? "Force a source agent next turn" : "Force a government agent next turn";
			sskill.max_uses = 3;
			sskill.rem_uses = 3 - to_int(get_property("_sourceTerminalPortscanUses"));
			break;
		case "turbo.edu":
			sskill.s = $skill[Turbo];
			sskill.skill_desc = "Recover 1000 mp, then overheat";
			if(have_effect($effect[Overheated]) <= 0) sskill.rem_uses = 1;
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
  if(sskill.rem_uses > 0) result.append(' hasdrops');
	else if(sskill.max_uses > 0) result.append(' danger');
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
	if(sskill.max_uses > 0) {
		result.append(' (');
		result.append(sskill.rem_uses);
		result.append('/');
		result.append(sskill.max_uses);
		result.append(' left)');
	}
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

void addSourceSkillDisplay(buffer result, string edu, int i, boolean fullSize) {
	source_skill sskill = getSourceSkill(edu);
	
	if(fullSize) result.append('<td class="icon">');
	else result.append('<span style="white-space:nowrap;">');
	if(sskill.s != $skill[none]) {
		result.append('<a class="done" href="#" oncontextmenu="skill(');
		result.append(to_int(sskill.s));
		result.append('); return false;" onclick="skill(');
		result.append(to_int(sskill.s));
		result.append(')">');
	}
	result.append('<img ');
	if(fullSize) {
		result.append('class="chit_icon');
		if(sskill.rem_uses > 0) result.append(' hasdrops');
		else if(sskill.max_uses > 0) result.append(' danger');
		result.append('" ');
	} else result.append('style="max-width:14px;max-height:14px;" ');
	result.append('src="/images/itemimages/');
	if(sskill.s == $skill[none])
		result.append('antianti.gif" />');
	else {
		result.append(sskill.s.image);
		result.append('" title="Click for skill description" />');
	}
	if(fullSize) result.append('</td><td>');
	result.append('<a class="chit_launcher" rel="chit_pickersourceskills');
	result.append(i);
	result.append('" href="#">');
	if(fullSize) {
		result.append('<b>Skill #');
		result.append(i);
		result.append(':</b><br />');
	}
	result.append(sskill.s);
	if(sskill.max_uses > 0) {
		result.append(' (');
		result.append(sskill.rem_uses);
		result.append('/');
		result.append(sskill.max_uses);
		result.append(')');
	}
	result.append('</a>');
	if(fullSize) result.append('</td>');
	else result.append('</span>');
	
	pickerSourceSkills(i);
}

void addSourceSkillDisplay(buffer result, string edu, int i) {
	addSourceSkillDisplay(result, edu, i, true);
}

void term_link(buffer result) {
	if(my_path() == "Nuclear Autumn")
		result.append('place.php?whichplace=falloutshelter&action=vault_term');
	else
		result.append('campground.php?action=terminal');
}

// Part of terminal block that can be included in stats for a smaller footprint
void addTerminal(buffer result) {
	// Nothing to do if you don't have the terminal
	if(get_campground() contains $item[Source terminal] && is_unrestricted($item[Source terminal])) {
		foreach i,chip in split_string(get_property("sourceTerminalChips"), ",")
			chips[chip] = true;
		
		result.append('<tr><td class="label"><a class="visit" target="mainpane" href="');
		result.term_link();
		result.append('">Terminal</a></td><td ');
		if(to_boolean(vars["chit.stats.showbars"])) result.append('colspan="2">');
		else result.append('class="info">');
		
		result.addSourceSkillDisplay(get_property("sourceTerminalEducate1"), 1, false);
		result.append(" ");
		result.addSourceSkillDisplay(get_property("sourceTerminalEducate2"), 2, false);
		
		result.append('</td></tr>');
	}
}

void bakeTerminal() {
	// Nothing to do if you don't have the terminal
	if(get_campground() contains $item[Source terminal] && be_good($item[Source terminal])) {
		foreach i,chip in split_string(get_property("sourceTerminalChips"), ",")
			chips[chip] = true;
		
		buffer result;
		
		result.append('<table id="chit_terminal" class="chit_brick nospace"><tbody>');
		result.append('<tr><th class="label" colspan="4"><a class="visit" target="mainpane" href="');
		result.term_link();
		result.append('"><img src="');
		result.append(imagePath);
		result.append('application_xp_terminal.png" />Source Terminal</a></th></tr><tr>');
		
		result.addSourceSkillDisplay(get_property("sourceTerminalEducate1"), 1);
		result.addSourceSkillDisplay(get_property("sourceTerminalEducate2"), 2);
		
		result.append('</tr></tbody></table>');

		chitBricks["terminal"] = result.to_string();
		chitTools["terminal"] = "Source Terminal|application_xp_terminal.png";
	}
}
