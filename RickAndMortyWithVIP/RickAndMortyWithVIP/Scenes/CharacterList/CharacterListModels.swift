//
//  CharacterListModels.swift
//  RickAndMortyWithVIP
//
//  Created by MacOS on 27.01.2022.
//

import Foundation
enum Characters {

    enum Fetch {

        struct Request {
            var page : Int
        }

        struct Response {
            var characters: [CharacterDetails]
        }

        struct ViewModel {
            var characters: [Characters.Fetch.ViewModel.Character]

            struct Character {
                let name: String?
                let status: String?
                let image: String?
            }
        }
    }
}
