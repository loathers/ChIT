// picker for body parts in the path You, Robot

void addRobavatar(buffer result, string override, int overrideTo) {
    foreach partCapitalized in $strings[Left, Right, Top, Bottom, Body] {
        string part = partCapitalized.to_lower_case();
        int partNum = (override == part) ? overrideTo : get_property("youRobot" + partCapitalized).to_int();
        if(partNum > 0) {
            result.append('<img src="/images/otherimages/robot/');
            result.append(part);
            result.append(partNum);
            result.append('.png" />');
        }
    }
}

void addRobavatar(buffer result) {
    addRobavatar(result, "", 0);
}

int roboPartNumber;
string roboPartType;

void addRoboOption(buffer picker, string name, string desc, int scrap) {
    string capitalizedPart = roboPartType.substring(0, 1).to_upper_case() + roboPartType.substring(1);
    boolean isActive = get_property("youRobot" + capitalizedPart).to_int() == roboPartNumber;
    boolean isUnavailable = isActive || my_robot_scraps() < scrap;

    picker.append('<tr class="pickitem');
    if(isUnavailable) picker.append(' currentitem');
    picker.append('"><td class="chit_robopickericon">');
    picker.addRobavatar(roboPartType, roboPartNumber);
    picker.append('</td><td>');
    if(isActive) {
        picker.append('<b>Current:</b> ');
    }
    else if(isUnavailable) {
        picker.append('<b>Too Expensive:</b> ');
    }
    else {
        string cmd = 'ashq visit_url("place.php?whichplace=scrapheap&action=sh_configure", false); '
            + 'visit_url("choice.php?whichchoice=1445&show=' + roboPartType + '", false); '
            + 'visit_url("choice.php?part=' + roboPartType + '&pwd&whichchoice=1445&show='
            + roboPartType + '&p=' + roboPartNumber + '&option=1", true);';
        picker.append('<a class="change" href="');
        picker.append(sideCommand(cmd));
        picker.append('"><b>Choose</b> ');
    }
    picker.append(name);
    picker.append('<br /><span class="descline">');
    picker.append(desc);
    picker.append(' (');
    picker.append(scrap.to_string());
    picker.append(' scrap)</span>');
    if(!isUnavailable) picker.append('</a>');
    picker.append('</td></tr>');
    ++roboPartNumber;
}

void pickerRoboTop() {
    buffer picker;
    picker.pickerStart("robotop", "Change Your Top Attachment");

    roboPartNumber = 1;
    roboPartType = "top";

    picker.addRoboOption("Pea Shooter", "Deal 20 Damage + 10% of your Moxie", 5);
    picker.addRoboOption("Bird Cage", "Allows the use of a familiar", 5);
    picker.addRoboOption("Solar Panel", "Gain 1 Energy after each fight", 5);
    picker.addRoboOption("Mannequin Head", "Allows you to equip a hat", 15);
    picker.addRoboOption("Meat Radar", "+50% Meat Drops from Monsters", 30);
    picker.addRoboOption("Junk Cannon", "Spend 1 Scrap to deal 100% of your Moxie in damage", 30);
    picker.addRoboOption("Tesla Blaster", "Spend 1 Energy to deal 100% of your Moxie in damage", 30);
    picker.addRoboOption("Snow Blower", "Spend 1 Energy to deal 100% of your Muscle in Cold damage", 40);

    picker.addLoader("Reassembling...");
    picker.append('</table></div>');
    chitPickers["robotop"] = picker;
}

void pickerRoboLeft() {
    buffer picker;
    picker.pickerStart("roboleft", "Change Your Left Arm");

    roboPartNumber = 1;
    roboPartType = "left";

    picker.addRoboOption("Pound-O-Tron", "Deal 20 Damage + 10% of your Muscle", 5);
    picker.addRoboOption("Reflective Shard", "+3 Resistance to All Elements", 5);
    picker.addRoboOption("Metal Detector", "+30% Item Drops From Monsters", 5);
    picker.addRoboOption("Vice Grips", "Allows you to equip a weapon", 15);
    picker.addRoboOption("Sniper Rifle", "Spend 1 Scrap to deal 100% of your Mysticality in damage", 30);
    picker.addRoboOption("Junk Mace", "Spend 1 Scrap to deal 100% of your Muscle in damage", 30);
    picker.addRoboOption("Camouflage Curtain", "Monsters will be significantly less attracted to you", 30);
    picker.addRoboOption("Grease Gun", "Spend 1 Energy to deal 100% of your Moxie in Sleaze damage", 40);

    picker.addLoader("Reassembling...");
    picker.append('</table></div>');
    chitPickers["roboleft"] = picker;
}

