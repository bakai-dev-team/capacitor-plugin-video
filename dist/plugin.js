var capacitorVideo = (function (exports, core) {
    'use strict';

    // src/index.ts
    const Video = core.registerPlugin('Video', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.VideoWeb()),
    });

    // src/web.ts
    class VideoWeb extends core.WebPlugin {
        async play({ src, muted = true, loop = true }) {
            if (!this.el) {
                this.el = document.createElement('video');
                const style = this.el.style;
                style.position = 'fixed';
                style.top = '0';
                style.left = '0';
                style.right = '0';
                style.bottom = '0';
                style.width = '100%';
                style.height = '100%';
                style.objectFit = 'cover';
                style.zIndex = '-1';
                document.body.appendChild(this.el);
            }
            this.el.src = src;
            this.el.muted = muted;
            this.el.loop = loop;
            await this.el.play();
        }
        async stop() {
            var _a, _b;
            (_a = this.el) === null || _a === void 0 ? void 0 : _a.pause();
            (_b = this.el) === null || _b === void 0 ? void 0 : _b.remove();
            this.el = undefined;
        }
        async pause() {
            var _a;
            (_a = this.el) === null || _a === void 0 ? void 0 : _a.pause();
        }
        async resume() {
            if (this.el) {
                await this.el.play().catch(() => undefined);
            }
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        VideoWeb: VideoWeb
    });

    exports.Video = Video;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
