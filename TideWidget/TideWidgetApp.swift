//
//  TideWidgetApp.swift
//  TideWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import SwiftUI

@main
struct TideWidgetApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleWidgetDeepLink(url)
                }
        }
    }
    
    private func handleWidgetDeepLink(_ url: URL) {
            // 1. Verify the incoming custom scheme matches your app
            guard url.scheme == "tidewidget",
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                  let queryItems = components.queryItems else { return }
            
            // 2. Extract the actual target Safari URL from the query string
            if let targetUrlString = queryItems.first(where: { $0.name == "target" })?.value,
               let safariURL = URL(string: targetUrlString) {
                
                // 3. Command the system to open Safari directly
                UIApplication.shared.open(safariURL, options: [:], completionHandler: nil)
            }
        }

}
