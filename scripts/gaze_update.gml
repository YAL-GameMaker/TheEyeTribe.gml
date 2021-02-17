/// gaze_update(x, y)
var _x = argument0, _y = argument1;
gaze_raw_x = _x;
gaze_raw_y = _y;
//
var ww = window_get_width();
var wh = window_get_height();
var gw, gh;
if (application_surface_is_enabled()) {
	gw = surface_get_width(application_surface);
	gh = surface_get_height(application_surface);
} else {
	gw = room_width;
	gh = room_height;
}
var gz = min(ww / gw, wh / gh);
var gx = (ww - gw * gz) div 2;
var gy = (wh - gh * gz) div 2;
gaze_x = (_x - window_get_x() - gx) / gz;
gaze_y = (_y - window_get_y() - gy) / gz;