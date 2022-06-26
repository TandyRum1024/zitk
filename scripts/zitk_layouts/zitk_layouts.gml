/*
	ZITK: Layout & containers
*/

#macro UI_LAYOUTSTATE_BUILD [ \
							global.zitkLayoutRegionX1, \
							global.zitkLayoutRegionY1, \
							global.zitkLayoutRegionX2, \
							global.zitkLayoutRegionY2, \
							global.zitkLayoutDirection, \
							global.zitkLayoutCursorX, \
							global.zitkLayoutCursorY, \
							global.zitkLayoutCurrentMaxX, \
							global.zitkLayoutCurrentMaxY, \
							global.zitkLayoutLineheight, \
							]
#macro UI_LAYOUTSTATE_DEFAULT [0, 0, window_get_width(), window_get_height(), UI_LAYOUT_DIR.RIGHT, 0, 0, 0, 0, 0]
#macro UI_LAYOUTSTATE_ASSIGN global.zitkLayoutRegionX1=_state[0]; \
							global.zitkLayoutRegionY1=_state[1]; \
							global.zitkLayoutRegionX2=_state[2]; \
							global.zitkLayoutRegionY2=_state[3]; \
							global.zitkLayoutDirection=_state[4]; \
							global.zitkLayoutCursorX=_state[5]; \
							global.zitkLayoutCursorY=_state[6]; \
							global.zitkLayoutCurrentMaxX=_state[7]; \
							global.zitkLayoutCurrentMaxY=_state[8]; \
							global.zitkLayoutLineheight=_state[9];

/// @func zitk_layout_set_from(_state_arr)
/// @desc Sets layout state from given array
function zitk_layout_set_from (_state)
{
	UI_LAYOUTSTATE_ASSIGN
}

/// @func zitk_layout_push(_x, _y, _w, _h, _direction=global.zitkLayoutDirection)
/// @desc Begins new layout
function zitk_layout_push (_x, _y, _w, _h, _direction=global.zitkLayoutDirection)
{
	// Push current layout state to stack
	ds_stack_push(UI_LAYOUT_STACK, UI_LAYOUTSTATE_BUILD);
	
	// Debug: show layout region
	if (ZITK_DEBUG_LAYOUT)
		zitk_draw_rect_wire(_x, _y, _w, _h, c_white, 1);
	
	// Set layout state
	global.zitkLayoutDirection = _direction;
	
	global.zitkLayoutRegionX1 = _x;
	global.zitkLayoutRegionY1 = _y;
	global.zitkLayoutRegionX2 = _x + _w;
	global.zitkLayoutRegionY2 = _y + _h;
	global.zitkLayoutRegionW = _w;
	global.zitkLayoutRegionH = _h;
	global.zitkLayoutLineheight = 0;
	//global.zitkLayoutCurrentMaxX = _x;
	//global.zitkLayoutCurrentMaxY = _y;
	
	switch (global.zitkLayoutDirection)
	{
		case UI_LAYOUT_DIR.LEFT:
			UI_LAYOUT_LOCAL_X = 0;
			UI_LAYOUT_LOCAL_Y = 0;
			global.zitkLayoutCursorX = global.zitkLayoutRegionX2;
			global.zitkLayoutCursorY = global.zitkLayoutRegionY1;
			global.zitkLayoutCurrentMaxX = global.zitkLayoutRegionX2;
			global.zitkLayoutCurrentMaxY = global.zitkLayoutRegionY1;
			break;
		case UI_LAYOUT_DIR.RIGHT:
			UI_LAYOUT_LOCAL_X = _w;
			UI_LAYOUT_LOCAL_Y = 0;
			global.zitkLayoutCursorX = global.zitkLayoutRegionX1;
			global.zitkLayoutCursorY = global.zitkLayoutRegionY1;
			global.zitkLayoutCurrentMaxX = global.zitkLayoutRegionX1;
			global.zitkLayoutCurrentMaxY = global.zitkLayoutRegionY1;
			break;
		case UI_LAYOUT_DIR.DOWN:
			UI_LAYOUT_LOCAL_X = 0;
			UI_LAYOUT_LOCAL_Y = 0;
			global.zitkLayoutCursorX = global.zitkLayoutRegionX1;
			global.zitkLayoutCursorY = global.zitkLayoutRegionY1;
			global.zitkLayoutCurrentMaxX = global.zitkLayoutRegionX1;
			global.zitkLayoutCurrentMaxY = global.zitkLayoutRegionY1;
			break;
		case UI_LAYOUT_DIR.UP:
			UI_LAYOUT_LOCAL_X = 0;
			UI_LAYOUT_LOCAL_Y = _h;
			global.zitkLayoutCursorX = global.zitkLayoutRegionX1;
			global.zitkLayoutCursorY = global.zitkLayoutRegionY2;
			global.zitkLayoutCurrentMaxX = global.zitkLayoutRegionX1;
			global.zitkLayoutCurrentMaxY = global.zitkLayoutRegionY2;
			break;
	}
}

