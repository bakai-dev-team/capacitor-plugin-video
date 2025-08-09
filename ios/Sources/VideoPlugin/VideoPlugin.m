#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(VideoPlugin, "Video",   // <-- имя класса из @objc(...), и имя плагина из TS
  CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(stop,  CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(prepare, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(show, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(pause, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(destroy, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(setMuted, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(setVolume, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(configure, CAPPluginReturnPromise);   // <-- добавили
  CAP_PLUGIN_METHOD(getPosition, CAPPluginReturnPromise); // <-- добавили
  CAP_PLUGIN_METHOD(seekTo, CAPPluginReturnPromise); 
)