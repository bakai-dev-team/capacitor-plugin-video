// src/web.ts
import { WebPlugin } from '@capacitor/core';
import type { VideoPlugin, PlayOptions } from './definitions';

export class VideoWeb extends WebPlugin implements VideoPlugin {
  private el?: HTMLVideoElement;

  async play({ src, muted = true, loop = true }: PlayOptions) {
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
    this.el?.pause();
    this.el?.remove();
    this.el = undefined;
  }

  async pause() {
    this.el?.pause();
  }

  async resume() {
    if (this.el) {
      await this.el.play().catch(() => undefined);
    }
  }
}