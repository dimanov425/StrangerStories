import SwiftUI

extension Font {
    /// New York serif font for story reading — scales with Dynamic Type
    static func storyBody(_ style: TextStyle = .body) -> Font {
        .system(style, design: .serif)
    }

    /// SF Mono for timer display and writing editor
    static func mono(_ style: TextStyle = .body) -> Font {
        .system(style, design: .monospaced)
    }

    /// Large timer countdown display — fixed size, does not scale with Dynamic Type
    static let timerDisplay: Font = .system(size: 48, weight: .light, design: .monospaced)
}
