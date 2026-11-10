var url = "/chitapi.ash";

var roofOffset = 4;
var floorOffset = 4;

var activePicker = null;

var fuidom = window.FloatingUIDOM;

var updateTimer;
var lastAPIResponse;

// modeled very similarly to TourGuide's autorefresh implementation
function chitIssueTimer() {
	if(updateTimer !== undefined) {
		clearTimeout(updateTimer);
	}
	// TODO: Guide has some stuff with the timer decaying/growing in response to some stuff,
	// I imagine this is unnecessary because of the automating refreshes when manually doing stuff in
	// game, but I'm not certain. Investigate further.
	updateTimer = setTimeout(chitCheckForUpdate, 5000);
}

function chitCheckForUpdate() {
	var request = new XMLHttpRequest();
	request.onerror = chitIssueTimer;
	request.onabort = chitIssueTimer;
	request.ontimeout = chitIssueTimer;
	request.onreadystatechange = function() {
		if(request.readyState === 4) {
			if(request.status === 200) {
				chitParseAPIResponseAndFireTimer(request.responseText);
			} else {
				chitIssueTimer();
			}
		}
	}
	request.open("POST", url);
	request.send("API=status");
}

function chitParseAPIResponseAndFireTimer(response_string) {
	var response;
	try {
		response = JSON.parse(response_string);
	} catch(exception) {
		chitIssueTimer();
		return;
	}

	if(lastAPIResponse === undefined) {
		lastAPIResponse = response;
		chitIssueTimer();
		return;
	}

	if(response["loggedin"] === "false" && lastAPIResponse["loggedin"] === "true") {
		// don't refresh while logged out
		return;
	}

	function objectMatch(obj1, obj2) {
		for(var i in obj1) {
			if(typeof obj1[i] !== typeof obj2[i]) {
				return false;
			} else if(typeof obj1[i] === "object") {
				if(!objectMatch(obj1[i], obj2[i])) {
					return false;
				}
			} else if(obj1[i] !== obj2[i]) {
				return false;
			}
		}

		return true;
	}

	if(!objectMatch(response, lastAPIResponse)) {
		lastAPIResponse = response;
		chitUpdatePageAndFireTimer();
	} else {
		chitIssueTimer();
	}
}

function chitUpdatePageAndFireTimer() {
	var request = new XMLHttpRequest();
	request.onerror = chitIssueTimer;
	request.onabort = chitIssueTimer;
	request.ontimeout = chitIssueTimer;
	request.onreadystatechange = function() {
		if(request.readyState === 4) {
			if(request.status === 200) {
				chitUpdatePageHTML(request.responseText);
			}
			chitIssueTimer();
		}
	}
	request.open("POST", url);
	request.send("API=body");
}

function chitUpdatePageHTML(body) {
	if(body.length < 11) {
		return;
	}
	// TODO: Save the entries in any forms (maximizer for example)
	chitDocumentCleanup();
	document.body.innerHTML = body;
	chitDocumentReady();
}

chitCheckForUpdate();

