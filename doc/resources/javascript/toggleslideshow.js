function toggleSlideshow() {
	var rack = dojo.byId('rack');
	var slideshow = dojo.byId('slideshow');
	display = dojo.style.getStyle(rack, "display");
	if(display=="none") {
		var callback = function() {
			dojo.fx.html.wipeIn(rack, 300);
		}
		dojo.fx.html.wipeOut(slideshow, 300, callback);
	} else {
		var callback = function() {
			dojo.fx.html.wipeIn(slideshow, 300);
		}
		dojo.fx.html.wipeOut(rack, 300, callback);
	}
}
