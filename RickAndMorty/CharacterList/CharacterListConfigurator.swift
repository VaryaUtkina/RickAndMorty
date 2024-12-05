//
//  CharacterListConfigurator.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

final class CharacterListConfigurator {
    static let shared = CharacterListConfigurator()
    
    private init() {}
    
    func configure(with viewController: CharacterListViewController) {
        let interactor = CharacterListInteractor()
        let presenter = CharacterListPresenter()
        viewController.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = viewController
    }
}
