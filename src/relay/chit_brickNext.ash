void bakeNext() {
	location[string][int] locs;

	foreach loc in $locations[] {
		if(can_adventure(loc)) {
			locs[loc.zone][locs[loc.zone].count()] = loc;
		}
	}

	buffer res;

	res.append('<table id="chit_next" class="chit_brick nospace"><tbody>');
	res.append('<tr><th class="label"><img src="');
	res.append(imagePath);
	res.append('trail.png" />Next Location</th></tr><tr><td>');
	res.append('<form action="/KoLmafia/sideCommand"><input type="hidden" name="pwd" value="');
	res.append(my_hash());
	res.append('" /><select name="cmd" id="next">');

	string prevzone = "";
	foreach zone, i, loc in locs {
		if(zone != prevzone) {
			if(prevzone != "") {
				res.append('</optgroup>');
			}
			res.append('<optgroup label="');
			res.append(zone);
			res.append('">');
			prevzone = zone;
		}
		string locShort = loc.to_string();
		boolean wasShortened = false;
		int maxLength = vars["chit.next.maxlen"].to_int();
		if(maxLength > 0 && locShort.length() > maxLength) {
			locShort = locShort.substring(0, maxLength - 3) + "...";
			wasShortened = true;
		}
		res.append('<option value="ashq set_location($location[');
		res.append(loc);
		res.append('])"');
		if(loc == my_location()) {
			res.append(' selected');
		}
		if(wasShortened) {
			res.append(' title="');
			res.append(loc);
			res.append('"');
		}
		res.append('>');
		res.append(locShort);
		res.append('</option>');
	}

	res.append('</select><input type="submit" value="Set"></form>');
	res.append('</td></tr></tbody></table>');

	chitBricks["next"] = res.to_string();
}
