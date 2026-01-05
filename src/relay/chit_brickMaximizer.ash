void bakeMaximizer() {
	buffer result;

	string[string] fields = form_fields();

	result.append('<table id="chit_maximizer" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="5">Maximizer</th></tr><tr>');
	result.append('<td class="info" colspan="5">');
	result.append('<form action="./charpane.php">');
	result.append('<input type="hidden" name="autoopen" value="maximizer" />');
	result.append('<input type="text" name="tomax" value="');
	if(fields contains "tomax") {
		result.append(fields["tomax"]);
	} else {
		result.append(get_property('_chitLastMax'));
	}
	result.append('" />');
	result.append('<button type="submit" name="action" value="maximize">Maximize</button>');
	result.append('</form>');
	result.append('</td></tr>');

	if(fields contains "tomax") {
		set_property('_chitLastMax', fields["tomax"]);
		result.append('<tr class="darkrow"><td>Icon</td><td>Commmand</td><td>Score</td><td>Info</td><td>Go!</td></tr>');
		foreach i,plan in maximize(fields["tomax"], get_property("autoBuyPriceLimit").to_int(), 2, true, true) {
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
			if(plan.skill != $skill[none]) {
				string cost = skillCost(plan.skill);
				if(cost != '') {
					result.append(cost);
					result.append(', ');
				}
				result.append(turns_per_cast(plan.skill).formatInt());
				result.append(' adv duration');
			} else if(plan.item != $item[none] && plan.effect != $effect[none]) {
				result.append(chit_available(plan.item).formatInt());
				result.append(' available, ');
				result.append(numeric_modifier(plan.item, 'Effect Duration').formatInt());
				result.append(' adv duration');
			} else if(plan.display.starts_with('uneffect')) {
				result.append(chit_available($item[soft green echo eyedrop antidote]).formatInt());
				result.append(' SGEEAs on hand');
			}
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
				result.append(plan.display.split_string(' ')[0]);
				result.append('</button></form>');
			}
			result.append('</td></tr>');
		}
	}

	result.append('</tbody></table>');

	chitBricks["maximizer"] = result.to_string();
}
