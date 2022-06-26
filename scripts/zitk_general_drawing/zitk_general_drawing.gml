function zitk_draw_rect (_x, _y, _w, _h, _col=c_white, _a=1)
{
	draw_sprite_ext(sprFullwhite, 0, _x, _y, _w, _h, 0, _col, _a);
}

function zitk_draw_rect_wire (_x, _y, _w, _h, _col=c_white, _a=1)
{
	draw_sprite_ext(sprFullwhite, 0, _x, _y, 1, _h, 0, _col, _a);
	draw_sprite_ext(sprFullwhite, 0, _x, _y, _w, 1, 0, _col, _a);
	draw_sprite_ext(sprFullwhite, 0, _x+_w, _y, 1, _h+1, 0, _col, _a);
	draw_sprite_ext(sprFullwhite, 0, _x, _y+_h, _w, 1, 0, _col, _a);
}

/// @func zitk_draw_rect_wire_ext(_x, _y, _w, _h, _col=c_white, _a=1, _line_wid=2, _line_align=[-1;outside|0;middle|1;inside])
/// @desc Draws wire rectangle with line width/thickness.
function zitk_draw_rect_wire_ext (_x, _y, _w, _h, _col=c_white, _a=1, _line_wid=2, _line_align=0)
{
	var _off = _line_wid*(-0.5+_line_align*0.5), // -0.5w if align=0, -1.0w if align=-1, 0.0 if align=1
		_off2 = _line_wid*(-0.5-_line_align*0.5); // -0.5w if align=0, -1.0w if align=1, 0.0 if align=-1
	draw_sprite_ext(sprFullwhite, 0, _x+_off, _y+_off, _line_wid, _h-_off*2, 0, _col, _a); // left side
	draw_sprite_ext(sprFullwhite, 0, _x, _y+_off, _w, _line_wid, 0, _col, _a); // top side
	draw_sprite_ext(sprFullwhite, 0, _x+_w+_off2, _y+_off, _line_wid, _h-_off*2, 0, _col, _a); // right side
	draw_sprite_ext(sprFullwhite, 0, _x, _y+_h+_off2, _w, _line_wid, 0, _col, _a); // bottom side
}

function zitk_draw_rect_rot (_x, _y, _w, _h, _angle, _col=c_white, _a=1)
{
	draw_sprite_ext(sprFullwhiteCenter, 0, _x, _y, _w*0.5, _h*0.5, _angle, _col, _a);
}

function zitk_draw_text (_x, _y, _str, _xs=1, _ys=1, _angle=0, _col=c_white, _a=1)
{
	draw_text_transformed_colour(_x, _y, _str, _xs, _ys, _angle, _col, _col, _col, _col, _a);
}

function zitk_draw_text_shadow (_x, _y, _str, _xs=1, _ys=1, _angle=0, _col=c_white, _a=1, _shadowcol=c_black)
{
	draw_text_transformed_colour(_x+_xs, _y+_ys, _str, _xs, _ys, _angle, _shadowcol, _shadowcol, _shadowcol, _shadowcol, _a);
	draw_text_transformed_colour(_x, _y, _str, _xs, _ys, _angle, _col, _col, _col, _col, _a);
}

function zitk_draw_textbox (_x, _y, _w, _h, _str, _col=c_white, _textcol=c_white, _a=1, _scale=1, _align_h=0, _align_v=0)
{
	if (_w <= 0) _w = string_width(_str) * _scale - _w;
	if (_h <= 0) _h = string_height(_str) * _scale - _h;
	
	_x -= _w * (_align_h * 0.5);
	_y -= _h * (_align_v * 0.5);
	
	draw_sprite_ext(sprFullwhite, 0, _x, _y, _w, _h, 0, _col, _a);
	draw_set_halign(1); draw_set_valign(1);
	zitk_draw_text_shadow(_x + _w * 0.5, _y + _h * 0.5, _str, _scale, _scale, 0, _textcol);
}

function zitk_draw_textbox_outline (_x, _y, _w, _h, _str, _col=c_white, _textcol=c_white, _a=1, _scale=1, _align_h=0, _align_v=0)
{
	if (_w <= 0) _w = string_width(_str) * _scale - _w;
	if (_h <= 0) _h = string_height(_str) * _scale - _h;
	
	_x -= _w * (_align_h * 0.5);
	_y -= _h * (_align_v * 0.5);
	
	draw_sprite_ext(sprFullwhite, 0, _x, _y, _w, _h, 0, _col, _a);
	// outline
	draw_sprite_ext(sprFullwhite, 0, _x, _y, 1, _h, 0, _textcol, _a);
	draw_sprite_ext(sprFullwhite, 0, _x, _y, _w, 1, 0, _textcol, _a);
	draw_sprite_ext(sprFullwhite, 0, _x+_w, _y, 1, _h+1, 0, _textcol, _a);
	draw_sprite_ext(sprFullwhite, 0, _x, _y+_h, _w, 1, 0, _textcol, _a);
	draw_set_halign(1); draw_set_valign(1);
	zitk_draw_text_shadow(_x + _w * 0.5, _y + _h * 0.5, _str, _scale, _scale, 0, _textcol, _a);
}


/// @func zitk_set_font(font)
/// @desc Wrapper for draw_set_font
function zitk_set_font (_fnt)
{
	UI_EM = string_height("M");
	draw_set_font(_fnt);
}

/// @func zitk_colour_add(_col, _amount_r, _amount_g, _amount_b)
/// @desc Adds given amount to each channel and returns the result
function zitk_colour_add (_col, _add_r, _add_g, _add_b)
{
	return	clamp((_col & 0x0000FF) + _add_r, 0, 255) |					// red
			(clamp(((_col & 0x00FF00) >> 8) + _add_g, 0, 255) << 8) |	// green
			(clamp(((_col & 0xFF0000) >> 16) + _add_b, 0, 255) << 16);	// blue
}
