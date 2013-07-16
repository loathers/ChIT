
var roofOffset = 4;
var floorOffset = 4;

$(document).ready(function () {

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
				picker.show();
			} else {
				picker.hide();
			}
		}
        return false;
	});
	$(".chit_picker a.change").live("click", function(e) {
		$(this).closest(".chit_picker").find("tr.pickloader").show();
		$(this).closest(".chit_picker").find("tr.pickitem").hide();
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
					'bottom': bottom+'px'
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
	
}); 

// Now for KoLmafia's Familiar Picker, with a small change:
var familiarpicklist = (function () {
var self = {
	pickdiv: null,
	kill: function () {
		if (self.pickdiv) $(self.pickdiv).remove();
	},
	uhoh: function (res) {
		self.pickdiv.find('.guts').html("Sorry, you're too busy "+res+" to change familiars right now.");
		self.pickdiv.find('.title').html("Uh Oh!");
		setTimeout(self.kill, 5000);
	},
	cookiename: 'frcm_style',
	_style: null,
	set_style: function (sid) {
		self._style = sid;
		setCookie(self.cookiename, sid, 365);
	},
	style: function () { 
		if (self._style === null) {
			self._style = getCookie(self.cookiename);
		}
		return self._style;	
	},
	get_pick: function (choices, caller) {
		self.kill();
		var ht = '<ul style="padding: 0; margin: 0; font-size: 8pt">';
		var fam, name;
		var style = self.style();
		for (var i=0; i<choices.length; i++) {
			fam = choices[i];
			if (fam[3] == CURFAM) continue;
			name = fam[0];
			if (style == 2)
				ht +='<li>&middot;<a href="#" class="picker" rel="'+fam[3]+'" title="'+name+'">'+fam[1]+'</a></li>';
			else if (style == 3)
				ht +='<a href="#" class="picker" rel="'+fam[3]+'" title="'+name+' (the '+fam[1]+')" style="padding-left: 4px;"><img src="http://images.kingdomofloathing.com/itemimages/'+fam[2]+'.gif" border="1" /></a></li>';
			else
				ht +='<li>&middot;<a href="#" class="picker" rel="'+fam[3]+'" title="(the '+fam[1]+')">'+name+'</a></li>';
		}
		ht +='</ul>';
		ht += '<div class="settype" style="padding-top: 3px; font-size:7pt">show: <a href="#" rel="1">name</a> <a href="#" rel="2">type</a> <a href="#" rel="3">image</a></div>';
		var $div = $('<div><div style="color:white;background-color:blue;padding:2px 15px 2px 15px;white-space: nowrap;text-align:center" class="title">Favorites</div><img class="close" style="cursor: pointer; position: absolute;right:1px;top:1px;" alt="Cancel" title="Cancel" src="http://images.kingdomofloathing.com/closebutton.gif"/><div style="padding:4px; text-align: left" class="guts">'+ht+'</div><div style="clear:both"></div></div>');
		var pos = caller.offset();
		$div.css({
			'position': 'absolute',
			'text-align': 'right',
			'background-color': 'white',
			'border': '1px solid black',
			'margin-left': '2px',
			'width': '97%',
			'top': pos.top - 24,
			'left': 0
		});
		$('body').append($div);
		if ((pos.top + $div.height() + 30) > $(document).height()) {
			$div.css('top', (pos.top - $div.height() + 20));
		}
		$div.find('.close').click(self.kill);
		$div.find('.settype a').click(function () {
			self.set_style($(this).attr('rel'));
			self.get_pick(choices, caller);
			return false;
		}).each(function () {
			var st = style == 0 ? 1 : style;
			if ($(this).attr('rel') == st) $(this).css('text-decoration','none');
		});
		$div.find('.picker').click(function () {
			self.pick($(this).attr('rel'));
			$(this).parents('div.guts').html('Inviting <b>'+$(this).text()+' '+$(this).attr('title')+'</b> to join you.');
			return false;
		});
		self.pickdiv = $div;
	},
	pick: function (famid) {
	var httpObject = getHttpObject();
	httpObject.open( "GET", "/KoLmafia/sideCommand?cmd=ashq use_familiar(to_familiar("+famid+"))&pwd="+pwdhash, true );
	httpObject.send( "" );
	function reloader() { window.top.charpane.location.reload(); }
	window.setTimeout(reloader, 2500);
	}
};
return self;
})();

$(document).ready(function () {
	if (typeof FAMILIARFAVES == 'undefined' || FAMILIARFAVES.length < 1) return;
	$('.familiarpick').live('contextmenu', function (e) {

		familiarpicklist.get_pick(FAMILIARFAVES, $(this));
		return false;
	}).live('click', function (e) {
		if (!e.shiftKey) return true;
		else { $(this).trigger('contextmenu'); return false; }
	});
});

