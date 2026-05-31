//
//  TideInfoWidget.swift
//  TideInfoWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TideDataEntry {
        TideDataEntry(date: Date(), error: nil, currentHeight: nil, nextTideBoundary: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TideDataEntry) -> ()) {
        let entry = TideDataEntry(date: Date(), error: nil, currentHeight: nil, nextTideBoundary: nil)
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
                
                let entry = TideDataEntry(date: currentDate, error: nil, currentHeight: currentTide.height, nextTideBoundary: nextTideBoundary)
                
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.nextQuarterHour()))
                
                completion(timeline)
            } catch {
                let entry = TideDataEntry(date: currentDate, error: error.localizedDescription, currentHeight: nil, nextTideBoundary: nil)
                
                let timeline = Timeline(entries: [entry], policy: .after(currentDate.nextQuarterHour()))
                
                completion(timeline)
            }
        }
    }
}

struct TideDataEntry: TimelineEntry {
    let date: Date
    
    let error: String?
    
    let currentHeight: Decimal?
    let nextTideBoundary: TideBoundary?
}

struct TideInfoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if entry.error != nil {
                Text("Error: \(entry.error!)")
            } else if entry.currentHeight == nil && entry.nextTideBoundary == nil {
                Text("Loading...")
            } else {
                Text("Current Tide:")
                if entry.currentHeight == nil {
                    Text("Loading...")
                } else {
                    Text((entry.currentHeight?.formatted() ?? "Unknown") + "m")
                }
                
                Spacer()
                
                if entry.nextTideBoundary == nil {
                    Text("Loading...")
                } else {
                    Text("Tide is going " + (entry.nextTideBoundary!.tideType == TideType.Low ? "down" : "up"))
                    
                    Spacer()
                    
                    Text("Next " + entry.nextTideBoundary!.tideType.rawValue + " Tide:")
                    Text(entry.nextTideBoundary!.time.formatted(date: .omitted, time: .shortened))
                }
            }
        }
    }
}

struct TideInfoWidget: Widget {
    let kind: String = "TideInfoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TideInfoWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TideInfoWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    TideInfoWidget()
} timeline: {
    TideDataEntry(date: .now, error: nil, currentHeight: 5, nextTideBoundary: TideBoundary(time: .now, height: 10, tideType: TideType.High))
    TideDataEntry(date: .now, error: nil, currentHeight: nil, nextTideBoundary: nil)
    TideDataEntry(date: .now, error: "Failed to load", currentHeight: nil, nextTideBoundary: nil)
}
