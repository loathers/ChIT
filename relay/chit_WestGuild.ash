// This is central location for West of Loathing skill books to reside

void westGuild() {
	static {
		buffer guild;
		guild.append('<html><head><link rel="stylesheet" type="text/css" href="/images/styles.20150113.css">');
		guild.append('<style type="text/css"> td.study {font-size:12px; padding-left:3px;} </style>');
		guild.append("<script language=Javascript>function descitem(desc) { newwindow=window.open('/desc_item.php?whichitem='+desc,'name','height=200,width=214'); if (window.focus) {newwindow.focus()} } </script>");
		guild.append('</head>');
		guild.append('<body><center><table width=95% cellspacing=0 cellpadding=0><tr><td style="color: white;" align=center bgcolor=blue><b>Bookshelf of the West</b></td></tr>');
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
				guild.append('">study skills</a>]</td></tr>');
			}
		
		guild.append('</table><p></center></td></tr></table></center></td></tr></table></center></body></html>');
	}
	
	write(guild);
}

void main() {
	westGuild();
}

	