/*
	ZIK'S ILLEGAL UI TOOLKIT
	Immediate mode GUI heavily inspired by Imgui
	
	ZIK@MMXXII
*/
#macro _ZITK_AUTORUN_ON_STARTUP true
#macro _ZITK_VERSION "v0.0.0"

// Colour
enum ZITK_PAL
{
	WHITE = #fafacf,
	BLACK = #140e0d,
	DARK = #473d33,
	RED = #eb5931,
	GREEN = #3ef775,
	BLUE = #3c40ba,
	BLUE_DK = #221159
}

global.zitkColBackdrop = ZITK_PAL.DARK;
global.zitkColButton = ZITK_PAL.DARK;
global.zitkColButtonClick = ZITK_PAL.BLUE;

global.zitkColLabel = ZITK_PAL.WHITE;
//

// UI States
// (cached UI states)
global.zitkStateButtons = {};
// (current font stuff)
#macro UI_EM global.zitkFontEm
global.zitkFontEm = 16;

// (input)
global.zitkInputX = 0;
global.zitkInputY = 0;
global.zitkInput1Press = 0;
global.zitkInput1Hold = 0;
global.zitkInput1Release = 0;
global.zitkInput2Press = 0;
global.zitkInput2Hold = 0;
global.zitkInput2Release = 0;
// (current "region")
global.zitkRegionX1 = 0;
global.zitkRegionY1 = 0;
global.zitkRegionX2 = 0;
global.zitkRegionY2 = 0;

global.zitkTextSize = 1;
//

// ID & Label (= Tag) wrangling functions
function zitk_tag_get_label (_tag)
{
	// Separate by '|' delimiter, and return it
	var _prevpos = -1, // last known safe delimiter position
		_delimpos = string_pos_ext("|", _tag, 1); // currently inspecting position
	while (_delimpos > 0) // march until the end of the tag string
	{
		if (string_char_at(_tag, _delimpos - 1) != "\\") // update last known 'safe' delimiter position
			_prevpos = _delimpos;
		_delimpos = string_pos_ext("|", _tag, _delimpos + 1);
	}
	
	// Copy the label part only
	if (_prevpos == -1) // everything is label
		return _tag;
	else
		return string_copy(_tag, 1, _prevpos - 1);
}

function zitk_tag_get_id (_tag)
{
	// Separate by '||' delimiter, and return it
	var _prevpos = -1, // last known delimiter position
		_delimpos = string_pos_ext("|", _tag, 1); // currently inspecting position
	while (_delimpos > 0) // march until the end of the tag string
	{
		if (string_char_at(_tag, _delimpos - 1) != "\\") // update last known delimiter position
			_prevpos = _delimpos;
		_delimpos = string_pos_ext("|", _tag, _delimpos + 1);
	}
	
	// Copy the id part only
	if (_prevpos == -1) // everything is label, so the label itself becomes the id
		return _tag;
	else
		return string_delete(_tag, 1, _prevpos);
}

/// @func zitk_tag_separate(_tag)
/// @desc Returns array containing [label, id] separated from _tag
function zitk_tag_separate (_tag)
{
	// Separate by '||' delimiter, and return it
	var _prevpos = -1, // last known delimiter position
		_delimpos = string_pos_ext("|", _tag, 1); // currently inspecting position
	while (_delimpos > 0) // march until the end of the tag string
	{
		if (string_char_at(_tag, _delimpos - 1) != "\\") // update last known delimiter position
			_prevpos = _delimpos;
		_delimpos = string_pos_ext("|", _tag, _delimpos + 1);
	}
	
	// Copy the id part only
	if (_prevpos == -1) // everything is label, so the label itself becomes the id
		return [_tag, _tag];
	else
		return [string_copy(_tag, 1, _prevpos - 1), string_delete(_tag, 1, _prevpos)];
}

// Initialization fuction
function zitk ()
{
	show_debug_message("ZI " + _ZITK_VERSION + " COMPILED @ " + string(date_get_year(GM_build_date)) + "/" + string(date_get_month(GM_build_date)) + "/" + string(date_get_day(GM_build_date)));
	
	// Tests
	show_debug_message("\TAG TEST: 'HELLO|WORLD'"); var _TAG = "HELLO|WORLD";
	show_debug_message("\t> (ID, LAB): `" + string(zitk_tag_separate(_TAG)));
	show_debug_message("\tTAG TEST: 'HELLO|LONGER|WORLD'"); var _TAG = "HELLO|LONGER|WORLD";
	show_debug_message("\t> (ID, LAB): `" + string(zitk_tag_separate(_TAG)));
	show_debug_message("\tTAG TEST: 'HELLO\\|DELIMITED|WORLD'"); var _TAG = "HELLO\\|DELIMITED|WORLD";
	show_debug_message("\t> (ID, LAB): `" + string(zitk_tag_separate(_TAG)));
}

// Run initialization
if (_ZITK_AUTORUN_ON_STARTUP)
	zitk();
