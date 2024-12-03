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
    
    private var isLoading = false
    
    private init() {}
    
    func fetchCharacters(from url: URL?, completion: @escaping(Result<CharactersInfo, NetworkError>) -> Void) {
        guard !isLoading else {
            Log.error("Status of loading: \(isLoading)")
            return
        }
        
        guard let url else {
            completion(.failure(.invalidURL))
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            
            defer { isLoading = false }
            
            guard let data else {
                completion(.failure(.noData))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let info = try decoder.decode(CharactersInfo.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(info))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    func fetch<T: Decodable>(_ type: T.Type, fromURL url: URL?, completion: @escaping(Result<T, NetworkError>) -> Void) {
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
                let dataModel = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(dataModel))
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
