//
//  CharacterListPresenter.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 05.12.2024.
//

import Foundation

protocol CharacterListPresentationLogic {
    func presentCharacters(response: CharacterList.ShowCharacters.Response)
}

final class CharacterListPresenter: CharacterListPresentationLogic {
    
    weak var viewController: CharacterListDisplayLogic?
    
    func presentCharacters(response: CharacterList.ShowCharacters.Response) {
        let rows: [CharacterCellViewModelProtocol] = response.characters.map {
            CharacterCellViewModel(character: $0)
        }
        let viewModel = CharacterList.ShowCharacters.ViewModel(rows: rows)
        viewController?.displayCharacters(viewModel: viewModel)
    }
}
