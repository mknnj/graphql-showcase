//
//  ContentView.swift
//  RickAndMortyDemoApp
//
//  Created by Antonio Pantaleo on 08/04/24.
//

import Combine
import SwiftUI
import Apollo
import RickAndMortyKit

struct ContentView: View {
    
    @State
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(viewModel.characters) { character in
                        VStack {
                            CharacterImageView(
                                character: character,
                                viewModel: $viewModel
                            )
                            
                            Text(character.name)
                                .lineLimit(1)
                                .font(.headline)
                                .foregroundColor(.accentColor)
                                .redacted(when: viewModel.characters.isEmpty)
                        }
                    }
                }
                
            }
            .task { try? await viewModel.loadCharacters() }
            .padding()
        }
    }
}

fileprivate extension View {
    func redacted(when condition: Bool) -> some View {
        redacted(reason: condition ? .placeholder : [])
    }
}
