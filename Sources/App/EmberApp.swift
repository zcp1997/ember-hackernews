import SwiftUI

@main
struct EmberApp: App {
    @StateObject private var settings = SettingsStore()
    @StateObject private var bookmarks = BookmarkStore()
    @StateObject private var readStore = ReadStore()
    @StateObject private var linkOpener = LinkOpener()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(bookmarks)
                .environmentObject(readStore)
                .environmentObject(linkOpener)
        }
    }
}
