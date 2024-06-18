//
//  RickAndMortyDemoApp.swift
//  RickAndMortyDemoApp
//
//  Created by Antonio Pantaleo on 08/04/24.
//

import RickAndMortyKit
import SwiftUI
import Apollo

@main
struct RickAndMortyDemoApp: App {
    
    private let viewModel: ViewModel = {
        let graphQLCharactersLoader = {
            let url = URL(string: "https://rickandmortyapi.com/graphql")!
            let client = ApolloClient(url: url)
            return GraphQLCharacterLoader(client: client)
        }()
        
        let restCharactersLoader = {
            let url = URL(string: "https://rickandmortyapi.com/api/character")!
            let client = URLSessionHTTPClient(session: .shared)
            return RESTCharactersLoader(url: url, client: client)
        }()
        
        return ViewModel(
            charactersLoader: graphQLCharactersLoader,
            characterImageLoader: URLSessionCharacterImageLoader(session: .shared)
        )
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(viewModel: viewModel)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(Text("Rick And Morty"))
            }
        }
    }
}
