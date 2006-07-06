function toggleSlideshow() {
	var rack = dojo.byId('rack');
	var slideshow = dojo.byId('slideshow');
	display = dojo.style.getStyle(rack, "display");
	if(display=="none") {
		var callback = function() {
			dojo.lfx.html.wipeIn(rack, 300);
		}
		dojo.lfx.html.wipeOut(slideshow, 300, callback);
	} else {
		var callback = function() {
			dojo.lfx.html.wipeIn(slideshow, 300);
		}
		dojo.lfx.html.wipeOut(rack, 300, callback);
	}
}
