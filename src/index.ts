import { registerPlugin } from '@capacitor/core';

import type { VideoPlugin } from './definitions';

const Video = registerPlugin<VideoPlugin>('Video', {
  web: () => import('./web').then((m) => new m.VideoWeb()),
});

export * from './definitions';
export { Video };
