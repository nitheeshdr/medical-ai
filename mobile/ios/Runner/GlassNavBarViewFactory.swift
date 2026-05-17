import Flutter
import UIKit

// MARK: - Factory

/// Registered as "medinova/glass_nav_bar".
/// Renders a native UIKit navigation bar chrome with Liquid Glass.
@objc final class GlassNavBarViewFactory: NSObject, FlutterPlatformViewFactory {
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
        GlassNavBarNativeView(frame: frame, args: args)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - View

final class GlassNavBarNativeView: NSObject, FlutterPlatformView {
    private let root: UIView

    init(frame: CGRect, args: Any?) {
        root = UIView(frame: frame)
        root.backgroundColor = .clear
        root.isUserInteractionEnabled = false
        super.init()
        buildNavBar(args: args)
    }

    func view() -> UIView { root }

    private func buildNavBar(args: Any?) {
        let effectView = UIVisualEffectView(
            effect: UIBlurEffect(style: .systemUltraThinMaterialLight)
        )

        effectView.frame = root.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Bottom separator line
        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        separator.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        root.addSubview(effectView)
    }
}
