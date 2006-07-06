function submitForm(form, dataDivId, formDivId, keepForm) {
	var formDiv = dojo.byId(formDivId);
	var dataDiv = dojo.byId(dataDivId);
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: form.action,
		formNode: form,
		transport: 'IframeTransport',
		load: function(type, data, event) {
			dataDiv.innerHTML = data.body.innerHTML;	
			if(!keepForm) {
				formDiv.innerHTML = "";
			}	
			document.body.style.cursor = 'auto';
		},
		mimetype: 'text/html'
	});
}

function toggleTicker() {
	var node = dojo.byId('ticker-container');
	display = dojo.style.getStyle(node, "display");
	if(display=="none" || display=='') {
		dojo.style.hide(node); //setStyle(node, 'display', 'none');
		var anim = dojo.lfx.html.wipeIn('ticker-container', 300);	
		anim.play();
	} else {
		dojo.lfx.html.wipeOut('ticker-container', 300).play();	
	}
}

function toggleHiddenDiv(divId) {
	var node = dojo.byId(divId);
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.lfx.html.wipeIn(node, 300).play();	
	} else {
		dojo.lfx.html.wipeOut(node, 300).play();	
	}
}

function toggleInnerHTML(divId, url) {
	var node = dojo.byId(divId);
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

function showMovieGallery(divId, replaceDivId, url) {
	var node = dojo.byId(divId);
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.io.bind({
			url: url,
			load: function(type, data, event) {
				node.innerHTML = data;	
				replaceDiv(replaceDivId, divId);
			},
			mimetype: 'text/html'
		});
	} else {
		replaceDiv(divId, replaceDivId);
		node.innerHTML = "";			
	}
}

function replaceDiv(id, replace_id) {
	var node = dojo.byId(id);	
	var replace = dojo.byId(replace_id);
	var callback = function() {
		dojo.lfx.html.wipeIn(replace, 100).play();
	}
	dojo.lfx.html.wipeOut(node, 1000, dojo.lfx.easeInOut, callback).play();
}

function toggleDeskContent(id, url, wipe) {
	var reloadDesk = function() {
		var desk = dojo.widget.byId(id);
		dojo.io.bind({
			url: url,	
			load: function(type, data, event) {
				desk.toggleInnerHTML(data);
				if(wipe == true) {
					dojo.lfx.html.wipeIn('show-wipearea', 1000).play();
				}
			}, 
			mimetype: "text/html"
		});
	}

	if(wipe == true) {
		dojo.lfx.html.wipeOut('show-wipearea', 1000, dojo.lfx.easeInOut, 
																								reloadDesk).play();
	} else {
		reloadDesk();
	}
}

function toggleShow(id, url, view, replace_id, serie_id) {
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

	if(serie_id == null) {
		serie_id = show.serieId;	
	}

	var fragmentIdentifier = view + "_" + serie_id;
	
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
				if(dojo.style.getStyle(wipearea, "display") == 'none') {
					wipearea.style.overflow = 'hidden';
					dojo.lfx.html.wipeIn(wipearea, 1000, 
																					dojo.lfx.easeInOut).play();
				}
			},
			changeUrl: fragmentIdentifier,
			mimetype: "text/json"
		});
	}
	if(replace && dojo.style.getStyle(replace, "display") != 'none') {
		dojo.lfx.html.wipeOut(replace, 1000, dojo.lfx.easeInOut, loadShow).play();
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
				dojo.lfx.html.wipeIn(node, 1000, dojo.lfx.easeInOut, function() {
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
				}).play();
			},
			mimetype: "text/html"
		});
	} else {
		dojo.lfx.html.wipeOut(node, 100).play();	
	}
}

function jumpTo(nodeId) {
	document.location.hash = nodeId;
}

function reloadLinkListComposite(url) {
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
	var node = dojo.byId('displayelement-form');
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

function addLink(url) {
	var node = dojo.byId('links-list-container');
	var linkWord = dojo.byId('link-word').value;
	dojo.io.bind({
		url: url + linkWord,	
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
			dojo.lfx.html.wipeIn(node, 300, callback);
		},
		mimetype: 'text/html'
	});
}
