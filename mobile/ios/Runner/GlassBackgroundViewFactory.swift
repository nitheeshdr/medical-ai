import Flutter
import UIKit

// MARK: - Factory

/// Registered as "medinova/glass_background".
/// Used for full-screen frosted backgrounds (sheets, overlays, etc.).
@objc final class GlassBackgroundViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    @objc init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        GlassBackgroundNativeView(frame: frame, args: args)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - View

final class GlassBackgroundNativeView: NSObject, FlutterPlatformView {
    private let root: UIView

    init(frame: CGRect, args: Any?) {
        root = UIView(frame: frame)
        root.backgroundColor = .clear
        root.isUserInteractionEnabled = false
        super.init()
        buildBackground(args: args)
    }

    func view() -> UIView { root }

    private func buildBackground(args: Any?) {
        let params = args as? [String: Any]
        let style  = params?["style"] as? String ?? "ultraThin"
        let radius = CGFloat(params?["cornerRadius"] as? Double ?? 0)

        let blurStyle: UIBlurEffect.Style = style == "thick"
            ? .systemThickMaterialLight
            : .systemUltraThinMaterialLight
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))

        effectView.frame = root.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if radius > 0 {
            effectView.layer.cornerRadius = radius
            effectView.layer.cornerCurve  = .continuous
            effectView.layer.masksToBounds = true
        }

        root.addSubview(effectView)
    }
}
