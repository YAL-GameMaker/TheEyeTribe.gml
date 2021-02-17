/// __trace_draw(x, y, w, miny = 0)
var _x = argument[0], _y = argument[1], w = argument[2];
var _miny; if (argument_count > 3) _miny = argument[3]; else _miny = 0;
var l = global.__trace_log, i;
var n = ds_list_size(l);
for (i = 0; i < n; i += 1) {
    var s = l[|i];
    _y -= string_height_ext(s, -1, w);
    draw_text_ext(_x, _y, s, -1, w);
    if (_y < _miny) break;
}