/// @func zitk_autolayout(_x, _y, _w, _h, _div, _arr_layout_callbacks, _direction=global.zitkLayoutDirection, _fill_freespace=false, _sizes=undefined, _inner_directions=undefined)
/// @desc Begins auto-layout, which divides given region to (equal) sized sub-regions and sets the layout to region and calls callback function for each regions
function zitk_autolayout (_x, _y, _w, _h, _div, _arr_layout_callbacks, _direction=global.zitkLayoutDirection, _fill_freespace=false, _sizes=undefined, _inner_directions=undefined)
{
	if (!is_array(_arr_layout_callbacks))
		throw "zitk_autolayout::parameter `_arr_layout_callbacks` must be array of layout callback functions!";
	// nothing to draw?
	if (array_length(_arr_layout_callbacks) <= 0)
		return;
	
	zitk_layout_push(_x, _y, _w, _h, _direction);
		// Calculate stuffs
		// (default size/weights)
		var _layout_is_vertical = (_direction == UI_LAYOUT_DIR.UP || _direction == UI_LAYOUT_DIR.DOWN),
			_layout_size = (_direction == UI_LAYOUT_DIR.UP || _direction == UI_LAYOUT_DIR.DOWN) ? _w : _h, _size_sum = [0, 0],
			;
		_sizes ??= [];
		_inner_directions ??= [];
		for (var i=array_length(_sizes); i<array_length(_arr_layout_callbacks); i++)
		{
			var _sz = _fill_freespace ? 1 : _layout_size;
			_sizes[i] = [_sz, _sz];
		}
		for (var i=array_length(_inner_directions); i<array_length(_arr_layout_callbacks); i++)
		{
			_inner_directions[i] = UI_LAYOUT_DIR.RIGHT;
		}
		for (var i=0; i<array_length(_sizes); i++)
		{
			_size_sum[0] += _sizes[i][0];
			_size_sum[1] += _sizes[i][1];
		}
		if (!_fill_freespace || _size_sum == 0) // whoopse
			_size_sum = [1, 1];
		if (_fill_freespace)
			_size_sum = [_size_sum[0] / _layout_is_vertical ? _h : _w, _size_sum[1] / _layout_is_vertical ? _h : _w];
		// Calculate real size of each space
		var _space_w = [], _space_h = [];
		for (var i=0; i<array_length(_arr_layout_callbacks); i++)
		{
			_space_w[i] = _sizes[i][0] / _size_sum[0];
			_space_h[i] = _sizes[i][1] / _size_sum[1];
			/*
			if (_layout_is_vertical)
			{
				_space_w[i] = _layout_size;
				_space_h[i] = _sizes[i] / _size_sum[1];
			}
			else
			{
				_space_w[i] = _sizes[i] / _size_sum[1];
				_space_h[i] = _layout_size;
			}*/
		}
		// (Equally) divide given space and call layout functions for each spaces
		var _xx = _x, _yy = _y;
		for (var i=0; i<array_length(_arr_layout_callbacks); i++)
		{
			var _lay_w = _space_w[i], _lay_h = _space_h[i],
				_pos = zitk_layout_increment_cursor(, , _lay_w, _lay_h, false);
			_xx = _pos[0]; _yy = _pos[1];
			zitk_layout_push(_xx, _yy, _lay_w, _lay_h, _inner_directions[i]);
				_arr_layout_callbacks[i](i, _xx, _yy, _lay_w, _lay_h);
			zitk_layout_pop();
		}
	zitk_layout_pop();
}

