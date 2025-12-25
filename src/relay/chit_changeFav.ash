import "charpane.ash";

void main(string choice, item it, string favType) {
	string name = "chit.gear.favorites";
	if(favType != "")
		name += "." + favType;

	boolean [item] list = to_list(cvars[name]);

	if(choice == "add")
		list[it] = true;
	else if(choice == "remove")
		remove list[it];
	else return;

	set_property(name, cat_list(list));
}
