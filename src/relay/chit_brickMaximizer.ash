record maximizer_result {
	string display;
	string command;
	float score;
	effect effect;
	item item;
	skill skill;
	string afterdisplay;
};

string[string] recommendedMaximizerStrings() {
	string[string] res;

	void recommendIf(boolean condition, string recommendation, string reason) {
		if(condition) {
			if(res contains recommendation) {
				res[recommendation] += ', ' + reason;
			} else {
				res[recommendation] = reason;
			}
		}
	}

	boolean highlandsTime = $strings[step1, step2] contains get_property('questL09Topping');
	string nsQuest = get_property('questL13Final');
	boolean nunsTime = get_property('sidequestNunsCompleted') == 'none' &&
		get_property('questL12War') == 'step1' &&
		get_property('fratboysDefeated').to_int() >= 192;
	boolean kitchenTime = get_property('questM20Necklace') == 'started';
	boolean peakTime = $strings[step3, step4] contains get_property('questL08Trapper');
	boolean wantPassiveDamage = get_property('questL13Final') == 'step6';
	boolean wantSpellDamage = get_property('questL13Final') == 'step8';

	recommendIf(nsQuest == 'step7', 'meat', 'wall of meat');
	recommendIf(nunsTime, 'meat, outfit frat warrior fatigues', 'nuns');
	// probably not an exhaustive list of reasons to want ML
	recommendIf(get_property('questL03Rat') == 'step1', 'ML', 'rat kings');
	recommendIf(get_property('cyrptCrannyEvilness').to_int() > 13, 'ML', 'ghuol whelps');
	recommendIf(highlandsTime && get_property('oilPeakProgress').to_float() > 0, 'ML', 'oil peak');
	recommendIf(available_amount($item[unstable fulminate]) > 0, 'ML', 'wine bomb');
	// likewise probably not exhaustive list of reasons to want init
	recommendIf(get_property('cyrptAlcoveEvilness').to_int() > 13, 'init', 'modern zmobie');
	recommendIf(highlandsTime && (get_property('twinPeakProgress').to_int() & 7) == 7
		&& initiative_modifier() < 40, 'init', 'twin peaks');
	recommendIf(nsQuest != 'unstarted' && get_property('nsContestants1').to_int() < 0, 'init', 'init test');
	// probably want more ele res considerations
	recommendIf(kitchenTime, 'hot res 9 max, stench res 9 max', 'kitchen');
	recommendIf(peakTime, 'cold res 5 max', 'peak');
	recommendIf(highlandsTime && get_property('booPeakProgress').to_int() > 0, 'cold res, spooky res', 'surviving a-boo clues');
	recommendIf(nsQuest == 'step4', 'all res', 'hedge maze');
	// some towerkilling recs
	recommendIf(wantPassiveDamage, 'damage aura, thorns', 'towerkilling');
	recommendIf(wantSpellDamage, 'spell damage percent, 200 lantern, 0.5 myst', 'towerkilling');

	return res;
}

