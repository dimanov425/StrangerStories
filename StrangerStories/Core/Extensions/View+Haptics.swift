import SwiftUI

extension View {
    /// Conditionally apply animation only when Reduce Motion is not enabled
    func animateIfAllowed<V: Equatable>(
        _ animation: Animation = .default,
        value: V
    ) -> some View {
        self.animation(
            UIAccessibility.isReduceMotionEnabled ? .none : animation,
            value: value
        )
    }

    /// Standard card shape with Apple's continuous (squircle) corner radius
    func cardShape() -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: Spacing.cardCornerRadius, style: .continuous))
    }

    /// Constrain content to a comfortable reading width on iPad
    func readableWidth() -> some View {
        self.frame(maxWidth: Typography.maxReadableWidth)
    }
}
