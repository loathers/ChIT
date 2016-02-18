// This is central location for West of Loathing skill books to reside

void addBook(buffer table, item it) {
	table.append('<tr><td><img src="/images/itemimages/');
	table.append(it.image);
	table.append('" class=hand onClick=\'javascript:descitem(');
	table.append(it.descid);
	table.append(')\'></td><td valign=center><a onClick=\'javascript:descitem(');
	table.append(it.descid);
	table.append(')\'><b>');
	table.append(it);
	table.append('</b></a></td><td>&nbsp;</td><td><a href="inv_use.php?pwd=');
	table.append(my_hash());
	table.append('&which=3&whichitem=');
	table.append(to_int(it));
	table.append('">[study skills]</a></td></tr>');
}

void westGuild() {
	static {
		buffer guild;
		guild.append('<html><head><link rel="stylesheet" type="text/css" href="/images/styles.20150113.css">');
		guild.append("<script language=Javascript>function descitem(desc) { newwindow=window.open('/desc_item.php?whichitem='+desc,'name','height=200,width=214'); if (window.focus) {newwindow.focus()} } </script></head>");
		guild.append('<body><centeR><table width=95% cellspacing=0 cellpadding=0><tr><td style="color: white;" align=center bgcolor=blue><b>Bookshelf of the West</b></td></tr>');
		guild.append('<tr><td style="padding: 5px; border: 1px solid blue;"><center><table><tr><td><center><br>');
		guild.append('<table cellspacing=2 cellpadding=0 style="">');
		foreach b in $items[Tales of the West: Cow Punching, Tales of the West: Beanslinging, Tales of the West: Snake Oiling]
			if(available_amount(b) > 0)
				guild.addBook(b);
		guild.append('</table><p></center></td></tr></table></center></td></tr><tr><td height=4></td></tr></table></center></body></html>');
	}
	
	write(guild);
}

void main() {
	westGuild();
}

	