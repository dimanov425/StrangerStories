import WidgetKit
import SwiftUI

struct DailyChallengeEntry: TimelineEntry {
    let date: Date
    let photoURL: URL?
    let storyCount: Int
    let isPlaceholder: Bool
}

struct DailyChallengeProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyChallengeEntry {
        DailyChallengeEntry(date: .now, photoURL: nil, storyCount: 0, isPlaceholder: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyChallengeEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyChallengeEntry>) -> Void) {
        // In production, fetch from shared App Group UserDefaults or Supabase
        let entry = DailyChallengeEntry(
            date: .now,
            photoURL: nil,
            storyCount: 0,
            isPlaceholder: false
        )

        // Refresh at midnight and every 4 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct DailyChallengeWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: DailyChallengeEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    private var smallView: some View {
        ZStack {
            if entry.isPlaceholder {
                Color(.secondarySystemBackground)
            } else {
                Color(.systemBackground)
            }

            VStack(spacing: 8) {
                Image(systemName: "pencil.line")
                    .font(.title)
                    .foregroundStyle(.orange)

                Text("Tap to write")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .widgetURL(URL(string: "strangerstories://daily-challenge"))
    }

    private var mediumView: some View {
        HStack(spacing: 16) {
            ZStack {
                Color(.tertiarySystemBackground)
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Challenge")
                    .font(.headline)

                Text("\(entry.storyCount) stories so far")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Tap to write")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            }
            .padding(.vertical, 12)

            Spacer()
        }
        .widgetURL(URL(string: "strangerstories://daily-challenge"))
    }
}

@main
struct DailyChallengeWidget: Widget {
    let kind = "DailyChallengeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyChallengeProvider()) { entry in
            DailyChallengeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Daily Challenge")
        .description("See today's photo prompt and start writing.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
