/*:
 * @author Casper Gaming
 * @url https://www.caspergaming.com/plugins/cgmz/menutheme/
 * @target MZ
 * @base CGMZ_Core
 * @orderAfter CGMZ_Core
 * @plugindesc Add a BGM to the menu
 * @help
 * ============================================================================
 * For terms and conditions using this plugin in your game please visit:
 * https://www.caspergaming.com/terms-of-use/
 * ============================================================================
 * Become a Patron to get access to beta/alpha plugins plus other goodies!
 * https://www.patreon.com/CasperGamingRPGM
 * ============================================================================
 * Version: 1.1.0
 * ----------------------------------------------------------------------------
 * Compatibility: Only tested with my CGMZ plugins.
 * Made for RPG Maker MZ 1.1.0
 * ----------------------------------------------------------------------------
 * Description: Adds a BGM to the menu. It will autoplay the previous BGM
 * when exiting menu. The menu theme will persist through all different menus
 * within the main menu (such as item, status, or save).
 * ----------------------------------------------------------------------------
 * Documentation:
 * If NOT using variables to control menu theme, laeve variable set to 0. Then
 * set the default menu theme.
 *
 * If using variables to control  menu theme, the first variable menu theme
 * corresponds to a variable value of 0. The second variable menu theme
 * corresponds to a variable value of 1, and so on. If your variable has a
 * value greater than the number of menu themes possible, it will default to
 * the first menu theme in the variable menu themes array.
 *
 * Version History:
 * 1.0.0: Initial release
 *
 * 1.1.0:
 * - Added ability to designate the menu theme by game variable
 *
 * @param Default Menu Theme
 * @type file
 * @dir audio/bgm/
 * @desc The menu theme BGM to play if not using variable
 *
 * @param Menu Theme Variable
 * @type variable
 * @default 0
 * @desc The variable which controls which menu theme is played
 *
 * @param Variable Menu Themes
 * @type file[]
 * @dir audio/bgm/
 * @desc The menu theme BGMs to play by variable value (0 = first, 1 = second, etc).
*/
var Imported = Imported || {};
Imported.CGMZ_MenuTheme = true;
var CGMZ = CGMZ || {};
CGMZ.Versions = CGMZ.Versions || {};
CGMZ.Versions["Menu Theme"] = "1.1.0";
CGMZ.MenuTheme = CGMZ.MenuTheme || {};
CGMZ.MenuTheme.parameters = PluginManager.parameters('CGMZ_MenuTheme');
CGMZ.MenuTheme.Theme = CGMZ.MenuTheme.parameters["Default Menu Theme"];
CGMZ.MenuTheme.Variable = Number(CGMZ.MenuTheme.parameters["Menu Theme Variable"]) || 0;
CGMZ.MenuTheme.VariableThemes = CGMZ.MenuTheme.parameters["Variable Menu Themes"];
if(CGMZ.MenuTheme.Variable !== 0) {
	CGMZ.MenuTheme.VariableThemes = JSON.parse(CGMZ.MenuTheme.parameters["Variable Menu Themes"]);
}
//=============================================================================
// Game System
//-----------------------------------------------------------------------------
// Do not save menu BGM (instead save previous BGM)
//=============================================================================
//-----------------------------------------------------------------------------
// Save the correct BGM (not Menu Theme)
//-----------------------------------------------------------------------------
const alias_CGMZ_MenuTheme_GameSystem_onBeforeSave = Game_System.prototype.onBeforeSave;
Game_System.prototype.onBeforeSave = function() {
    alias_CGMZ_MenuTheme_GameSystem_onBeforeSave.call(this);
	if($cgmzTemp.isPlayingMenuTheme()) {
		this._bgmOnSave = $cgmzTemp.getSavedBgmForMenuTheme();
	}
};
//=============================================================================
// Scene Menu
//-----------------------------------------------------------------------------
// Handling for playing menu theme
//=============================================================================
//-----------------------------------------------------------------------------
// Play menu theme if player came from map
//-----------------------------------------------------------------------------
const alias_CGMZ_MenuTheme_SceneMenu_start = Scene_Menu.prototype.start;
Scene_Menu.prototype.start = function() {
    alias_CGMZ_MenuTheme_SceneMenu_start.call(this);
    if(SceneManager.isPreviousScene(Scene_Map)) {
		$cgmzTemp.playMenuTheme();
	}
};
//-----------------------------------------------------------------------------
// Replay map music if returning to map
//-----------------------------------------------------------------------------
const alias_CGMZ_MenuTheme_SceneMenu_terminate = Scene_Menu.prototype.terminate;
Scene_Menu.prototype.terminate = function() {
	alias_CGMZ_MenuTheme_SceneMenu_terminate.call(this);
    if(SceneManager.isNextScene(Scene_Map)) {
		$cgmzTemp.replayPreviousMenuThemeBgm();
	}
};
//=============================================================================
// CGMZ Temp
//-----------------------------------------------------------------------------
// Handles saving past BGM and switching which BGM is playing
//=============================================================================
//-----------------------------------------------------------------------------
// Initialize the previous BGM for menu theme to empty sound file
//-----------------------------------------------------------------------------
const alias_CGMZ_MenuTheme_CGMZTemp_createPluginData = CGMZ_Temp.prototype.createPluginData;
CGMZ_Temp.prototype.createPluginData = function() {
	alias_CGMZ_MenuTheme_CGMZTemp_createPluginData.call(this);
	this._previousBGMForMenuTheme = null;
	this._isPlayingMenuTheme = false;
	if(CGMZ.MenuTheme.Variable === 0) {
		this._menuThemeBgm = {name: CGMZ.MenuTheme.Theme, volume: 100, pitch: 100, pan: 0, pos: 0};
	} else {
		let variableValue = $gameVariables.value(CGMZ.MenuTheme.Variable);
		if(variableValue > CGMZ.MenuTheme.VariableThemes.length) {
			variableValue = 0;
		}
		this._menuThemeBgm = {name: CGMZ.MenuTheme.VariableThemes[variableValue], volume: 100, pitch: 100, pan: 0, pos: 0};
	}
};
//-----------------------------------------------------------------------------
// Play menu theme, save previous bgm
//-----------------------------------------------------------------------------
CGMZ_Temp.prototype.setMenuThemeToPlay = function() {
	if(CGMZ.MenuTheme.Variable !== 0) {
		let variableValue = $gameVariables.value(CGMZ.MenuTheme.Variable);
		if(variableValue > CGMZ.MenuTheme.VariableThemes.length) {
			variableValue = 0;
		}
		const name = CGMZ.MenuTheme.VariableThemes[variableValue];
		if(name !== this._menuThemeBgm.name) {
			this._menuThemeBgm = {name: CGMZ.MenuTheme.VariableThemes[variableValue], volume: 100, pitch: 100, pan: 0, pos: 0};
		}
	}
};
//-----------------------------------------------------------------------------
// Play menu theme, save previous bgm
//-----------------------------------------------------------------------------
CGMZ_Temp.prototype.playMenuTheme = function() {
	this._isPlayingMenuTheme = true;
    this._previousBGMForMenuTheme = AudioManager.saveBgm();
	this.setMenuThemeToPlay();
	if(this._menuThemeBgm.pos !== 0) {
		AudioManager.replayBgm(this._menuThemeBgm);
	} else {
		AudioManager.playBgm(this._menuThemeBgm);
	}
};
//-----------------------------------------------------------------------------
// Replay saved bgm for menu theme
//-----------------------------------------------------------------------------
CGMZ_Temp.prototype.replayPreviousMenuThemeBgm = function() {
	this._isPlayingMenuTheme = false;
    if (this._previousBGMForMenuTheme) {
		this._menuThemeBgm = AudioManager.saveBgm();
        AudioManager.replayBgm(this._previousBGMForMenuTheme);
    }
};
//-----------------------------------------------------------------------------
// Determine if currently playing menu theme
//-----------------------------------------------------------------------------
CGMZ_Temp.prototype.isPlayingMenuTheme = function() {
	return this._isPlayingMenuTheme;
};
//-----------------------------------------------------------------------------
// Get the saved BGM if menu theme is playing
//-----------------------------------------------------------------------------
CGMZ_Temp.prototype.getSavedBgmForMenuTheme = function() {
	if(this._previousBGMForMenuTheme) {
		return this._previousBGMForMenuTheme;
	}
	return AudioManager.makeEmptyAudioObject();
};