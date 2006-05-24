var toggle_busy = false;
function toggleImageSrc(imageId, url) {
	if(toggle_busy) return;
	var node = dojo.byId(imageId);
	var src_image_id = node.src.split("/").pop();
	var new_image_id = url.split("/").pop();
	if(src_image_id == new_image_id) return;
	toggle_busy = true;
	var callback2 = function() {
		toggle_busy = false;
	}
	var callback1 = function() {
		node.src = url;
		dojo.fx.fadeIn(node, 200, callback2);
	}
	dojo.fx.fadeOut(node, 200, callback1);
}

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

function toggleTicker() {
	var node = dojo.byId('ticker-container');
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.fx.html.wipeIn('ticker-container', 300);	
	} else {
		dojo.fx.html.wipeOut('ticker-container', 300);	
	}
}

function toggleHiddenDiv(divId) {
	var node = dojo.byId(divId);
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.fx.html.wipeIn(node, 300);	
	} else {
		dojo.fx.html.wipeOut(node, 300);	
	}
}

function reloadShoppingCart(url, count) {
	if(count!='0') {
		var node = dojo.byId('shopping-cart');
		document.body.style.cursor = 'progress';
		dojo.io.bind({
			url: url + count,
			load: function(type, data, event) {
				node.innerHTML = data;
				document.body.style.cursor = 'auto';
			},
			mimetype: 'text/html'
		});	
	}
}

function removeFromShoppingCart(url, fieldId) {
	var node = dojo.byId('shopping-cart');
	var inputNode = dojo.byId(fieldId);
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			node.innerHTML = data;
			inputNode.value = '0';
			document.body.style.cursor = 'auto';
		},
		mimetype: 'text/html'
	});
}

function toggleArticle(link, articleId, url) {
	var node = dojo.byId(articleId);
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		document.body.style.cursor = 'progress';
		link.style.cursor = 'progress';
		dojo.io.bind({
			url: url,
			load: function(type, data, event) { 
				node.innerHTML = data;
				dojo.fx.html.wipeIn(node, 1000, function() {
					document.location.hash = articleId;
					document.body.style.cursor = 'auto';
					link.style.cursor = 'auto';
				});
			},
			mimetype: "text/html"
		});
	} else {
		dojo.fx.html.wipeOut(node, 100);	
	}
}

function jumpTo(nodeId) {
	document.location.hash = nodeId;
}
