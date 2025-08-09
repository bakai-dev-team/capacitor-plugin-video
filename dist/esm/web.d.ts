import { WebPlugin } from '@capacitor/core';
import type { VideoPlugin, PlayOptions } from './definitions';
export declare class VideoWeb extends WebPlugin implements VideoPlugin {
    private el?;
    play({ src, muted, loop }: PlayOptions): Promise<void>;
    stop(): Promise<void>;
}
