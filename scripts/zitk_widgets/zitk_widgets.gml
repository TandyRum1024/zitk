/*
	ZITK: UI Widggets
*/

/// @func zitk_text(*_x, *_y, _str, *_col=global.zitkColLabel, *_alpha=1, *_rot=0, *_scale_x=1, *_scale_y=1)
/// @desc Draws text
function zitk_text (_x, _y, _str, _col=global.zitkColLabel, _alpha=1, _rot=0, _scale_x=1, _scale_y=1) {
	var _sz = global.zitkTextSize;
	_scale_x *= _sz;
	_scale_y *= _sz;
	var _xx = _x ?? UI_LAYOUT_X, _yy = _y ?? UI_LAYOUT_Y,
		_w = _scale_x * string_width(_str),
		_h = _scale_y * string_height(_str);
	
	// Update cursor
	var _pos = zitk_layout_increment_cursor(_xx, _yy, _w, _h);
	_xx = _pos[0]; _yy = _pos[1];
	
	// Draw text
	draw_set_halign(0); draw_set_valign(0);
	zitk_draw_text(_xx, _yy, _str, _scale_x, _scale_y, _rot, _col, _alpha); // text
}

#region Buttons
/// @func zitk_buttonbehaviour(_x, _y, _id, _wid, _hei, _ignore=false)
/// @desc Button behaviour; Returns array containing [_state_hover, _state_hold, _state_click, _state_trans, _state_trans2] flag, Mostly used internally for button widgets.
function zitk_buttonbehaviour (_x, _y, _id, _wid, _hei, _ignore=false) {
	//zitk_draw_rect_wire(_x, _y, _wid, _hei, c_lime, 0.5);
	// Update button state
	var _state = _ignore ? ([false, false, false, 0, 0]) : (global.zitkStateButtons[$ _id] ?? [false, false, false, 0, 0]); // query cache with ID with default values
	var _state_hover = !_ignore && point_in_rectangle(UI_INPUT_X, UI_INPUT_Y, _x, _y, _x+_wid, _y+_hei),
		_state_hold = _state[1],
		_state_click = false,
		_state_trans = _state[3], _state_trans2 = _state[4];

	if (_state_hover) // Is hovering?
	{
		global.zitkStateCurrentHoverItem = _id;
		if (global.zitkInput1Press) // And clicked on it?
		{
			global.zitkStateCurrentHoldItem = _id;
			global.zitkInputXOff = UI_INPUT_X - _x;
			global.zitkInputYOff = UI_INPUT_Y - _y;
			_state_hold = true;
			_state_trans = 1;
		}
		else // Hovering transition counter
		{
			_state_trans = min(_state_trans + 1 / 15, 1);
			_state_trans2 = min(_state_trans2 + 1 / 15, 1);
		}
	}
	else // Hovering end transition counter
	{
		_state_trans = max(_state_trans - 1 / 15, 0);
		if (!_state_hold)
			_state_trans2 = max(_state_trans2 - 1 / 15, 0);
	}
	
	if (!global.zitkInput1Hold) // Released; Reset hold
	{
		if (_state_hold && _state_hover)
			_state_click = true;
		else
			_state_click = false;
		
		if (_state_hold)
		{
			global.zitkStateCurrentHoverItem = undefined;
			global.zitkStateCurrentHoldItem = undefined;
			global.zitkInputXOff = 0;
			global.zitkInputYOff = 0;
		}
		_state_hold = false;
	}
	
	var _state = [_state_hover, _state_hold, _state_click, _state_trans, _state_trans2];
	global.zitkStateButtons[$ _id] = _state;
	return _state;
}

/// @func zitk_button(*_x, *_y, _str="DISPLAY|ID", *_wid=[-4;auto_margin_4px], *_hei=[-4;1em_margin_4px])
/// @desc Button with text; Returns 'on clicked' flag. Set _x and _y to undefined for auto-layout.
function zitk_button (_x, _y, _str, _wid=-4, _hei=-4) {
	var _tag = zitk_tag_separate(_str), _label = _tag[0], _id = _tag[1], _sz = global.zitkTextSize;
	var _xx = _x ?? UI_LAYOUT_X, _yy = _y ?? UI_LAYOUT_Y,
		_w = _wid > 0 ? _wid : _sz * string_width(_label) - (_wid << 1),
		_h = _hei > 0 ? _hei : _sz * UI_EM - (_hei << 1);
	
	// Update cursor
	var _pos = zitk_layout_increment_cursor(_xx, _yy, _w, _h);
	_xx = _pos[0]; _yy = _pos[1];
	
	// Update button state
	var _state = zitk_buttonbehaviour(_xx, _yy, _id, _w, _h),
		_state_hover = _state[0], _state_hold = _state[1], _state_click = _state[2], _state_ctr = 1.0 - power(1.0 - _state[3], 3.0);
	
	// Draw button
	var _backdrop_col = _state_click ? global.zitkColButtonClick : // on click
						(_state_hold ? merge_color(global.zitkColButtonHold, global.zitkColButtonClick, _state_ctr) : // on click | hold
						(_state_hover ? merge_color(global.zitkColButton, global.zitkColButtonHover, _state_ctr) : global.zitkColButton)); // on hover | normal
	draw_set_halign(1); draw_set_valign(1);
	// (backdrop)
	zitk_draw_rect(_xx, _yy, _w, _h, _backdrop_col, 1);
	var _tx = floor(_xx + (_w >> 1)), _ty = floor(_yy + (_h >> 1));
	// (text)
	zitk_draw_text_shadow(_tx, _ty, _label, _sz, _sz, 0, global.zitkColLabel, 1, c_black);
	return _state_click;
}

