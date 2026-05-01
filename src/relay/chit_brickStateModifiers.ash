// <p><b><font size=2>Adventure Modifiers:</font></b><br><div style='text-align: left'><small>You are temporarily in the mostly-combatless world of Clara's Bell.<br>A sniper is guiding you out of trouble.</small></div><center><p><b><font size=2>Misc. Modifiers:</font></b><br><div style='text-align: left'><small>Your skin will be really tough for 5 more fights</small></div><center><p><b><font size=2>Effects:

void bakeStateModifiers() {
	string[string][int] sections;
	int lines = 0;

	void addLine(string section, string line) {
		sections[section][sections[section].count()] = line;
		lines += 1;
	}

	print(chitSource["mods"]);
	matcher section_matcher = create_matcher('<b><font size=2>([^:]+):</font></b><br><div style=\'text-align: left\'><small>(.*?)</small></div><center><p>', chitSource["mods"]);
	while(section_matcher.find()) {
		foreach i, line in section_matcher.group(2).split_string('<br>') {
			addLine(section_matcher.group(1), line);
		}
	}

	if(lines <= 0)
		return;

	buffer result;

	result.append('<table id="chit_stateModifiers" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="2">State Modifiers</th></tr>');

	foreach section in sections {
		result.append('<tr class="sectionHeader"><td colspan="2">');
		result.append(section);
		result.append('</td></tr>');
		foreach i, line in sections[section] {
			result.append('<tr><td colspan="2">');
			result.append(line);
			result.append('</td></tr>');
		}
	}

	result.append('</tbody></table>');

	chitBricks["statemodifiers"] = result.to_string();
}
