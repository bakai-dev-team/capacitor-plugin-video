import Foundation
import Capacitor
import AVFoundation

@objc(VideoPlugin)       
public class VideoPlugin: CAPPlugin {
    private var player: AVPlayer?
    private var layer: AVPlayerLayer?

    @objc public func play(_ call: CAPPluginCall) {
        print("VideoPlugin.play called")
        guard let src = call.getString("src") else { call.reject("src is required"); return }
        let muted = call.getBool("muted") ?? true
        let loop  = call.getBool("loop")  ?? true

        // 1) сделать WebView прозрачным (чтобы видеть слой под ним)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.bridge?.webView?.isOpaque = false
            self.bridge?.webView?.backgroundColor = .clear
            self.bridge?.viewController?.view.backgroundColor = .clear
        }

        // 2) корректно разрулить путь
        var url: URL?
        if src.hasPrefix("http") || src.hasPrefix("file://") {
            url = URL(string: src)
        } else {
            let ns = src as NSString
            let fileName = (ns.lastPathComponent as NSString).deletingPathExtension // "intro"
            let ext = ns.pathExtension // "mp4"
            var dir = ns.deletingLastPathComponent                               // "assets/video" или "public/assets/video"
            if dir.isEmpty { dir = "public" }
            else if !dir.hasPrefix("public/") { dir = "public/" + dir }

            if let path = Bundle.main.path(forResource: fileName, ofType: ext, inDirectory: dir) {
                url = URL(fileURLWithPath: path)
                print("url: \(url)")
            }
        }
        guard let videoURL = url else { call.reject("File not found: \(src)"); return }
        print("VideoPlugin: trying src =", src)
        print("VideoPlugin: resolved URL =", videoURL)

        let item = AVPlayerItem(url: videoURL)
        if player == nil { player = AVPlayer(playerItem: item) } else { player?.replaceCurrentItem(with: item) }
        player?.isMuted = muted

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let root = self.bridge?.viewController?.view else { return }
            if self.layer == nil {
                let l = AVPlayerLayer(player: self.player)
                l.videoGravity = .resizeAspectFill
                l.frame = root.bounds
                root.layer.insertSublayer(l, at: 0) // под WebView
                self.layer = l
            } else {
                self.layer?.player = self.player
                self.layer?.frame = root.bounds
            }
            webView?.isOpaque = false
            webView!.backgroundColor = .clear
            webView?.scrollView.backgroundColor = .clear
            root.backgroundColor = .clear
            self.player?.play()
        }

        if loop {
            NotificationCenter.default.addObserver(
              forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero); self?.player?.play()
            }
        }
        call.resolve()
    }

    @objc public func stop(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            self?.player?.pause(); self?.player = nil
            self?.layer?.removeFromSuperlayer(); self?.layer = nil
            call.resolve()
        }
    }
}
