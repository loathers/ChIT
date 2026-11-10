import "charpane.ash";

void main() {
	string[string] fields = form_fields();

	if(!(fields contains "API")) {
		print('called chitapi.ash without API field...');
		return;
	}

	if(fields["API"] == "status") {
		APIStatusResponse().to_json().write();
	} else if(fields["API"] == "body") {
		visit_url("/charpane.php").modifyPage(true).write();
	} else {
		write("ERROR");
	}
}
