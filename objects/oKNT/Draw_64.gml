/// @description GUI
var _ww = window_get_width(), _wh = window_get_height();
var _x = UI_MEM[$ "panel_x"] ?? 32, _y = UI_MEM[$ "panel_y"] ?? 32,
	_vx = UI_MEM[$ "panel_vx"] ?? 0, _vy = UI_MEM[$ "panel_vy"] ?? 0,
	_w = 400, _h = 300;
var _xo = random_range(-shake, shake) + punchX,
	_yo = random_range(-shake, shake) + punchY;
camera_set_view_pos(view_camera[view_current], _xo * shakeAmp, _yo * shakeAmp);
camera_set_view_angle(view_camera[view_current], punchR * shakeAmp);
camera_set_view_size(view_camera[view_current], _ww, _wh);
camera_apply(view_camera[view_current]);

zitk_before_ui();

zitk_layout_push(_x + 8, _y + 8, _w - 16, _h - 16, UI_LAYOUT_DIR.RIGHT);
	// Backdrop (horrid)
	var _tab_text = "Honestly quite incredible", _tab_sz = global.zitkTextSize,
		_tab_w = string_width(_tab_text) * _tab_sz;
	zitk_draw_rect(UI_LAYOUT_X1-8, UI_LAYOUT_Y1-8-32, _tab_w + 16, 32, ZITK_PAL.RED, 1); // tab
	zitk_draw_rect_rot(UI_LAYOUT_X1-8 + _tab_w + 16, UI_LAYOUT_Y1-8, 64*0.70707, 64*0.70707, 45, ZITK_PAL.RED, 1); // tab ornament
	draw_set_halign(0); draw_set_valign(1);
	zitk_draw_text_shadow(UI_LAYOUT_X1, UI_LAYOUT_Y1-8-16, _tab_text, _tab_sz, _tab_sz, 0, ZITK_PAL.WHITE); // tab text
	zitk_draw_rect(UI_LAYOUT_X1-8+16, UI_LAYOUT_Y1-8+16, UI_LAYOUT_W+16, UI_LAYOUT_H+16, 0, 0.5);
	zitk_draw_rect(UI_LAYOUT_X1-8, UI_LAYOUT_Y1-8, UI_LAYOUT_W+16, UI_LAYOUT_H+16, ZITK_PAL.BLACK, 1);
	zitk_draw_rect_wire(UI_LAYOUT_X1-8, UI_LAYOUT_Y1-8, UI_LAYOUT_W+16, UI_LAYOUT_H+16, ZITK_PAL.RED, 1);
	
	draw_set_halign(2); draw_set_valign(1);
	if (zitk_button_sprite(, , "ANVIL PLZ|btn_dropanvil", sprPortrait, image_index, 1, sin(current_time * 0.001 * pi) * 0, c_white, 1, -32, -16, 1, 0, 1, true))
	{
		instance_create_depth(_ww * 0.5 + random_range(-64, 64), _wh + 64, 0, oAnvil);
		punchY += 16;
		
		var _sfx = audio_play_sound(sndWhoosh, 0, false);
		audio_sound_pitch(_sfx, random_range(0.9, 1.1));
	}
	zitk_layout_linebreak();
	
	UI_MEM[$ "legs_val"] = zitk_slider_h(, , "STUFF|LEGS", UI_MEM[$ "legs_val"] ?? 42, 42, 66);
	zitk_layout_linebreak();
	shakeAmp = zitk_slider_h(, , "JUICE|JUICE", shakeAmp, 0, 1);
	zitk_layout_linebreak();
	
	zitk_layout_push(UI_LAYOUT_X1, UI_LAYOUT_Y, UI_LAYOUT_W, (UI_LAYOUT_Y2-UI_LAYOUT_Y) / 2, UI_LAYOUT_DIR.LEFT);
	zitk_text(, , "Test text 1!");
	zitk_text(, , "Test text (2)", ZITK_PAL.RED);
	zitk_layout_linebreak();
	zitk_text(UI_LAYOUT_X + sin(current_time * 0.001 * pi) * 16, UI_LAYOUT_Y + sin(current_time * 0.001 * pi) * 16, "Test text (3)", ZITK_PAL.GREEN);
	zitk_text(, , "Test text (4)", ZITK_PAL.BLUE);
	zitk_layout_pop();
	
	zitk_layout_push(UI_LAYOUT_X1, UI_LAYOUT_Y, UI_LAYOUT_W, UI_LAYOUT_Y2-UI_LAYOUT_Y, UI_LAYOUT_DIR.UP);
	zitk_text(, , "Test text 1!");
	zitk_text(, , "Test text (2)", ZITK_PAL.RED);
	zitk_layout_linebreak();
	zitk_text(UI_LAYOUT_X + sin(current_time * 0.001 * pi) * 16, UI_LAYOUT_Y + sin(current_time * 0.001 * pi) * 16, "Test text (3)", ZITK_PAL.GREEN);
	zitk_text(, , "Test text (4)", ZITK_PAL.BLUE);
	zitk_layout_pop();
	
	// Dragging
	var _states = zitk_buttonbehaviour(_x, _y, "BACKDROP1", 400, 300, global.zitkStateCurrentHoverItem != undefined && global.zitkStateCurrentHoldItem != "BACKDROP1");
	if (_states[1])
	{
		var _newx = clamp(UI_INPUT_X - global.zitkInputXOff, 0, window_get_width() - _w),
			_newy = clamp(UI_INPUT_Y - global.zitkInputYOff, 0, window_get_height() - _h),
			_deltax = _newx - _x,
			_deltay = _newy - _y;
		UI_MEM[$ "panel_x"] = _newx; UI_MEM[$ "panel_y"] = _newy;
		UI_MEM[$ "panel_vx"] = _deltax; UI_MEM[$ "panel_vy"] = _deltay;
	}
	else
	{
		_x += _vx;
		_y += _vy;
		_vx *= 0.95;
		_vy *= 0.95;
		
		if (_x < 0)
		{
			_x = 0;
			_vx *= -0.95;
			punchX -= 8 * abs(_vx / 16);
			punchVelR += 1;
			var _sfx = audio_play_sound(sndThud, 0, false);
			audio_sound_pitch(_sfx, random_range(0.9, 1.1));
		}
		else if (_x > window_get_width() - _w)
		{
			_x = window_get_width() - _w;
			_vx *= -0.95;
			punchX += 8 * abs(_vx / 16);
			punchVelR -= 1;
			var _sfx = audio_play_sound(sndThud, 0, false);
			audio_sound_pitch(_sfx, random_range(0.9, 1.1));
		}
		if (_y < 0)
		{
			_y = 0;
			_vy *= -0.95;
			punchY -= 8 * abs(_vy / 16);
			punchVelR += random_range(-1, 1);
			var _sfx = audio_play_sound(sndThud, 0, false);
			audio_sound_pitch(_sfx, random_range(0.9, 1.1));
		}
		else if (_y > window_get_height() - _h)
		{
			_y = window_get_height() - _h;
			_vy *= -0.95;
			punchY += 8 * abs(_vy / 16);
			punchVelR += random_range(-1, 1);
			var _sfx = audio_play_sound(sndThud, 0, false);
			audio_sound_pitch(_sfx, random_range(0.9, 1.1));
		}
		
		UI_MEM[$ "panel_x"] = _x;
		UI_MEM[$ "panel_y"] = _y;
		UI_MEM[$ "panel_vx"] = _vx;
		UI_MEM[$ "panel_vy"] = _vy;
	}
