// ==================================================
// Cae_MenuDisplayOpts.js
// ==================================================

/**
 * @file Cae_MenuDisplayOpts.js (RMMZ)
 * Various menu-related display and control options.
 * @author Caethyril
 * @version 1.4
 */

//#region Plugin header
/*:
 * @target MZ
 * @plugindesc v1.4 - Various menu-related display and control options.
 * @author Caethyril
 * @url https://forums.rpgmakerweb.com/index.php?threads/125657/
 * 
 * @help Features:
 *   Each feature is optional~
 * 
 *   - Resize the command cursor to match the text width.
 *   - Disable cursor blinking animation.
 *   - Block the cursor from wrapping top-bottom and/or left-right.
 *   - Select final entry in list if scroll down fails.
 * 
 *   - Remove the opening and/or closing animation of all windows.
 *   - Specify text alignment for choice windows.
 *   - Align choice window to message window, rather than to screen.
 *   - Adjust choice window Y-position when no message is showing.
 * 
 *   - Random messages (list on Terms tab in the database):
 *     - Write A|B|C and one will be randomly selected each time!
 *     - E.g. %1 runs away!|%1 tries to escape!|%1 doesn't want to be here.
 *   - Specify empty help text messages, so the help box isn't left blank.
 *   - Parse \v[x][y] as yth element of array stored in variable x.
 *   - Use text codes for the currency unit, e.g. \i[314]
 *       and/or rename the currency unit mid-game with a plugin command.
 * 
 *   - Adjust some window-related colours: outline, background, etc~
 * 
 *   - Show hidden item A and/or B categories in the inventory.
 *   - Adjust how much the volume options change when pressing left/right.
 *   - Swap the pause menu for a different scene (e.g. options or item).
 *   - Show an alternative scene when the menu is called while disabled.
 *   - Hide the HP, MP, or TP gauges.
 *   - Hide/remove specific settings from the options window.
 * 
 * Plugin command:
 *   - Rename Currency Unit - renames the currency unit!
 *                          - currency unit name is included in save data.
 *                          - note you can use text codes now instead~
 *
 *  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Terms of use:
 *   This plugin is free to use and/or modify, under these conditions:
 *     - None of the original plugin header is removed.
 *     - Credit is given to Caethyril for the original work.
 * 
 *  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Compatibility:
 *   Overrides: Scene_Menu (if a replacement is specified)
 *              TextManager:
 *                currencyUnit
 *              ColorManager (blank entries are skipped):
 *                outlineColor, dimColor1, dimColor2,
 *                itemBackColor1, itemBackColor2
 *              Window_ChoiceList:
 *                drawItem, itemTextAlign
 *              Window_SkillType:
 *                updateHelp
 *              Window_ItemCategory:
 *                updateHelp
 *              Window_EquipCommand:
 *                updateHelp
 *              Window_ShopCommand:
 *                updateHelp
 *              Window_Options:
 *                volumeOffset
 *              Window_Base:
 *                drawCurrencyValue
 *   Aliases:   Scene_Shop:
 *                create, onBuyCancel
 *              Scene_Map:
 *                updateCallMenu
 *              Scene_Options:
 *                maxCommands
 *              TextManager:
 *                message
 *              Window:
 *                _makeCursorAlpha
 *              Window_Base:
 *                open, close, convertEscapeCharacters
 *              Window_StatusBase:
 *                placeGauge
 *              Window_Selectable:
 *                cursorUp, cursorDown, cursorLeft, cursorRight
 *              Window_ChoiceList:
 *                windowX, windowY, start, isOkEnabled
 *              Window_Command:
 *                _updateCursor
 *              Window_EquipItem:
 *                updateHelp
 *              Window_EquipSlot:
 *                updateHelp
 *              Window_EventItem:
 *                start, isOkEnabled
 *              Window_ItemCategory:
 *                maxCols, makeCommandList
 *              Window_ItemList:
 *                updateHelp, includes
 *              Window_NumberInput:
 *                start, isOkEnabled
 *              Window_Options:
 *                addCommand
 *              Window_ShopBuy:
 *                updateHelp
 *              Window_ShopSell:
 *                updateHelp
 *              Window_SkillList:
 *                updateHelp
 *   Defines:   Game_System (if Rename Currency Unit plugin command is used):
 *                currencyUnit
 *   Other than currencyUnit, this plugin adds no data to save files.
 * 
 *  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Changelog:
 *   v1.4 (2021-11-16): Added - Release OK Before Choice parameter.
 *   v1.3 (2020-09-07): Added - features for these plugin parameters:
 *                                "Currency Text Codes",
 *                                "Hidden Item A Name",
 *                                "Hidden Item B Name",
 *                                "Volume Divisions",
 *                                "Hide Options",
 *                                "Disabled Pause Menu".
 *                      Various edits to improve compatibility.
 *   v1.2 (2020-08-30): Added - internal text-width-cursor window blacklist.
 *                              e.g. now the options window doesn't use it.
 *   v1.1 (2020-08-29): Added - "Only Choice Y Alignment" plugin parameter.
 *   v1.0 (2020-08-29): Initial release! Merge/extension of my RMMV plugins.
 * 
 * @command Rename Currency Unit
 * @desc Lets you rename the currency unit mid-game.
 * 
 * @arg Name
 * @type string
 * @desc The new name for the currency unit
 * @default
 *
 * @param --- Menu Cursor ---
 * @type select
 * @desc Options for customising how the menu cursor looks/behaves.
 *
 * @param Text-Width Cursor
 * @parent --- Menu Cursor ---
 * @type boolean
 * @desc If true, the selection cursor will match the text width in command windows (skill/item selection is unaffected).
 * @default false
 * 
 * @param No Menu Cursor Blink
 * @parent --- Menu Cursor ---
 * @type boolean
 * @desc If true, the menu selection cursor will not blink.
 * @default false
 *
 * @param No Cursor Wrap Up/Down
 * @parent --- Menu Cursor ---
 * @type boolean
 * @desc If true, prevents being able to scroll up from the top row or down from the bottom row in command windows.
 * @default false
 *
 * @param No Cursor Wrap Left/Right
 * @parent --- Menu Cursor ---
 * @type boolean
 * @desc If true, prevents being able to scroll left from the left-most column or right from the right-most column in command windows.
 * @default false
 * 
 * @param Scroll Can Change Column
 * @parent --- Menu Cursor ---
 * @type boolean
 * @desc If true, failed "scroll down" actions will automatically select the last entry in the selectable list.
 * @default false
 *
 * @param --- Game Windows ---
 * @type select
 * @desc Various options relating to how windows display in-game.
 *
 * @param Instant Open
 * @parent --- Game Windows ---
 * @type boolean
 * @desc If true, all windows will open instantly.
 * @default false
 *
 * @param Instant Close
 * @parent --- Game Windows ---
 * @type boolean
 * @desc If true, all windows will close instantly.
 * @default false
 * 
 * @param Release OK Before Choice
 * @parent --- Game Windows ---
 * @type boolean
 * @desc If true, the OK button must be released before selecting a message choice, number, or item.
 * @default true
 *
 * @param Choice Text Alignment
 * @parent --- Game Windows ---
 * @type combo
 * @option left
 * @option center
 * @option right
 * @option match window
 * @desc Choose how the Show Choices text is aligned in its window.
 * "match window" means they're centred if the window is, etc.
 * @default left
 * 
 * @param Align Choice to Message
 * @parent --- Game Windows ---
 * @type boolean
 * @desc If true, choice window will be aligned relative to the message window rather than the screen.
 * @default false
 * 
 * @param Only Choice Y Alignment
 * @parent --- Game Windows ---
 * @type combo
 * @option Default
 * @option Top
 * @option Middle
 * @option Bottom
 * @desc Where to position the choice window when there is no message displaying.
 * @default Default
 * 
 * @param --- Messages ---
 * @type select
 * @desc Options relating to messages/text.
 * 
 * @param Random Msg Splitter
 * @parent --- Messages ---
 * @type combo
 * @option |
 * @desc Splits multiple possible messages (database Terms tab).
 * Leave blank to disable this feature.
 * @default |
 * 
 * @param Empty Help Text
 * @parent --- Messages ---
 * @type struct<HelpTextType>
 * @desc Defines help text to display, where it would otherwise be blank. Random Msg Splitter and text codes work here.
 * @default {"Generic":"Navigate using the arrow keys.\nPress \\c[4]Z\\c[0] or \\c[4]Enter\\c[0] to select, \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","ItemCategory":"Select an item category!\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","ItemList":"No items to see here.\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","SkillType":"Select a skill type!\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","SkillList":"No skills to see here.\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","EquipCommand":"","EquipSlot":"This equip slot is empty.\nPress \\c[4]Z\\c[0] or \\c[4]Enter\\c[0] to choose an item to equip!","EquipItem":"You have nothing to equip in this slot.\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","ShopCommand":"","ShopBuy":"There's nothing here to purchase.\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back.","ShopSell":"You have no items of this type to sell.\nPress \\c[4]X\\c[0] or \\c[4]Esc\\c[0] to go back."}
 * 
 * @param Show Text \v[x][y]
 * @parent --- Messages ---
 * @type boolean
 * @desc If true, enables parsing of array variable x, entry y in Show Text commands.
 * @default false
 * 
 * @param Currency Text Codes
 * @parent --- Messages ---
 * @type boolean
 * @desc If true, you can use text codes in the currency name.
 * @default false
 * 
 * @param --- ColorManager ---
 * @type select
 * @desc Customise some window-related colours!
 * 
 * @param Outline Colour
 * @parent --- ColorManager ---
 * @type struct<RGBAType>
 * @desc Used for text outlines.
 * Default: 0, 0, 0, 0.6 (60% opaque black).
 * @default {"R":"0","G":"0","B":"0","A":"0.6"}
 * 
 * @param Dim Colour 1
 * @parent --- ColorManager ---
 * @type struct<RGBAType>
 * @desc Used for one end of Dim window backgrounds.
 * Default: 0, 0, 0, 0.6 (60% opaque black).
 * @default {"R":"0","G":"0","B":"0","A":"0.6"}
 * 
 * @param Dim Colour 2
 * @parent --- ColorManager ---
 * @type struct<RGBAType>
 * @desc Used for the other end of Dim window backgrounds.
 * Default: 0, 0, 0, 0 (100% transparent).
 * @default {"R":"0","G":"0","B":"0","A":"0"}
 * 
 * @param Item Back Colour 1
 * @parent --- ColorManager ---
 * @type struct<RGBAType>
 * @desc Used for background boxes in selectable lists (border + fill). Default: 32, 32, 32, 0.5 (50% opaque grey-black).
 * @default {"R":"32","G":"32","B":"32","A":"0.5"}
 * 
 * @param Item Back Colour 2
 * @parent --- ColorManager ---
 * @type struct<RGBAType>
 * @desc Used for background boxes in selectable lists (fill). Default: 0, 0, 0, 0.5 (50% opaque black).
 * @default {"R":"0","G":"0","B":"0","A":"0.5"}
 * 
 * @param --- Other ---
 * @type select
 * @desc Options that don't fit into other categories.
 * 
 * @param Hidden Item A Name
 * @parent --- Other ---
 * @type string
 * @desc In-game name for the Hidden Item A inventory category.
 * Will remain hidden if left blank.
 * @default
 * 
 * @param Hidden Item B Name
 * @parent --- Other ---
 * @type string
 * @desc In-game name for the Hidden Item B inventory category.
 * Will remain hidden if left blank.
 * @default
 * 
 * @param Volume Divisions
 * @parent --- Other ---
 * @type number
 * @min 1
 * @max 100
 * @desc How many times you need to press left/right to go from 0 to 100 volume in the options. Default: 5.
 * @default 5
 * 
 * @param Pause Menu Swap
 * @parent --- Other ---
 * @type combo
 * @option No Swap
 * @option Options
 * @option GameEnd
 * @option Item
 * @option Skill
 * @option Status
 * @desc Swaps the pause menu for a completely different scene.
 * Remember to provide players with a way to save etc!
 * @default No Swap
 * 
 * @param Disabled Pause Menu
 * @parent --- Other ---
 * @type combo
 * @option None
 * @option Options
 * @option GameEnd
 * @option Status
 * @desc Specify a scene to go to if the menu is disabled and the player tries to open the menu.
 * @default None
 * 
 * @param Hide Gauges
 * @parent --- Other ---
 * @type combo[]
 * @option hp
 * @option mp
 * @option tp
 * @desc List of gauge IDs to hide in-game.
 * @default []
 * 
 * @param Hide Options
 * @parent --- Other ---
 * @type combo[]
 * @option alwaysDash
 * @option commandRemember
 * @option touchUI
 * @option bgmVolume
 * @option bgsVolume
 * @option meVolume
 * @option seVolume
 * @desc Options listed here will not be shown in-game.
 * @default []
 * 
 * @param --- Advanced ---
 * @type select
 * @desc Advanced internal configuration options.
 * 
 * @param Hidden Item A Symbol
 * @parent --- Advanced ---
 * @type string
 * @desc Internal symbol for Hidden Item A category.
 * Default: hiddenItemA
 * @default hiddenItemA
 * 
 * @param Hidden Item B Symbol
 * @parent --- Advanced ---
 * @type string
 * @desc Internal symbol for Hidden Item B category.
 * Default: hiddenItemB
 * @default hiddenItemB
 */
