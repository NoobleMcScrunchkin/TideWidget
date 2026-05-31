//
//  tides.swift
//  TideWidget
//
//  Created by Harry whittle on 31/05/2026.
//

import Foundation

enum FetchTidesError : Error {
    case InvalidUrl
}

func fetchCurrentTide() async throws -> Tide {
    if let url = URL(string: "https://tides.aslett.io/currentTide") {
        let (data, _) = try await URLSession.shared.data(from: url);
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedTide = try decoder.decode(Tide.self, from: data)
        
        return decodedTide
    } else {
        throw FetchTidesError.InvalidUrl
    }
}


func fetchTides() async throws -> [Tide] {
    if let url = URL(string: "https://tides.aslett.io/tides") {
        let (data, _) = try await URLSession.shared.data(from: url);
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedTides = try decoder.decode(Array<Tide>.self, from: data)
        
        return decodedTides
    } else {
        throw FetchTidesError.InvalidUrl
    }
}

func fetchTideBoundaries() async throws -> [TideBoundary] {
    if let url = URL(string: "https://tides.aslett.io/tideBoundaries") {
        let (data, _) = try await URLSession.shared.data(from: url);
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedTides = try decoder.decode(Array<TideBoundary>.self, from: data)
        
        return decodedTides
    } else {
        throw FetchTidesError.InvalidUrl
    }
}
