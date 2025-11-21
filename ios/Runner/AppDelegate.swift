import Flutter
import UIKit
import MediaPlayer
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var channel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      channel = FlutterMethodChannel(name: "com.huangjien.novel/media_control", binaryMessenger: controller.binaryMessenger)
      setupRemoteCommands()
    }
    try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    UIApplication.shared.beginReceivingRemoteControlEvents()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupRemoteCommands() {
    let center = MPRemoteCommandCenter.shared()
    center.playCommand.addTarget { [weak self] _ in
      self?.channel?.invokeMethod("play", arguments: nil)
      return .success
    }
    center.pauseCommand.addTarget { [weak self] _ in
      self?.channel?.invokeMethod("pause", arguments: nil)
      return .success
    }
    center.stopCommand.addTarget { [weak self] _ in
      self?.channel?.invokeMethod("stop", arguments: nil)
      return .success
    }
    center.togglePlayPauseCommand.addTarget { [weak self] _ in
      self?.channel?.invokeMethod("play", arguments: nil)
      return .success
    }
    center.nextTrackCommand.addTarget { [weak self] _ in
      self?.channel?.invokeMethod("next", arguments: nil)
      return .success
    }
    center.previousTrackCommand.addTarget { [weak self] _ in
      self?.channel?.invokeMethod("prev", arguments: nil)
      return .success
    }
  }
}
