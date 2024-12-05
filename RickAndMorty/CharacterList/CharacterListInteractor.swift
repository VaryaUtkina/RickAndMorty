//
//  CharacterListInteractor.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

protocol CharacterListBusinessLogic {
    func fetchCourses()
}

protocol CharacterListDataStore {
    var courses: [Course] { get }
}

class CharacterListInteractor: CharacterListBusinessLogic, CharacterListDataStore {
    
    var presenter: CharacterListPresentationLogic?
    var characters: [CharacterData]
    
    func fetchCharacters() {
//        NetworkManager.shared.fetchData { [weak self] courses in
//            self?.courses = courses
//            let response = CourseList.ShowCourses.Response(courses: courses)
//            self?.presenter?.presentCourses(response: response)
//        }
    }
}
