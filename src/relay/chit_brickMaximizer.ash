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
				res[recommendation] += '/' + reason;
			} else {
				res[recommendation] = reason;
			}
		}
	}

	boolean highlandsTime = $strings[step1, step2] contains get_property('questL09Topping');
	boolean bridgeTime = get_property('questL09Topping') == 'started';
	string nsQuest = get_property('questL13Final');
	string warQuest = get_property('questL12War');
	boolean nunsTime = get_property('sidequestNunsCompleted') == 'none' &&
		warQuest == 'step1' && get_property('hippiesDefeated').to_int() >= 192;
	boolean kitchenTime = get_property('questM20Necklace') == 'started';
	boolean peakTime = $strings[step3, step4] contains get_property('questL08Trapper');
	boolean wantPassiveDamage = nsQuest == 'step6';
	boolean wantSpellDamage = nsQuest == 'step8';

	recommendIf(nsQuest == 'step7', 'meat', 'wall of meat');
	recommendIf(nunsTime, 'meat, outfit frat warrior fatigues', 'nuns');
	// probably not an exhaustive list of reasons to want ML
	recommendIf(get_property('questL03Rat') == 'step1', 'ML, combat', 'rat kings');
	recommendIf(get_property('cyrptCrannyEvilness').to_int() > 13, 'ML, -combat', 'ghuol whelps');
	recommendIf(highlandsTime && get_property('oilPeakProgress').to_float() > 0, 'ML, 0.2 item', 'oil peak');
	recommendIf(available_amount($item[unstable fulminate]) > 0, '82 max, ML', 'wine bomb');
	// likewise probably not exhaustive list of reasons to want init
	recommendIf(get_property('cyrptAlcoveEvilness').to_int() > 13,
		'init 850 max, -combat', 'modern zmobie');
	recommendIf(highlandsTime && get_property('twinPeakProgress').to_int() == 7,
		'init 40 max, -combat', 'twin peaks');
	recommendIf(nsQuest != 'unstarted' && get_property('nsContestants1').to_int() < 0,
		'400 max, init', 'init test');
	// probably want more ele res considerations
	recommendIf(kitchenTime, 'hot res 9 max, stench res 9 max', 'kitchen');
	recommendIf(peakTime, 'cold res 5 max, 0.02 meat', 'peak');
	recommendIf(highlandsTime && get_property('booPeakProgress').to_int() > 0, 'cold res, spooky res, 0.05 hp', 'surviving a-boo clues');
	recommendIf(nsQuest == 'step4', 'all res', 'hedge maze');
	// some towerkilling recs
	recommendIf(wantPassiveDamage, 'damage aura, thorns', 'wall of skin');
	recommendIf(wantSpellDamage,
		'spell damage percent, 200 lantern, 0.5 myst, -1000 damage aura, -1000 thorns', 'wall of bones');
	// other ns contests
	string testStat = get_property('nsChallenge1').to_lower_case();
	recommendIf(nsQuest != 'unstarted' && get_property('nsContestants2').to_int() < 0 && testStat != 'none',
		'600 max, ' + testStat, testStat + ' test');
	string testElement = get_property('nsChallenge2').to_lower_case();
	recommendIf(nsQuest != 'unstarted' && get_property('nsContestants3').to_int() < 0 && testElement != 'none',
		'100 max, ' + testElement + ' damage, ' + testElement + ' spell damage', testElement + ' test');
	// SUPER incomplete list of reasons to want -combat
	recommendIf(warQuest == 'started', '-combat, outfit frat warrior fatigues', 'war start');
	// incomplete list of reasons to want +combat
	recommendIf($strings[started, step1] contains get_property('questL11Black') &&
		(item_amount($item[reassembled blackbird]) + item_amount($item[reconstituted crow])) == 0,
		'combat 5 max, item 200 max', 'black forest');
	recommendIf(get_property('questL08Trapper') == 'step2', 'combat', 'ninja snowman assassin');
	// smorc stuff
	recommendIf(bridgeTime, '-ml, item, spell damage percent, cold spell damage', 'orc chasm');
	boolean blechTime = bridgeTime && get_property('smutOrcNoncombatProgress').to_int() >= 15;
	recommendIf(blechTime, 'muscle, weapon damage, 10 weapon damage percent', 'blech house');
	recommendIf(blechTime, 'mysticality, spell damage, 10 spell damage percent', 'blech house');
	recommendIf(blechTime, 'moxie, 20 sleaze res', 'blech house');
	// protestors
	recommendIf($strings[started, step1] contains get_property('questL11Ron'),
		'sleaze damage, sleaze spell damage, -combat', 'protestors');

	return res;
}

