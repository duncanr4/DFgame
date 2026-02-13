Window_TitleCommand.prototype.makeCommandList = function() {
    const continueEnabled = this.isContinueEnabled();
    this.addCommand(TextManager.newGame, "newGame");
    //this.addCommand(TextManager.continue_, "continue", continueEnabled);
    this.addCommand(TextManager.options, "options");
};

Window_Options.prototype.addGeneralOptions = function() {
    //this.addCommand(TextManager.alwaysDash, "alwaysDash");
    this.addCommand(TextManager.commandRemember, "commandRemember");
    this.addCommand(TextManager.touchUI, "touchUI");
};