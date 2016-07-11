function submitForm(form, dataDivId, formDivId, keepForm) {
	var formDiv = dojo.byId(formDivId);
	var dataDiv = dojo.byId(dataDivId);
	document.body.style.cursor = 'progress';
	dojo.io.iframe.send({
		url: form.action,
		form: form,
		load: function(data, request) {
			dataDiv.innerHTML = data.body.innerHTML;	
			if(!keepForm) {
				formDiv.innerHTML = "";
			}	
			document.body.style.cursor = 'auto';
		},
		handleAs: 'html'
	});
}

function toggleTicker() {
  require([
    'dojo/dom'
  , 'dojo/dom-style'
  , 'dojo/fx'
  , 'dijit/dijit'
  , 'dojo/domReady!'
  ], function(dom, domStyle, fx, dijit) {
    var node   = dom.byId('ticker_container')
      , ticker = dijit.byId('ywesee_widget_ticker_0')
      ;
    var display = node.style.display;
    if (display === "none" || display === '' || display == undefined) {
      fx.wipeIn({
        node:     node
      , duration: 300
      , onEnd:    function() {
          domStyle.set(node, 'display', 'block');
        }
      }).play();
    } else {
      fx.wipeOut({
        node:     node
      , duration: 300
      , onEnd:    function() {
          domStyle.set(node, 'display', 'none');
        }
      }).play();
    }
    ticker.TogglePaused();
  });
}

function toggleHiddenDiv(divId) {
	var node = dojo.byId(divId);
	var display = node.style.display; 
	if(display=="none") {
		dojo.fx.wipeIn(node, 300).play();	
	} else {
		dojo.fx.wipeOut(node, 300).play();	
	}
}

function checkRemovalStatus(selectValue, url) {
	document.body.style.cursor = 'progress';
	url = url + selectValue; 
	dojo.xhrGet({
		url: url,
		load: function(data, request) { 
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
		handleAs: "json-comment-filtered"
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
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
      var pane = new dijit.layout.ContentPane({executeScripts: true}, node);
      pane.setContent(data);
			if(callback) { callback(); }
			document.body.style.cursor = 'auto';
      dojo.back.addToHistory({changeUrl:fragmentidentifier});
		},
		handleAs: 'text'
	});
}

function toggleUploadImageForm(divId, url) {
	var node = dojo.byId(divId);
	if(node.innerHTML === '') {
		document.body.style.cursor = 'progress';
		dojo.xhrGet({
			url: url,
			load: function(data, request) {
				node.style.display = 'none';
				node.innerHTML = data;
				dojo.fx.wipeIn(node, 300).play();
				document.body.style.cursor = 'auto';
			},
			handleAs: 'text'
		});
	} else {
		dojo.fx.wipeOut(node, 300, null, function() {
			node.innerHTML = "";
		}).play();
	}
}

function reloadShoppingCart(url, count) {	
	if(parseInt(count)===count-0) {
		var node = dojo.byId('shopping_cart');
		document.body.style.cursor = 'progress';
		dojo.xhrGet({
			url: url + count,
			load: function(data, request) {
				node.innerHTML = data;
				document.body.style.cursor = 'auto';
			},
			handleAs: 'text'
		});	
	}
}

function removeFromShoppingCart(url, fieldId) {
	var node = dojo.byId('shopping_cart');
	var inputNode = dojo.byId(fieldId);
	document.body.style.cursor = 'progress';
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
			node.innerHTML = data;
			inputNode.value = '0';
			document.body.style.cursor = 'auto';
		},
		handleAs: 'text'
	});
}

