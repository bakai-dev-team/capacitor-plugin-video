import Foundation
import Capacitor
import AVFoundation

@objc(VideoPlugin)
public class VideoPlugin: CAPPlugin {
    private var player: AVPlayer?
    private var layer: AVPlayerLayer?
    private var orientationObserver: Any?
    private var videoView: UIView?

    // lifecycle state
    private var lastTime: CMTime = .zero
    private var wasPlayingBeforeBackground = false
    private var endObserver: Any? // для loop, чтобы чисто снимать observer

    @objc public func play(_ call: CAPPluginCall) {
        print("VideoPlugin.play called")
        guard let src = call.getString("src") else { call.reject("src is required"); return }
        let muted = call.getBool("muted") ?? true
        let loop  = call.getBool("loop")  ?? true

        // 1) WebView прозрачный (виден слой под ним)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.bridge?.webView?.isOpaque = false
            self.bridge?.webView?.backgroundColor = .clear
            self.bridge?.webView?.scrollView.backgroundColor = .clear
            self.bridge?.viewController?.view.backgroundColor = .clear
        }

        // 2) Разруливание пути
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
                print("url: \(url!)")
            }
        }
        guard let videoURL = url else { call.reject("File not found: \(src)"); return }
        print("VideoPlugin: trying src =", src)
        print("VideoPlugin: resolved URL =", videoURL)

        // 3) Player + item
        let item = AVPlayerItem(url: videoURL)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        player?.isMuted = muted

        // 4) Подложить слой под WebView и стартануть
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let root = self.bridge?.viewController?.view,
                  let webView = self.bridge?.webView else { return }

            let parent: UIView = webView.superview ?? root

            // Создаем контейнер-вью под WebView, чтобы корректно управлять порядком слоев через UIKit
            if self.videoView == nil {
                let container = UIView(frame: parent.bounds)
                container.isUserInteractionEnabled = false
                container.backgroundColor = .clear
                container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                parent.insertSubview(container, belowSubview: webView)
                // гарантированно ниже webView
                container.layer.zPosition = -1000
                self.videoView = container
            } else {
                self.videoView?.frame = parent.bounds
                if let container = self.videoView, container.superview !== parent {
                    parent.insertSubview(container, belowSubview: webView)
                }
                self.videoView?.layer.zPosition = -1000
            }

            // Создаем или обновляем AVPlayerLayer внутри контейнера
            if self.layer == nil {
                let l = AVPlayerLayer(player: self.player)
                l.videoGravity = .resizeAspectFill
                l.frame = self.videoView?.bounds ?? parent.bounds
                self.videoView?.layer.addSublayer(l)
                self.layer = l
            } else {
                self.layer?.player = self.player
                self.layer?.frame = self.videoView?.bounds ?? parent.bounds
            }

            // гарантируем, что сам webView поверх видео
            webView.isOpaque = false
            webView.backgroundColor = .clear
            webView.scrollView.backgroundColor = .clear
            // поднять вебвью поверх
            webView.layer.zPosition = 1000
            parent.bringSubviewToFront(webView)

            if self.orientationObserver == nil {
                self.orientationObserver = NotificationCenter.default.addObserver(
                    forName: UIDevice.orientationDidChangeNotification,
                    object: nil,
                    queue: .main
                ) { [weak self] _ in
                    guard let self = self,
                          let root = self.bridge?.viewController?.view,
                          let webView = self.bridge?.webView else { return }
                    let parent: UIView = webView.superview ?? root
                    self.videoView?.frame = parent.bounds
                    self.layer?.frame = self.videoView?.bounds ?? parent.bounds
                }
            }

            self.player?.play()
        }

        // 5) Loop (снятие старого observer, если был)
        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }
        if loop {
            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player?.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        }

        call.resolve()
    }

    @objc public func stop(_ call: CAPPluginCall) {
        lastTime = .zero
        wasPlayingBeforeBackground = false

        // снять observer, если есть
        if let obs = endObserver {
            NotificationCenter.default.removeObserver(obs)
            endObserver = nil
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.player?.pause()
            self.player = nil
            self.layer?.removeFromSuperlayer()
            self.layer = nil
            if let obs = self.orientationObserver {
                NotificationCenter.default.removeObserver(obs)
                self.orientationObserver = nil
            }
            self.videoView?.removeFromSuperview()
            self.videoView = nil
            call.resolve()
        }
    }

    public override func load() {
        // подписки на лайфсайкл приложения
        NotificationCenter.default.addObserver(self,
            selector: #selector(onAppPause),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(onAppResume),
            name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - App lifecycle -> автопауза/автовозврат на ту же позицию

    @objc private func onAppPause() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let p = self.player else { return }
            self.wasPlayingBeforeBackground = (p.rate > 0)
            self.lastTime = p.currentTime()
            p.pause()
        }
    }

    @objc private func onAppResume() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let p = self.player else { return }
            p.seek(
                to: self.lastTime,
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )
            if self.wasPlayingBeforeBackground {
                p.play()
            }
        }
    }

    // Вспомогательные (если вдруг захочешь дергать извне)
    func currentTime() -> CMTime { player?.currentTime() ?? .zero }
    func seek(to time: CMTime)   { player?.seek(to: time) }
    func isPlaying() -> Bool     { (player?.rate ?? 0) > 0 }
}