void pickerRoboRight() {
    buffer picker;
    picker.pickerStart("roboright", "Change Your Right Arm");

    roboPartNumber = 1;
    roboPartType = "right";

    picker.addRoboOption("Slab-O-Matic", "+30 Maximum HP", 5);
    picker.addRoboOption("Junk Shield", "+10 Damage Reduction +50 Damage Absorption", 5);
    picker.addRoboOption("Horseshoe Magnet", "Gain 1 Scrap after each fight", 5);
    picker.addRoboOption("Omni-Claw", "Allows you to equip an offhand item", 15);
    picker.addRoboOption("Mammal Prod", "Spend 1 Energy to deal 100% of your Mysticality in damage", 30);
    picker.addRoboOption("Solenoid Piston", "Spend 1 Energy to deal 100% of your Muscle in damage", 30);
    picker.addRoboOption("Blaring Speaker", "+30 to Monster Level", 30);
    picker.addRoboOption("Surplus Flamethrower", "Spend 1 Energy to deal 100% of your Mysticality in Hot damage", 40);

    picker.addLoader("Reassembling...");
    picker.append('</table></div>');
    chitPickers["roboright"] = picker;
}

void pickerRoboBottom() {
    buffer picker;
    picker.pickerStart("robobottom", "Change Your Propulsion System");

    roboPartNumber = 1;
    roboPartType = "bottom";

    picker.addRoboOption("Bald Tires", "+10 Maximum HP", 5);
    picker.addRoboOption("Rocket Crotch", "Deal 20 Hot Damage + 10% of your Mysticality", 5);
    picker.addRoboOption("Motorcycle Wheel", "+30% Combat Initiative", 5);
    picker.addRoboOption("Robo-Legs", "Allows you to equip pants", 15);
    picker.addRoboOption("Magno-Lev", "+30% Item Drops from Monsters", 30);
    picker.addRoboOption("Tank Treads", "+50 Maximum HP +10 Damage Reduction", 30);
    picker.addRoboOption("Snowplow", "Gain 1 Scrap after each fight", 30);

    picker.addLoader("Reassembling...");
    picker.append('</table></div>');
    chitPickers["robobottom"] = picker;
}

void bakeRobo() {
    // Nothing to do if you aren't a robot
    if(my_path().name != "You, Robot") {
        return;
    }
    buffer result;

    result.append('<table id="chit_robo" class="chit_brick nospace"><tbody>');
    result.append('<tr><th class="label" colspan="4"><a class"visit" target="mainpane" href="');
    result.append('place.php?whichplace=scrapheap&action=sh_configure');
    result.append('"><img src="');
    result.append(imagePath);
    result.append('cog.png" />Reassemble Thyself</a><th></tr>');

    result.append('<tr><td colspan="4"><a class="chit_launcher" rel="chit_pickerrobotop" href="#">Top Attachment</a></td></tr>');
    result.append('<tr><td><a class="chit_launcher" rel="chit_pickerroboleft" href="#">Left<br />Arm</a></td>');
    result.append('<td colspan="2" class="robrickavatar">');
    result.addRobavatar();
    result.append('</td><td><a class="chit_launcher" rel="chit_pickerroboright" href="#">Right<br />Arm</a></td></tr>');
    result.append('<tr><td colspan="4"><a class="chit_launcher" rel="chit_pickerrobobottom" href"#">Propulsion System</a></td></tr>');

    result.append('</tbody></table>');

    chitBricks["robo"] = result.to_string();

    pickerRoboTop();
    pickerRoboLeft();
    pickerRoboRight();
    pickerRoboBottom();
}