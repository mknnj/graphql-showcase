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

class ViewModel: ObservableObject {
    
    private let loader: CharactersLoader
    
    private var cancellable: AnyCancellable?
    private var cancellables = [Character: AnyCancellable]()
    private var alreadyLoadedCharacters: Set<Character> = []
    private let imageLoadingQueue = DispatchQueue(label: "Image loading", qos: .userInteractive)
    
    @Published private(set) var characters: [Character] = []
    @Published private(set) var characterImages: [Character: UIImage] = [:]
    @Published private(set) var errorMessage: String? = nil
    
    init(loader: CharactersLoader) {
        self.loader = loader
    }
    
    func loadCharacters() async throws {
        guard let loader = loader as? GraphQLCharacterLoader else { fatalError() }
        cancellable = loader
            .allCharactersPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in },
                receiveValue: { [weak self] characters in
                    self?.characters = characters
                }
            )
            
//        let characters = try await loader.loadCharacters()
//        await MainActor.run { [weak self] in
//            self?.characters = characters
//        }
    }
    
    func loadCharacterImage(for character: Character) {
        cancellables[character] = URLSession.shared
            .dataTaskPublisher(for: character.imageUrl)
            .subscribe(on: imageLoadingQueue)
//            .delay(
//                for: .seconds(TimeInterval.random(in: 2..<4)),
//                scheduler: imageLoadingQueue
//            )
            .retry(2)
            .map(\.data)
            .compactMap(UIImage.init(data:))
            .replaceEmpty(with: UIImage.placeholder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] image in
                    self?.alreadyLoadedCharacters.insert(character)
                    self?.characterImages[character] = image
                }
            )
    }
    
    func cancelImageLoading(for character: Character) {
        cancellables[character]?.cancel()
        cancellables[character] = nil
        characterImages[character] = nil
    }
    
}

struct ContentView: View {
    
    @StateObject
    private var viewModel: ViewModel
    
    enum HTTPMode {
        case rest
        case graphql
    }
    
    @State private var httpMode: HTTPMode = .graphql
    
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    
    var body: some View {
        // Segmented picker
        ScrollView(.vertical) {
            VStack {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .frame(maxWidth: .infinity)
                        .background(.red)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                    ForEach(viewModel.characters) { character in
                        VStack {
                            Group {
                                if let image = viewModel.characterImages[character] {
                                    Image(uiImage: image)
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
                            .onAppear {
                                viewModel.loadCharacterImage(for: character)
                            }
                            .onDisappear {
                                viewModel.cancelImageLoading(for: character)
                            }
                            
                            Text(character.name)
                                .lineLimit(1)
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .task { try? await viewModel.loadCharacters() }
            .padding()
            }
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("HTTP Mode", selection: $httpMode) {
                    Text("REST").tag(HTTPMode.rest)
                    Text("GraphQL").tag(HTTPMode.graphql)
                }.pickerStyle(.segmented)
            }
        }
    }
}

#Preview {
    ContentView(
        viewModel: ViewModel(
            loader: GraphQLCharacterLoader(
                client: ApolloClient(
                    url: URL(string: "https://rickandmortyapi.com/graphql")!
                )
            )
        )
    )
}
