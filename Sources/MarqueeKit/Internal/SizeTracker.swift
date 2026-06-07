import SwiftUI

// MARK: - Preference key

struct ContentSizeKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - View extension

extension View {
    /// Reports the view's layout size upward through the preference system.
    func trackContentSize(onChange: @escaping @MainActor (CGSize) -> Void) -> some View {
        self
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ContentSizeKey.self, value: proxy.size)
                }
            )
            .onPreferenceChange(ContentSizeKey.self) { size in
                Task { @MainActor in onChange(size) }
            }
    }
}
