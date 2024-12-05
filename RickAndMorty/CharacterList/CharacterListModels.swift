//
//  CharacterListModels.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

typealias CharacterCellViewModel = ChatacterList.ShowCharacters.ViewModel.CharacterCellViewModel

protocol CharacterCellViewModelProtocol {
    var identifier: String { get }
    var characterName: String { get }
    var imageData: Data? { get }
    init(character: CharacterData)
    func loadEpisodes(completion: @escaping (String) -> Void)
}

enum ChatacterList {
    
    // MARK: Use cases
    enum ShowCharacters {
        
        struct Response {
            let characters: [CharacterData]
        }
        
        struct ViewModel {
            struct CharacterCellViewModel: CharacterCellViewModelProtocol {
                var identifier: String {
                    "characterCell"
                }
                
                var characterName: String {
                    character.name ?? ""
                }
                
                var imageData: Data? {
                    ImageManager.shared.fetchImageData(from: character.image)
                }
                
                private let character: CharacterData
                
                init(character: CharacterData) {
                    self.character = character
                }
                
                func loadEpisodes(completion: @escaping (String) -> Void) {
                    var episodesText = ""
                    let group = DispatchGroup()
                    
                    guard let episodesSet = character.episodes as? Set<EpisodeData> else {
                        Log.error("No episodes in characterData.")
                        completion(episodesText)
                        return
                    }
                    
                    for episode in Array(episodesSet) {
                        group.enter()
                        NetworkManager.shared.fetch(Episode.self, fromURL: episode.episodeURL) { result in
                            switch result {
                            case .success(let episode):
                                episodesText.append("\(episode.episode): \(episode.name)\n")
                            case .failure(let error):
                                Log.error(error)
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        let description = """
                            Status: \(character.status ?? "")
                            
                            Origin: \(character.origin ?? "")
                            Location: \(character.location ?? "")
                            
                            Episodes: 
                            \(episodesText)
                            """
                        completion(description)
                    }
                }
            }
            let rows: [CharacterCellViewModelProtocol]
        }
    }
}
