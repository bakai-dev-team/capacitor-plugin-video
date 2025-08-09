// src/index.ts
import { registerPlugin } from '@capacitor/core';
export const Video = registerPlugin('Video', {
    web: () => import('./web').then(m => new m.VideoWeb()),
});
export * from './definitions';
//# sourceMappingURL=index.js.map