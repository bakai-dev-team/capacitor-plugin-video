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
                Object.assign(this.el.style, {
                    position: 'fixed', inset: '0', width: '100%', height: '100%',
                    objectFit: 'cover', zIndex: '-1'
                });
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
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        VideoWeb: VideoWeb
    });

    exports.Video = Video;

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