function showMovieGallery(divId, replaceDivId, url) {
	var node = dojo.byId(divId);
	var artobjectId = url.split("/").pop();
	var display = node.style.display; 
	if(display=="none") {
		dojo.xhrGet({
			url: url,
			load: function(data, request) {
        var pane = new dijit.layout.ContentPane({executeScripts: true}, node);
        pane.setContent(data);
				replaceDiv(replaceDivId, divId);
        dojo.back.addToHistory({changeUrl:artobjectId});
			},
			handleAs: 'text'
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
		dojo.fx.wipeIn({node:replace, duration:100}).play();
	};
	dojo.fx.wipeOut({node:node, duration:1000, onEnd:callback}).play();
}

function toggleDeskContent(id, serieId, objectId, url, wipe) {
	var fragmentIdentifier = 'Detail_' + serieId + '_' + objectId;
	var reloadDesk = function() {
		var desk = dijit.byId(id);
		dojo.xhrGet({
			url: url,	
			load: function(data, event) {
				desk.toggleInnerHTML(data);
				if(wipe === true) {
					dojo.fx.wipeIn('show_wipearea', 1000).play();
				}
        dojo.back.addToHistory({changeUrl:fragmentIdentifier});
			}, 
			handleAs: "text"
		});
	};

	if(wipe === true) {
		dojo.fx.wipeOut({node:'show_wipearea', duration:1000, onEnd:reloadDesk}).play();
	} else {
		reloadDesk();
	}
}

function toggleShow(id, url, view, replace_id, serie_id, artobject_id) {
  require([
    'dojo/_base/xhr'
  , 'dojo/dom'
  , 'dojo/dom-style'
  , 'dojo/fx'
  , 'dojo/back'
  , 'dijit/dijit'
  , 'dojo/domReady!'
  , 'ywesee/widget/slide'
  , 'ywesee/widget/desk'
  , 'ywesee/widget/rack'
  ], function(xhr, dom, domStyle, fx, back, dijit) {
    var show = dijit.byId(id);
    if (show) {
      var lastUrl = show.dataUrl
        , lastId  = lastUrl.split('/').pop()
        ;
    }
    var serieLink = dojo.byId(serie_id);
    if (serie_id && show) {
      if (lastId != serie_id) {
        var lastSerieLink = dojo.byId(lastId);
        if (lastSerieLink) {
          lastSerieLink.className = lastSerieLink.className.replace(/ ?active/, '');
        }
      }
    }
    var container = dojo.byId(id + '_container')
      , wipearea  = dojo.byId(id + '_wipearea')
      , display
      , replace = dojo.byId(replace_id)
      ;
    if (view === null) {
      if (show) {
        view = show.view;
      } else  {
        view = 'rack';
      }
    }
    if (url === null && show) {
      url = lastUrl;
    }
    if (serie_id === null && show) {
      serie_id = show.serieId;
    }
    var flag = view.charAt(0).toUpperCase() + view.slice(1);
    var fragmentIdentifier = flag + '_' + serie_id;

    if (artobject_id) {
      fragmentIdentifier = fragmentIdentifier + '_' + artobject_id;
    }

    var loadShow = function() {
      xhr.get({
        url:      url
      , handleAs: 'json'
      , load:     function(data, args) {
          data.id = id;
          if (show) {
            show.destroy();
          }
          var domNode = dojo.doc.createElement('div');
          switch(view) {
          case 'slide':
            var widget = new ywesee.widget.slide(data, domNode);
            break;
          case 'desk':
            var widget = new ywesee.widget.desk(data, domNode);
            break;
          default:
            var widget = new ywesee.widget.rack(data, domNode);
          }
          container.appendChild(widget.domNode);
          widget.startup();
          var style = wipearea.style.display;
          if (!style || style === 'none') {
            wipearea.style.overflow = 'hidden';
            fx.wipeIn({
              node:     wipearea
            , duration: 900
            }).play();
          }
          // change color of active link to black
          if (serieLink != null && !serieLink.className.match(/ ?active/)) {
            serieLink.className += ' active';
          }
          back.addToHistory({changeUrl:fragmentIdentifier});
        },
      });
    };

    if (replace && replace.style.display !== 'none') {
      fx.wipeOut({
        node:     replace
      , duration: 1200
      , onEnd:    loadShow
      }).play();
    } else {
      loadShow.call();
    }
  });
}

function toggleJavaApplet(url, artobjectId) {
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
			var container = dojo.byId('java_applet');
			container.innerHTML = data;
      dojo.back.addToHistory({changeUrl:artobjectId});
		},
		handleAs: "text"
	});
}

function toggleArticle(link, articleId, url) {
	var node = dojo.byId(articleId);
	display = node.style.display; 
	if(display=="none") {
		document.body.style.cursor = 'progress';
		link.style.cursor = 'progress';
		dojo.xhrGet({
			url: url,
			load: function(data, request) { 
				node.innerHTML = data;
				dojo.fx.wipeIn({node:node, duration:1000, onEnd:function() {
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
				}}).play();
			},
			handleAs: "text"
		});
	} else {
		dojo.fx.wipeOut({node:node, duration:100}).play();	
	}
}

