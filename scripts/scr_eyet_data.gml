var _json = argument0, _str = argument1;
//trace(_str);
if (_json == -1) exit;
var _values = _json[?"values"];
if (_values == undefined) exit;
var _frame = _values[?"frame"];
if (_frame == undefined) exit;
var _time = _frame[?"time"];
var _point = _frame[?"raw"];
if (_point != undefined) {
	trace(_time, _point[?"x"], _point[?"y"]);
	gaze_update(_point[?"x"], _point[?"y"]);
}