/// @func zitk_button_sprite(*_x, *_y, _str="DISPLAY|ID", _spr, *_spr_subimg=image_index, *_spr_scale=1, *_rot=0, *_col=c_white, *_alpha=1, *_wid=[-4;auto_margin_4px], *_hei=[-4;auto_margin_4px], *_sprite_mode=[0;ignore_size|1;scale_to_fit|2;stretch_to_fit], *_sprite_align_h=[0|1|2], *_sprite_align_v=[0|1|2], *_draw_backdrop=false)
/// @desc Button with sprite (and optional text); _spr can be either a single sprite, or array of sprite containing: [normal, hover, hold]. Text is aligned within button by current text align. Returns 'on clicked' flag. Set _x and _y to undefined for auto-layout.
function zitk_button_sprite (_x, _y, _str, _spr, _spr_subimg=image_index, _spr_scale=1, _rot=0, _col=c_white, _alpha=1, _wid=-4, _hei=-4, _sprite_mode=0, _sprite_align_h=0, _sprite_align_v=0, _draw_backdrop=false) {
	var _tag = zitk_tag_separate(_str), _label = _tag[0], _id = _tag[1], _sz = global.zitkTextSize;
	var _xx = _x ?? UI_LAYOUT_X, _yy = _y ?? UI_LAYOUT_Y,
		_w = _wid > 0 ? _wid : _sz * string_width(_label) - (_wid << 1),
		_h = _hei > 0 ? _hei : _sz * UI_EM - (_hei << 1);
	
	// Update cursor
	var _pos = zitk_layout_increment_cursor(_xx, _yy, _w, _h);
	_xx = _pos[0]; _yy = _pos[1];
	
	// Update button state
	var _state = zitk_buttonbehaviour(_xx, _yy, _id, _w, _h),
		_state_hover = _state[0], _state_hold = _state[1], _state_click = _state[2], _state_ctr = 1.0 - power(1.0 - _state[3], 3.0);
	
	// Draw button
	// (backdrop)
	if (_draw_backdrop)
	{
		var _backdrop_col = _state_click ? global.zitkColButtonClick : // on click
							(_state_hold ? merge_color(global.zitkColButtonHold, global.zitkColButtonClick, _state_ctr) : // on click | hold
							(_state_hover ? merge_color(global.zitkColButton, global.zitkColButtonHover, _state_ctr) : global.zitkColButton)); // on hover | normal
		zitk_draw_rect(_xx, _yy, _w, _h, _backdrop_col, 1);
	}
	// (sprite)
	if (is_array(_spr))
		_spr = _spr[_state_hold ? 2 : (_state_hover ? 1 : 0)]; // decide sprite from array of sprites and button state
	var _spr_xoff = sprite_get_xoffset(_spr), _spr_yoff = sprite_get_yoffset(_spr),
		_spr_w = sprite_get_width(_spr), _spr_h = sprite_get_height(_spr),
		_spr_xs = _spr_scale, _spr_ys = _spr_scale, _spr_x = _xx, _spr_y = _yy;
	// (calculate sprite stretch mode)
	switch (_sprite_mode)
	{
		case 0: // normal scale
			_spr_x = _xx + _spr_xoff*_spr_xs + lerp(0, _w - _spr_w*_spr_xs, _sprite_align_h * 0.5);
			_spr_y = _yy + _spr_yoff*_spr_ys + lerp(0, _h - _spr_h*_spr_ys, _sprite_align_v * 0.5);
			break;
		case 1: // scale to fit
			_spr_xs = min(_w / _spr_w, _h / _spr_h) * _spr_scale;
			_spr_ys = _spr_xs;
			_spr_x = _xx + _spr_xoff*_spr_xs + lerp(0, _w - _spr_w*_spr_xs, _sprite_align_h * 0.5);
			_spr_y = _yy + _spr_yoff*_spr_ys + lerp(0, _h - _spr_h*_spr_ys, _sprite_align_v * 0.5);
			break;
		case 2: // stretch to fit
			_spr_xs = _w / _spr_w * _spr_scale;
			_spr_ys = _h / _spr_h * _spr_scale;
			// ignore sprite align settings
			_spr_x = _xx + (_w >> 1) + (_spr_xoff - _spr_w*0.5)*_spr_xs;
			_spr_y = _yy + (_h >> 1) + (_spr_yoff - _spr_h*0.5)*_spr_ys;
			break;
	}
	draw_sprite_ext(_spr, _spr_subimg, _spr_x, _spr_y, _spr_xs, _spr_ys, _rot, _col, _alpha);
	// (text)
	if (_label != "")
	{
		var _ha = draw_get_halign(), _va = draw_get_valign();
		draw_set_halign(_ha); draw_set_valign(_va);
		var _tx = floor(_xx + 4 + ((_w-8) * (_ha * 0.5))), _ty = floor(_yy + 4 + ((_h-8) * (_va * 0.5)));
		zitk_draw_text_shadow(_tx, _ty, _label, _sz, _sz, 0, global.zitkColLabel, 1, c_black);
	}
	
	//zitk_draw_rect_wire(_xx, _yy, _w, _h, c_lime, 0.5);
	return _state_click;
}
#endregion

