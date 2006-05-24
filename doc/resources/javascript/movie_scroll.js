//var clipTop = 0;
//var clipWidth = 700;
//var clipBottom = 250;
//var topper = 300;
//var lyrheight = 0;

var clipLeft = 0;
var clipRight = 700;
var clipHeight = 330;
var lefter = 20;
//var lyrwidth = 220;
var time,amount,theTime,theHeight,DHTML;


function init()
{
	DHTML = (document.getElementById || document.all || document.layers)
		if (!DHTML) return;
	var x = new getObj('divMovies');
	if (document.layers)
	{
		//lyrwidth = x.style.clip.right;
		//lyrwidth += 20;
		x.style.clip.top = 0;
		x.style.clip.left = clipLeft;
		x.style.clip.right = clipRight;
		x.style.clip.bottom = clipHeight;
	}
	else if (document.getElementById || document.all)
	{
		//lyrwidth = x.obj.offsetWidth;
		x.style.clip = 'rect(0,'+clipRight+'px,'+clipHeight+'px,'+clipLeft+'px)';
	}
}

function scrollayer(layername,amt,tim)
{
	if (!DHTML) return;
	thelayer = new getObj(layername);
	if (!thelayer) return;
	amount = amt;
	theTime = tim;
	realscroll();
}

function realscroll()
{
	if (!DHTML) return;
	clipLeft += amount;
	clipRight += amount;
	lefter -= amount;
	
	if (clipLeft < 0 || clipRight > lyrwidth)
	{
		clipLeft -= amount;
		clipRight -= amount;
		lefter += amount;
		return;
	}
	if (document.getElementById || document.all)
	{
		clipstring = 'rect(0,'+clipRight+'px,'+clipHeight+'px,'+clipLeft+'px)';
		thelayer.style.clip = clipstring;
		thelayer.style.left = lefter + 'px';
	}
	else if (document.layers)
	{
		thelayer.style.clip.left = clipLeft;
		thelayer.style.clip.right = clipRight;
		thelayer.style.left = lefter;
	}
	time = setTimeout('realscroll()',theTime);
}

function stopScroll()
{
	if (time) clearTimeout(time);
}

function getObj(name)
{
	if (document.getElementById)
	{
		this.obj = document.getElementById(name);
		this.style = document.getElementById(name).style;
	}
	else if (document.all)
	{
		this.obj = document.all[name];
		this.style = document.all[name].style;
	}
	else if (document.layers)
	{
		if (document.layers[name])
		{
			this.obj = document.layers[name];
			this.style = document.layers[name];
		}
		else
		{
			this.obj = document.layers.testP.layers[name];
			this.style = document.layers.testP.layers[name];
		}
	}
}
