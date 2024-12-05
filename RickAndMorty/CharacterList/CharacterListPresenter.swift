//
//  CharacterListPresenter.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

protocol CharacterListPresentationLogic {
    func presentCharacters(response: CourseList.ShowCourses.Response)
}

final class CharacterListPresenter: CharacterListPresentationLogic {
    
    weak var viewController: CharacterListDisplayLogic?
    
    func presentCharacters(response: CourseList.ShowCourses.Response) {
        let rows: [CourseCellViewModelProtocol] = response.courses.map {
            CourseCellViewModel(course: $0)
        }
        let viewModel = CourseList.ShowCourses.ViewModel(rows: rows)
        viewController?.displayCourses(viewModel: viewModel)
    }
}
