//
//  TideInfoWidget.swift
//  TideInfoWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import WidgetKit
import SwiftUI

struct NextTideWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextTideEntry {
        NextTideEntry(date: Date(), error: nil, nextTideBoundary: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NextTideEntry) -> ()) {
        let entry = NextTideEntry(date: Date(), error: nil, nextTideBoundary: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        Task {
            do {
                let tideBoundaries = try await fetchTideBoundaries()
                
                let nextTideBoundary = tideBoundaries
                    .filter {$0.time > currentDate}
                    .min {$0.time < $1.time}
                
                let entry = NextTideEntry(date: currentDate, error: nil, nextTideBoundary: nextTideBoundary)
                
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.nextQuarterHour()))
                
                completion(timeline)
            } catch {
                let entry = NextTideEntry(date: currentDate, error: error.localizedDescription, nextTideBoundary: nil)
                
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.nextQuarterHour()))
                
                completion(timeline)
            }
        }
    }
}

struct NextTideEntry: TimelineEntry {
    let date: Date
    
    let error: String?
    
    let nextTideBoundary: TideBoundary?
}

struct NextTideWidgetEntryView : View {
    var entry: NextTideWidgetProvider.Entry

    var body: some View {
        VStack {
            if entry.error != nil {
                Text("Error: \(entry.error!)")
            } else if entry.nextTideBoundary == nil {
                Text("Loading...")
            } else {
                Text(entry.nextTideBoundary!.height.formatted() + "m" + (entry.nextTideBoundary!.tideType == TideType.Low ? "↓" : "↑") + " at " + entry.nextTideBoundary!.time.formatted(date: .omitted, time: .shortened))
            }
        }.widgetURL(URL(string: "tidewidget://open-safari?target=https://tides.digimap.gg/"))
    }
}

struct NextTideWidget: Widget {
    let kind: String = "NextTideWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextTideWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                NextTideWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NextTideWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Next Tide")
        .description("Shows info about the next tide.")
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview(as: .accessoryRectangular) {
    NextTideWidget()
} timeline: {
    NextTideEntry(date: .now, error: nil, nextTideBoundary: TideBoundary(time: .now, height: 9.82, tideType: TideType.Low))
    NextTideEntry(date: .now, error: nil, nextTideBoundary: nil)
    NextTideEntry(date: .now, error: "Failed to load", nextTideBoundary: nil)
}
