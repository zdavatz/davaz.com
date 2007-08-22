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
	var ticker = dojo.widget.byId('ticker');
  dojo.style.setStyle(node, 'overflow', 'hidden');
	display = dojo.style.getStyle(node, "display");
	if(display==="none" || display==='') {
		dojo.style.hide(node); //setStyle(node, 'display', 'none');
		var anim = dojo.lfx.html.wipeIn('ticker-container', 300);	
		anim.play();
		ticker.togglePaused();
	} else {
		dojo.lfx.html.wipeOut('ticker-container', 300).play();	
		ticker.togglePaused();
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

function checkRemovalStatus(selectValue, url) {
	document.body.style.cursor = 'progress';
	url = url + selectValue; 
	dojo.io.bind({
		url: url,
		load: function(type, data, event) { 
			//var removalStatus = data['removalStatus'];
			var removalStatus = data.removalStatus;
			//var removeLink = dojo.byId(data['removeLinkId']);
			var removeLink = dojo.byId(data.removeLinkId);
			if(removalStatus == 'goodForRemoval') {
				if(removeLink) {
					removeLink.style.color = 'blue';
				}
			} else {
				if(removeLink) {
					removeLink.style.color = 'grey';
				}
			}
			document.body.style.cursor = 'auto';
		},
		mimetype: "text/json"
	});
}

function addElement(inputSelect, url, value, addFormId, removeLinkId) {
	url += value;	
	toggleInnerHTML(inputSelect.parentNode, url, '', function() {
		dojo.byId(addFormId).innerHTML='&nbsp;';
		var removeLink = dojo.byId(removeLinkId);
		removeLink.style.color = 'blue';
	});
}

function removeElement(inputSelect, url, removeLinkId) {
	var selectedId = inputSelect.value;
	url += selectedId;
	toggleInnerHTML(inputSelect.parentNode, url, '', function() {
		var removeLink = dojo.byId(removeLinkId);
		removeLink.style.color = 'grey';
	});
}

function toggleInnerHTML(divId, url, changeUrl, callback) {
	var fragmentidentifier = "";
	if(changeUrl) {
		fragmentidentifier = changeUrl;
	} 
	var node = dojo.byId(divId);
	if(url == 'null') {
		node.innerHTML = '';
		return;
	}
	document.body.style.cursor = 'progress';
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			node.innerHTML = data;
			if(callback) { callback(); }
			document.body.style.cursor = 'auto';
		},
		changeUrl: fragmentidentifier,
		mimetype: 'text/html'
	});
}

function toggleUploadImageForm(divId, url) {
	var node = dojo.byId(divId);
	if(node.innerHTML === '') {
		document.body.style.cursor = 'progress';
		dojo.io.bind({
			url: url,
			load: function(type, data, event) {
				node.style.display = 'none';
				node.innerHTML = data;
				dojo.lfx.wipeIn(node, 300).play();
				document.body.style.cursor = 'auto';
			},
			mimetype: 'text/html'
		});
	} else {
		dojo.lfx.wipeOut(node, 300, null, function() {
			node.innerHTML = "";
		}).play();
	}
}

