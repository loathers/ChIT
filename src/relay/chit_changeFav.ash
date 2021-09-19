import "charpane.ash";

void main(string choice, item it) {
	string name = "chit.gear.favorites";
	boolean [item] list = to_list(vars[name]);
	
	if(choice == "add")
		list[it] = true;
	else if(choice == "remove")
		remove list[it];
	else return;
	
	set_property(name, cat_list(list));
}
