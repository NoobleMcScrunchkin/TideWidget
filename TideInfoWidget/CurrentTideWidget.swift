//
//  TideInfoWidget.swift
//  TideInfoWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import WidgetKit
import SwiftUI

struct CurrentTideWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CurrentTideEntry {
        CurrentTideEntry(date: Date(), error: nil, currentHeight: nil, nextTideBoundary: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CurrentTideEntry) -> ()) {
        let entry = CurrentTideEntry(date: Date(), error: nil, currentHeight: nil, nextTideBoundary: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        
        Task {
            do {
                let currentTide = try await fetchCurrentTide()
                
                let tideBoundaries = try await fetchTideBoundaries()
                
                let nextTideBoundary = tideBoundaries
                    .filter {$0.time > currentDate}
                    .min {$0.time < $1.time}
                
                let entry = CurrentTideEntry(date: currentDate, error: nil, currentHeight: currentTide.height, nextTideBoundary: nextTideBoundary)
                
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.nextQuarterHour()))
                
                completion(timeline)
            } catch {
                let entry = CurrentTideEntry(date: currentDate, error: error.localizedDescription, currentHeight: nil, nextTideBoundary: nil)
                
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.nextQuarterHour()))
                
                completion(timeline)
            }
        }
    }
}

struct CurrentTideEntry: TimelineEntry {
    let date: Date
    
    let error: String?
    
    let currentHeight: Decimal?
    let nextTideBoundary: TideBoundary?
}

struct CurrentTideWidgetEntryView : View {
    var entry: CurrentTideWidgetProvider.Entry

    var body: some View {
        VStack {
            if entry.error != nil {
                Text("Error: \(entry.error!)")
            } else if entry.currentHeight == nil {
                Text("Loading...")
            } else {
                Text((entry.currentHeight?.formatted() ?? "Unknown") + "m" + (entry.nextTideBoundary!.tideType == TideType.Low ? "↓" : "↑"))
            }
        }.widgetURL(URL(string: "tidewidget://open-safari?target=https://tides.digimap.gg/"))
    }
}

struct CurrentTideWidget: Widget {
    let kind: String = "CurrentTideWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrentTideWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                CurrentTideWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                CurrentTideWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Current Tide")
        .description("Shows the current height of the tide.")
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview(as: .accessoryRectangular) {
    CurrentTideWidget()
} timeline: {
    CurrentTideEntry(date: .now, error: nil, currentHeight: 5, nextTideBoundary: TideBoundary(time: .now, height: 10, tideType: TideType.Low))
    CurrentTideEntry(date: .now, error: nil, currentHeight: nil, nextTideBoundary: nil)
    CurrentTideEntry(date: .now, error: "Failed to load", currentHeight: nil, nextTideBoundary: nil)
}