function reloadShoppingCart(url, count) {	
	if(parseInt(count)===count-0) {
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
	var artobjectId = url.split("/").pop();
	display = dojo.style.getStyle(node, "display");
	if(display=="none") {
		dojo.io.bind({
			url: url,
			load: function(type, data, event) {
				node.innerHTML = data;	
				replaceDiv(replaceDivId, divId);
			},
			changeUrl: artobjectId,
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
	};
	dojo.lfx.html.wipeOut(node, 1000, dojo.lfx.easeInOut, callback).play();
}

function toggleDeskContent(id, serieId, objectId, url, wipe) {
	var fragmentIdentifier = 'Detail_' + serieId + '_' + objectId;
	var reloadDesk = function() {
		var desk = dojo.widget.byId(id);
		dojo.io.bind({
			url: url,	
			load: function(type, data, event) {
				desk.toggleInnerHTML(data);
				if(wipe === true) {
					dojo.lfx.html.wipeIn('show-wipearea', 1000).play();
				}
			}, 
			changeUrl: fragmentIdentifier,
			mimetype: "text/html"
		});
	};

	if(wipe === true) {
		dojo.lfx.html.wipeOut('show-wipearea', 1000, dojo.lfx.easeInOut, 
																								reloadDesk).play();
	} else {
		reloadDesk();
	}
}

function toggleShow(id, url, view, replace_id, serie_id, artobject_id) {
	var show = dojo.widget.byId(id);
	if(show) {
		var lastUrl = show.dataUrl;
		var lastId = lastUrl.split("/").pop();
	}

  var serieLink = dojo.byId(serie_id);

	if(serie_id && show) {
		if(lastId != serie_id) {
			var lastSerieLink = dojo.byId(lastId);	
			if(lastSerieLink) {
        lastSerieLink.className = lastSerieLink.className.replace(/ ?active/, '');
			}
		} 
	}
	var container = dojo.byId(id + "-container");
	var wipearea = dojo.byId(id + "-wipearea");
	var display;
	var replace = dojo.byId(replace_id);

	if(view === null) {
		if(show) {
			view = show.widgetType;
		} else  {
			view = 'Rack';	
		}
	}

	if(url === null && show) {
		url = lastUrl;	
	}

	if(serie_id === null) {
		serie_id = show.serieId;	
	}

	var fragmentIdentifier = view + "_" + serie_id;

	if(artobject_id) {
		fragmentIdentifier = fragmentIdentifier + "_" + artobject_id;
	}

	var loadShow = function() {
		dojo.io.bind({
			url: url,
			load: function(type, data, event) { 
				//data['id'] = id;
				data.id = id;
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

        // change color of active link to black
        if(serieLink != null && !serieLink.className.match(/ ?active/))
        {
          serieLink.className += " active";
        }
			},
			changeUrl: fragmentIdentifier,
			mimetype: "text/json"
		});
	};
	if(replace && dojo.style.getStyle(replace, "display") != 'none') {
		dojo.lfx.html.wipeOut(replace, 1000, dojo.lfx.easeInOut, loadShow).play();
	} else {
		loadShow.call();	
	}
}

function toggleJavaApplet(url, artobjectId) {
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			var container = dojo.byId('java-applet');
			container.innerHTML = data;
		},
		changeUrl: artobjectId,
		mimetype: "text/html"
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

function login_form(link, url) {
	var hash = document.location.hash;
	var login_url = url + "fragment/" + hash.replace(/#/, '');
	dojo.io.bind({
		url: login_url,
		load: function(type, data, event) {
			var form = dojo.byId('login-form');
			if(form) {
				dojo.html.body().removeChild(form);
			} else {
				var div = document.createElement("div");
				div.innerHTML = data; 
				div.id = 'login-form';
				div.style.position="absolute";
				dojo.html.body().appendChild(div);
				var position = dojo.html.getAbsolutePosition(link, true);
				var left = position[0];
				var top = position[1] - 5 - div.offsetHeight;
				div.style.left = left+"px";
				div.style.top = top+"px";
			}
		},
		mimetype: 'text/html'
	});
}

function loginError(errorMessage) {
	var form = dojo.byId('login-form');	
	var div = document.createElement("div");
	div.innerHTML = errorMessage;
	form.appendChild(div); 
}

function logout(link) {
	var hash = document.location.hash;
	var href = link.href + "fragment/" + hash.replace(/#/, '');
	link.href = href;
}

function addNewElement(url) {
	var container = dojo.byId('element-container');
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			var div = document.createElement("div");
			container.insertBefore(div,container.firstChild);
			var pane = dojo.widget.createWidget("ContentPane", {executeScripts: true}, div);
			pane.setContent(data);
		},
		mimetype: 'text/html'
	});	
}

function deleteElement(url) {
	var container = dojo.byId('element-container');
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			//window.location.href=data['url'];
			window.location.href=data.url;
		},
		mimetype: 'text/html'
	});	
}

function deleteImage(url, image_div_id) {
	var image_div = dojo.byId(image_div_id);
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			image_div.innerHTML = "";
		},
		mimetype: 'text/html'
	});
}

function reloadImageAction(url, div_id) {
	var image_action_div = dojo.byId(div_id) ;
	dojo.io.bind({
		url: url,
		load: function(type, data, event) {
			image_action_div.innerHTML = data;
		},
		mimetype: 'text/html'
	});
}

function toggleLoginWidget(loginLink, url) {
	var newDiv = document.createElement("div");	
	dojo.html.body().appendChild(newDiv);
	dojo.widget.createWidget("LoginWidget", 
		{
			loginLink: loginLink,
			loginFormUrl: url,
			oldOnclick: loginLink.onclick
		}, newDiv );
	loginLink.onclick = "return false;";
}
