
/// Automatically update window scaling
var _ww = window_get_width(), _wh = window_get_height();
if (_ww != 0 && _wh != 0 && (_ww != surface_get_width(application_surface) || _wh != surface_get_height(application_surface)))
{
	surface_resize(application_surface, _ww, _wh);
	display_set_gui_size(_ww, _wh);
	camera_set_view_size(view_camera[view_current], _ww, _wh);
}

punchVelR -= punchR * 0.5;
punchR += punchVelR;

punchVelR *= 0.9;
shake *= 0.5;
punchX *= 0.85;
punchY *= 0.85;

var _x = random_range(-shake, shake) + punchX,
	_y = random_range(-shake, shake) + punchY;
camera_set_view_pos(view_camera[view_current], _x * shakeAmp, _y * shakeAmp);
camera_set_view_angle(view_camera[view_current], punchR * shakeAmp);
//camera_set_view_size(view_camera[view_current], _ww, _wh);
//camera_apply(view_camera[view_current]);

/// Update input
global.zitkInputX = window_mouse_get_x();
global.zitkInputY = window_mouse_get_y();

global.zitkInput1Press = mouse_check_button_pressed(mb_left);
global.zitkInput1Hold = mouse_check_button(mb_left);
global.zitkInput1Release = mouse_check_button_released(mb_left);

global.zitkInput2Press = mouse_check_button_pressed(mb_right);
global.zitkInput2Hold = mouse_check_button(mb_right);
global.zitkInput2Release = mouse_check_button_released(mb_right);

window_set_caption("FPS: " + string(fps) + "/" + string(fps_real));