import SafariServices
import SwiftUI

// MARK: - Navigation routes

/// Pushed onto a `NavigationStack` to show a user profile.
struct UserRoute: Hashable { let username: String }

// MARK: - In-app browser

/// A URL pending presentation in an in-app Safari sheet.
struct PresentedURL: Identifiable {
    let id = UUID()
    let url: URL
    let reader: Bool
}

/// Holds the URL currently being presented in the in-app browser.
final class LinkOpener: ObservableObject {
    @Published var presented: PresentedURL?
    func present(_ url: URL, reader: Bool) {
        presented = PresentedURL(url: url, reader: reader)
    }
}

/// `SFSafariViewController` wrapper for in-app reading with optional Reader mode.
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    var entersReaderIfAvailable = false

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = entersReaderIfAvailable
        let controller = SFSafariViewController(url: url, configuration: config)
        controller.preferredControlTintColor = UIColor(named: "AccentColor")
        controller.dismissButtonStyle = .done
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

// MARK: - Store re-injection for presented views

/// Re-injects the app's observable stores into a presented surface
/// (sheet / full-screen cover). SwiftUI does not reliably propagate
/// `ObservableObject` environment objects across a presentation boundary — most
/// visibly on Mac Catalyst — so presented views that read them must have them
/// re-supplied to avoid a fatal "missing environment" crash.
struct AppStoresEnvironment: ViewModifier {
    let settings: SettingsStore
    let bookmarks: BookmarkStore
    let readStore: ReadStore
    let linkOpener: LinkOpener

    func body(content: Content) -> some View {
        content
            .environmentObject(settings)
            .environmentObject(bookmarks)
            .environmentObject(readStore)
            .environmentObject(linkOpener)
    }
}

// MARK: - Environment actions

private struct OpenArticleKey: EnvironmentKey {
    static let defaultValue: (URL) -> Void = { _ in }
}

extension EnvironmentValues {
    /// Opens an article URL respecting the user's in-app/system + Reader settings.
    /// Configured once at the app root where settings and `openURL` are available.
    var openArticle: (URL) -> Void {
        get { self[OpenArticleKey.self] }
        set { self[OpenArticleKey.self] = newValue }
    }
}
