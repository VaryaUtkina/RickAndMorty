//
//  CharacterListViewController.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

final class CharacterListViewController: UITableViewController {
    
    private let networkManager = NetworkManager.shared
    private let storageManager = StorageManager.shared
    
    private var dataCharacters: [CharacterData] = []
    private var nextURL: URL?
    
    private var isLoading = false
    private var hasMoreData = false
    
    var interactor: CharacterListBusinessLogic?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackground
        
        setupNavigationBar()
        tableView.register(CharacterCell.self, forCellReuseIdentifier: "characterCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        CharacterListConfigurator.shared.configure(with: self)
        
        isFirstAppLaunch { [weak self] in
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
                    completion()
                }
            case .failure(let error):
                Log.error("Loading error in ApiData: \(error)")
                nextURL = URL(string: "https://rickandmortyapi.com/api/character")
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
                    self.dataCharacters = characters
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Log.error(error)
            }
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
            
            switch result {
            case .success(let info):
                DispatchQueue.main.async {
                    var characters: [Character] = []
                    info.results.forEach { characters.append($0) }
                    self.storageManager.save(characters)
                    
                    self.nextURL = info.info.next
                    self.hasMoreData = (self.nextURL != nil)
                    self.storageManager.save(self.nextURL)
                    
                    completion()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    Log.error(error)
                    completion()
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CharacterListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataCharacters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath)
        guard let cell = cell as? CharacterCell else { return UITableViewCell() }
        let character = dataCharacters[indexPath.row]
        cell.config(with: character)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CharacterListViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            if isLoading || !hasMoreData { return }
            loadCharacters { [weak self] in
                guard let self else { return }
                self.fetchData {
                    self.fetchCharacters()
                }
            }
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

#Preview {
    UINavigationController(rootViewController: CharactersViewController())
}
