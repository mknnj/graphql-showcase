//
//  ViewModel.swift
//  RickAndMortyDemoApp
//
//  Created by Antonio Pantaleo on 19/12/24.
//

import Foundation
import RickAndMortyKit

@Observable
class ViewModel {
    
    private let charactersLoader: CharactersLoader
    private let characterImageLoader: CharacterImageLoader
    
    private(set) var characters: [Character] = []
    private(set) var tasks: [Character:Task<Data?, Never>] = [:]
    
    init(
        charactersLoader: CharactersLoader,
        characterImageLoader: CharacterImageLoader
    ) {
        self.charactersLoader = charactersLoader
        self.characterImageLoader = characterImageLoader
    }
    
    func loadCharacters() async throws {
        let characters = try await charactersLoader.loadCharacters()
        await MainActor.run { [weak self] in
            self?.characters = characters
        }
    }
    
    func loadCharacterImage(for character: Character) {
        tasks[character] = Task { [weak self] in
            try? await self?.characterImageLoader
                .loadCharacterImage(from: character.imageUrl)
        }
    }
    
    func cancelImageLoading(for character: Character) {
        tasks[character]?.cancel()
        tasks[character] = nil
    }
    
}
