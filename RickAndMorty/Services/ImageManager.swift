//
//  ImageManager.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

final class ImageManager {
    static let shared = ImageManager()
    
    private init() {}
    
    func fetchImageData(from url: URL?, completion: @escaping (Data?) -> Void) {
        guard let url = url else {
            Log.error("Invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data else {
                Log.error("No data received")
                return
            }
            completion(data)
        }.resume()
    }
}
