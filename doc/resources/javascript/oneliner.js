var type = "IE";

BrowserSniffer();

function BrowserSniffer() {
	if (navigator.userAgent.indexOf("Opera")!=-1 && document.getElementById) type="OP";
	else if (document.all) type="IE";
	else if (document.layers) type="NN";
	else if (!document.all && document.getElementById) type="MO";
	else type = "IE";
}

function ChangeContent(id, str) {
	if (type=="IE") {
		document.all[id].innerHTML = str;
	}
	if (type=="NN") { 
		document.layers[id].document.open();
		document.layers[id].document.write(str);
		document.layers[id].document.close();
	}
	if (type=="MO" || type=="OP") {
		document.getElementById(id).innerHTML = str;
	}
}

function ChangeLayerFontColor(id, color){
	if (type=="IE") document.all[id].style.color=color;
	if (type=="NN") document.layer['id'].color=color;
	if (type=="MO" || type=="OP") document.getElementById(id).style.color=color;
}

function whatBrows() {
	window.alert("Browser is : " + type);
}

var current=-1;
var messages=new Array();
var colors=new Array();

function TimeOut(){
	current++ 
	if (current >= messages.length) { 
		current = 0;
	} 
	ChangeLayerFontColor('oneliner', colors[current]);
	ChangeContent('oneliner', messages[current]);	
	setTimeout("TimeOut()",3200); 
}
