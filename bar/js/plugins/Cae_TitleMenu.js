// ==================================================
// Cae_TitleMenu.js
// ==================================================

/**
 * @file Cae_TitleMenu.js (RMMZ)
 * Customise title screen commands and layout.
 * @author Caethyril
 * @version 1.1
 */

//#region Plugin header
/*:
 * @target MZ
 * @plugindesc v1.1 - Customise title screen commands and layout.
 * @author Caethyril
 * @url https://forums.rpgmakerweb.com/index.php?threads/caethyrils-mz-plugins.125657/
 * @orderAfter VisuMZ_0_CoreEngine
 * @orderAfter Luna_Quit2Desktop
 * @orderAfter Cae_ScoreTable
 * 
 * @help Features:
 *   Each feature is optional!
 * 
 *   - Add custom "New Game" commands to the title menu~
 *     - Each one starts a new game at a custom position (map, x, y).
 *     - They can be hidden/shown and enabled/disabled with script conditions.
 *   - Display title commands in a block instead of a list.
 *     - "Max Commands" parameter determines commands per row.
 *     - All commands display at once, no scrolling.
 *
 *  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Terms of use:
 *   This plugin is free to use and/or modify, under these conditions:
 *     - None of the original plugin header is removed.
 *     - Credit is given to Caethyril for the original work.
 * 
 *  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Compatibility:
 *   Overrides: Window_TitleCommand:
 *                maxCols (if Horizontal Style is true)
 *   Aliases:   Window_TitleCommand:
 *                makeCommandList (recreates window contents after)
 *              Scene_Title:
 *                createCommandWindow
 *   Defines:   Scene_Title:
 *                commandAltStart
 *   This plugin does not add data to save files.
 *   Recommended: load this after other plugins that alter the title screen.
 * 
 *  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 * Changelog:
 *   v1.1 (2020-09-26): Added - 0 value for Max Commands parameter.
 *                      Added - some Plugin Manager load order warnings.
 *   v1.0 (2020-08-26): Initial release! Rewrite/extension of RMMV version.
 * 
 * @param New Game Commands
 * @type struct<ComNewGameType>[]
 * @desc List of custom New Game commands to add to the title menu.
 * @default []
 * 
 * @param Max No-Scroll Commands
 * @type number
 * @min 0
 * @desc Maximum title menu commands to display without scrolling.
 * Default: 0 (ignores this plugin setting)
 * @default 0
 * 
 * @param Block Style
 * @type boolean
 * @desc If true, title commands display in a rectangular block instead of a list. Multiple rows instead of scrolling.
 * @default false
 * 
 * @param JS: Block Width
 * @parent Block Style
 * @type string
 * @desc JavaScript eval: window width (px) if Block Style is true.
 * Default: Graphics.boxWidth * 0.8
 * @default Graphics.boxWidth * 0.8
 * 
 * @param --- Advanced ---
 * @type select
 * @desc Advanced internal configuration options.
 * 
 * @param New Game Symbol
 * @parent --- Advanced ---
 * @type string
 * @desc Pattern for the symbols of the custom New Game commands.
 * Not visible to the player. %1 = custom command index.
 * @default altStart%1
 */
// =========================
/*~struct~ComNewGameType:
 * @param Command Name
 * @type string
 * @desc Display name for the command added to the title menu.
 * @default Alt Start
 *
 * @param Map ID
 * @type number
 * @min 1
 * @desc ID of the destination map.
 * @default 1
 *
 * @param Map X
 * @type number
 * @min 0
 * @desc X-coordinate of arrival on the destination map.
 * @default 0
 *
 * @param Map Y
 * @type number
 * @min 0
 * @desc Y-coordinate of arrival on the destination map.
 * @default 0
 *
 * @param Command Position
 * @type number
 * @min -1
 * @desc Position to insert this command, 0 is the top of the list.
 * Use -1 for default behaviour (add to end of list).
 * @default -1
 *
 * @param JS: Visible
 * @type multiline_string
 * @desc JavaScript eval: if true, this command is visible.
 * Evaluated during makeCommandList.
 * @default true
 *
 * @param JS: Enabled
 * @type multiline_string
 * @desc JavaScript eval: if true, this command is enabled.
 * Evaluated during makeCommandList.
 * @default true
 */
//#endregion

