import { WebPlugin } from '@capacitor/core';

import type { VideoPlugin } from './definitions';

export class VideoWeb extends WebPlugin implements VideoPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
