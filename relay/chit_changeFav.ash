import "zlib.ash";

void main(string choice, string item_name) {

	if(choice == "add") {
		vars["chit.gear.favorites"] += "," + item_name;
	} else if(choice == "remove") {
		string old_favs = vars["chit.gear.favorites"];
		buffer new_favs;
		item it = to_item(item_name);
		boolean add_comma = false;
		
		foreach i,fav in split_string(old_favs,"\\s*(?<!\\\\),\\s*")
		{
			if(it != to_item(fav))
			{
				if(add_comma)
				{
					new_favs.append(",");
				}
				new_favs.append(fav);
				add_comma = true;
			}
		}
		
		vars["chit.gear.favorites"] = new_favs.to_string();
	} else return;

	updatevars();
}
