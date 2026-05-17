import Flutter
import UIKit

// MARK: - Platform View Factory

/// Registered as "medinova/glass_card".
/// Renders true UIGlassEffect on iOS 26+ and falls back to
/// UIBlurEffect(style: .systemUltraThinMaterialDark) on iOS 14–25.
@objc final class GlassCardViewFactory: NSObject, FlutterPlatformViewFactory {
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
        GlassCardNativeView(frame: frame, args: args)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Platform View

final class GlassCardNativeView: NSObject, FlutterPlatformView {
    private let root: UIView

    init(frame: CGRect, args: Any?) {
        root = UIView(frame: frame)
        root.backgroundColor = .clear
        root.isUserInteractionEnabled = false
        super.init()

        let radius = CGFloat((args as? [String: Any])?["cornerRadius"] as? Double ?? 20)
        buildGlass(cornerRadius: radius)
    }

    func view() -> UIView { root }

    // MARK: Private

    private func buildGlass(cornerRadius: CGFloat) {
        let effectView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterialLight)
        )

        effectView.frame = root.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.layer.cornerRadius = cornerRadius
        effectView.layer.cornerCurve = .continuous
        effectView.layer.masksToBounds = true

        // Frosted-glass border
        addBorder(to: effectView.layer, radius: cornerRadius)

        root.addSubview(effectView)
    }

    private func addBorder(to layer: CALayer, radius: CGFloat) {
        let border = CALayer()
        border.frame = layer.bounds
        border.cornerRadius = radius
        border.cornerCurve = .continuous
        border.borderWidth = 0.5
        border.borderColor = UIColor.white.withAlphaComponent(0.22).cgColor
        border.masksToBounds = true
        layer.addSublayer(border)
    }
}
