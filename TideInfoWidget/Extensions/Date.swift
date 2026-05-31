//
//  Date.swift
//  TideWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import Foundation

extension Date {
    func nextHalfHour() -> Date {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: self)
        
        // 1. Calculate minutes needed to reach the next 30-minute mark
        let minutesToAdd = 30 - (minutes % 30)
        
        // 2. Add those minutes to the current date
        guard let nextDate = calendar.date(byAdding: .minute, value: minutesToAdd, to: self) else {
            return self // Fallback in case of calendar failure
        }
        
        // 3. Strip out the seconds and nanoseconds for a clean time (e.g., exactly 15:00:00)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
        return calendar.date(from: components) ?? nextDate
    }
    
    func nextQuarterHour() -> Date {
            let calendar = Calendar.current
            let minutes = calendar.component(.minute, from: self)
            
            // 1. Calculate minutes needed to reach the next 15-minute mark
            let minutesToAdd = 15 - (minutes % 15)
            
            // 2. Add those minutes to the current date
            guard let nextDate = calendar.date(byAdding: .minute, value: minutesToAdd, to: self) else {
                return self // Fallback in case of calendar failure
            }
            
            // 3. Strip out the seconds and nanoseconds for a clean time
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: nextDate)
            return calendar.date(from: components) ?? nextDate
        }
}