// =========================
/*~struct~HelpTextType:
 * @param Generic
 * @type multiline_string
 * @desc The help text displayed if no window-specific replacement is defined.
 * @default Navigate using the arrow keys.
 * Press \c[4]Z\c[0] or \c[4]Enter\c[0] to select, \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 *
 * @param ItemCategory
 * @type multiline_string
 * @desc The help text displayed when choosing an item category.
 * @default Select an item category!
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 * 
 * @param ItemList
 * @type multiline_string
 * @desc The help text displayed when navigating an empty item list.
 * @default No items to see here.
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 * 
 * @param SkillType
 * @type multiline_string
 * @desc The help text displayed when choosing a skill type.
 * @default Select a skill type!
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 * 
 * @param SkillList
 * @type multiline_string
 * @desc The help text displayed when navigating an empty skill list.
 * @default No skills to see here.
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 * 
 * @param EquipCommand
 * @type multiline_string
 * @desc The help text displayed when choosing what action to take on equipped items.
 * @default
 * 
 * @param EquipSlot
 * @type multiline_string
 * @desc The help text displayed when highlighting an empty equip slot.
 * @default This equip slot is empty.
 * Press \c[4]Z\c[0] or \c[4]Enter\c[0] to choose an item to equip!
 * 
 * @param EquipItem
 * @type multiline_string
 * @desc The help text displayed when navigating an empty equips list (after selecting an equip slot).
 * @default You have nothing to equip in this slot.
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 * 
 * @param ShopCommand
 * @type multiline_string
 * @desc The help text displayed when choosing to buy or sell in a shop.
 * @default
 * 
 * @param ShopBuy
 * @type multiline_string
 * @desc The help text displayed when navigating a shop with no goods to buy. O_o
 * @default There are no items to purchase.
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 * 
 * @param ShopSell
 * @type multiline_string
 * @desc The help text displayed when choosing an item to sell when you have no valid item.
 * @default You have no items of this type to sell.
 * Press \c[4]X\c[0] or \c[4]Esc\c[0] to go back.
 */
