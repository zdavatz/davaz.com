function toggleTicker() {
	var node = dojo.byId('ticker-container');
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.fx.html.wipeIn('ticker-container', 300);	
	} else {
		dojo.fx.html.wipeOut('ticker-container', 300);	
	}
}
