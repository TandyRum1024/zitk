/// @description desc
vy += 0.9;

x += vx;
y += vy;

image_angle += sign(vx) * 4;

if (vy > 0 && y > room_height * 1.5)
{
	var _sfx = audio_play_sound(sndAnvil, 0, false);
	audio_sound_pitch(_sfx, random_range(0.9, 1.1));
	
	with (oKNT){
		shake += 4;
		punchY += 32;
		punchR += random_range(-16, 16);
	}
	
	instance_destroy(id);
}
