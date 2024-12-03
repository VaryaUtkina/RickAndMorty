//
//  StorageManager.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 03.12.2024.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Character")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - CRUD
    func fetchData(completion: @escaping(Result<[CharacterData], Error>) -> Void) {
        let fetchRequest = CharacterData.fetchRequest()
        
        do {
            let characters = try viewContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                completion(.success(characters))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchApiData(completion: @escaping(Result<[ApiData], Error>) -> Void) {
        let fetchRequest = ApiData.fetchRequest()
        
        do {
            let apiData = try viewContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                completion(.success(apiData))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func save(_ characters: [Character]) {
        for character in characters {
            let characterData = CharacterData(context: viewContext)
            characterData.name = character.name
            characterData.status = character.status
            characterData.origin = character.origin.name
            characterData.location = character.location.name
            characterData.image = character.image
            
            for episode in character.episode {
                let episodeData = EpisodeData(context: viewContext)
                episodeData.episodeURL = episode
                characterData.addToEpisodes(episodeData)
            }
        }
        saveContext()
    }
    
    func save(_ url: URL?) {
        let apiData = ApiData(context: viewContext)
        apiData.nextURL = url
        saveContext()
    }
    
    func update(_ character: CharacterData, withName name: String) {
        character.name = name
        saveContext()
    }
    
    func delete(_ character: CharacterData) {
        viewContext.delete(character)
        saveContext()
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
