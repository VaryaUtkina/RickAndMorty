//
//  CharacterListInteractor.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

protocol CharacterListBusinessLogic {
    func getCharacters()
    func loadMoreCharacters()
}

protocol CharacterListDataStore {
    var characters: [CharacterData] { get }
}

final class CharacterListInteractor: CharacterListBusinessLogic, CharacterListDataStore {
    
    var presenter: CharacterListPresentationLogic?
    var characters: [CharacterData] = []
    
    private let storageManager = StorageManager.shared
    private let networkManager = NetworkManager.shared
    
    private var nextURL: URL?
    private var isLoading = false
    private var hasMoreData = false
    
    func getCharacters() {
        isFirstAppLaunch { [weak self] in
            guard let self else { return }
            self.fetchData {
                self.fetchCharacters()
            }
        }
    }
    
    func loadMoreCharacters() {
        if isLoading || !hasMoreData { return }
        loadCharacters { [weak self] in
            guard let self else { return }
            self.fetchData {
                self.fetchCharacters()
            }
        }
    }
    
    private func isFirstAppLaunch(completion: @escaping() -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            UserDefaults.standard.set(true, forKey: "done")
            nextURL = URL(string: "https://rickandmortyapi.com/api/character")
            loadCharacters {
                completion()
            }
        } else {
            completion()
        }
    }
    
    private func fetchData(completion: @escaping() -> Void) {
        storageManager.fetchApiData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let apiData):
                DispatchQueue.main.async {
                    self.nextURL = apiData.last?.nextURL
                    self.hasMoreData = (self.nextURL != nil)
                    completion()
                }
            case .failure(let error):
                Log.error("Loading error in ApiData: \(error)")
                nextURL = URL(string: "https://rickandmortyapi.com/api/character")
                hasMoreData = true
                completion()
            }
        }
    }
    
    private func fetchCharacters() {
        storageManager.fetchData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let characters):
                DispatchQueue.main.async {
                    self.characters = characters
                    let response = CharacterList.ShowCharacters.Response(characters: characters)
                    self.presenter?.presentCharacters(response: response)
                }
            case .failure(let error):
                Log.error(error)
            }
            self.isLoading = false
        }
    }
    
    private func loadCharacters(completion: @escaping(() -> Void)) {
        guard !isLoading else {
            Log.error("Loading status: \(isLoading)")
            return
        }
        isLoading = true

        guard let url = nextURL else {
            isLoading = false
            Log.error("No url, loading is stopped")
            return
        }
        
        networkManager.fetchCharacters(from: url) { [weak self] result in
            guard let self else { return }
            
            defer { isLoading = false }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let info):
                    var characters: [Character] = []
                    info.results.forEach { characters.append($0) }
                    self.storageManager.save(characters)
                    
                    self.nextURL = info.info.next
                    self.hasMoreData = (self.nextURL != nil)
                    self.storageManager.save(self.nextURL)
                    
                    completion()
                case .failure(let error):
                    Log.error(error)
                    completion()
                }
            }
        }
    }
}