/// @func zitk_slider_h(*_x, *_y, _str="DISPLAY|ID", _val=0, _val_min=0, _val_max=1, *_wid=[-4;auto_margin_4px], *_hei=[-4;1em_margin_4px])
/// @desc Horizontal slider with text; Returns current value of slider. Set _x and _y to undefined for auto-layout.
function zitk_slider_h (_x, _y, _str, _val=0, _val_min=0, _val_max=1, _wid=-4, _hei=0) {
	var _tag = zitk_tag_separate(_str), _label = _tag[0], _id = _tag[1], _sz = global.zitkTextSize;
	var _xx = _x ?? UI_LAYOUT_X, _yy = _y ?? UI_LAYOUT_Y,
		_str_w = _sz * string_width(_label), _str_h = _sz * UI_EM,
		_slider_w = _wid > 0 ? _wid : (UI_LAYOUT_W - _str_w - (_xx - UI_LAYOUT_X1) - 8) + (_wid << 1),
		_slider_h = _hei > 0 ? _hei : _str_h - (_hei << 1);
	
	// Update cursor
	var _pos = zitk_layout_increment_cursor(_xx, _yy, _str_w + _slider_w + 4, max(_slider_h, _str_h));
	_xx = _pos[0]; _yy = _pos[1];
	var _slider_x = _xx + _str_w - _wid + 8, _slider_y = _yy + (_str_h >> 1);
	
	// Update marker/button state for slider
	var _slider_state = global.zitkStateSliders[$ _id] ?? 0, // query cache with ID with default values
		_slider_interp = ((_val - _val_min) / (_val_max - _val_min)),
		_slider_pos_x = _slider_x + _slider_w * _slider_interp,
		_slider_marker_x = _slider_pos_x - (UI_SLIDER_MARKER_W >> 1),
		_slider_hover = point_in_rectangle(UI_INPUT_X, UI_INPUT_Y, _slider_x, _yy, _slider_x+_slider_w, _yy+_slider_h),
		_slider_hover_ctr;
	var _btn_state = zitk_buttonbehaviour(_slider_marker_x, _yy, _id, UI_SLIDER_MARKER_W, _slider_h),
		_state_hover = _btn_state[0], _state_hold = _btn_state[1], _state_click = _btn_state[2],
		_state_ctr1 = 1.0 - power(1.0 - _btn_state[3], 3.0), _state_ctr2 = 1.0 - power(1.0 - _btn_state[4], 3.0);
	
	// Update slider
	if (_slider_hover)
	{
		_slider_state = min(_slider_state + 1 / 15, 1);
		
		global.zitkStateCurrentHoverItem = _id;
		if (!_state_hold && global.zitkInput1Press) // instant jump
		{
			global.zitkStateCurrentHoldItem = _id;
			global.zitkInputXOff = UI_SLIDER_MARKER_W >> 1;
			global.zitkInputYOff = UI_INPUT_Y - _yy;
			var _state = [true, true, true, 1, 1];
			global.zitkStateButtons[$ _id] = _state;
			
			_state_hold = true;
		}
	}
	else
	{
		_slider_state = max(_slider_state - 1 / 15, 0);
	}
	_slider_hover_ctr = 1.0 - power(1.0 - _slider_state, 3.0);
	global.zitkStateSliders[$ _id] = _slider_state;
	
	if (_state_hold && global.zitkStateCurrentHoldItem == _id)
	{
		_slider_interp = clamp(((UI_INPUT_X - global.zitkInputXOff + (UI_SLIDER_MARKER_W >> 1)) - _slider_x) / _slider_w, 0, 1);
		_val = _slider_interp * (_val_max - _val_min) + _val_min;
	}
	
	var _hover_ctr = max(_state_ctr2, _slider_hover_ctr);
	
	// Draw slider
	// (label)
	draw_set_halign(0); draw_set_valign(0);
	zitk_draw_text_shadow(_xx, _yy, _label, _sz, _sz, 0, global.zitkColLabel, 1, c_black);
	// (slider 'track')
	var _slider_track_h = 4 + 8 * _hover_ctr,
		_slider_track_y = _slider_y - (_slider_track_h * 0.5);
	zitk_draw_rect(_slider_x, _slider_track_y, _slider_w, _slider_track_h, global.zitkColSliderBackdrop, 1);
	zitk_draw_rect(_slider_x, _slider_track_y, _slider_w * _slider_interp, _slider_track_h, global.zitkColButtonClick, 0.25 + _slider_interp);
	zitk_draw_rect_wire(_slider_x, _slider_track_y, _slider_w, _slider_track_h, global.zitkColSliderOutline, 1);
	
	// Draw slider marker/button
	var _backdrop_col = _state_click ? global.zitkColButtonClick : // on click
						(_state_hold ? merge_color(global.zitkColButtonHover, global.zitkColButtonClick, _state_ctr1) : // on click | hold
						(_state_hover ? merge_color(global.zitkColButton, global.zitkColButtonHover, _state_ctr1) : global.zitkColButton)); // on hover | normal
	// (marker)
	var _marker_draw_w = UI_SLIDER_MARKER_W, _marker_draw_point_w = _marker_draw_w*0.70710678118,
		_marker_draw_h = _slider_h + 8 * _state_ctr2 - _marker_draw_point_w * 0.5,
		_marker_draw_x = _slider_pos_x - (_marker_draw_w * 0.5);
	zitk_draw_rect(_marker_draw_x-1, _yy, _marker_draw_w+2, _marker_draw_h, c_black, 1);
	zitk_draw_rect_rot(_slider_pos_x-1, _yy+1+_marker_draw_h, _marker_draw_point_w, _marker_draw_point_w, 45, c_black, 1);
	zitk_draw_rect(_marker_draw_x+4, _yy+4, _marker_draw_w, _marker_draw_h, c_black, 1);
	zitk_draw_rect_rot(_slider_pos_x+4, _yy+4+_marker_draw_h, _marker_draw_point_w, _marker_draw_point_w, 45, c_black, 1);
	
	zitk_draw_rect(_marker_draw_x, _yy, _marker_draw_w, _marker_draw_h, _backdrop_col, 1);
	zitk_draw_rect_rot(_slider_pos_x, _yy+_marker_draw_h, _marker_draw_point_w, _marker_draw_point_w, 45, _backdrop_col, 1);
	
	// (text)
	if (_hover_ctr > 0)
	{
		var _tx = (_slider_pos_x), _ty = (_yy - 4 * _hover_ctr), _ty2 = _yy + (_str_h >> 1);
		
		zitk_draw_textbox_outline(_slider_x, _ty, -4, -2, string(_val_min), global.zitkColSliderBackdrop, global.zitkColSliderHint, _hover_ctr, _sz, 0, 2);
		zitk_draw_textbox_outline(_slider_x+_slider_w, _ty, -4, -2, string(_val_max), global.zitkColSliderBackdrop, global.zitkColSliderHint, _hover_ctr, _sz, 2, 2);
		
		draw_set_halign(1); draw_set_valign(2);
		zitk_draw_text_shadow(_tx, _ty, string(_val), _sz, _sz, 0, global.zitkColLabel, _hover_ctr, c_black);
		
		//draw_set_halign(1); draw_set_valign(2);
		//zitk_draw_text_shadow(_slider_x, _ty, string(_val_min), _sz, _sz, 0, global.zitkColSliderHint, _hover_ctr*0.5, c_black);
		//zitk_draw_text_shadow(_slider_x+_slider_w, _ty, string(_val_max), _sz, _sz, 0, global.zitkColSliderHint, _hover_ctr*0.5, c_black);
		
		if (!_state_hold)
		{
			var _preview_interp = clamp(((UI_INPUT_X - global.zitkInputXOff + (UI_SLIDER_MARKER_W >> 1)) - _slider_x) / _slider_w, 0, 1);
			zitk_draw_text_shadow(UI_INPUT_X, _ty, string(_preview_interp * (_val_max - _val_min) + _val_min), _sz, _sz, 0, global.zitkColLabel, _hover_ctr * 0.5, c_black);
		}
	}
	return _val;
}