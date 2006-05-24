var toggle_busy = false;
function toggleImageSrc(imageId, url) {
	if(toggle_busy) return;
	var node = dojo.byId(imageId);
	var src_image_id = node.src.split("/").pop();
	var new_image_id = url.split("/").pop();
	if(src_image_id == new_image_id) return;
	toggle_busy = true;
	var callback2 = function() {
		toggle_busy = false;
	}
	var callback1 = function() {
		node.src = url;
		dojo.fx.fadeIn(node, 200, callback2);
	}
	dojo.fx.fadeOut(node, 200, callback1);
}
