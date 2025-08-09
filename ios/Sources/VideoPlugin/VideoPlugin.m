#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(VideoPlugin, "Video",   // <-- имя класса из @objc(...), и имя плагина из TS
  CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
  CAP_PLUGIN_METHOD(stop,  CAPPluginReturnPromise);
)