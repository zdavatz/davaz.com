function toggleTicker() {
	var node = dojo.byId('ticker-container');
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.lfx.html.wipeIn('ticker-container', 300);	
	} else {
		dojo.lfx.html.wipeOut('ticker-container', 300);	
	}
}
