import { Video } from 'capacitor-plugin-video';

document.getElementById('play')!.addEventListener('click', async () => {
    try {
        await Video.play({ src:'assets/video/intro.mp4', muted:true, loop:true });
        console.log('Video.play resolved');
      } catch (e) {
        console.error('Video.play error', e);
      }
});

document.getElementById('stop')!.addEventListener('click', async () => {
  await Video.stop();
});