// =========================
/*~struct~RGBAType:
 * @param R
 * @type number
 * @max 255
 * @decimals 0
 * @desc Red. 0 = no red, 255 = full red.
 * @default 0
 * 
 * @param G
 * @type number
 * @max 255
 * @decimals 0
 * @desc Green. 0 = no green, 255 = full green.
 * @default 0
 * 
 * @param B
 * @type number
 * @max 255
 * @decimals 0
 * @desc Blue. 0 = no blue, 255 = full blue.
 * @default 0
 * 
 * @param A
 * @type number
 * @max 1
 * @decimals 2
 * @desc Alpha. 0 = transparent, 1 = opaque.
 * @default 0
 */
//#endregion

(function() {
'use strict';

    const NAMESPACE   = 'MenuDisplayOpts';
    const PLUGIN_NAME = 'Cae_' + NAMESPACE;
    const ERR_PRE     = PLUGIN_NAME + '.js ';
    const ERR_NOPARAM = ERR_PRE + 'could not find its parameters!\nCheck the plugin file is named correctly and try again.';

    window.CAE = window.CAE || {};      // Author namespace

    (($, U) => {

        Object.defineProperty($, 'VERSION', { value: 1.4 });    // Version declaration
        window.Imported = window.Imported || {};                // Import namespace
        Imported[PLUGIN_NAME] = $.VERSION;                      // Import declaration

    // ======== Utility (share) ======== //
    // ======== Parameter stuff ======== //

        void (p => {

            if (!p) { SceneManager.showDevTools(); throw new Error(ERR_NOPARAM); };

            $.comboRef = {};

            $.parse = {
                bool:  function(name) { return p[name] === 'true'; },
                int:   function(name) { return parseInt(p[name], 10) || 0; },
                trim:  function(name) { return String(p[name] || '').trim(); },
                combo: function(name) { return $.comboRef[name].indexOf(p[name]); },
                obj:   function(name) { return JSON.parse(p[name] || '{}'); },
                arr:   function(name) { return JSON.parse(p[name] || '[]'); },
                sArr:  function(name) { return $.parse.arr(name).map(s => String(s || '').trim()); },
                rgba:  function(name) {
                    const o = $.parse.obj(name);
                    return 'rgba(' + ['G','B','A'].reduce((a, c) => a += ',' + (o[c] || '0'), o.R || '0') + ')';
                }
            };

            $.cursor = {
                txtW           : $.parse.bool('Text-Width Cursor'),
                noBlinkMnu     : $.parse.bool('No Menu Cursor Blink'),
                noWrapV        : $.parse.bool('No Cursor Wrap Up/Down'),
                noWrapH        : $.parse.bool('No Cursor Wrap Left/Right'),
                scrollCrossCol : $.parse.bool('Scroll Can Change Column')
            };

            $.win = {
                instantOpen    : $.parse.bool('Instant Open'),
                instantClose   : $.parse.bool('Instant Close'),
                releaseInput   : $.parse.bool('Release OK Before Choice'),
                choiceTxtAlign : $.parse.trim('Choice Text Alignment') || 'left',
                alignChoiceMsg : $.parse.bool('Align Choice to Message'),
                alignChoiceY   : $.parse.trim('Only Choice Y Alignment')
            };

            $.msg = {
                helpText      : $.parse.obj('Empty Help Text'),
                randomSplit   : $.parse.trim('Random Msg Splitter') || '|',
                arrVar        : $.parse.bool('Show Text \\v[x][y]'),
                currencyCodes : $.parse.bool('Currency Text Codes')
            };

            $.cm = {
                outlineColor   : $.parse.rgba('Outline Colour'),
                dimColor1      : $.parse.rgba('Dim Colour 1'),
                dimColor2      : $.parse.rgba('Dim Colour 2'),
                itemBackColor1 : $.parse.rgba('Item Back Colour 1'),
                itemBackColor2 : $.parse.rgba('Item Back Colour 2')
            };

            $.misc = {
                hiddenCatA : $.parse.trim('Hidden Item A Name'),
                hiddenCatB : $.parse.trim('Hidden Item B Name'),
                volumeDivs : $.parse.int('Volume Divisions'),
                hiddenOpts : $.parse.sArr('Hide Options'),
                altPause   : $.parse.trim('Pause Menu Swap'),
                disPause   : $.parse.trim('Disabled Pause Menu'),
                hideGauges : $.parse.sArr('Hide Gauges')
            };

            $.RGX = {
                ARRVAR : '\\\\V\\[(\\d+)\\]',
                ARRIX  : '\\[(.*)\\]\\[(\\d+)\\]'		
            };

            Object.defineProperty($, 'SYM_HIDDENITEMA', { value: $.parse.trim('Hidden Item A Symbol') || 'hiddenItemA' });
            Object.defineProperty($, 'SYM_HIDDENITEMB', { value: $.parse.trim('Hidden Item B Symbol') || 'hiddenItemB' });

        })($.params = PluginManager.parameters(PLUGIN_NAME));

        // Windows listed here should not use the text-width cursor, irrespective of inheritance.
        $.textWidthCursorExceptions = [Window_Options];

    // ========= Init Routines ========= //
    // ======== Utility (local) ======== //

        /** Regular expression replacer function; retains [] on arrays, otherwise as default. */
        $.parseArrVar = function() {
            const v = $gameVariables.value(parseInt(arguments[1], 10));
            return Array.isArray(v) ? '[' + v + ']' : v;
        };

        /** Regular expression replacer function: swaps [a,b,...][y] for index y of array [a,b,...]. */
        $.parseArrIx = function() { return arguments[1].split(',')[parseInt(arguments[2], 10) || 0]; };

        /**
         * @param {String} text - Input text
         * @returns {String} Random substring from splitting input by random split character.
         */
        $.randomSubstring = function(text) {
            const SPLIT = $.msg.randomSplit;
            if (!SPLIT) return text;
            const arr = String(text || '').split(SPLIT);
            return arr[Math.randomInt(arr.length)];
        };

        /**
         * Creates and applies an alias/override for a given window's updateHelp method.
         * @param {String} name - Name of the window constructor, minus the Window_ part
         * @param {Boolean} inherit - If true, make a postfix-alias; else make an override
         * @param {String} helpText - Base text to display as help; if blank will show generic text instead
         */
        $.makeUpdateHelp = function(name, inherit, helpText) {
            const c = 'Window_' + name;
            if (!c) return false;
            const w = window[c];
            if (!w) return false;
            const txt = helpText || $.msg.helpText.Generic || '';
            if (inherit) {
                void (alias => {
                    w.prototype.updateHelp = function() {
                        alias.apply(this, arguments);
                        const hw = this._helpWindow;
                        if (hw && !hw._text) hw.setText($.randomSubstring(txt));
                    };
                })($.alias[c + '_updateHelp'] = w.prototype.updateHelp);
            } else {
                w.prototype.updateHelp = function() {
                    const hw = this._helpWindow;
                    if (hw) hw.setText($.randomSubstring(txt));
                };
            }
            return true;
        };

    // ======== Plugin Commands ======== //

        $.com = {
            /** Plugin command! Change the system's currency unit name. */
            setCurrency:  function(args) { $gameSystem.currencyUnit = args.Name; },
        };
        PluginManager.registerCommand(PLUGIN_NAME, 'Rename Currency Unit', $.com.setCurrency);

    // ============ Extends ============ //
    // ========== Alterations ========== //

        // Override! Currency unit that can change mid-game.
        Object.defineProperty(TextManager, 'currencyUnit', {
            get: function() { return $gameSystem.currencyUnit || $dataSystem.currencyUnit; },
            configurable: true
        });

        // Override! Replace specified ColorManager colours.
        Object.keys($.cm).forEach(k => {
            if (!k) return;
            ColorManager[k] = function() { return $.cm[k]; };
        });

        $.alias = $.alias || {};        // This plugin's alias namespace

    // ~~~~ cursor ~~~~ //

        // Alias! Command cursor to text width.
        void (alias => { if (!$.cursor.txtW) return;
            Window_Command.prototype._updateCursor = function() {
                alias.apply(this, arguments);
                if ($.textWidthCursorExceptions.some(w => this instanceof w)) return;
                const current = this.currentData();
                if (current && !this.cursorAll()) {
                    const rect = this.itemRect(this.index());
                    const w = Math.min(this.textSizeEx(current.name || '').width + this.itemPadding() * 2, rect.width);
                    const dw = rect.width - w;
                    const frac = Math.max(['left','center','right'].indexOf(this.itemTextAlign()), 0);
                    const x = rect.x + frac * dw / 2;
                    this.setCursorRect(x, rect.y, w, rect.height);
                }
            };
        })($.alias.Window_Command__updateCursor = Window_Command.prototype._updateCursor);

        // Override! Remove cursor alpha blinking.
        void (() => { if (!$.cursor.noBlinkMnu) return;
            Window.prototype._makeCursorAlpha = function() { return this.contentsOpacity / 255; };
        })();

        // Alias! No up -> down cursor wrapping (up only; down is just below, y'know?).
        void (alias => {
            Window_Selectable.prototype.cursorUp = function(wrap, ...args) {
                alias.call(this, $.cursor.noWrapV ? false : wrap, ...args);
            };
        })($.alias.Window_Selectable_cursorUp = Window_Selectable.prototype.cursorUp);

        // Alias! No down -> up cursor wrapping + column switch on failed down-scroll.
        void (alias => {
            Window_Selectable.prototype.cursorDown = function(wrap, ...args) {
                const prev = this.index();
                alias.call(this, $.cursor.noWrapV ? false : wrap, ...args);
                if ($.cursor.scrollCrossCol && prev === this.index()) this.select(this.maxItems() - 1);
            };
        })($.alias.Window_Selectable_cursorDown = Window_Selectable.prototype.cursorDown);

        // Alias! No left -> right cursor wrapping.
        void (alias => {
            Window_Selectable.prototype.cursorLeft = function(wrap, ...args) {
                alias.call(this, $.cursor.noWrapH ? false : wrap, ...args);
            };
        })($.alias.Window_Selectable_cursorLeft = Window_Selectable.prototype.cursorLeft);

        // Alias! No right -> left cursor wrapping.
        void (alias => {
            Window_Selectable.prototype.cursorRight = function(wrap, ...args) {
                alias.call(this, $.cursor.noWrapH ? false : wrap, ...args);
            };
        })($.alias.Window_Selectable_cursorRight = Window_Selectable.prototype.cursorRight);

    // ~~~~ game windows ~~~~ //

        // Alias! Instant window open.
        void (alias => { if (!$.win.instantOpen) return;
            Window_Base.prototype.open = function() {
                alias.apply(this, arguments);
                this.openness = 255;
            };
        })($.alias.Window_Base_open = Window_Base.prototype.open);

        // Alias! Instant window close.
        void (alias => { if (!$.win.instantClose) return;
            Window_Base.prototype.close = function() {
                alias.apply(this, arguments);
                this.openness = 0;
            };
        })($.alias.Window_Base_close = Window_Base.prototype.close);

        // Aliases! Safeguards against skipped messages, especially with Instant Open.
        void (() => { if (!$.win.releaseInput) return;

            Object.defineProperty($, 'SYM_RELEASE_BEFORE_OK', { value: Symbol() });
            const S = $.SYM_RELEASE_BEFORE_OK;                      // flag
            const w = ['ChoiceList', 'NumberInput', 'EventItem'];   // affected game windows
            const f = Input.isPressed.bind(Input, 'ok');            // trigger checker
            
            // Disable OK if apt
            for (const c of w) {
                (alias => {
                    window['Window_' + c].prototype.isOkEnabled = function() {
                        if (this[S])
                            if (!f()) delete this[S];
                            else return false;
                        return alias.apply(this, arguments);
                    };
                })(window['Window_' + c].prototype.isOkEnabled);
            }
            
            // Set flag if OK is pressed when the window starts
            for (const c of w) {
                (alias => {
                    window['Window_' + c].prototype.start = function() {
                        if (f()) this[S] = true;
                        alias.apply(this, arguments);
                    };
                })(window['Window_' + c].prototype.start);
            }
            
        })();

        void (alias => { if (!$.win.alignChoiceMsg) return;

            // Alias! Align choice window to the message window.
            Window_ChoiceList.prototype.windowX = function() {
                const msgWin = this._messageWindow;
                const dw = msgWin.width - Graphics.boxWidth;
                let dx = msgWin.x;
                switch ($gameMessage.choicePositionType()) {
                    case 1: dx += dw / 2; break;        // Center
                    case 2: dx += dw;     break;        // Right
                }
                return alias.apply(this, arguments) + dx;
            };

            // Override! Properly define and apply choice window text alignment
            Window_ChoiceList.prototype.itemTextAlign = function() {
                const align = $.win.choiceTxtAlign;
                const NAMES = ['left','center','right'];
                return align === 'match window' ? NAMES[$gameMessage.choicePositionType()] || 'left' : align;
            };

            // Override! Use the inherited method, it's more flexible... >_>
            Window_ChoiceList.prototype.drawItem = Window_Command.prototype.drawItem;

        })($.alias.Window_ChoiceList_windowX = Window_ChoiceList.prototype.windowX);

        // Alias! Vertically align choice window when unaccompanied by a message window.
        void (alias => { if ($.win.alignChoiceY === 'Default') return;
            Window_ChoiceList.prototype.windowY = function() {
                if (this._messageWindow.isClosed()) {
                    const dh = Graphics.boxHeight - this.windowHeight();
                    switch ($.win.alignChoiceY) {
                        case 'Top':    return 0;
                        case 'Middle': return dh / 2;
                        case 'Bottom': return dh;
                    }
                }
                return alias.apply(this, arguments);
            };
        })($.alias.Window_ChoiceList_windowY = Window_ChoiceList.prototype.windowY);

    // ~~~~ messages ~~~~ //

        // Override! Allow text codes in currency name.
        // (Maybe there's an easy way to make text codes global thru drawText? Where is alignment used anyway?)
        void (() => { if (!$.msg.currencyCodes) return;
            Window_Base.prototype.drawCurrencyValue = function(value, unit, x, y, width) {
                const unitWidth = Math.min(80, this.textSizeEx(unit).width);
                this.resetTextColor();
                this.drawText(value, x, y, width - unitWidth - 6, "right");
                this.changeTextColor(ColorManager.systemColor());
                this.drawTextEx(unit, x + width - unitWidth, y, unitWidth);
            };
        })();

        // For help text stuff. This was...more harrowing than anticipated.
        void (o => {

            $.makeUpdateHelp('ShopSell',     true,  o.ShopSell);        // Alias! - inherits ItemList
            $.makeUpdateHelp('ItemList',     true,  o.ItemList);        // Alias!
            $.makeUpdateHelp('SkillList',    true,  o.SkillList);       // Alias!
            $.makeUpdateHelp('EquipItem',    true,  o.EquipItem);       // Alias!
            $.makeUpdateHelp('ShopBuy',      true,  o.ShopBuy);         // Alias!
            $.makeUpdateHelp('EquipSlot',    true,  o.EquipSlot);       // Alias!
            $.makeUpdateHelp('SkillType',    false, o.SkillType);       // Override! - default no help
            $.makeUpdateHelp('ItemCategory', false, o.ItemCategory);    // Override! - default no help
            $.makeUpdateHelp('EquipCommand', false, o.EquipCommand);    // Override! - default no help
            $.makeUpdateHelp('ShopCommand',  false, o.ShopCommand);     // Override! - default no help
            
            // Aliases! Why is the shop such a mess? Recette!
            void (alias => {
                Scene_Shop.prototype.create = function() {
                    alias.apply(this, arguments);
                    this._commandWindow.setHelpWindow(this._helpWindow);
                    this._commandWindow.reselect();     // refresh help
                };
            })(Scene_Shop.prototype.create);
            void (alias => {
                Scene_Shop.prototype.onBuyCancel = function() {
                    alias.apply(this, arguments);
                    this._commandWindow.reselect();     // refresh help
                };
            })(Scene_Shop.prototype.onBuyCancel);

        })($.msg.helpText);

        // Alias! Support for random messages.
        void (alias => { if (!$.msg.randomSplit) return;
            TextManager.message = function(messageId) {
                return $.randomSubstring(alias.apply(this, arguments));
            };
        })($.alias.TextManager_message = TextManager.message);

        // Alias! \v[x][y] text code parsing. Overkill for good measure.
        void (alias => { if (!$.msg.arrVar) return;
            Window_Base.prototype.convertEscapeCharacters = function(text = '', ...args) {
                text = text.replace(new RegExp($.RGX.ARRVAR, 'gi'), $.parseArrVar.bind(this));
                text = text.replace(new RegExp($.RGX.ARRVAR, 'gi'), $.parseArrVar.bind(this));
                text = alias.call(this, text, ...args);
                text = text.replace(new RegExp($.RGX.ARRVAR, 'gi'), $.parseArrVar.bind(this));
                text = text.replace(new RegExp($.RGX.ARRVAR, 'gi'), $.parseArrVar.bind(this));
                text = text.replace(new RegExp($.RGX.ARRIX, 'gi'), $.parseArrIx.bind(this));
                text = text.replace(new RegExp($.RGX.ARRIX, 'gi'), $.parseArrIx.bind(this));
                return text;
            };
        })(Window_Base.prototype.convertEscapeCharacters);

    // ~~~~ other ~~~~ //

        // Hidden item categories~
        void ((a, b) => { if (!a && !b) return;

            // Alias! Add more columns to item category window as needed.
            void (alias => {
                Window_ItemCategory.prototype.maxCols = function() {
                    return alias.apply(this, arguments) + (a ? 1 : 0) + (b ? 1 : 0);
                };
            })($.alias.Window_ItemCategory_maxCols = Window_ItemCategory.prototype.maxCols);

            // Alias! Add commands to item category window as needed.
            void (alias => {
                Window_ItemCategory.prototype.makeCommandList = function() {
                    alias.apply(this, arguments);
                    if (a) this.addCommand(a, $.SYM_HIDDENITEMA);
                    if (b) this.addCommand(b, $.SYM_HIDDENITEMB);
                };
            })($.alias.Window_ItemCategory_makeCommandList = Window_ItemCategory.prototype.makeCommandList);

            // Alias! Show "hidden item" types in inventory when appropriate.
            void (alias => {
                Window_ItemList.prototype.includes = function(item) {
                    switch (this._category) {
                        case $.SYM_HIDDENITEMA:
                            return DataManager.isItem(item) && item.itypeId === 3;
                        case $.SYM_HIDDENITEMB:
                            return DataManager.isItem(item) && item.itypeId === 4;
                        default:
                            return alias.apply(this, arguments);
                    }
                };
            })($.alias.Window_ItemList_includes = Window_ItemList.prototype.includes);

        })($.misc.hiddenCatA, $.misc.hiddenCatB);

        // Override! Adjust volume offset value for options menu.
        void (divs => { if (divs <= 0) return;
            Window_Options.prototype.volumeOffset = function() { return Math.ceil(100 / divs); };
        })($.misc.volumeDivs);

        // Hide specified options
        void (hideList => { if (!hideList.length) return;

            // Alias! Hide specified commands from the options window.
            void (alias => {
                Window_Options.prototype.addCommand = function(name, symbol, enabled, ext) {
                    console.log(symbol, hideList);
                    if (!hideList.includes(symbol)) alias.apply(this, arguments);
                };
            })($.alias.Window_Options_addCommand = Window_Options.prototype.addCommand);
            
            // Alias! Reduce number of commands by one per hidden setting (don't bother checking existence).
            void (alias => {
                Scene_Options.prototype.maxCommands = function() {
                    return Math.max(alias.apply(this, arguments) - hideList.length, 1);
                };
            })($.alias.Scene_Options_maxCommands = Scene_Options.prototype.maxCommands);

        })($.misc.hiddenOpts);

        // Override! Swap Scene_Menu for something else~
        void (scMnu => { if (scMnu) Scene_Menu = scMnu; })(window['Scene_' + $.misc.altPause]);

        // Alias! Call alternative scene if menu called while disabled.
        void ((alias, disMnu) => { if (!disMnu) return;
            Scene_Map.prototype.updateCallMenu = function() {
                if (!this.isMenuEnabled() && this.isMenuCalled() && !$gamePlayer.isMoving()) {
                    SceneManager.push(disMnu);
                } else alias.apply(this, arguments);
            };
        })($.alias.Scene_Map_updateCallMenu = Scene_Map.prototype.updateCallMenu, window['Scene_' + $.misc.disPause])

        // Alias! Hide HP/MP/TP gauges.
        void (alias => { if (!$.misc.hideGauges.some(k => k)) return;
            Window_StatusBase.prototype.placeGauge = function(actor, type, x, y) {
                if (!$.misc.hideGauges.includes(type)) alias.apply(this, arguments);
            };
        })($.alias.Window_StatusBase_placeGauge = Window_StatusBase.prototype.placeGauge);

    })(CAE[NAMESPACE] = CAE[NAMESPACE] || {}, CAE.Utils = CAE.Utils || {});

})();