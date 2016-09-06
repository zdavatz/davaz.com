// Adds new element for admin
//   * /personal/work
//   * /communication/news
//   * /communication/links
function addNewElement(url) {
  require([
    'dojo/dom'
  , 'dojo/_base/xhr'
  , 'dijit/layout/ContentPane'
  , 'dojo/domReady!'
  ], function(dom, xhr, cpane) {
    xhr.get({
      url:       url,
      handleAs: 'text',
      load:      function(data, request) {
        var container = dom.byId('element_container');
        var div = document.createElement('div');
        container.insertBefore(div,container.firstChild);
        var pane = new cpane({
          executeScripts: true
        }, div);
        pane.setContent(data);
        pane.startup();
      },
    });
  });
}

// Displays ticker widget
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
    if (display === 'none' || display === '' || display == undefined) {
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

// Checks removable states
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
            link.style.color = 'blue';
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

// Adds new element {serie|tool|material}
function addElement(inputSelect, url, value, addFormId, removeLinkId) {
  require([
    'dojo/dom'
  , 'dojo/dom-attr'
  ], function(dom, attr) {
    url += value;
    // NOTE:
    //   htmlgrid does not provide way to set id attribute for container
    //   element in composite (CSS_ID_MAP is a config for inner component).
    //   Therefore id attribute is needed to be set at here.
    klass = attr.get(inputSelect.parentNode, 'class');
    klass = klass.replace(' dijitContentPane', '');
    attr.set(inputSelect.parentNode, 'id', klass);
    return toggleInnerHTML(inputSelect.parentNode.id, url, '', function() {
      var form = dom.byId(addFormId);
      form.innerHTML = '&nbsp;';
      var removeLink = dom.byId(removeLinkId);
      removeLink.style.color = 'blue';
      toggleInnerHTML(addFormId, 'null');
    });
  });
}

// Removes element {serie|tool|material}
function removeElement(inputSelect, url, removeLinkId) {
  require([
    'dojo/dom'
  , 'dojo/dom-attr'
  ], function(dom, attr) {
    url += inputSelect.value;
    // See NOTE at addElement
    klass = attr.get(inputSelect.parentNode, 'class');
    klass = klass.replace(' dijitContentPane', '');
    attr.set(inputSelect.parentNode, 'id', klass);
    return toggleInnerHTML(inputSelect.parentNode.id, url, '', function() {
      var removeLink = dom.byId(removeLinkId);
      removeLink.style.color = 'grey';
    });
  });
}

// Toggles content with response of ajax request
//   * input widgets {serie|tool|material}
//   * movies
function toggleInnerHTML(divId, url, changeUrl, callback) {
  require([
    'dojo/_base/xhr'
  , 'dojo/back'
  , 'dojo/dom'
  , 'dojo/dom-attr'
  , 'dojo/dom-construct'
  , 'dijit/dijit'
  , 'dijit/layout/ContentPane'
  , 'dojo/domReady!'
  ], function(xhr, back, dom, attr, cnst, dijit, cpane) {
    var fragmentidentifier = '';
    if (changeUrl) {
      fragmentidentifier = changeUrl;
    }
    var node = dom.byId(divId)
      , wdgt = dijit.byId(divId)
      ;
    if (url == 'null' || // cancel
        wdgt != null) {  // re:click
      var container = node.parentNode;
      if (wdgt && wdgt.id) {
        wdgt.destroy();
        cnst.destroy(wdgt.id);
      }
      var tag;
      var select = String(divId).match(/container/);
      if (select) {
        tag = 'td';
      } else {
        tag = 'div';
      }
      // re:create node as new one
      node = cnst.create(tag);
      attr.set(node, 'id', divId);
      cnst.place(node, container);
      // form for artobject
      if (!select && String(divId).match(/serie|tool|material/)) {
        return;
      }
    }
    document.body.style.cursor = 'progress';
    xhr.get({
      url:      url
    , handleAs: 'text'
    , load:     function(data, request) {
        var pane = new cpane({
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

// Shows movie detail view using replaceDiv
function showMovieGallery(divId, replaceDivId, url) {
  require([
    'dojo/_base/xhr'
  , 'dojo/dom'
  , 'dojo/dom-attr'
  , 'dojo/back'
  , 'dijit/dijit'
  , 'dijit/layout/ContentPane'
  ], function(xhr, dom, attr, back, dijit, cpane) {
	  var node = dom.byId(divId);
    if (node.style.display == 'none') {
	    var artobjectId = url.split('/').pop();
      xhr.get({
        url:      url
      , handleAs: 'text'
      , load:      function(data, request) {
          var pane = dijit.byId(divId);
          if (pane == null) {
            pane = new cpane({
              id:             divId
            , executeScripts: true
            }, node);
          }
          pane.setContent(data);
          replaceDiv(replaceDivId, divId);
          back.addToHistory({
            changeUrl: artobjectId
          });
        },
      });
    } else {
      replaceDiv(divId, replaceDivId);
      node.innerHTML = '';
    }
  });
}

// Replaces with wipe animation
function replaceDiv(id, replaceId) {
  require([
    'dojo/dom'
  , 'dojo/fx'
  ], function(dom, fx) {
    var node    = dom.byId(id)
      , replace = dom.byId(replaceId)
      ;
    var callback = function() {
      fx.wipeIn({
        node:     replace
      , duration: 100
      }).play();
    };
    fx.wipeOut({
      node:     node
    , duration: 1000
    , onEnd:    callback
    }).play();
  });
}

// Toggles show widgets {rack|slide|desk}
function toggleShow(id, url, view, replaceId, serieId, artobjectId) {
  require([
    'dojo/_base/window'
  , 'dojo/_base/xhr'
  , 'dojo/parser'
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
  ], function(win, xhr, parser, dom, attr, cnst, query, fx, back, dijit) {
    var wrapper   = dom.byId(replaceId)
      , container = dom.byId(id + '_container')
      ;

    if (attr.get(wrapper, 'data-toggle-action') == 'true') {
      return;
    }
    // prevents multiple clicks
    attr.set(wrapper, 'data-toggle-action', 'true');

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
          lastSerieLink.className =
            lastSerieLink.className.replace(/ ?active/, '');
        }
      }
    }
    if (view === null) {
      if (wdgt) {
        view = wdgt.view;
      } else  { // default widget
        view = 'rack';
      }
    }
    var reuse = false; // reuse widget without ajax
    if (url === null && wdgt) {
      reuse = true;
      url = lastUrl;
    }
    if (serieId === null && wdgt) {
      serieId = wdgt.serieId;
    }
    var type = view.toLowerCase();

    var flag = type.charAt(0).toUpperCase() + view.slice(1);
    var anchor = flag + '_' + serieId;
    if (artobjectId) {
      anchor = anchor + '_' + artobjectId;
    }

    var loadWidget = function(type, url, anchor, container, callback) {
      var data      = {dataUrl: url, anchor: anchor}
        , domNode   = win.doc.createElement('div')
        ;
      switch (type) {
      case 'slide':
        var wdgt = new ywesee.widget.slide(data, domNode);
        break;
      case 'desk':
        var wdgt = new ywesee.widget.desk(data, domNode);
        break;
      default:
        var wdgt = new ywesee.widget.rack(data, domNode);
      }
      wdgt.startup();
      wdgt.placeAt(container);
      // change color of active link to black
      if (serieLink != null && !serieLink.className.match(/ ?active/)) {
        serieLink.className += ' active';
      }
      back.addToHistory({
        changeUrl: anchor
      });
      callback.call();
    };

    if (wdgt) {
      fx.wipeOut({
        node:     container
      , duration: 1200
      , onEnd: function() {
          var container = wdgt.domNode.parentNode
            , current   = wdgt.view
            ;
          // wipeIn animation callback
          var callback = function() {
            setTimeout(function() {
              var style = container.style.display;
              if (style === '' || style === 'none') {
                fx.wipeIn({
                  node:     container
                , duration: 800
                , onEnd: function() {
                    attr.set(wrapper, 'data-toggle-action', 'false');
                  }
                }).play();
              }
            }, 3);
          }

          if (type == current && reuse) { // same as current widget
            callback.call();
          } else {
            // destroy current widget
            // NOTE: this might remains widgt in registry :'(
            wdgt.destroy(true);
            cnst.destroy(wdgt.id);
            wdgt = null;

            loadWidget.call(this, type, url, anchor, container, callback);
          }
        }
      }).play();
    } else { // initialize
      container.innerHTML = '';
      loadWidget.call(this, type, url, anchor, container, function() {
        attr.set(wrapper, 'data-toggle-action', 'false');
      });
    }
  });
}

// Displays login form
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
    }, newDiv);
    login.startup();
  });
}

// Makes tooltips
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
          id:           dialogId + '_dialog'
        , style:        'width: 400px;'
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

// Show/Hides hidden div using fx wipe animation
function toggleHiddenDiv(divId) {
  require([
    'dojo/fx'
  , 'dojo/dom'
  , 'dojo/dom-style'
  , 'dojo/domReady!'
  ], function(fx, dom, styl) {
    var node = dom.byId(divId);
    var display = node.style.display;
    if (display === 'none' || display === '' || display == undefined) {
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
  });
}

// Uploads as using iframe
//   * /works/drawings etc.
function submitForm(form, dataDivId, formDivId, keepForm) {
  require([
    'dojo/dom'
  , 'dojo/io/iframe'
  , 'dojo/_base/xhr'
  ], function(dom, iframe, xhr) {
    var formDiv = dom.byId(formDivId);
    var dataDiv = dom.byId(dataDivId);
    document.body.style.cursor = 'progress';
    iframe.send({
      url:       form.action
    , form:      form
    , handleAs: 'html'
    , load:      function(data, request) {
        if (dataDiv) {
          dataDiv.innerHTML = data.body.innerHTML;
        }
        if (!keepForm) {
          formDiv.innerHTML = '';
        }
        document.body.style.cursor = 'auto';
      },
    });
  });
}

// Upload as using iframe
//   * /works/drawings etc.
function deleteImage(url, image_div_id) {
  require([
    'dojo/dom'
  , 'dojo/_base/xhr'
  ], function(dom, xhr) {
    var image_div = dom.byId(image_div_id);
    xhr.get({
      url:      url
    , handleAs: 'text'
    , load:     function(type, data, event) {
        image_div.innerHTML = '';
      },
    });
  })
}

// This is used at shopping cart
function jumpTo(nodeId) {
	document.location.hash = nodeId;
}

// Changes as logged out
function logout(link) {
	var hash = document.location.hash;
	var href = link.href + 'fragment/' + hash.replace(/#/, '');
	link.href = href;
}

// Changes panorama view
function togglePanorama(url) {
  require([
    'dojo/dom'
  , 'dojo/domReady!'
  ], function(dom) {
    var frame = dom.byId('panorama_frame');
    frame.src = url;
  });
}

//
//
//

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
