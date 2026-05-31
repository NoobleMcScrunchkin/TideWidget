//
//  TideBoundary.swift
//  TideWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import Foundation

struct TideBoundary : Decodable {
    let time: Date
    let height: Decimal
    let tideType: TideType
}
