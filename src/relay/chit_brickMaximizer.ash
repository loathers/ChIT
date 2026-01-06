record maximizer_result {
	string display;
	string command;
	float score;
	effect effect;
	item item;
	skill skill;
	string afterdisplay;
};

record maximizer_filters {
	boolean equip;
	boolean cast;
	boolean wish;
	boolean other;
	boolean usable;
	boolean booze;
	boolean food;
	boolean spleen;
};

void bakeMaximizer() {
	buffer result;

	string[string] fields = form_fields();
	boolean[string] allFilters = $strings[equip,cast,wish,other,usable,booze,food,spleen];
	maximizer_filters filters;
	maximizer_result[int] maximizeOut;
	string maxFilters = "";
	if(fields contains "tomax") {
		set_property('_chitLastMax', fields["tomax"]);
		filters = new maximizer_filters(
			fields["maxequip"].to_boolean(),
			fields["maxcast"].to_boolean(),
			fields["maxwish"].to_boolean(),
			fields["maxother"].to_boolean(),
			fields["maxusable"].to_boolean(),
			fields["maxbooze"].to_boolean(),
			fields["maxfood"].to_boolean(),
			fields["maxspleen"].to_boolean(),
		);
		foreach filter in allFilters {
			if(fields["max" + filter].to_boolean()) {
				maxFilters = maxFilters.simple_list_add(filter, ',');
			}
		}
		set_property('_chitLastFilters', maxFilters);
		maximizeOut = maximize(fields["tomax"], get_property("autoBuyPriceLimit").to_int(), 2, true, true, filters);
	} else {
		maxFilters = get_property('_chitLastFilters');
	}

	result.append('<table id="chit_maximizer" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="5">Maximizer');
	if(fields contains "tomax") {
		result.append(' (Current score: ');
		result.append(last_maximizer_score().to_string('%,.2f'));
		result.append(')');
	}
	result.append('</th></tr>');
	result.append('<form action="./charpane.php">');
	result.append('<tr><td class="info" colspan="4">');
	result.append('<input type="hidden" name="autoopen" value="maximizer" />');
	result.append('<input type="text" name="tomax" value="');
	if(fields contains "tomax") {
		result.append(fields["tomax"]);
	} else {
		result.append(get_property('_chitLastMax'));
	}
	result.append('" />');
	result.append('</td><td>');
	result.append('<button type="submit" name="action" value="maximize">Max</button>');
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
		result.append('" value="true" />');
		result.append('<label for="max');
		result.append(filter);
		result.append('">');
		result.append(filter);
		result.append('</label>');
		result.append('</td><td>');
		count += 1;
		if(count == 4) {
			result.append('</td></tr><tr><td>');
		}
	}
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
			if(plan.item != $item[none] && (plan.display.contains_text('>keep ') || plan.display.contains_text('equip '))) {
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
