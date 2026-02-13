//=============================================================================
// main.js v1.6.0
//=============================================================================

const scriptUrls = [
    "js/libs/pixi.js",
    "js/libs/pako.min.js",
    "js/libs/localforage.min.js",
    "js/libs/effekseer.min.js",
    "js/libs/vorbisdecoder.js",
    "js/rmmz_core.js",
    "js/rmmz_managers.js",
    "js/rmmz_objects.js",
    "js/rmmz_scenes.js",
    "js/rmmz_sprites.js",
    "js/rmmz_windows.js",
    "js/plugins.js"
];
const effekseerWasmUrl = "js/libs/effekseer.wasm";

class Main {
    constructor() {
        this.xhrSucceeded = false;
        this.loadCount = 0;
        this.error = null;
        this._isMuted = false;
        this._storedVolumes = null;
        this._muteButton = null;
        this._muteCheckInterval = null;
    }

    run() {
        this.showLoadingSpinner();
        this.createMuteButton();
        this.testXhr();
        this.hookNwjsClose();
        this.loadMainScripts();
    }

    showLoadingSpinner() {
        const loadingSpinner = document.createElement("div");
        const loadingSpinnerImage = document.createElement("div");
        loadingSpinner.id = "loadingSpinner";
        loadingSpinnerImage.id = "loadingSpinnerImage";
        loadingSpinner.appendChild(loadingSpinnerImage);
        document.body.appendChild(loadingSpinner);
    }

    createMuteButton() {
        const muteButton = document.createElement("button");
        muteButton.id = "muteButton";
        muteButton.type = "button";
        muteButton.textContent = "Mute";
        muteButton.title = "Toggle game audio";
        muteButton.setAttribute("aria-pressed", "false");
        muteButton.addEventListener("click", () => this.toggleMute());
        document.body.appendChild(muteButton);
        this._muteButton = muteButton;
    }

    toggleMute() {
        this._isMuted = !this._isMuted;
        this.updateMuteButton();
        this.applyMuteState();
    }

    updateMuteButton() {
        if (!this._muteButton) {
            return;
        }
        if (this._isMuted) {
            this._muteButton.textContent = "Unmute";
            this._muteButton.setAttribute("aria-pressed", "true");
        } else {
            this._muteButton.textContent = "Mute";
            this._muteButton.setAttribute("aria-pressed", "false");
        }
    }

    applyMuteState() {
        if (typeof AudioManager === "undefined") {
            if (!this._muteCheckInterval) {
                this._muteCheckInterval = window.setInterval(() => {
                    if (typeof AudioManager !== "undefined") {
                        this.clearMuteCheckInterval();
                        this.applyMuteState();
                    }
                }, 100);
            }
            return;
        }
        this.clearMuteCheckInterval();
        if (this._isMuted) {
            this._storedVolumes = {
                bgm: AudioManager.bgmVolume,
                bgs: AudioManager.bgsVolume,
                me: AudioManager.meVolume,
                se: AudioManager.seVolume
            };
            AudioManager.bgmVolume = 0;
            AudioManager.bgsVolume = 0;
            AudioManager.meVolume = 0;
            AudioManager.seVolume = 0;
        } else {
            const volumes = this._storedVolumes || {
                bgm: 100,
                bgs: 100,
                me: 100,
                se: 100
            };
            AudioManager.bgmVolume = volumes.bgm;
            AudioManager.bgsVolume = volumes.bgs;
            AudioManager.meVolume = volumes.me;
            AudioManager.seVolume = volumes.se;
        }
    }

    clearMuteCheckInterval() {
        if (this._muteCheckInterval) {
            window.clearInterval(this._muteCheckInterval);
            this._muteCheckInterval = null;
        }
    }

    eraseLoadingSpinner() {
        const loadingSpinner = document.getElementById("loadingSpinner");
        if (loadingSpinner) {
            document.body.removeChild(loadingSpinner);
        }
    }

    testXhr() {
        const xhr = new XMLHttpRequest();
        xhr.open("GET", document.currentScript.src);
        xhr.onload = () => (this.xhrSucceeded = true);
        xhr.send();
    }

    hookNwjsClose() {
        // [Note] When closing the window, the NW.js process sometimes does
        //   not terminate properly. This code is a workaround for that.
        if (typeof nw === "object") {
            nw.Window.get().on("close", () => nw.App.quit());
        }
    }

    loadMainScripts() {
        for (const url of scriptUrls) {
            const script = document.createElement("script");
            script.type = "text/javascript";
            script.src = url;
            script.async = false;
            script.defer = true;
            script.onload = this.onScriptLoad.bind(this);
            script.onerror = this.onScriptError.bind(this);
            script._url = url;
            document.body.appendChild(script);
        }
        this.numScripts = scriptUrls.length;
        window.addEventListener("load", this.onWindowLoad.bind(this));
        window.addEventListener("error", this.onWindowError.bind(this));
    }

    onScriptLoad() {
        if (++this.loadCount === this.numScripts) {
            PluginManager.setup($plugins);
        }
    }

    onScriptError(e) {
        this.printError("Failed to load", e.target._url);
    }

    printError(name, message) {
        this.eraseLoadingSpinner();
        if (!document.getElementById("errorPrinter")) {
            const errorPrinter = document.createElement("div");
            errorPrinter.id = "errorPrinter";
            errorPrinter.innerHTML = this.makeErrorHtml(name, message);
            document.body.appendChild(errorPrinter);
        }
    }

    makeErrorHtml(name, message) {
        const nameDiv = document.createElement("div");
        const messageDiv = document.createElement("div");
        nameDiv.id = "errorName";
        messageDiv.id = "errorMessage";
        nameDiv.innerHTML = name;
        messageDiv.innerHTML = message;
        return nameDiv.outerHTML + messageDiv.outerHTML;
    }

    onWindowLoad() {
        if (!this.xhrSucceeded) {
            const message = "Your browser does not allow to read local files.";
            this.printError("Error", message);
        } else if (this.isPathRandomized()) {
            const message = "Please move the Game.app to a different folder.";
            this.printError("Error", message);
        } else if (this.error) {
            this.printError(this.error.name, this.error.message);
        } else {
            this.initEffekseerRuntime();
        }
    }

    onWindowError(event) {
        if (!this.error) {
            this.error = event.error;
        }
    }

    isPathRandomized() {
        // [Note] We cannot save the game properly when Gatekeeper Path
        //   Randomization is in effect.
        return (
            typeof process === "object" &&
            process.mainModule.filename.startsWith("/private/var")
        );
    }

    initEffekseerRuntime() {
        const onLoad = this.onEffekseerLoad.bind(this);
        const onError = this.onEffekseerError.bind(this);
        effekseer.initRuntime(effekseerWasmUrl, onLoad, onError);
    }

    onEffekseerLoad() {
        this.eraseLoadingSpinner();
        SceneManager.run(Scene_Boot);
    }

    onEffekseerError() {
        this.printError("Failed to load", effekseerWasmUrl);
    }
}

const main = new Main();
main.run();

//-----------------------------------------------------------------------------
