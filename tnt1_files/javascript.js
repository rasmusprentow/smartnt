
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}


window.onload=function(){
	
	var s = document.createElement("script");
	
	s.type = "text/javascript";
	s.src = "/iis-assets/jquery.ba-postmessage.js";
	document.getElementsByTagName('head')[0].appendChild(s)
	
	var q = document.createElement("script");
	
	q.type = "text/javascript";
	q.src = "/iis-assets/PostenCosIFrameResizer.js";
	document.getElementsByTagName('head')[0].appendChild(q)
	
	var T=setTimeout('PostenCosFrameResizer.autoResize()','400');
	
};



