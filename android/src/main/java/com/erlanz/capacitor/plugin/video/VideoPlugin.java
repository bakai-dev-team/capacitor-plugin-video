package com.erlanz.capacitor.plugin.video;

import android.app.Activity;
import android.graphics.Color;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.webkit.WebView;

import androidx.annotation.Nullable;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.ui.AspectRatioFrameLayout;
import androidx.media3.ui.PlayerView;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "Video")
public class VideoPlugin extends Plugin {

  @Nullable private ExoPlayer player;
  @Nullable private PlayerView view;

  @PluginMethod
  public void play(PluginCall call) {
    final String src = call.getString("src");
    if (src == null || src.isEmpty()) {
      call.reject("src is required");
      return;
    }
    final boolean muted = call.getBoolean("muted", true);
    final boolean loop  = call.getBoolean("loop",  true);

    final Activity ctx = getBridge().getActivity();
    ctx.runOnUiThread(() -> {
      // A) Прозрачный WebView и его родитель
      WebView webView = (WebView) getBridge().getWebView();
      webView.setBackgroundColor(Color.TRANSPARENT);
      ViewGroup root = (ViewGroup) webView.getParent();
      if (root != null) {
        root.setBackgroundColor(Color.TRANSPARENT);
      }

      // B) Инициализация плеера и вью
      if (player == null) {
        player = new ExoPlayer.Builder(ctx).build();
      }
      if (view == null) {
        view = new PlayerView(ctx);
        view.setUseController(false);
        view.setResizeMode(AspectRatioFrameLayout.RESIZE_MODE_ZOOM); // cover
        view.setLayoutParams(new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        ));
        if (root != null) {
          // Добавляем НИЖЕ WebView, чтобы кнопки из WebView были сверху
          root.addView(view, 0);
        }
      }
      view.setPlayer(player);

      // C) Унифицированный путь: можно передавать "assets/video/intro.mp4"
      String path = src.startsWith("public/") ? src : "public/" + src;
      Uri uri;
      if (src.startsWith("http") || src.startsWith("file://")) {
        uri = Uri.parse(src);
      } else if (src.startsWith("res://")) {
        String name = src.substring(src.lastIndexOf('/') + 1);
        uri = Uri.parse("android.resource://" + ctx.getPackageName() + "/raw/" + name);
      } else {
        uri = Uri.parse("asset:///" + path);
      }

      MediaItem item = MediaItem.fromUri(uri);
      player.setMediaItem(item);
      player.setRepeatMode(loop ? Player.REPEAT_MODE_ONE : Player.REPEAT_MODE_OFF);
      player.setVolume(muted ? 0f : 1f);
      player.prepare();
      player.play();

      call.resolve();
    });
  }

  @PluginMethod
  public void stop(PluginCall call) {
    final Activity ctx = getBridge().getActivity();
    ctx.runOnUiThread(() -> {
      if (player != null) {
        player.pause();
        player.release();
        player = null;
      }
      if (view != null) {
        ViewGroup parent = (ViewGroup) view.getParent();
        if (parent != null) parent.removeView(view);
        view = null;
      }
      call.resolve();
    });
  }
}