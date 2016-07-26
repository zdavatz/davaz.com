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
  ], function(dom, styl, fx, dijit) {
    var node   = dom.byId('ticker_container')
      , ticker = dijit.byId('ywesee_widget_ticker_0')
      ;
    var display = node.style.display;
    if (display === "none" || display === '' || display == undefined) {
      fx.wipeIn({
        node:     node
      , duration: 300
      , onEnd:    function() {
          styl.set(node, 'display', 'block');
        }
      }).play();
    } else {
      fx.wipeOut({
        node:     node
      , duration: 300
      , onEnd:    function() {
          styl.set(node, 'display', 'none');
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
  require([
    'dojo/_base/xhr'
  , 'dojo/dom'
  , 'dojo/domReady!'
  ], function(xhr, dom) {
    document.body.style.cursor = 'progress';
    xhr.get({
      url:      url + selectValue
    , handleAs: 'json'
    , load:     function(data, request) {
        var status = data.removalStatus
          , link   = dom.byId(data.removeLinkId)
          ;
        if (status == 'goodForRemoval') {
          if (link) {
            linx.style.color = 'blue';
          }
        } else {
          if (link) {
            link.style.color = 'grey';
          }
        }
        document.body.style.cursor = 'auto';
      }
    });
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

// Toggles input widgets {serie|tool|material}
function toggleInnerHTML(divId, url, changeUrl, callback) {
  require([
    'dojo/_base/xhr'
  , 'dojo/back'
  , 'dojo/dom'
  , 'dojo/dom-attr'
  , 'dojo/dom-construct'
  , 'dijit/dijit'
  , 'dojo/domReady!'
  ], function(xhr, back, dom, attr, cnst, dijit) {
    var fragmentidentifier = '';
    if (changeUrl) {
      fragmentidentifier = changeUrl;
    }
    var node = dom.byId(divId)
      , container = node.parentNode
      ;
    if (url == 'null') {
      var wdgt = dijit.byId(divId);
      if (wdgt) {
        wdgt.destroy();
        cnst.destroy(wdgt.id);
      }
      // re:create as new noe
      node = cnst.create('div');
      attr.set(node, 'id', divId);
      cnst.place(node, container);
      return;
    }
    document.body.style.cursor = 'progress';
    xhr.get({
      url:      url
    , handleAs: 'text'
    , load:     function(data, request) {
        var pane = new dijit.layout.ContentPane({
          id:             divId
        , executeScripts: true
        }, node);
        pane.setContent(data);
        if (callback) { callback(); }
        document.body.style.cursor = 'auto';
        back.addToHistory({
          changeUrl: fragmentidentifier
        });
      }
    });
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

// Toggles show widgets {rack|slide|desk}
function toggleShow(id, url, view, replaceId, serieId, artobjectId) {
  require([
    'dojo/_base/xhr'
  , 'dojo/_base/window'
  , 'dojo/dom'
  , 'dojo/dom-attr'
  , 'dojo/dom-construct'
  , 'dojo/query'
  , 'dojo/fx'
  , 'dojo/back'
  , 'dijit/dijit'
  , 'dojo/domReady!'
  , 'ywesee/widget/rack'
  , 'ywesee/widget/slide'
  , 'ywesee/widget/desk'
  ], function(xhr, win, dom, attr, cnst, query, fx, back, dijit) {
    var container = dom.byId(id + '_container');
    if (attr.get(container, 'data-toggle-action') == 'true') {
      return;
    }
    // prevents multiple clicks
    attr.set(container, 'data-toggle-action', 'true');

    var show = query('#' + id + '_container > div')[0]
      , wdgt = dijit.byId(attr.get(show, 'widgetid'))
      ;
    if (wdgt) { // current widget
      var lastUrl = wdgt.dataUrl
        , lastId  = lastUrl.split('/').pop()
        ;
    }
    var serieLink = dom.byId(serieId);
    if (serieId && wdgt) {
      if (lastId != serieId) {
        var lastSerieLink = dom.byId(lastId);
        if (lastSerieLink) {
          lastSerieLink.className = lastSerieLink.className.replace(/ ?active/, '');
        }
      }
    }
    var container = dom.byId(id + '_container')
      , wipearea  = dom.byId(id + '_wipearea')
      , replace   = dom.byId(replaceId)
      ;
    if (view === null) {
      if (wdgt) {
        view = wdgt.view;
      } else  {
        view = 'rack';
      }
    }
    if (url === null && wdgt) {
      url = lastUrl;
    }
    if (serieId === null && wdgt) {
      serieId = wdgt.serieId;
    }
    var type = view.toLowerCase();

    var flag = type.charAt(0).toUpperCase() + view.slice(1);
    var fragmentIdentifier = flag + '_' + serieId;

    if (artobjectId) {
      fragmentIdentifier = fragmentIdentifier + '_' + artobjectId;
    }

    var loadShow = function() {
      xhr.get({
        url:      url
      , handleAs: 'json'
      , load:     function(data, args) {
          if (wdgt) {
            cnst.destroy(wdgt.id);
          }
          var domNode = win.doc.createElement('div');
          switch (type) {
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
          attr.set(container, 'data-toggle-action', 'false');
          // change color of active link to black
          if (serieLink != null && !serieLink.className.match(/ ?active/)) {
            serieLink.className += ' active';
          }
          back.addToHistory({
            changeUrl: fragmentIdentifier
          });
        },
      });
    };

    if (replace && replace.style.display !== 'none') {
      fx.wipeOut({
        node:     replace
      , duration: 1200
      , onEnd:    loadShow
      }).play();
    } else { // initialize
      if (wdgt) {
        loadShow.call();
      } else {
        attr.set(container, 'data-toggle-action', 'false');
      }
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

function toggleLoginForm(loginLink, url) {
  require([
    'dojo/_base/window'
  , 'dojo/domReady!'
  , 'ywesee/widget/login'
  ], function(win) {
    var newDiv = document.createElement('div');
    win.body().appendChild(newDiv);
    loginLink.onclick = 'return false;';
    var login = new ywesee.widget.login({
      loginLink:    loginLink
    , loginFormUrl: url
    , oldOnclick:   loginLink.onclick
    }, newDiv);
    login.startup();
  });
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
