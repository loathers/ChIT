import "zlib.ash";

void main(string item_name)
{
	string old_favs = vars["chit.favgear"];
	buffer new_favs;
	item it = to_item(item_name);
	boolean add_comma = false;
	
	foreach i,fav in split_string(old_favs,",")
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
	
	vars["chit.favgear"] = new_favs.to_string();

	updatevars();
}
