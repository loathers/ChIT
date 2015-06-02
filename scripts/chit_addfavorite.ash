import "zlib.ash";

void main(string item_name)
{
	vars["chit.favgear"] = (vars["chit.favgear"] + "," + item_name);
	updatevars();
}