void bake_maximizer(boolean mainpane) {
	buffer result;

	string[string] recommendations = recommendedMaximizerStrings();
	string[string] fields = form_fields();
	string equipWhere = fields["maxequipwhere"];
	int equipScope = equipWhere == "pullbuy" ? 2 : equipWhere == "create" ? 1 : equipWhere == "onhand"
		? 0 : cvars["chit.maximizer.scope"].to_int();
	boolean[string] allFilters = $strings[equip,cast,wish,other,usable,booze,food,spleen];
	maximizer_result[int] maximizeOut;
	string maxFilters = "";
	int priceScope = fields contains "maxpricescope"
		? fields["maxpricescope"].to_int()
		: cvars["chit.maximizer.priceScope"].to_int();
	if(fields contains "tomax") {
		set_property('chit.maximizer.max', fields["tomax"]);
		set_property('chit.maximizer.scope', equipScope);
		set_property('chit.maximizer.priceScope', priceScope == 2 ? `DEFAULT:{priceScope}` : priceScope.to_string());
		foreach filter in allFilters {
			if(fields["max" + filter].to_boolean()) {
				maxFilters = maxFilters.simple_list_add(filter, ',');
			}
		}
		if(maxFilters == '' && cvars['chit.maximizer.filters'] != '') {
			maxFilters = cvars["chit.maximizer.filters"];
		} else {
			set_property('chit.maximizer.filters', maxFilters);
		}
		string actualMax = fields["tomax"];
		if(cvars["chit.maximizer.noTies"].to_boolean() && !actualMax.contains_text('-tie')) {
			actualMax += ",-tie";
		}
		maximizeOut = maximize(actualMax, get_property("autoBuyPriceLimit").to_int(), priceScope, equipScope, maxFilters);
	} else {
		maxFilters = cvars["chit.maximizer.filters"];
	}

	string displayName = 'Maximizer';
	if(fields contains 'tomax') {
		displayName += ' (Current score: '
			+ current_maximizer_score(fields['tomax']).to_string('%,.2f') + ')';
	}
	result.brickStart(displayName, 'maximizer', '5', true);
	result.tagStart('form', attrmap { 'action': mainpane ? './chitmax.ash' : './charpane.php' });
	result.tagStart('tr');
	result.tagStart('td', attrmap { 'class': 'info', 'colspan': '3' });
	result.tagSelfClosing('input', attrmap {
		'type': 'hidden',
		'name': 'autoopen',
		'value': 'maximizer',
	});
	result.tagSelfClosing('input', attrmap {
		'type': 'text',
		'name': 'tomax',
		'value': fields contains 'tomax' ? fields['tomax'] : cvars['chit.maximizer.max'],
		'list': recommendations.count() > 0 ? 'maxsuggestions' : '',
	});
	if(recommendations.count() > 0) {
		result.tagStart('datalist', attrmap { 'id': 'maxsuggestions' });
		foreach str, reason in recommendations {
			result.tagSelfClosing('option', attrmap {
				'value': str,
				'label': reason,
			});
		}
		result.tagFinish('datalist');
	}
	result.tagFinish('td');
	result.tagStart('td');
	result.tagStart('button', attrmap {
		'type': 'submit',
		'name': 'action',
		'value': 'maximize',
	});
	result.append('Max');
	result.tagFinish('button');
	result.tagFinish('td');
	result.tagStart('td');
	result.tagSelfClosing('input', attrmap {
		'type': 'radio',
		'id': 'maxonhand',
		'name': 'maxequipwhere',
		'value': 'onhand',
		'checked': equipScope == 0 ? 'TRUE' : '',
	});
	result.tagStart('label', attrmap { 'for': 'maxonhand' });
	result.append('On hand');
	result.tagFinish('label');
	result.tagFinish('td');
	result.tagFinish('tr');
	result.tagStart('tr');
	result.tagStart('td');
	int count = 0;
	foreach filter in allFilters {
		result.tagSelfClosing('input', attrmap {
			'type': 'checkbox',
			'checked': maxFilters.simple_list_contains(filter, ',') ? 'TRUE' : '',
			'name': 'max' + filter,
			'id': 'max' + filter,
			'value': 'true',
		});
		result.tagStart('label', attrmap { 'for': 'max' + filter });
		result.append(filter);
		result.tagFinish('label');
		result.tagFinish('td');
		result.tagStart('td');
		count += 1;
		if(count == 4) {
			result.tagSelfClosing('input', attrmap {
				'type': 'radio',
				'id': 'maxcreatable',
				'name': 'maxequipwhere',
				'value': 'create',
				'checked': equipScope == 1 ? 'TRUE' : '',
			});
			result.tagStart('label', attrmap { 'for': 'maxcreatable' });
			result.append('Create');
			result.tagFinish('label');
			result.tagFinish('td');
			result.tagFinish('tr');
			result.tagStart('tr');
			result.tagStart('td');
		}
	}
	result.tagSelfClosing('input', attrmap {
		'type': 'radio',
		'id': 'maxpullbuy',
		'name': 'maxequipwhere',
		'value': 'pullbuy',
		'checked': equipScope == 2 ? 'TRUE' : '',
	});
	result.tagStart('label', attrmap { 'for': 'maxpullbuy' });
	result.append('Pull/Buy');
	result.tagFinish('label');
	result.tagFinish('td');
	result.tagFinish('tr');
	if(mainpane) {
		result.tagStart('tr');
		result.tagStart('td');
		result.append('Max price');
		result.tagFinish('td');
		result.tagStart('td');
		result.tagSelfClosing('input', attrmap {
			'type': 'number',
			'name': 'maxpricelimit',
			'value': fields contains 'maxpricelimit' ? fields['maxpricelimit'] : cvars['chit.maximizer.priceLimit'],
		});
		result.tagFinish('td');
		result.tagStart('td');
		result.tagSelfClosing('input', attrmap {
			'type': 'radio',
			'id': 'maxpricenocheck',
			'name': 'maxpricescope',
			'value': '0',
			'checked': priceScope == 0 ? 'TRUE' : '',
		});
		result.tagStart('label', attrmap { 'for': 'maxpricenocheck' });
		result.append("don't check");
		result.tagFinish('label');
		result.tagFinish('td');
		result.tagStart('td');
		result.tagSelfClosing('input', attrmap {
			'type': 'radio',
			'id': 'maxpricebuyable',
			'name': 'maxpricescope',
			'value': '1',
			'checked': priceScope == 1 ? 'TRUE' : '',
		});
		result.tagStart('label', attrmap { 'for': 'maxpricebuyable' });
		result.append("buyable only");
		result.tagFinish('label');
		result.tagFinish('td');
		result.tagStart('td');
		result.tagSelfClosing('input', attrmap {
			'type': 'radio',
			'id': 'maxpriceall',
			'name': 'maxpricescope',
			'value': '2',
			'checked': priceScope == 2 ? 'TRUE' : '',
		});
		result.tagStart('label', attrmap { 'for': 'maxpriceall' });
		result.append("all consumables");
		result.tagFinish('label');
		result.tagFinish('td');
		result.tagFinish('tr');
	}
	if(!mainpane) {
		result.tagStart('tr');
		result.tagStart('td', attrmap { 'colspan': '5' });
		result.tagStart('button', attrmap {
			'formtarget': 'mainpane',
			'formaction': './chitmax.ash',
		});
		result.append('Maximize in mainpane');
		result.tagFinish('button');
		result.tagFinish('td');
		result.tagFinish('tr');
	}
	result.tagFinish('form');

	if(fields contains "tomax") {
		matcher m = create_matcher("^\\s*([\\d\\.]+)\\s*[Mm][Aa][Xx]\\s*,", fields["tomax"]);
		if(m.find()) {
			float maxThreshold = m.group(1).to_float();
			if(current_maximizer_score(fields["tomax"]) >= maxThreshold) {
				result.tagStart('tr');
				result.tagStart('td', attrmap { 'colspan': '5' });
				result.tagStart('b');
				result.append('You already met your goal! Don\'t waste anything!');
				result.tagFinish('b');
				result.tagFinish('td');
				result.tagFinish('tr');
			}
		}
		result.tagStart('tr', attrmap { 'class': 'darkrow' });
		result.tagStart('td');
		result.append('Icon');
		result.tagFinish('td');
		result.tagStart('td');
		result.append('Command');
		result.tagFinish('td');
		result.tagStart('td');
		result.append('Score');
		result.tagFinish('td');
		result.tagStart('td');
		result.append('Info');
		result.tagFinish('td');
		result.tagStart('td');
		result.append('Go!');
		result.tagFinish('td');
		result.tagFinish('tr');
		foreach i,plan in maximizeOut {
			result.tagStart('tr', attrmap { 'class': i % 2 == 1 ? 'darkrow' : '' });
			result.tagStart('td', attrmap { 'class': mainpane ? 'icon' : 'smallicon' });
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
			result.tagFinish('td');
			result.tagStart('td');
			result.append(plan.display);
			result.tagFinish('td');
			result.tagStart('td');
			result.append(plan.score.to_string(plan.score % 1 == 0 ? '%.0f' :'%.2f'));
			result.tagFinish('td');
			result.tagStart('td');
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
			result.tagFinish('td');
			result.tagStart('td');
			if(plan.command != '') {
				result.tagStart('form', attrmap { 'action': mainpane ? './chitmax.ash' : './charpane.php' });
				result.tagSelfClosing('input', attrmap {
					'type': 'hidden',
					'name': 'autoopen',
					'value': 'maximizer',
				});
				result.tagSelfClosing('input', attrmap {
					'type': 'hidden',
					'name': 'tomax',
					'value': fields['tomax'],
				});
				result.tagSelfClosing('input', attrmap {
					'type': 'hidden',
					'name': 'cmd',
					'value': plan.command,
				});
				result.tagStart('button', attrmap {
					'disabled': plan.command == '' ? 'TRUE' : '',
					'type': 'submit',
					'name': 'action',
					'value': 'cliexec',
				});
				string[int] splitDisplay = plan.display.split_string(' ');
				result.append(splitDisplay[0] == '...or' ? splitDisplay[1] : splitDisplay[0]);
				result.tagFinish('button');
				result.tagFinish('form');
			}
			result.tagFinish('td');
			result.tagFinish('tr');
		}
	}

	result.brickFinish();
}

void bake_maximizer() {
	bake_maximizer(false);
}
