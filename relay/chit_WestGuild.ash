// This is central location for West of Loathing skill books to reside as if there was a single skill teacher for the class.

int count_skills(item book) {
	int total;
	int first_skill = (to_int(book) - 8937) * 1000;
	for s from first_skill to first_skill + 9
		if(have_skill(to_skill(s)))
			total += 1;
	return total;
}

void westGuild() {
	buffer guild;
	guild.append('<html><head><link rel="stylesheet" type="text/css" href="/images/styles.20150113.css">');
	guild.append('<style type="text/css"> td.study {font-size:12px; padding-left:3px;} </style>');
	guild.append('<script language=Javascript src="/images/scripts/window.20111231.js"></script>');
	guild.append("<script language=Javascript>function descitem(desc) { newwindow=window.open('/desc_item.php?whichitem='+desc,'name','height=200,width=214'); if (window.focus) {newwindow.focus()} } </script>");
	guild.append('</head><body><center><table width=95% cellspacing=0 cellpadding=0><tr><td style="color: white;" align=center bgcolor=blue><b>Bookshelf of the West</b></td></tr>');
	guild.append('<tr><td style="padding: 5px; border: 1px solid blue;"><center><table><tr><td><center><br>');
	guild.append('<table cellspacing=2 cellpadding=0>');
	
	foreach b in $items[Tales of the West: Cow Punching, Tales of the West: Beanslinging, Tales of the West: Snake Oiling]
		if(available_amount(b) > 0) {
			guild.append('<tr><td><img src="/images/itemimages/');
			guild.append(b.image);
			guild.append('" class=hand onClick="javascript:descitem(');
			guild.append(b.descid);
			guild.append(')"></td><td valign=center><a onClick="javascript:descitem(');
			guild.append(b.descid);
			guild.append(')"><b>');
			guild.append(b);
			guild.append('</b></a></td><td class=study>[<a href="inv_use.php?pwd=');
			guild.append(my_hash());
			guild.append('&which=3&whichitem=');
			guild.append(to_int(b));
			guild.append('">study skills</a>]</td></tr><tr><td>&nbsp;</td><td colspan=2><center><table>');
			# guild.append('">study skills</a>]</td></tr><tr><td>&nbsp;</td><td colspan=2><center>You can learn ');
			# guild.append(to_int(get_property("cowPuncherPoints")) - count_skills(b))l
			# guild.append(' more skill from this book right now.<table>');
			int first_skill = (to_int(b) - 8937) * 1000;
			for s from first_skill to first_skill + 9 {
				guild.append('<tr><td><img class=hand onClick=\'javascript:poop("desc_skill.php?whichskill=');
				guild.append(s);
				guild.append('&self=true","skill", 350, 300)\' src="/images/itemimages/');
				guild.append(to_skill(s).image);
				guild.append('" width=30 height=30 border=0></td><td valign=center><b><a onClick=\'javascript:poop("desc_skill.php?whichskill=');
				guild.append(s);
				guild.append('&self=true","skill", 350, 300)\'>');
				guild.append(to_skill(s));
				guild.append('</a></b>&nbsp;&nbsp;&nbsp;</td><td align=center>');
				if(have_skill(to_skill(s)))
					guild.append('Known');
				else
					guild.append('--');
				guild.append('</td></tr>');
			}
			guild.append('</table></center><p></td></tr>');
		}
	
	guild.append('</table><p></center></td></tr></table></center></td></tr></table></center></body></html>');
	
	write(guild);
}

void main() {
	westGuild();
}

	