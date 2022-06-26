/*
	ZIK'S ILLEGAL UI TOOLKIT
	Immediate mode GUI heavily inspired by Imgui
	Somewhat of a continuation of IMNOTGUI for GMS1
	
	ZIK@MMXXII
*/
#macro ZITK_AUTORUN_ON_STARTUP true
#macro ZITK_VERSION "v0.0.0"
#macro ZITK_DEBUG_LAYOUT false

// Colour
enum ZITK_PAL
{
	WHITE	= #fafacf,
	BLACK	= #140e0d,
	DARK	= #473d33,
	RED		= #eb5931,
	GREEN	= #3ef775,
	BLUE	= #3c40ba,
	BLUE_DK = #221159,
}

// UI Widget styles
// (generic backdrop)
global.zitkColBackdrop = ZITK_PAL.DARK;
// (buttons)
global.zitkColButton = ZITK_PAL.DARK;
global.zitkColButtonHover = zitk_colour_add(ZITK_PAL.DARK, 50, 50, 50);
global.zitkColButtonHold = zitk_colour_add(ZITK_PAL.DARK, -25, -25, -25);
global.zitkColButtonClick = ZITK_PAL.RED;
// (text/label)
global.zitkColLabel = ZITK_PAL.WHITE;
// (sliders)
#macro UI_SLIDER_MARKER_W 16
global.zitkColSliderBackdrop = ZITK_PAL.DARK;
global.zitkColSliderOutline = ZITK_PAL.WHITE;
global.zitkColSliderHint = ZITK_PAL.RED;
//

// UI States
// (cached UI states)
global.zitkStateMem = {}; // general purpose memory
global.zitkStateButtons = {}; // button
global.zitkStateSliders = {}; // sliders

global.zitkStateIsUsingInput = false; // is any of the ZITK ui widget occupying either mouse (hover/click etc...) or keyboard input?

global.zitkStateCurrentHoverItem = undefined;
global.zitkStateCurrentHoldItem = undefined;

// (tag: id stack/prefix)
global.zitkIDPrefix = "";
global.zitkIDPrefixStack = undefined;

// (current font stuff)
global.zitkFontEm = 16;
global.zitkTextSize = 1;

// (input)
global.zitkInputX = 0;
global.zitkInputY = 0;
global.zitkInputXOff = 0; // offsets used for dragging
global.zitkInputYOff = 0;
global.zitkInput1Press = 0;
global.zitkInput1Hold = 0;
global.zitkInput1Release = 0;
global.zitkInput2Press = 0;
global.zitkInput2Hold = 0;
global.zitkInput2Release = 0;

// UI Layout states
global.zitkLayoutStack = undefined;
global.zitkLayoutCursorStack = undefined;
global.zitkAutoLayoutStack = undefined; // auto-layout method stack
// (current "region")
global.zitkLayoutRegionX1 = 0;
global.zitkLayoutRegionY1 = 0;
global.zitkLayoutRegionX2 = 0;
global.zitkLayoutRegionY2 = 0;
global.zitkLayoutRegionW = 0;
global.zitkLayoutRegionH = 0;
enum UI_LAYOUT_DIR
{
	RIGHT = 0,	// left-to-right
	LEFT,		// right-to-left
	DOWN,		// up-to-down
	UP			// down-to-up
}
global.zitkLayoutDirection = UI_LAYOUT_DIR.RIGHT; // 0: left-right, 1: right-left, 2: up-down, 3: down-up
// (current cursor position)
global.zitkLayoutCursorX = 0;
global.zitkLayoutCursorY = 0;
global.zitkLayoutCursorLocalX = 0;
global.zitkLayoutCursorLocalY = 0;
// (current maximum position of written content so far)
global.zitkLayoutCurrentMaxX = 0;
global.zitkLayoutCurrentMaxY = 0;
// (current line height, or width depending on the layout direction)
global.zitkLayoutLineheight = 0;
// (current margin)
global.zitkLayoutMarginX = 8;
global.zitkLayoutMarginY = 8;

// Macro aliases
#macro UI_EM global.zitkFontEm
#macro UI_MEM global.zitkStateMem

#macro UI_INPUT_X global.zitkInputX
#macro UI_INPUT_Y global.zitkInputY

#macro UI_LAYOUT_X global.zitkLayoutCursorX
#macro UI_LAYOUT_Y global.zitkLayoutCursorY
#macro UI_LAYOUT_LOCAL_X global.zitkLayoutCursorLocalX
#macro UI_LAYOUT_LOCAL_Y global.zitkLayoutCursorLocalY
#macro UI_LAYOUT_X1 global.zitkLayoutRegionX1
#macro UI_LAYOUT_X2 global.zitkLayoutRegionX2
#macro UI_LAYOUT_Y1 global.zitkLayoutRegionY1
#macro UI_LAYOUT_Y2 global.zitkLayoutRegionY2
#macro UI_LAYOUT_W global.zitkLayoutRegionW
#macro UI_LAYOUT_H global.zitkLayoutRegionH

