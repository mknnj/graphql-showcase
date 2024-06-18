//
//  RickAndMortyDemoAppApp.swift
//  RickAndMortyDemoApp
//
//  Created by Antonio Pantaleo on 08/04/24.
//

import SwiftUI

@main
struct RickAndMortyDemoAppApp: App {
    private static let rickAndMortyString = "https://rickandmortyapi.com/graphql"
    private let graphQLUrl = URL(string: rickAndMortyString)!
    var body: some Scene {
        WindowGroup {
            AppComposer.composeContentViewWithGraphQL(serverURL: graphQLUrl)
        }
    }
}

import RickAndMortyKit
import Apollo

enum AppComposer {
    static func composeContentViewWithGraphQL(serverURL: URL) -> some View {
        NavigationStack {
            ContentView(
                viewModel: ViewModel(
                    loader: GraphQLCharacterLoader(
                        client: ApolloClient(
                            url: serverURL
                        )
                    )
                )
            )
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Text("Rick And Morty"))
        }
    }
}
