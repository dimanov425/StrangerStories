import ActivityKit
import WidgetKit
import SwiftUI

struct WritingTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: Int
        var wordCount: Int
    }

    var photoThumbnailURL: URL?
}

@main
struct WritingTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WritingTimerAttributes.self) { context in
            // Lock Screen presentation
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "pencil.line")
                        .font(.title2)
                        .foregroundStyle(.orange)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timeString(context.state.timeRemaining))
                        .font(.system(.title, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("\(context.state.wordCount) words")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        ProgressView(value: Double(context.state.timeRemaining), total: 180)
                            .tint(.orange)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Image(systemName: "pencil.line")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                Text(timeString(context.state.timeRemaining))
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(context.state.timeRemaining <= 30 ? .red : .primary)
            } minimal: {
                Image(systemName: "pencil.line")
                    .foregroundStyle(.orange)
            }
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<WritingTimerAttributes>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "pencil.line")
                .font(.title)
                .foregroundStyle(.orange)

            VStack(alignment: .leading) {
                Text("Writing...")
                    .font(.headline)
                Text(timeString(context.state.timeRemaining))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundStyle(context.state.timeRemaining <= 30 ? .red : .primary)
            }

            Spacer()

            Text("\(context.state.wordCount)")
                .font(.system(.title3, design: .monospaced))
                .foregroundStyle(.secondary)
            Text("words")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
