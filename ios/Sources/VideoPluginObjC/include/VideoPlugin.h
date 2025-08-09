#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(VideoPlugin, "Video",
  CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(stop,  CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(pause, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(configure, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(getPosition, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(seekTo, CAPPluginReturnPromise);
)
