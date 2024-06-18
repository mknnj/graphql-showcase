//
//  CharacterImageLoader.swift
//  RickAndMortyDemoApp
//
//  Created by Antonio Pantaleo on 19/12/24.
//

import Foundation

protocol CharacterImageLoader {
    func loadCharacterImage(from url: URL) async throws -> Data
}

class URLSessionCharacterImageLoader: CharacterImageLoader {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func loadCharacterImage(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
