//
//  CharacterImageView.swift
//  RickAndMortyDemoApp
//
//  Created by Antonio Pantaleo on 19/12/24.
//


import UIKit
import SwiftUI
import RickAndMortyKit

struct CharacterImageView: View {
    
    private let character: Character
    @Binding private var viewModel: ViewModel
    
    init(character: Character, viewModel: Binding<ViewModel>) {
        self.character = character
        self._viewModel = viewModel
    }
    
    @State private var image: Image?
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    Image(.placeholder)
                        .resizable()
                        .scaledToFit()
                    ProgressView()
                        .tint(.white)
                }
            }
        }
        .task {
            viewModel.loadCharacterImage(for: character)
            guard let data = await viewModel.tasks[character]?.value else { return }
            guard let uiImage = UIImage(data: data) else { return }
            image = Image(uiImage: uiImage)
            
        }
        .onDisappear {
            viewModel.cancelImageLoading(for: character)
            image = nil
        }
    }
}
