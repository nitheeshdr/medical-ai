import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        registerNativeViews()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Native Liquid Glass Platform Views

    private func registerNativeViews() {
        // Glass card — used as the background layer for every card on iOS
        if let reg = registrar(forPlugin: "GlassCardPlugin") {
            reg.register(
                GlassCardViewFactory(messenger: reg.messenger()),
                withId: "medinova/glass_card"
            )
        }

        // Glass background — full-screen frosted surface (sheets / modals)
        if let reg = registrar(forPlugin: "GlassBackgroundPlugin") {
            reg.register(
                GlassBackgroundViewFactory(messenger: reg.messenger()),
                withId: "medinova/glass_background"
            )
        }

        // Glass nav bar — frosted navigation bar chrome
        if let reg = registrar(forPlugin: "GlassNavBarPlugin") {
            reg.register(
                GlassNavBarViewFactory(messenger: reg.messenger()),
                withId: "medinova/glass_nav_bar"
            )
        }
    }
}