function zitk_layout_pop (_update_cursor=false)
{
	// Debug: show layout max region
	if (ZITK_DEBUG_LAYOUT)
	{
		switch (global.zitkLayoutDirection)
		{
			case UI_LAYOUT_DIR.DOWN:
			case UI_LAYOUT_DIR.RIGHT:
				zitk_draw_rect_wire(global.zitkLayoutRegionX1, global.zitkLayoutRegionY1, (global.zitkLayoutCurrentMaxX-global.zitkLayoutRegionX1), (global.zitkLayoutCurrentMaxY-global.zitkLayoutRegionY1), c_lime, 0.5);
				break;
			case UI_LAYOUT_DIR.LEFT:
				zitk_draw_rect_wire(global.zitkLayoutCurrentMaxX, global.zitkLayoutRegionY1, (global.zitkLayoutRegionX2-global.zitkLayoutCurrentMaxX), (global.zitkLayoutCurrentMaxY-global.zitkLayoutRegionY1), c_lime, 0.5);
				break;
			case UI_LAYOUT_DIR.UP:
				zitk_draw_rect_wire(global.zitkLayoutRegionX1, global.zitkLayoutCurrentMaxY, (global.zitkLayoutCurrentMaxX-global.zitkLayoutRegionX1), (global.zitkLayoutRegionY2-global.zitkLayoutCurrentMaxY), c_lime, 0.5);
				break;
		}
	}
	
	// Calculate bounds of previous region
	var _wid = UI_LAYOUT_W, _hei = UI_LAYOUT_H;
	/*
	switch (global.zitkLayoutDirection)
	{
		case UI_LAYOUT_DIR.DOWN:
		case UI_LAYOUT_DIR.RIGHT:
			_wid = (global.zitkLayoutCurrentMaxX - global.zitkLayoutRegionX1);
			_hei = (global.zitkLayoutCurrentMaxY - global.zitkLayoutRegionY1);
			break;
		case UI_LAYOUT_DIR.LEFT:
			_wid = (global.zitkLayoutRegionX2 - global.zitkLayoutCurrentMaxX);
			_hei = (global.zitkLayoutCurrentMaxY - global.zitkLayoutRegionY1);
			break;
		case UI_LAYOUT_DIR.UP:
			_wid = (global.zitkLayoutCurrentMaxX - global.zitkLayoutRegionX1);
			_hei = (global.zitkLayoutRegionY2 - global.zitkLayoutCurrentMaxY);
			break;
	}
	*/
	
	var _has_parent = !ds_stack_empty(UI_LAYOUT_STACK);
	var _state = _has_parent ? ds_stack_pop(UI_LAYOUT_STACK) : UI_LAYOUTSTATE_DEFAULT;
	UI_LAYOUTSTATE_ASSIGN
	UI_LAYOUT_W = UI_LAYOUT_X2 - UI_LAYOUT_X1;
	UI_LAYOUT_H = UI_LAYOUT_Y2 - UI_LAYOUT_Y1;
	
	if (_update_cursor)
	{
		if (_has_parent) // use the API to increment the cursor
			zitk_layout_increment_cursor(, , _wid, _hei, false);
		else
		{
			UI_LAYOUT_X += _wid;
			UI_LAYOUT_Y += _hei;
		}
	}
	
	UI_LAYOUT_LOCAL_X = UI_LAYOUT_X - UI_LAYOUT_X1;
	UI_LAYOUT_LOCAL_Y = UI_LAYOUT_Y - UI_LAYOUT_Y1;
}

