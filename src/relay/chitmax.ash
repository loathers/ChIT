import "charpane.ash";

void main() {
	string[string] fields = form_fields();
	if(fields contains "action" && fields["action"] == "cliexec" && fields contains "cmd") {
		cli_execute(fields["cmd"]);
	}

	bake_maximizer(true);

	write('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">\n');
	write('<html><head>');
	write('<link rel="stylesheet" href="basics.1.css" />\n');
	write('<link rel="stylesheet" href="chit.css" />\n');
	write('<link rel="stylesheet" href="chit_custom.css" />\n');
	write('</head>');
	write('<script src="https://cdn.jsdelivr.net/npm/@floating-ui/core@1.7.2"></script>');
	write('<script src="https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.7.2"></script>');
	write('<script src="/images/scripts/jquery-1.3.1.min.js"></script>');
	write('<script src="/images/scripts/window.20111231.js"></script>');
	write('<script type="text/javascript" src="chit.js"></script>');
	write('<body>');
	write(chitBricks["maximizer"]);
	write('</body></html>');
}