function jumpTo(nodeId) {
	document.location.hash = nodeId;
}

function reloadLinkListComposite(url) {
	var node = dojo.byId('links_list_container');
	document.body.style.cursor = 'progress';
	dojo.xhrGet({
		url: url,	
		load: function(data, request) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		handleAs: 'text'
	});
}

function addImage(url) {
	var node = dojo.byId('displayelement_form');
	document.body.style.cursor = 'progress';
	dojo.xhrGet({
		url: url,	
		load: function(data, request) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		handleAs: 'text'
	});
}

function addLink(url) {
	var node = dojo.byId('links_list_container');
	var linkWord = dojo.byId('link_word').value;
	dojo.xhrGet({
		url: url + linkWord,	
		load: function(data, request) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		handleAs: 'text'
	});
}

function addImageFromChooser(url) {
	var node = dojo.byId('links_list_container');
	var chooser = dojo.byId('links_list_image_chooser');
	document.body.style.cursor = 'progress';
	dojo.xhrGet({
		url: url,	
		load: function(data, request) {
			node.innerHTML = data;
			document.body.style.cursor = 'auto';
		},
		handleAs: 'text'
	});
}

function showImageChooser(url) {
	var node = dojo.byId('links_list_image_chooser');
	document.body.style.cursor = 'progress';
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
			node.innerHTML = data;
			var callback = function() {
				document.body.style.cursor = 'auto';
			};
			dojo.fx.wipeIn(node, 300, callback);
		},
		handleAs: 'text'
	});
}
/*
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
*/
function logout(link) {
	var hash = document.location.hash;
	var href = link.href + "fragment/" + hash.replace(/#/, '');
	link.href = href;
}

function addNewElement(url) {
	var container = dojo.byId('element_container');
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
			var div = document.createElement("div");
			container.insertBefore(div,container.firstChild);
			var pane = new dijit.layout.ContentPane({executeScripts: true}, div);
			pane.setContent(data);
		},
		handleAs: 'text'
	});	
}

function deleteElement(url) {
	var container = dojo.byId('element_container');
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
			//window.location.href=data['url'];
			window.location.href=data.url;
		},
		handleAs: 'text'
	});	
}

function deleteImage(url, image_div_id) {
	var image_div = dojo.byId(image_div_id);
	dojo.xhrGet({
		url: url,
		load: function(type, data, event) {
			image_div.innerHTML = "";
		},
		handleAs: 'text'
	});
}

function reloadImageAction(url, div_id) {
	var image_action_div = dojo.byId(div_id) ;
	dojo.xhrGet({
		url: url,
		load: function(data, request) {
			image_action_div.innerHTML = data;
		},
		handleAs: 'text'
	});
}

function toggleLoginWidget(loginLink, url) {
	var newDiv = document.createElement("div");	
	dojo.body().appendChild(newDiv);
  var login = new ywesee.widget.LoginWidget({ loginLink: loginLink,
      loginFormUrl: url, oldOnclick: loginLink.onclick }, newDiv);
	loginLink.onclick = "return false;";
  login.startup();
}

function setHrefTooltip(domId, hrefHolderId, dialogId, orient) {
  require([
    'dijit/TooltipDialog'
  , 'dijit/popup'
  , 'dojo/on'
  , 'dojo/dom'
  , 'dojo/dom-attr'
  , 'dojo/domReady!'
  ], function(TooltipDialog, popup, on, dom, attr) {
    var targetDom = dom.byId(domId)
      , holder    = dom.byId(hrefHolderId)
      ;
    if (targetDom === null || holder === null) { return }
    var artDialog = new TooltipDialog({
          id:           dialogId + 'Dialog'
        , style:        'width:400px;'
        , href:         attr.get(holder, 'href')
        , onMouseLeave: function() {
            popup.close(artDialog);
          }
        });
    on(targetDom, 'mouseover', function() {
      popup.open({
        popup:  artDialog
      , around: targetDom
      , orient: orient
      });
    });
    on(targetDom, 'mouseleave', function() {
      popup.close(artDialog);
    });
  });
}

setHrefTooltip('photo_davaz',    'davaz',      'art',        ['below-alt']);
setHrefTooltip('pic_bottleneck', 'bottleneck', 'bottleneck', ['below-alt']);
