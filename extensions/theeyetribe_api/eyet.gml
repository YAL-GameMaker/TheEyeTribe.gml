#define eyet_preinit
//#global eyet_is_connected
//#global eyet_init_json
eyet_init_json = '{"values":{"push":true,"version":1},"category":"tracker","request":"set"}';
global.__eyet_socket = -1;
global.__eyet_acc = buffer_create(1024, buffer_grow, 1);
global.__eyet_send = buffer_create(1024, buffer_grow, 1);
global.__eyet_script_connect = -1;
global.__eyet_script_data = -1;
global.__eyet_next_heartbeat = 0;

#define eyet_init
/// (url, port, on_data:script<json_map;json_str>, ?async:bool, ?on_connect:script<success:bool>)
var _url = argument[0], _port = argument[1], _on_data = argument[2];
var _async; if (argument_count > 3) _async = argument[3]; else _async = false;
var _on_connect; if (argument_count > 4) _on_connect = argument[4]; else _on_connect = -1;
if (global.__eyet_socket != -1) network_destroy(global.__eyet_socket);
global.__eyet_socket = network_create_socket(network_socket_tcp);
global.__eyet_script_connect = _on_connect;
global.__eyet_script_data = _on_data;
global.__eyet_next_heartbeat = current_time + 250;
eyet_is_connected = false;
var t = get_timer()
var _ok = network_connect_raw(global.__eyet_socket, _url, _port) >= 0;
if (_ok) {
	if (!_async) {
		eyet_is_connected = true;
		eyet_send(eyet_init_json);
	}
} else {
	network_destroy(global.__eyet_socket);
	global.__eyet_socket = -1;
}
return _ok;

#define eyet_update
/// ()
if (eyet_is_connected) {
	var _now = current_time;
	if (global.__eyet_next_heartbeat <= _now) {
		global.__eyet_next_heartbeat = _now + 250;
		eyet_send('{"category":"heartbeat","request":null}');
	}
}

#define eyet_async
/// ()
if (async_load[?"id"] != global.__eyet_socket) exit;
var _type = async_load[?"type"];
if (_type == network_type_non_blocking_connect) {
	var _ok = async_load[?"succeeded"];
	if (_ok) {
		eyet_is_connected = true;
		eyet_send(eyet_init_json);
	} else {
		network_destroy(global.__eyet_socket);
		global.__eyet_socket = -1;
	}
	var _scr = global.__eyet_script_connect;
	if (_scr != -1) script_execute(_scr, _ok);
	exit;
}
if (_type != network_type_data) exit;
var _size = async_load[?"size"];
var _buf = async_load[?"buffer"];
var _acc = global.__eyet_acc;
for (var i = 0; i < _size; i++) {
	var _byte = buffer_read(_buf, buffer_u8);
	if (_byte == 13) {
		var _at = buffer_tell(_buf);
		if (_at < _size && buffer_peek(_buf, _at, buffer_u8) == 10) {
			buffer_seek(_buf, buffer_seek_relative, 1);
			i += 1;
		}
	} else if (_byte != 10) {
		buffer_write(_acc, buffer_u8, _byte);
		continue;
	}
	buffer_write(_acc, buffer_u8, 0);
	buffer_seek(_acc, buffer_seek_start, 0);
	var _str = buffer_read(_acc, buffer_string);
	var _json = json_decode(_str);
	script_execute(global.__eyet_script_data, _json, _str);
	if (_json != -1) ds_map_destroy(_json);
	buffer_seek(_acc, buffer_seek_start, 0);
}

#define eyet_send
/// (json_string_or_map)
if (!eyet_is_connected) return false;
var _json = argument0;
var _str = is_string(_json) ? _json : json_encode(_json);
var _send = global.__eyet_send;
buffer_seek(_send, buffer_seek_start, 0);
buffer_write(_send, buffer_text, _str);
buffer_write(_send, buffer_u8, 13);
buffer_write(_send, buffer_u8, 10);
return network_send_raw(global.__eyet_socket, _send, buffer_tell(_send));