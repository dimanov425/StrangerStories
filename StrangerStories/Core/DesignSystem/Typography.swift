import SwiftUI

enum Typography {
    static let storyReading: Font = .storyBody()
    static let storyReadingLarge: Font = .storyBody(.title3)

    static let timerCountdown: Font = .timerDisplay
    static let editorFont: Font = .mono()

    static let storyReadingLineSpacing: CGFloat = 6
    static let maxReadableWidth: CGFloat = 680
}