/// @func zitk_layout_set_cursor_pos(_x, _y)
/// @desc Sets internal layout write position (cursor)
function zitk_layout_set_cursor_pos (_x, _y)
{
	global.zitkLayoutCursorX = _x;
	global.zitkLayoutCursorY = _y;
}

/// @func zitk_layout_linebreak(*_lineheight=margin)
/// @desc Increments internal layout write position to emulate arbitrary linebreak
function zitk_layout_linebreak (_lineheight)
{
	var _margin_x = _lineheight ?? global.zitkLayoutMarginX, _margin_y = _lineheight ?? global.zitkLayoutMarginY;
	//if (_use_margin)
	//	_margin_x = global.zitkLayoutMarginX; _margin_y = global.zitkLayoutMarginY;
	
	switch (global.zitkLayoutDirection)
	{
		case UI_LAYOUT_DIR.LEFT:
			global.zitkLayoutCursorX = global.zitkLayoutRegionX2;
			global.zitkLayoutCursorY += global.zitkLayoutLineheight + _margin_y;
				
			// (bounds)
			global.zitkLayoutLineheight = 0;
			global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY - _margin_y);
			break;
		
		case UI_LAYOUT_DIR.RIGHT:
			global.zitkLayoutCursorX = global.zitkLayoutRegionX1;
			global.zitkLayoutCursorY += global.zitkLayoutLineheight + _margin_y;
				
			// (bounds)
			global.zitkLayoutLineheight = 0;
			global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY - _margin_y);
			break;
		
		case UI_LAYOUT_DIR.DOWN:
			global.zitkLayoutCursorY = global.zitkLayoutRegionY1;
			global.zitkLayoutCursorX += global.zitkLayoutLineheight + _margin_x;
				
			// (bounds)
			global.zitkLayoutLineheight = 0;
			global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX - _margin_x);
			break;
		
		case UI_LAYOUT_DIR.UP:
			global.zitkLayoutCursorY = global.zitkLayoutRegionY2;
			global.zitkLayoutCursorX += global.zitkLayoutLineheight + _margin_x;
				
			// (bounds)
			global.zitkLayoutLineheight = 0;
			global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX - _margin_x);
			break;
	}
	
	UI_LAYOUT_LOCAL_X = UI_LAYOUT_X - UI_LAYOUT_X1;
	UI_LAYOUT_LOCAL_Y = UI_LAYOUT_Y - UI_LAYOUT_Y1;
}