function chitDocumentReady() {

	//Picker Launchers
	//use bind for multiple events (KoL uses jQuery 1.3, using multiple events for 'live' was added in jQuery 1.4)
	//$(".chit_launcher").live("click", function(e) {
	$(".chit_launcher").bind("click contextmenu", function(e) {
		var caller = $(this);
		var top = caller.offset().top + caller.height() + 2;
		var picker = $("#" + caller.attr("rel"));
		
		if (picker) {
			if (picker.is(':hidden')) {
				picker.css({
					'position': 'absolute',
					'top': top,
					'max-height': '93%',
					'overflow-y': 'auto'
				});
				if ((top + picker.height() + 30) > $(document).height()) {
					picker.css('top', ($(document).height()-picker.height()-30));
				}
        if(activePicker != null) {
          activePicker.hide();
        }
        picker.show();
        activePicker = picker;
			} else {
				picker.hide();
        activePicker = null;
			}
		}
        return false;
	});
	$(".chit_picker a.change").live("click", function(e) {
		var caller = $(this);
		var picker = caller.closest(".chit_picker");
		var subpicker = caller.attr("rel");
		picker.find("tr.pickloader" + subpicker).show();
		picker.find("tr.pickitem").hide();
		picker.find("tr.florist").hide();
	});
	$(".chit_picker a.done").live("click", function(e) {
		$(this).closest(".chit_skeleton").hide();
	});
	$(".chit_picker tr.picknone").live("click", function(e) {
		$(this).closest(".chit_skeleton").hide();
	});
	$(".chit_picker th").live("click", function(e) {
		$(this).closest(".chit_skeleton").hide();
	});
	
	$(".chit_skeleton").live("click", function(e) {
		e.stopPropagation();
	});
	$(document).live("click", function(e) {
		$(".chit_skeleton").hide();
	});

	// Popover Launchers
	$(".chit_popoverlauncher").each(function(e) {
		var popoverId = $(this).attr("aria-describedby");
		var popover = $("#" + popoverId);
		var popoverArrow = $("#arrow" + popoverId);

		function showTooltip() {
			popover.css("display", "block");
			fuidom.computePosition($(this)[0], popover[0], {
				middleware: [
					fuidom.offset(6),
					fuidom.shift({padding: 5}),
					fuidom.autoPlacement(),
					fuidom.arrow({element: popoverArrow[0]}),
				],
			}).then(({x, y, placement, middlewareData}) => {
				Object.assign(popover[0].style, {
					left: `${x}px`,
					top: `${y}px`,
				});

				const {x: arrowX, y: arrowY} = middlewareData.arrow;
				const staticSide = {
					top: 'bottom',
					right: 'left',
					bottom: 'top',
					left: 'right',
				}[placement.split("-")[0]];
				Object.assign(popoverArrow[0].style, {
					left: arrowX != null ? `${arrowX}px` : "",
					top: arrowY != null ? `${arrowY}px` : "",
					right: "",
					bottom: "",
					[staticSide]: '-3px',
					'border-width':
						staticSide === 'top'
						? '1px 0px 0px 1px'
						: staticSide === 'bottom'
						? '0px 1px 1px 0px'
						: staticSide === 'left'
						? '0px 0px 1px 1px'
						: '1px 1px 0px 0px',
				});
			});
		}
		function hideTooltip() {
			popover.css("display", "");
		}

		[
			['mouseenter', showTooltip],
			['mouseleave', hideTooltip],
			['focus', showTooltip],
			['blur', hideTooltip],
		].forEach(([event, listener]) => {
			$(this).bind(event, listener);
		});
	});

	//Tool Launchers
	$(".tool_launcher").live("click", function(e) {
		
		var caller = $(this);
		var bottom = $("#chit_toolbar").outerHeight() + floorOffset -1;
		var tool = $("#chit_tool" + caller.attr("rel"));
		
		if (tool) {
			if (tool.is(':hidden')) {
				$(".chit_skeleton").hide();
				tool.css({
					'position': 'absolute',
					'left': '4px',
					'right': '4px',
					'bottom': bottom+'px',
					'max-height': '98%',
					'overflow-y': 'auto'
				});
				tool.slideDown('fast');
			} else {
				tool.slideUp('fast');
			}
		}
        return false;
	});
	$("div.chit_skeleton table.chit_brick th").live("click", function(e) {
		$(this).closest("div.chit_skeleton").hide();
		e.stopPropagation();
	});
	$("div.chit_skeleton table.chit_brick th a").live("click", function(e) {
		e.stopPropagation();
	});
	
	//MCD
	$("#chit_mcd tbody a").live("click", function(e) {
		var h = $("#chit_mcd th");
		h.html(h.attr("rel")).addClass("busy");
	});
	
	$("a.visit").live("click", function(e) {
		if (top.mainpane.focus) top.mainpane.focus();
	});
	
	//Resize window
	$(window).resize(function() {
	
		var pad = 5;
		var roof = $("#chit_roof");
		var walls = $("#chit_walls");
		var floor = $("#chit_floor");

		var roofHeight = (roof) ? roof.outerHeight(true) : 0;
		var floorHeight = (floor) ? floor.outerHeight(true) : 0;
		var availableHeight = $(document).height() - floorHeight - roofOffset - floorOffset - pad;
		
		if (floor) {
			floor.css({
				"bottom": floorOffset + "px",
			});	
		}
		
		if (roof) {
			roof.css({
				"top": roofOffset + "px"
			});	
			if (!walls || (roofHeight > availableHeight)) {
				roof.css("bottom", (floorOffset + floorHeight + pad) + "px");
			}
		}
		
		
		if (walls && (roofHeight >= availableHeight)) {
			walls.css("bottom", (floorOffset + floorHeight + pad) + "px");
			roof.css("overflow-y","auto");
		}
		
		
		else if (walls && (roofHeight < availableHeight)) {
			walls.css("bottom", (floorOffset + floorHeight + pad) + "px");
			if (roof) {
				walls.css("top", (roofOffset + roofHeight + pad) + "px");
			} else {
				walls.css("top", (roofOffset) + "px");
			}
		}
		
		
	});
	
	
	$(window).resize();
	$(window).resize(); // This is redundant, but soolar added it in r420 and it is necessary.

	
	var curRoof = document.getElementById("chit_roof");
	var originalRoofHeight = $('#chit_roof').height();

	function finalResize()
	{
		$(window).resize();
		originalRoofHeight = $('#chit_roof').height();
	}
	
	window.setTimeout(finalResize, 500);
	
	function toggle_stretch ()
	{
		if (originalRoofHeight == $('#chit_roof').height())
		{
			curRoof.style.height = "0px";
			$(window).resize();
		}
		else
		{
			curRoof.style.height = originalRoofHeight+"px";
			$(window).resize();
		}
	}
	
	$(".chit_walls_stretch").live("click", function(e) {
		toggle_stretch();
	});
}

function chitDocumentCleanup() {
	$(".chit_launcher").unbind("click contextmenu");
	$(".chit_picker a.change").die("click");
	$(".chit_picker a.done").die("click");
	$(".chit_picker tr.picknone").die("click");
	$(".chit_picker th").die("click");
	$(".chit_skeleton").die("click");
	$(document).die("click");
	$(".chit_popoverlauncher").each(function(e) {
		['mouseenter', 'mouseleave', 'focus', 'blur'].forEach((event) => {
			$(this).unbind(event);
		});
	});
	$(".tool_launcher").die("click");
	$("div.chit_skeleton table.chit_brick th").die("click");
	$("div.chit_skeleton table.chit_brick th a").die("click");
	$("#chit_mcd tbody a").die("click");
	$("a.visit").die("click");
	$(window).unbind("resize");
	$(".chit_walls_stretch").die("click");
}

$(document).ready(chitDocumentReady);
