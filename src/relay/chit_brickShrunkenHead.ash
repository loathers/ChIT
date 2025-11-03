// <center><font size=2><b>Shrunken Head:</b></font><small><center>Animating horrible tourist family</small><table border=0><tr><td><img alt="Abilities: Meat Drop Bonus (52%), Cold Attack (48%)" title="Abilities: Meat Drop Bonus (52%), Cold Attack (48%)" src="https://d2uyhvukfffg5a.cloudfront.net/otherimages/shrunkenhead.png" /></td><td class="small">HP: <b>565</b></td></tr></table>

void bakeShrunkenHead() {
	buffer result;

	string pattern = '<center><font size=2><b>Shrunken Head:</b></font><small><center>Animating ([\\w\\s]+?)</small><table border=0><tr><td><img alt="Abilities: ([^"]+)" title="Abilities: [^"]+" src="[^"]+" /></td><td class="small">HP: <b>([^<]+)</b></td></tr></table>';
	matcher shrunkenMatcher = create_matcher(pattern, chitSource['wtfisthis']);

	result.append('<table id="chit_shrunkenHead" class="chit_brick nospace"><tbody>');
	result.append('<tr><th class="label" colspan="4">Shrunken Head</th></tr><tr>');
	result.append('<td class="icon" title="Shrunken Head"><img src="' + itemimage('shrunkenhead.gif') + '" /></td>');
	result.append('<td class="info" colspan="3">Animating ');

	if(shrunkenMatcher.find()) {
		result.append(shrunkenMatcher.group(1));
		result.append('<br />HP: ');
		result.append(shrunkenMatcher.group(3));
		result.append('<br />Abilities: ');
		result.append(shrunkenMatcher.group(2));
	} else if(chit_available($item[shrunken head]) > 0) {
		result.append('nothing<br />Go find a foe to reanimate!');
	}

	result.append('</td></tr></tbody></table>');

	chitBricks["shrunkenhead"] = result.to_string();
}
