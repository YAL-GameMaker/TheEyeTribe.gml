/// trace(...)
var r = "";
for (var i = 0; i < argument_count; i++) {
	r += string(argument[i]) + " ";
}
show_debug_message(r);

var l = global.__trace_log;
ds_list_insert(l, 0, r);
var n = ds_list_size(l);
if (n > global.__trace_limit) ds_list_delete(l, n - 1);