void bakeMaximizer() {
	buffer result;

	string[string] recommendations = recommendedMaximizerStrings();
	string[string] fields = form_fields();
	string equipWhere = fields["maxequipwhere"];
	int equipScope = equipWhere == "pullbuy" ? 2 : equipWhere == "create" ? 1 : equipWhere == "onhand"
		? 0 : cvars["chit.maximizer.scope"].to_int();
	boolean[string] allFilters = $strings[equip,cast,wish,other,usable,booze,food,spleen];
	maximizer_result[int] maximizeOut;
	string maxFilters = "";
	if(fields contains "tomax") {
		set_property('chit.maximizer.max', fields["tomax"]);
		set_property('chit.maximizer.scope', equipScope);
		foreach filter in allFilters {
			if(fields["max" + filter].to_boolean()) {
				maxFilters = maxFilters.simple_list_add(filter, ',');
			}
		}
		set_property('chit.maximizer.filters', maxFilters);
		string actualMax = fields["tomax"];
		if(cvars["chit.maximizer.noTies"].to_boolean() && !actualMax.contains_text('-tie')) {
			actualMax += ",-tie";
		}
		maximizeOut = maximize(actualMax, get_property("autoBuyPriceLimit").to_int(), 2, equipScope, maxFilters);
	} else {
		maxFilters = cvars["chit.maximizer.filters"];
	}

	result.append('<table id="chit_maximizer" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="5">Maximizer');
	if(fields contains "tomax") {
		result.append(' (Current score: ');
		result.append(current_maximizer_score(fields["tomax"]).to_string('%,.2f'));
		result.append(')');
	}
	result.append('</th></tr>');
	result.append('<form action="./charpane.php">');
	result.append('<tr><td class="info" colspan="3">');
	result.append('<input type="hidden" name="autoopen" value="maximizer" />');
	result.append('<input type="text" name="tomax" value="');
	if(fields contains "tomax") {
		result.append(fields["tomax"]);
	} else {
		result.append(cvars["chit.maximizer.max"]);
	}
	result.append('"');
	if(recommendations.count() > 0) {
		result.append(' list="maxsuggestions"');
	}
	result.append(' />');
	if(recommendations.count() > 0) {
		result.append('<datalist id="maxsuggestions">');
		foreach str, reason in recommendations {
			result.append('<option value="');
			result.append(str);
			result.append('" label="');
			result.append(reason);
			result.append('" />');
		}
		result.append('</datalist>');
	}
	result.append('</td><td>');
	result.append('<button type="submit" name="action" value="maximize">Max</button>');
	result.append('</td><td>');
	result.append('<input type="radio" id="maxonhand" name="maxequipwhere" value="onhand"');
	if(equipScope == 0) {
		result.append(' checked');
	}
	result.append(' />');
	result.append('<label for="maxonhand">On hand</label>');
	result.append('</td></tr>');
	result.append('<tr><td>');
	int count = 0;
	foreach filter in allFilters {
		result.append('<input type="checkbox"');
		if(maxFilters.simple_list_contains(filter, ',')) {
			result.append(' checked');
		}
		result.append(' name="max');
		result.append(filter);
		result.append('" id="max');
		result.append(filter);
		result.append('" value="true" />');
		result.append('<label for="max');
		result.append(filter);
		result.append('">');
		result.append(filter);
		result.append('</label>');
		result.append('</td><td>');
		count += 1;
		if(count == 4) {
			result.append('<input type="radio" id="maxcreatable" name="maxequipwhere" value="create"');
			if(equipScope == 1) {
				result.append(' checked');
			}
			result.append(' />');
			result.append('<label for="maxcreatable">Create</label>');
			result.append('</td></tr><tr><td>');
		}
	}
	result.append('<input type="radio" id="maxpullbuy" name="maxequipwhere" value="pullbuy"');
	if(equipScope == 2) {
		result.append(' checked');
	}
	result.append(' />');
	result.append('<label for="maxpullbuy">Pull/Buy</label>');
	result.append('</td></tr>');
	result.append('</form>');

	if(fields contains "tomax") {
		result.append('<tr class="darkrow"><td>Icon</td><td>Commmand</td><td>Score</td><td>Info</td><td>Go!</td></tr>');
		foreach i,plan in maximizeOut {
			result.append('<tr');
			if(i % 2 == 1) {
				result.append(' class="darkrow"');
			}
			result.append('><td class="smallicon">');
			chit_info effInfo = getEffectInfo(plan.effect);
			if(plan.item != $item[none] && plan.effect == $effect[none]) {
				result.addItemIcon(plan.item, '', true);
			} else if(plan.skill != $skill[none]) {
				chit_info skillInfo = new chit_info(plan.skill, effInfo.desc, DROPS_NONE, DANGER_NONE,
					itemimage(plan.skill.image));
				result.addInfoIcon(skillInfo, skillInfo.name, skillInfo.desc, 'skill(' + plan.skill.id + '); return false;', '',attrmap {});
			} else if(plan.effect != $effect[none]) {
				result.addEffectIcon(plan.effect, '', true, '', attrmap {});
			}
			result.append('</td><td>');
			result.append(plan.display);
			result.append('</td><td>');
			result.append(plan.score.to_string(plan.score % 1 == 0 ? '%.0f' :'%.2f'));
			result.append('</td><td>');
			string after = plan.afterdisplay;
			matcher afterMatcher = create_matcher('\\(\\+?\\d+\\)\\s*', after);
			if(afterMatcher.find()) {
				after = after.replace_string(afterMatcher.group(0), '');
			}
			afterMatcher = create_matcher(', \\+?\\d+\\)', after);
			if(afterMatcher.find()) {
				after = after.replace_string(afterMatcher.group(0), ')');
			}
			result.append(after);
			result.append('</td><td>');
			if(plan.command != '') {
				result.append('<form action="./charpane.php">');
				result.append('<input type="hidden" name="autoopen" value="maximizer" />');
				result.append('<input type="hidden" name="tomax" value="');
				result.append(fields["tomax"]);
				result.append('" />');
				result.append('<input type="hidden" name="cmd" value="');
				result.append(plan.command);
				result.append('" />');
				result.append('<button ');
				if(plan.command == "") {
					result.append('disabled ');
				}
				result.append('type="submit" name="action" value="cliexec">');
				string[int] splitDisplay = plan.display.split_string(' ');
				result.append(splitDisplay[0] == '...or' ? splitDisplay[1] : splitDisplay[0]);
				result.append('</button></form>');
			}
			result.append('</td></tr>');
		}
	}

	result.append('</tbody></table>');

	chitBricks["maximizer"] = result.to_string();
}
