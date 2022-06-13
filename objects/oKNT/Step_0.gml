
/// Automatically update window scaling
var _ww = window_get_width(), _wh = window_get_height();
if (_ww != 0 && _wh != 0 && (_ww != surface_get_width(application_surface) || _wh != surface_get_height(application_surface)))
{
	surface_resize(application_surface, _ww, _wh);
	display_set_gui_size(_ww, _wh);
}

/// Update input
global.zitkInputX = window_mouse_get_x();
global.zitkInputY = window_mouse_get_y();

global.zitkInput1Press = mouse_check_button_pressed(mb_left);
global.zitkInput1Hold = mouse_check_button(mb_left);
global.zitkInput1Release = mouse_check_button_released(mb_left);

global.zitkInput2Press = mouse_check_button_pressed(mb_right);
global.zitkInput2Hold = mouse_check_button(mb_right);
global.zitkInput2Release = mouse_check_button_released(mb_right);
