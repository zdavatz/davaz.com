function toggleTicker() {
	var node = dojo.byId('ticker-container');
	display = dojo.style.getStyle(node, "display");
	if(display=="none" || display=='') {
		node.style.overflow = 'hidden';
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

function replaceDiv(id, replace_id) {
	var node = dojo.byId(id);	
	var replace = dojo.byId(replace_id);
	var callback = function() {
		dojo.fx.html.wipeIn(replace, 100);
	}
	dojo.fx.html.wipeOut(node, 100, callback);	
}

function toggleShow(id, url, view, replace_id) {
	var show = dojo.widget.byId(id);
	var container = dojo.byId(id + "-container");
	var wipearea = dojo.byId(id + "-wipearea");
	var display;
	var replace = dojo.byId(replace_id);

	if(view == null) {
		if(show) {
			view = show.widgetType;
		} else  {
			view = 'Rack';	
		}
	}
	if(url == null) {
		url = show.dataUrl;	
	}
	
	var loadShow = function() {
		dojo.io.bind({
			url: url,
			load: function(type, data, event) { 
				data['id'] = id;
				if(show) {
					show.destroy();	
				}
				var widget = dojo.widget.createWidget(view, data, container,
																							'last');
				widget.dataUrl = url;
				if(dojo.style.getStyle(wipearea, "display") == 'none') {
					wipearea.style.overflow = 'hidden';
					dojo.fx.html.wipeIn(wipearea, 1000);
				}
			},
			mimetype: "text/json"
		});
	}
	if(replace && dojo.style.getStyle(replace, "display") != 'none') {
		dojo.fx.html.wipeOut(replace, 1000, loadShow);
	} else {
		loadShow.call();	
	}
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
					/*
					The following code does not work with ie.
					It is a nice-to-have feature:

					var href = document.location.href;
					var pos = href.indexOf('#');
					if(pos)
					{
						href = href.substring(0,pos);
					}
					document.location.href = href + "#" + articleId;
					document.location.hash = articleId; */
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

function removeImage(url) {
	var node = dojo.byId('links-list-container');
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,	
		load: function(type, data, event) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		mimetype: 'text/html'
	});
}

function addImage(url) {
	var node = dojo.byId('links-list-container');
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,	
		load: function(type, data, event) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		mimetype: 'text/html'
	});
}

function addImageFromChooser(url) {
	var node = dojo.byId('links-list-container');
	var chooser = dojo.byId('links-list-image-chooser');
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,	
		load: function(type, data, event) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		mimetype: 'text/html'
	});
}

function showImageChooser(url) {
	var node = dojo.byId('links-list-image-chooser');
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			node.innerHTML = data;
			var callback = function() {
				document.body.style.cursor = 'auto';
			};
			dojo.fx.html.wipeIn(node, 300, callback);
		},
		mimetype: 'text/html'
	});
}