zitk_layout_pop();

// Sets up the new layout, and pushes the previous layout onto stack
// It's dimensions are [400, 300]px, and its positions at [600, 80]px
zitk_layout_push(600, 32, 400, 300, UI_LAYOUT_DIR.RIGHT);
	// (simple draw_rectangle() wrapper)
	zitk_draw_rect(UI_LAYOUT_X1-8, UI_LAYOUT_Y1-8, UI_LAYOUT_W+16, UI_LAYOUT_H+16, ZITK_PAL.BLACK, 1);
	// zitk_button(x, y, str|id, wid, hei) returns true on 'press'
	// (i.e. when the user clicks the button and releases the mouse while hovering on it)
	if (zitk_button(, , "LEFT-TO-RIGHT|BTN2", -32, -16))
		show_message("boom");
	// Explicitly break the line, though the items will also overflow and continue on the new line according to the layouts size.
	zitk_layout_linebreak();
	zitk_text(, , "Test text 1!");
	zitk_text(, , "Test text (2)", ZITK_PAL.RED);
	zitk_text(, , "Test text (3)", ZITK_PAL.GREEN);
	// Implicit line break happens here, as the item has 'overflown' the layout region
	zitk_text(, , "Test text (4)", ZITK_PAL.BLUE);
	zitk_text(, , "Test text (5)", ZITK_PAL.GREEN);
	zitk_text(, , "Test text (6)", ZITK_PAL.WHITE);
	// This one does not care about the layout and all -- it's drawn at exactly wherever you want it.
	zitk_text(600-42, 24, "Free text", #FFDD00);
// Ends current layout, pop from stack and make it the current one
zitk_layout_pop();

_w = 600;
if (mouse_check_button(mb_left))
	_w = window_mouse_get_x() - 32;
zitk_layout_push(32, 400, _w, 200, UI_LAYOUT_DIR.RIGHT);
	zitk_draw_rect(UI_LAYOUT_X1, UI_LAYOUT_Y1, UI_LAYOUT_W, UI_LAYOUT_H, ZITK_PAL.BLACK, 1);
	// Set up the nested region
	// UI_LAYOUT_* contains values for currently 'active' layout.
	// The code below divides current region in two regions and uses it to make new layouts
	// Sub-layout A, 45% width of layout] Repeteadly draw 16 lines of text
	zitk_layout_push(UI_LAYOUT_X, UI_LAYOUT_Y, UI_LAYOUT_W * 0.45, UI_LAYOUT_H, UI_LAYOUT_DIR.DOWN);
		zitk_draw_text_shadow(UI_LAYOUT_X1, UI_LAYOUT_Y1 - 32, "Region A (DOWN layout)");
		zitk_draw_rect_wire(UI_LAYOUT_X1, UI_LAYOUT_Y1, UI_LAYOUT_W, UI_LAYOUT_H, ZITK_PAL.WHITE, 1);
		for (var i=0; i<16; i++)
			zitk_text(, , "Line #" + string(i), make_color_hsv((i<<2) & 0xFF, 128, 255));
	zitk_layout_pop(true);
	// Sub-layout B, 55% width of layout] Uses the 'meta'/auto layout, which programatically divides region into certain number of regions
	var _callbacks = [], _sizes = [], _directions = [];
	for (var i=0; i<24; i++)
	{
		// (ith sub-sub-layout blocks callback)
		_callbacks[i] = function (idx, layout_x, layout_y, layout_w, layout_h) {
			zitk_draw_rect(layout_x, layout_y, layout_w, layout_h, make_color_hsv((idx<<2) & 0xFF, 128, 80), 1); // backdrop for some flair
			zitk_draw_rect_wire(layout_x, layout_y, layout_w, layout_h, c_lime, 1)
			zitk_text(, , "#" + string(idx));
		};
		// (and its size)
		_sizes[i] = [32, 42];
		// (and internal layout direction)
		_directions[i] = i % 4; // Cycle through UI_LAYOUT_DIR.RIGHT, UI_LAYOUT_DIR.LEFT, UI_LAYOUT_DIR.DOWN, UI_LAYOUT_DIR.UP
	}
	// Request autolayout solver to allocate 32 blocks of sub-sub-layouts in a left-to-right direction, calling passed in callback function on each layouts
	zitk_draw_rect_wire(UI_LAYOUT_X, UI_LAYOUT_Y, UI_LAYOUT_W - UI_LAYOUT_LOCAL_X, UI_LAYOUT_H, ZITK_PAL.WHITE, 1);
	zitk_draw_text_shadow(UI_LAYOUT_X, UI_LAYOUT_Y - 32, "Region B (autolayout)");
	zitk_autolayout(UI_LAYOUT_X, UI_LAYOUT_Y, UI_LAYOUT_W - UI_LAYOUT_LOCAL_X, UI_LAYOUT_H, 24, _callbacks, UI_LAYOUT_DIR.RIGHT, false, _sizes, _directions);
zitk_layout_pop();

zitk_layout_push(1000, 400, 400, 200, UI_LAYOUT_DIR.UP);
	if (zitk_button(, , "UPPERCUT|BTN4", -32, -16))
		show_message("boom");
	zitk_text(, , "Test text 1!");
	zitk_text(, , "Test text (2)", ZITK_PAL.RED);
	zitk_text(, , "Test text (3)", ZITK_PAL.GREEN);
zitk_layout_pop();

zitk_after_ui();
zitk_draw_text_shadow(16, 16, string(global.zitkStateCurrentHoldItem) + "\n" + string(global.zitkStateCurrentHoverItem), 1, 1, 0, ZITK_PAL.RED);