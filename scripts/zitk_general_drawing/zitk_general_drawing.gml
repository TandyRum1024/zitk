function zitk_draw_rect (_x, _y, _w, _h, _col=c_white, _a=1)
{
	draw_sprite_ext(sprFullwhite, 0, _x, _y, _w, _h, 0, _col, _a);
}

function zitk_draw_text (_x, _y, _str, _xs=1, _ys=1, _angle=0, _col=c_white, _a=1)
{
	draw_text_transformed_colour(_x, _y, _str, _xs, _ys, _angle, _col, _col, _col, _col, _a);
}

/// @func zitk_set_font(font)
/// @desc Wrapper for draw_set_font
function zitk_set_font (_fnt)
{
	UI_EM = string_height("M");
	draw_set_font(_fnt);
}

/// @func zitk_colour_add(_col, _amount_r_or_all, *_amount_g, *_amount_b)
/// @desc Adds given amount to each channel and returns the result
function zitk_colour_add (_col, _add_r, _add_g=_add_r, _add_b=_add_r)
{
	return	clamp((_col & 0x0000FF) + _add_r, 0, 255) |					// red
			(clamp(((_col & 0x00FF00) >> 8) + _add_g, 0, 255) << 8) |	// green
			(clamp(((_col & 0xFF0000) >> 16) + _add_b, 0, 255) << 16);	// blue
}
