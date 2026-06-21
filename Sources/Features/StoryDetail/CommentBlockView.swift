import SwiftUI

/// Renders a single parsed `CommentBlock` (paragraph, quote, or code) natively.
/// Used for both comment bodies and self/text posts.
struct CommentBlockView: View {
    let block: CommentBlock

    @Environment(SettingsStore.self) private var settings

    private var scale: CGFloat { CGFloat(settings.readingTextScale) }
    private var bodyFont: Font { .reader(15.5 * scale, .regular, relativeTo: .callout) }

    var body: some View {
        switch block {
        case .text(let attributed):
            Text(styled(attributed))
                .font(bodyFont)
                .lineSpacing(AppFont.readingLineSpacing * scale)
                .foregroundStyle(Theme.textPrimary)
                .textSelection(.enabled)
                .fixedSize(horizontal: false, vertical: true)

        case .quote(let attributed):
            HStack(alignment: .top, spacing: Spacing.s) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(settings.accent.color.opacity(0.55))
                    .frame(width: 3)
                Text(attributed)
                    .font(bodyFont.italic())
                    .lineSpacing(AppFont.readingLineSpacing * scale)
                    .foregroundStyle(Theme.textSecondary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

        case .code(let code):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(size: 13 * scale, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    .textSelection(.enabled)
                    .padding(Spacing.m)
            }
            .background(Theme.surfacePressed)
            .clipShape(RoundedRectangle(cornerRadius: Radius.s, style: .continuous))
        }
    }

    /// Optionally underline links so they remain identifiable without color.
    private func styled(_ attributed: AttributedString) -> AttributedString {
        guard settings.underlineLinks else { return attributed }
        var copy = attributed
        for run in copy.runs where run.link != nil {
            copy[run.range].underlineStyle = .single
        }
        return copy
    }
}
