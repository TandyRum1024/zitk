/*
	ZITK: UI Widggets
*/

/// @func zitk_button(_x, _y, _str="DISPLAY|ID", *_wid=[-4;auto_margin_4px], *_hei=[16;4px])
/// @desc Button behaviour; Returns on clicked
function zitk_button (_x, _y, _str, _wid=-4, _hei=-4) {
	var _tag = zitk_tag_separate(_str), _label = _tag[0], _id = _tag[1], _sz = global.zitkTextSize;
	var _w = _wid > 0 ? _wid : _sz * string_width(_label) - (_wid<<1),
		_h = _hei > 0 ? _hei : _sz * UI_EM - (_hei<<1);
	// Update button state
	var _state = global.zitkStateButtons[$ _id] ?? [false, false, false]; // query cache with ID, default being all false
	var _state_hover = point_in_rectangle(global.zitkInputX, global.zitkInputY, _x, _y, _x+_w, _y+_h),
		_state_hold = _state[1],
		_state_click = false;
	
	if (_state_hover)
	{
		if (global.zitkInput1Press)
			_state_hold = true;
	}
	if (global.zitkInput1Release) // Reset hold
	{
		if (_state_hold)
		{
			_state_hold = false;
			_state_click = true;
		}
	}
	global.zitkStateButtons[$ _id] = [_state_hover, _state_hold, _state_click];
	
	// Draw button
	// (debug)
	//_label += "(id: " + _id + ")";
	var _backdrop_col = _state_click ? global.zitkColButtonClick : (_state_hold ? zitk_colour_add(global.zitkColButton, -50) : (_state_hover ? zitk_colour_add(global.zitkColButton, 50) : global.zitkColButton));
	draw_set_halign(1); draw_set_valign(1);
	zitk_draw_rect(_x, _y, _w, _h, _backdrop_col, 1); // backdrop
	zitk_draw_text(_x + (_w >> 1) + 1, _y + (_h >> 1) + 1, _label, _sz, _sz, 0, 0, 1); // text shadow
	zitk_draw_text(_x + (_w >> 1), _y + (_h >> 1), _label, _sz, _sz, 0, global.zitkColLabel, 1); // text
	return _state_click;
}
