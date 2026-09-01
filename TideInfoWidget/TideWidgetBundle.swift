//
//  TideInfoWidgetBundle.swift
//  TideInfoWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import WidgetKit
import SwiftUI

@main
struct TideWidgetBundle: WidgetBundle {
    var body: some Widget {
        TideInfoWidget()
        CurrentTideWidget()
        NextTideWidget()
    }
}
