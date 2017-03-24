import "charpane.ash";

void main(string choice, string item_name) {
	string name = "chit.gear.favorites";
	item it = to_item(item_name);
	boolean [item] list = to_list(vars[name]);
	
	if(choice == "add")
		list[it] = true;
	else if(choice == "remove")
		remove list[it];
	else return;
	
	set_property(name, cat_list(list));
}
