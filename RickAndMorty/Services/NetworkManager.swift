//
//  NetworkManager.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case noData
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchCharacters(fromURL url: URL?, completion: @escaping(Result<[Character], NetworkError>) -> Void) {
        guard let url else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let info = try decoder.decode(CharactersInfo.self, from: data)
                let characters = info.results
                DispatchQueue.main.async {
                    completion(.success(characters))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping(Result<Data,NetworkError>) -> Void) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else {
                completion(.failure(.noData))
                return
            }
            DispatchQueue.main.async {
                completion(.success(imageData))
            }
        }
    }
}
