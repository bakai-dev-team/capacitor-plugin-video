export interface PlayOptions {
    src: string;
    muted?: boolean;
    loop?: boolean;
}
export interface VideoPlugin {
    play(options: PlayOptions): Promise<void>;
    stop(): Promise<void>;
    pause(): Promise<void>;
    resume(): Promise<void>;
}
