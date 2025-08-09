// src/web.ts
import { WebPlugin } from '@capacitor/core';
import type { VideoPlugin, PlayOptions } from './definitions';

export class VideoWeb extends WebPlugin implements VideoPlugin {
  private el?: HTMLVideoElement;

  async play({ src, muted = true, loop = true }: PlayOptions) {
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
    this.el?.pause();
    this.el?.remove();
    this.el = undefined;
  }
}