/// @func zitk_layout_increment_cursor(_x=global.zitkLayoutCursorX, _y=global.zitkLayoutCursorY, _item_w=0, _item_h=_item_w, _use_margin=true)
/// @desc Increments internal layout write position & returns new position that can be used for drawing items
function zitk_layout_increment_cursor (_x=global.zitkLayoutCursorX, _y=global.zitkLayoutCursorY, _item_w=0, _item_h=_item_w, _use_margin=true)
{
	var _margin_x = 0, _margin_y = 0,
		_px=_x, _py=_y;
	if (_use_margin)
	{
		_margin_x = global.zitkLayoutMarginX; _margin_y = global.zitkLayoutMarginY;
	}
	switch (global.zitkLayoutDirection)
	{
		case UI_LAYOUT_DIR.LEFT:
			global.zitkLayoutCursorX = _x - (_item_w + _margin_x);
			_px = _x - _item_w;
			
			// Update bounds info
			//global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_h);
			
			// check for linebreak
			if (_px <= global.zitkLayoutRegionX1)
			{
				global.zitkLayoutCursorX = global.zitkLayoutRegionX2;
				global.zitkLayoutCursorY = _y + global.zitkLayoutLineheight + _margin_y;
				
				// (bounds)
				global.zitkLayoutCurrentMaxX = global.zitkLayoutRegionX1;
				global.zitkLayoutLineheight = _item_h;
				if (_x != global.zitkLayoutRegionX2 && _px < global.zitkLayoutRegionX1) // in case of item being bigger than the region or fitting TIGHTLY into the remaining space
				{
					_px = global.zitkLayoutCursorX - _item_w;
					_py = global.zitkLayoutCursorY;
					global.zitkLayoutCursorX -= _item_w + _margin_x;
					global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY + _item_h);
				}
				else
				{
					global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY - _margin_y);
					//global.zitkLayoutCursorY += _item_h;
					if (global.zitkLayoutCursorX - _item_w <= global.zitkLayoutRegionX1) // will drawing this item cause overflow?
					{
						global.zitkLayoutCursorY += _item_h;
						global.zitkLayoutLineheight = 0;
					}
				}
			}
			else
			{
				global.zitkLayoutCurrentMaxX = min(global.zitkLayoutCurrentMaxX, _px);
				global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY + _item_h);
				global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_h);
			}
			break;
		
		case UI_LAYOUT_DIR.RIGHT:
			global.zitkLayoutCursorX = _x + _item_w + _margin_x;
			
			// Update bounds info
			//global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_h);
			
			// check for linebreak
			if (_x + _item_w >= global.zitkLayoutRegionX2)
			{
				global.zitkLayoutCursorX = global.zitkLayoutRegionX1;
				global.zitkLayoutCursorY = _y + global.zitkLayoutLineheight + _margin_y;
				
				// (bounds)
				global.zitkLayoutCurrentMaxX = global.zitkLayoutRegionX2;
				global.zitkLayoutLineheight = _item_h;
				if (_x != global.zitkLayoutRegionX1 && _x + _item_w > global.zitkLayoutRegionX2) // in case of item being bigger than the region
				{
					_px = global.zitkLayoutCursorX;
					_py = global.zitkLayoutCursorY;
					global.zitkLayoutCursorX += _item_w + _margin_x;
					global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY + _item_h);
				}
				else
				{
					global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY - _margin_y);
					//global.zitkLayoutCursorY += _item_h;
					if (global.zitkLayoutCursorX + _item_w >= global.zitkLayoutRegionX2) // will drawing this item cause overflow?
					{
						global.zitkLayoutCursorY += _item_h;
						global.zitkLayoutLineheight = 0;
					}
				}
			}
			else
			{
				global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, _x + _item_w);
				global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, global.zitkLayoutCursorY + _item_h);
				global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_h);
			}
			break;
		
		case UI_LAYOUT_DIR.DOWN:
			global.zitkLayoutCursorY = _y + _item_h + _margin_y;
			
			// Update bounds info
			//global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_w);
			
			// check for linebreak
			if (_y + _item_h >= global.zitkLayoutRegionY2)
			{
				global.zitkLayoutCursorY = global.zitkLayoutRegionY1;
				global.zitkLayoutCursorX = _x + global.zitkLayoutLineheight + _margin_x;
				
				// (bounds)
				global.zitkLayoutCurrentMaxY = global.zitkLayoutRegionY2;
				global.zitkLayoutLineheight = _item_w;
				if (_y != global.zitkLayoutRegionY1 && _y + _item_h > global.zitkLayoutRegionY2) // in case of item being bigger than the region
				{
					_px = global.zitkLayoutCursorX;
					_py = global.zitkLayoutCursorY;
					global.zitkLayoutCursorY += _item_h + _margin_y;
					global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX + _item_w);
				}
				else
				{
					global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX - _margin_x);
					//global.zitkLayoutCursorX += _item_h;
					if (global.zitkLayoutCursorY + _item_h >= global.zitkLayoutRegionY2) // will drawing this item cause overflow?
					{
						global.zitkLayoutCursorX += _item_w;
						global.zitkLayoutLineheight = 0;
					}
				}
			}
			else
			{
				global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX + _item_w);
				global.zitkLayoutCurrentMaxY = max(global.zitkLayoutCurrentMaxY, _y + _item_h);
				global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_w);
			}
			break;
		
		case UI_LAYOUT_DIR.UP:
			global.zitkLayoutCursorY = _y - (_item_h + _margin_y);
			_py = _y - _item_h;
			
			// Update bounds info
			//global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_w);
			
			// check for linebreak
			if (_py <= global.zitkLayoutRegionY1)
			{
				global.zitkLayoutCursorY = global.zitkLayoutRegionY2;
				global.zitkLayoutCursorX = _x + global.zitkLayoutLineheight + _margin_x;
				
				// (bounds)
				global.zitkLayoutCurrentMaxY = global.zitkLayoutRegionY1;
				global.zitkLayoutLineheight = _item_w;
				if (_y != global.zitkLayoutRegionY2 && _py < global.zitkLayoutRegionY1) // in case of item being bigger than the region
				{
					_px = global.zitkLayoutCursorX;
					_py = global.zitkLayoutCursorY - _item_h;
					global.zitkLayoutCursorY -= _item_h + _margin_y;
					global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX + _item_w);
				}
				else
				{
					global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX - _margin_x);
					//global.zitkLayoutCursorX += _item_h;
					if (global.zitkLayoutCursorY - _item_h <= global.zitkLayoutRegionY1) // will drawing this item cause overflow?
					{
						global.zitkLayoutCursorX += _item_w;
						global.zitkLayoutLineheight = 0;
					}
				}
			}
			else
			{
				global.zitkLayoutCurrentMaxX = max(global.zitkLayoutCurrentMaxX, global.zitkLayoutCursorX + _item_w);
				global.zitkLayoutCurrentMaxY = min(global.zitkLayoutCurrentMaxY, _y - _item_h);
				global.zitkLayoutLineheight = max(global.zitkLayoutLineheight, _item_w);
			}
			break;
	}
	
	UI_LAYOUT_LOCAL_X = UI_LAYOUT_X - UI_LAYOUT_X1;
	UI_LAYOUT_LOCAL_Y = UI_LAYOUT_Y - UI_LAYOUT_Y1;
	return [_px, _py];
}