#macro UI_AUTOLAYOUT_STACK global.zitkAutoLayoutStack
#macro UI_LAYOUT_STACK global.zitkLayoutStack
#macro UI_LAYOUT_CURSORSTACK global.zitkLayoutStack
//

#region ID & Label (= Tag) wrangling functions
/// @func zitk_tag_get_label(_tag)
/// @desc Returns label part of the tag: `HELLO|THIS_IS_ID` returns `HELLO`
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

/// @func zitk_tag_get_id(_tag)
/// @desc Returns id part of the tag: `HELLO|THIS_IS_ID` returns `THIS_IS_ID`
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
		return global.zitkIDPrefix + _tag;
	else
		return global.zitkIDPrefix + string_delete(_tag, 1, _prevpos);
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
		return [_tag, global.zitkIDPrefix + _tag];
	else
		return [string_copy(_tag, 1, _prevpos - 1), global.zitkIDPrefix + string_delete(_tag, 1, _prevpos)];
}

/// @func zitk_tag_push(_tag)
/// @desc Appends ('pushes') given tag to the global tag stack / prefix
function zitk_tag_push (_prefix)
{
	ds_stack_push(global.zitkIDPrefixStack, global.zitkIDPrefix);
	global.zitkIDPrefix += _prefix;
}

/// @func zitk_tag_pop()
/// @desc Un-appends ('pops') last tag from the global tag stack / prefix
function zitk_tag_pop ()
{
	global.zitkIDPrefix = ds_stack_pop(global.zitkIDPrefixStack) ?? "";
}
#endregion

// Initialization fuction
function zitk ()
{
	show_debug_message("ZI " + ZITK_VERSION + " COMPILED @ " + string(date_get_year(GM_build_date)) + "/" + string(date_get_month(GM_build_date)) + "/" + string(date_get_day(GM_build_date)));

	// Summon data structures
	UI_LAYOUT_STACK = ds_stack_create();
	UI_LAYOUT_CURSORSTACK = ds_stack_create();
	UI_AUTOLAYOUT_STACK = ds_stack_create();
	global.zitkIDPrefixStack = ds_stack_create();

	// Tests
	show_debug_message("\TAG TEST: 'HELLO|WORLD'"); var _TAG = "HELLO|WORLD";
	show_debug_message("\t> (ID, LAB): `" + string(zitk_tag_separate(_TAG)));
	show_debug_message("\tTAG TEST: 'HELLO|LONGER|WORLD'"); var _TAG = "HELLO|LONGER|WORLD";
	show_debug_message("\t> (ID, LAB): `" + string(zitk_tag_separate(_TAG)));
	show_debug_message("\tTAG TEST: 'HELLO\\|DELIMITED|WORLD'"); var _TAG = "HELLO\\|DELIMITED|WORLD";
	show_debug_message("\t> (ID, LAB): `" + string(zitk_tag_separate(_TAG)));
	
	// Clear cache
	global.zitkIDPrefix = "";
	global.zitkStateButtons = {};
	global.zitkStateSliders = {};
}

function zitk_free ()
{
	if (ds_exists(UI_AUTOLAYOUT_STACK, ds_type_stack)) ds_stack_destroy(UI_AUTOLAYOUT_STACK);
	if (ds_exists(UI_LAYOUT_STACK, ds_type_stack)) ds_stack_destroy(UI_LAYOUT_STACK);
	if (ds_exists(UI_LAYOUT_CURSORSTACK, ds_type_stack)) ds_stack_destroy(UI_LAYOUT_CURSORSTACK);
	if (ds_exists(global.zitkIDPrefixStack, ds_type_stack)) ds_stack_destroy(global.zitkIDPrefixStack);
}

/// @func zitk_before_ui()
/// @desc Call this before calling your UI codes!
function zitk_before_ui ()
{
	global.zitkStateCurrentHoverItem = undefined;
	//global.zitkStateCurrentHoldItem = undefined;
}

/// @func zitk_after_ui()
/// @desc Call this after calling all your UI codes!
function zitk_after_ui ()
{
	global.zitkStateIsUsingInput = (global.zitkStateCurrentHoverItem != undefined) || (global.zitkStateCurrentHoldItem != undefined);
}

// Run initialization
if (ZITK_AUTORUN_ON_STARTUP)
	zitk();
