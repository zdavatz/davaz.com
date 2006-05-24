var type = "IE";

BrowserSniffer();

function BrowserSniffer() {
	if (navigator.userAgent.indexOf("Opera")!=-1 && document.getElementById) type="OP";
	else if (document.all) type="IE";
	else if (document.layers) type="NN";
	else if (!document.all && document.getElementById) type="MO";
	else type = "IE";
}

function ChangeDivContent(id, str) {
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

function ChangeDivBackground(id, image_path){
	if (type=="IE")	
		document.all[id].style.backgroundImage=image_path;
	if (type=="NN")
		document.layer['id'].backgroundImage=image_path;
	if (type=="MO" || type=="OP")
		document.getElementById(id).style.backgroundImage=image_path;
}

function whatBrows() {
	window.alert("Browser is : " + type);
}


var current_slide=-1;
var titles=new Array();
var images=new Array();
var time

function stopScript()
{
	if (time) clearTimeout(time);
}

function SlideshowTimeOut(){
	if (current_slide<titles.length-1) { 
		current_slide++ 
		ChangeDivBackground('slideshow', images[current_slide]);	
		ChangeDivContent('slideshow', titles[current_slide]);	
		time = setTimeout("SlideshowTimeOut()",3200); 
	} else { 
		current_slide=-1 
		SlideshowTimeOut();
	} 
}
