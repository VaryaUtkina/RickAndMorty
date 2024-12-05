//
//  CharacterListViewController.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

protocol CharacterListDisplayLogic: AnyObject {
    func displayCharacters(viewModel: CharacterList.ShowCharacters.ViewModel)
}

final class CharacterListViewController: UITableViewController {
    
    var interactor: CharacterListBusinessLogic?
    
    private var rows: [CharacterCellViewModelProtocol] = []
    
    private let networkManager = NetworkManager.shared
    private let storageManager = StorageManager.shared
    
    private var dataCharacters: [CharacterData] = []
    private var nextURL: URL?
    
    private var isLoading = false
    private var hasMoreData = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        CharacterListConfigurator.shared.configure(with: self)
        
        view.backgroundColor = .customBackground
        
        setupNavigationBar()
        tableView.register(CharacterCell.self, forCellReuseIdentifier: "characterCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        
        showCharacters()
    }
    
    private func showCharacters() {
        interactor?.getCharacters()
    }
}

// MARK: - UITableViewDataSource
extension CharacterListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellViewModel.identifier, for: indexPath)
        guard let cell = cell as? CharacterCell else { return UITableViewCell() }
        cell.viewModel = cellViewModel
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CharacterListViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 100 && !isLoading && hasMoreData {
            isLoading = true
            interactor?.loadMoreCharacters()
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let character = dataCharacters[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
            storageManager.delete(character)
            dataCharacters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(withCharacter: character) { [ weak self] newName in
                guard let self else { return }
                guard let name = newName else { return }
                storageManager.update(character, withName: name)
                dataCharacters[indexPath.row].name = name
                tableView.reloadRows(at: [indexPath], with: .automatic)

            }
            isDone(true)
        }
        
        editAction.backgroundColor = .customGreen
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .customBackground
    }
}


// MARK: - UIAlertController
private extension CharacterListViewController {
    func showAlert(withCharacter character: CharacterData, completion: @escaping(String?) -> Void) {
        let alert = UIAlertController(title: "Editing", message: "Enter new Character's name", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let textField = alert.textFields?.first, let newName = textField.text, !newName.isEmpty else {
                completion(nil)
                return
            }
            completion(newName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            completion(nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = character.name
            
            okAction.isEnabled = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
            
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        }
        
        present(alert, animated: true)
    }
    
    @objc func textChanged(_ textField: UITextField) {
        if let alert = presentedViewController as? UIAlertController {
            let okAction = alert.actions.first { action in
                action.title == "OK"
            }
            okAction?.isEnabled = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        }
    }
}

// MARK: - Setup NavigationBar
private extension CharacterListViewController {
    func setupNavigationBar() {
        title = "Rick and Morty"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = .customBackground
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.customLightGreen
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowBlurRadius = 3
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .customGreen
        
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.customBlue,
            .font: UIFont(name: "GetSchwifty-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18),
            .strokeColor: UIColor.customDarkBlue,
            .strokeWidth: -2,
            .shadow: shadow
        ]

        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.customBlue,
            .font: UIFont(name: "GetSchwifty-Regular", size: 35) ?? UIFont.systemFont(ofSize: 35),
            .strokeColor: UIColor.customDarkBlue,
            .strokeWidth: -2,
            .shadow: shadow
        ]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}


extension CharacterListViewController: CharacterListDisplayLogic {
    func displayCharacters(viewModel: CharacterList.ShowCharacters.ViewModel) {
        rows = viewModel.rows
        tableView.reloadData()
    }
}
