//
//  Character.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import Foundation

struct CharactersInfo: Decodable {
    let info: Info
    let results: [Character]
}

struct Info: Decodable {
    let next: URL?
    let prev: URL?
}

struct Character: Decodable {
    let name: String
    let status: String
    let species: String
    let gender: String
    let origin: Origin
    let location: Location
    let image: URL
}

struct Origin: Decodable {
    let name: String
}

struct Location: Decodable {
    let name: String
}