/// @func zitk_layout_push_cursor_pos(_x, _y)
/// @desc Pushes cursor position to the stack
function zitk_layout_push_cursor_pos (_x, _y)
{
	ds_stack_push(UI_LAYOUT_CURSORSTACK, [global.zitkLayoutCursorX, global.zitkLayoutCursorY, global.zitkLayoutLineheight]);
	global.zitkLayoutCursorX = _x;
	global.zitkLayoutCursorY = _y;
	UI_LAYOUT_LOCAL_X = UI_LAYOUT_X - UI_LAYOUT_X1;
	UI_LAYOUT_LOCAL_Y = UI_LAYOUT_Y - UI_LAYOUT_Y1;
	global.zitkLayoutLineheight = 0;
}

/// @func zitk_layout_pop_cursor_pos(_x, _y)
/// @desc Pops cursor position from the stack
function zitk_layout_pop_cursor_pos (_x, _y)
{
	if (!ds_stack_empty(UI_LAYOUT_CURSORSTACK))
	{
		var _state = ds_stack_pop(UI_LAYOUT_CURSORSTACK);
		global.zitkLayoutCursorX = _state[0];
		global.zitkLayoutCursorY = _state[1];
		UI_LAYOUT_LOCAL_X = UI_LAYOUT_X - UI_LAYOUT_X1;
		UI_LAYOUT_LOCAL_Y = UI_LAYOUT_Y - UI_LAYOUT_Y1;
		global.zitkLayoutLineheight = _state[2];
	}
}

/// @func zitk_layout_set_offset(_x=global.zitkLayoutRegionX1, _y=global.zitkLayoutRegionX1)
/// @desc Sets offset which widgets will be offsetted when drawn
/*
function zitk_layout_set_offset (_x=UI_LAYOUT_X1, _y=UI_LAYOUT_Y1)
{
	global.zitkLayoutOffX = _x;
	global.zitkLayoutOffY = _y;
}

function zitk_layout_reset_offset ()
{
	zitk_layout_set_offset();
}
*/