// This is a replacement for shop.5dprinter which works even if the shop is not available.

string amountify(item it) {
	int x = item_amount(it);
	if(x == 0) return "no "+ to_plural(it);
	if(x == 1) return "1 " + to_string(it);
	return x + " " + to_plural(it);
}

// Improved materials table has been re-ordered and annotated.
buffer materials() {
	buffer mats;
	mats.append('<table><tr><th colspan=2>You have:</th></tr><tr><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td>');
	mats.append(amountify($item[Xiblaxian circuitry]));
	mats.append('</td><td>(indoors)</td></tr><tr><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td>');
	mats.append(amountify($item[Xiblaxian polymer]));
	mats.append('</td><td>(outdoors)</td></tr><tr><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td>');
	mats.append(amountify($item[Xiblaxian alloy]));
	mats.append('</td><td>(underground)</td></tr><tr><td><img src=/images/itemimages/xicrystal.gif width=30 height=30 onClick=\'javascript:descitem(906452926)\' alt="Xiblaxian crystal" title="Xiblaxian crystal"></td><td>');
	mats.append(amountify($item[Xiblaxian crystal]));
	mats.append('</td><td>(mining)</td></tr></table>');
	return mats;
}

// Replace the table of Xiblaxian materials with improved table.
void printer() {
	string page = replace_first(create_matcher("<b>You have:</b>.+?</table>"
		, visit_url("shop.php?whichshop=5dprinter"))
		, materials());
	writeln(page);
}

// Create an entirely new page to display results since the 5dprinter is not available.
void no_printer() {
	writeln('<html><head><link rel="stylesheet" type="text/css" href="/images/styles.20150113.css">');
	writeln("<script language=Javascript>function descitem(desc) { newwindow=window.open('/desc_item.php?whichitem='+desc,'name','height=200,width=214'); if (window.focus) {newwindow.focus()} } </script></head>");

	// This is shop.php?whichshop=5dprinter with all the forms and purchasing text removed. Because purchase is not possible.
	writeln('<body><center><table width=95% cellspacing=0 cellpadding=0><tr><td style="color: white;" align=center bgcolor=blue><b>Xiblaxian 5D Printer</b></td></tr><tr><td style="padding: 5px; border: 1px solid blue;"><center><table><tr><td><center><br><table cellspacing=2 cellpadding=0><tr><td>&nbsp;</td><td colspan=2 align=center><b>Item:</b> (click for description)</td><td colspan=10 align=center>Ingredients:</b></td></tr><tr rel="7752"><td valign=center></td><td><img src="/images/itemimages/bigglasses.gif" class=hand onClick=\'javascript:descitem(147449485)\'></td><td valign=center><a onClick=\'javascript:descitem(147449485)\'><b>Xiblaxian xeno-detection goggles</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>4</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xicrystal.gif width=30 height=30 onClick=\'javascript:descitem(906452926)\' alt="Xiblaxian crystal" title="Xiblaxian crystal"></td><td><b>2</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr><tr rel="7753"><td valign=center></td><td><img src="/images/itemimages/xicowl.gif" class=hand onClick=\'javascript:descitem(350277729)\'></td><td valign=center><a onClick=\'javascript:descitem(350277729)\'><b>Xiblaxian stealth cowl</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td><b>4</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>9</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td><b>5</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr><tr rel="7755"><td valign=center></td><td><img src="/images/itemimages/xivest.gif" class=hand onClick=\'javascript:descitem(903610003)\'></td><td valign=center><a onClick=\'javascript:descitem(903610003)\'><b>Xiblaxian stealth vest</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td><b>5</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>4</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td><b>9</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr><tr rel="7754"><td valign=center></td><td><img src="/images/itemimages/xipants.gif" class=hand onClick=\'javascript:descitem(553413438)\'></td><td valign=center><a onClick=\'javascript:descitem(553413438)\'><b>Xiblaxian stealth trousers</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td><b>9</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>4</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td><b>5</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr><tr rel="7756"><td valign=center></td><td><img src="/images/itemimages/burrito.gif" class=hand onClick=\'javascript:descitem(384466763)\'></td><td valign=center><a onClick=\'javascript:descitem(384466763)\'><b>Xiblaxian ultraburrito</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td><b>1</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>1</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td><b>3</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr><tr rel="7757"><td valign=center></td><td><img src="/images/itemimages/flask.gif" class=hand onClick=\'javascript:descitem(845948150)\'></td><td valign=center><a onClick=\'javascript:descitem(845948150)\'><b>Xiblaxian space-whiskey</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td><b>3</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>1</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td><b>1</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr><tr rel="7758"><td valign=center></td><td><img src="/images/itemimages/residencecube.gif" class=hand onClick=\'javascript:descitem(571869324)\'></td><td valign=center><a onClick=\'javascript:descitem(571869324)\'><b>Xiblaxian residence-cube</b>&nbsp;&nbsp;&nbsp;&nbsp;</a></td><td><img src=/images/itemimages/xicurcuit.gif width=30 height=30 onClick=\'javascript:descitem(753030502)\' alt="Xiblaxian circuitry" title="Xiblaxian circuitry"></td><td><b>11</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xipolymer.gif width=30 height=30 onClick=\'javascript:descitem(541515996)\' alt="Xiblaxian polymer" title="Xiblaxian polymer"></td><td><b>11</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xialloy.gif width=30 height=30 onClick=\'javascript:descitem(801172143)\' alt="Xiblaxian alloy" title="Xiblaxian alloy"></td><td><b>11</b>&nbsp;&nbsp;</td><td><img src=/images/itemimages/xicrystal.gif width=30 height=30 onClick=\'javascript:descitem(906452926)\' alt="Xiblaxian crystal" title="Xiblaxian crystal"></td><td><b>3</b>&nbsp;&nbsp;</td><td></td><td>&nbsp;&nbsp;</td></tr></table><p>');
	writeln(materials());
	writeln('</center></td></tr></table></center></td></tr><tr><td height=4></td></tr></table></center></body></html>');
}

void main() {
	if(available_amount($item[Xiblaxian 5D printer]) > 0)
		printer();
	else
		no_printer();
}

	