(function() {
'use strict';

    const NAMESPACE    = 'TitleMenu';
    const PLUGIN_NAME  = 'Cae_' + NAMESPACE;
    const ERR_PRE      = PLUGIN_NAME + '.js ';
    const ERR_NOPARAM  = ERR_PRE + 'could not find its parameters!\nCheck the plugin file is named correctly and try again.';
    const ERR_EVAL     = ERR_PRE + 'eval error: "%1"\n\n%2';

    const WARN_SYMREQ  = ERR_PRE + '%1 parameter value "%2" does not contain required string "%3".\nReverting to default value: "%4".';
    const WARN_WATPROP = ERR_PRE + 'could not parse property %1.';

    window.CAE = window.CAE || {};      // Author namespace

    (($, U) => {

        Object.defineProperty($, 'VERSION', { value: 1.1 });    // Version declaration
        window.Imported = window.Imported || {};                // Import namespace
        Imported[PLUGIN_NAME] = $.VERSION;                      // Import declaration

    // ======== Utility (share) ======== //
    // ======== Parameter stuff ======== //

        void (p => {

            if (!p) { SceneManager.showDevTools(); throw new Error(ERR_NOPARAM); };

            const INTS = ['Map ID','Map X','Map Y','Command Position'];     // Keys of integer struct params

            $.com = JSON.parse(p['New Game Commands']).map(JSON.parse);
            $.com.forEach(o => {
                INTS.forEach(k => { o[k] = parseInt(o[k], 10) || 0; });
                if (o['Command Position'] < 0) o['Command Position'] = Number.MAX_SAFE_INTEGER;
            });
            $.com.sort((a, b) => a['Command Position'] - b['Command Position']);

            $.maxPageComs = Math.max(parseInt(p['Max No-Scroll Commands'], 10) || 0, 0);

            $.horz = p['Block Style'] === 'true';
            $.hWidth = p['JS: Block Width'] || 'Graphics.boxWidth * 0.8';

            Object.defineProperty($, 'SYM', { value: (v => {
                const REQ = '%1';
                const DEF_SYM = 'altStart%1';
                if (v && v.includes(REQ)) return v;
                console.warn(WARN_SYMREQ.format('Symbol Pattern', v, REQ, DEF_SYM));
                return DEF_SYM;
            })(p['New Game Symbol'])});

        })($.params = PluginManager.parameters(PLUGIN_NAME));

    // ========= Init Routines ========= //
    // ======== Utility (local) ======== //

        /**
         * Attempt eval of input string; on error, log to console and return provided catch value.
         * @param {String} str - String to evaluate
         * @param {any} catchVal - Default value to return in case of error
         * @returns {any} Result.
         */
        $.testEval = function(str, catchVal) {
            try {
                return eval(str);
            } catch (ex) {
                console.error(ERR_EVAL.format(str, ex));
                return catchVal;
            }
        };

        /**
         * A getter for command values.
         * @param {String} prop - Property code, e.g. "Name", "Map ID", etc
         * @param {Number} n - Custom command index
         * @returns {String|Number|Boolean} Requested property value.
         */
        $.getComValue = function(prop, n) {
            const c = $.com[n];
            const s = String(prop || '').toUpperCase();
            switch (s) {
                case 'COMMAND NAME': case 'NAME': case 'N':
                    return c['Command Name'];
                case 'MAP ID': case 'M':
                    return c['Map ID'];
                case 'MAP X': case 'X':
                    return c['Map X'];
                case 'MAP Y': case 'Y':
                    return c['Map Y'];
                case 'VISIBLE': case 'V':
                    return !!$.testEval(c['JS: Visible'], true);
                case 'ENABLED': case 'E':
                    return !!$.testEval(c['JS: Enabled'], true);
                case 'COMMAND POSITION': case 'POS': case 'P':
                    return c['Command Position'];
                case 'SYMBOL': case 'SYM': case 'S':
                    return $.SYM.format(n + 1);
                default:
                    console.warn(WARN_WATPROP.format(prop));
                    return;
            }
        };

        /**
         * Changes database start point, designed for use with restoreStartPoint.
         * @param {Number} n - Custom command index
         * @returns {{m:Number,x:Number,y:Number}} Memory object containing original starting map ID, X, Y.
         */
        $.changeStartPoint = function(n) {
            let o = { m: $dataSystem.startMapId, x: $dataSystem.startX, y: $dataSystem.startY };
            $dataSystem.startMapId = $.getComValue('M', n);
            $dataSystem.startX     = $.getComValue('X', n);
            $dataSystem.startY     = $.getComValue('Y', n);
            return o;
        };

        /**
         * Restores database start point from provided memory object.
         * @param {{m:Number,x:Number,y:Number}} o - Memory object: m (map ID), x, y
         */
        $.restoreStartPoint = function(o) {
            $dataSystem.startMapId = o.m;
            $dataSystem.startX     = o.x;
            $dataSystem.startY     = o.y;
        };

        /**
         * Evaluates and returns a custom New Game command's position and data.
         * @param {Number} n - Custom command index
         * @returns {[Number,{name:String,symbol:String,enabled:Boolean,ext:Number}]} [Command position, Command data]
         */
        $.makeNewCommand = function(n) {
            const cVis = $.getComValue('V', n);
            if (cVis) {
                const cName = $.getComValue('N', n);
                const cIsOn = $.getComValue('E', n);
                const cPosn = $.getComValue('P', n);
                const cSymb = $.getComValue('S', n);
                return [cPosn, { name: cName, symbol: cSymb, enabled: cIsOn, ext: n }];
            }
            return;
        };

        /** Update the size of the title menu based on parameter settings/command count. */
        $.updateSize = function() {
            if ($.maxPageComs === 0) return;        // Improved compatibility
            if ($.horz) {
                this[$.K_HORZCOLS] = this.maxItems();
                const rows = Math.ceil(this.maxItems() / this.maxCols());
                this.height = this.fittingHeight(rows);
                this.width = parseInt($.testEval($.hWidth, 0), 10) || Graphics.boxWidth * 0.8;
            } else {
                this.height = this.fittingHeight(Math.min(this.maxItems(), $.maxPageComs));
            }
            this.createContents();
        };

    // ======== Plugin Commands ======== //
    // ============ Extends ============ //

        /**
         * Changes start point, invokes original new game command, restores start point.
         * @param {Number} n - Custom command index
         */
        Scene_Title.prototype.commandAltStart = function(n) {
            const mem = $.changeStartPoint(n);
            this.commandNewGame();
            $.restoreStartPoint(mem);
        };

    // ========== Alterations ========== //

        $.alias = $.alias || {};        // This plugin's alias namespace

        void (orig => { if (!$.horz) return;

            // Alias! Change title command window to inherit from horizontal command if appropriate.
            Window_TitleCommand.prototype = Object.create(Window_HorzCommand.prototype);
            for (const p in orig) if (orig.hasOwnProperty(p)) Window_TitleCommand.prototype[p] = orig[p];

            // Override! Change maximum columns according to number of commands present (see updateSize).
            $.K_HORZCOLS = '_cols';
            Window_TitleCommand.prototype.maxCols = function() {
                return Math.min(this[$.K_HORZCOLS] || 1, $.maxPageComs);
            };
        
        })($.alias.Window_TitleCommand = Window_TitleCommand.prototype);

        // Alias! Splice new commands into title command list at appropriate positions.
        void (alias => {
            Window_TitleCommand.prototype.makeCommandList = function() {
                alias.apply(this, arguments);
                for (let n = $.com.length; --n >= 0;) {
                    const [position, command] = $.makeNewCommand(n);
                    if (command) this._list.splice(position, 0, command);
                }
                $.updateSize.call(this);
            };
        })($.alias.Window_TitleCommand_makeCommandList = Window_TitleCommand.prototype.makeCommandList);

        // Alias! Bind new command symbols to new commandAltStart method and adjust command window height.
        void (alias => {
            Scene_Title.prototype.createCommandWindow = function() {
                alias.apply(this, arguments);
                for (let n = $.com.length; --n >= 0;) {
                    const symbol = $.getComValue('S', n);
                    this._commandWindow.setHandler(symbol, this.commandAltStart.bind(this, n));
                }
            };
        })($.alias.Scene_Title_createCommandWindow = Scene_Title.prototype.createCommandWindow);

    })(CAE[NAMESPACE] = CAE[NAMESPACE] || {}, CAE.Utils = CAE.Utils || {});

})();