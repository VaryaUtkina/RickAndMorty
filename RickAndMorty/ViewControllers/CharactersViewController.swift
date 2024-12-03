//
//  CharactersViewController.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

final class CharactersViewController: UITableViewController {
    
    private let networkManager = NetworkManager.shared
    private let storageManager = StorageManager.shared
    
    private var dataCharacters: [CharacterData] = []
    private var characters: [Character] = []
    private var nextURL: URL?
    
    private var isLoading = false
    private var hasMoreData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackground
        setupNavigationBar()
        tableView.register(CharacterCell.self, forCellReuseIdentifier: "characterCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        fetchData { [weak self] in
            guard let self else { return }
            self.loadCharacters()
        }
    }
    
    private func fetchData(completion: @escaping() -> Void) {
        storageManager.fetchApiData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let apiData):
                DispatchQueue.main.async {
                    self.nextURL = apiData.last?.nextURL
                    self.fetchCharacters {
                        if self.dataCharacters.count < 10 {
                            completion()
                        }
                    }
                }
            case .failure(let error):
                Log.error("Loading error in ApiData: \(error)")
                nextURL = URL(string: "https://rickandmortyapi.com/api/character")
                completion()
            }
        }
    }
    
    private func fetchCharacters(completion: @escaping() -> Void) {
        storageManager.fetchData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let characters):
                DispatchQueue.main.async {
                    self.dataCharacters = characters
                    completion()
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }
    
    private func loadCharacters() {
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
                    info.results.forEach { self.characters.append($0) }
                    self.storageManager.save(self.characters)
                    self.nextURL = info.info.next
                    self.storageManager.save(self.nextURL)
                    self.hasMoreData = (self.nextURL != nil)
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    Log.error(error)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CharactersViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath)
        guard let cell = cell as? CharacterCell else { return UITableViewCell() }
        let character = characters[indexPath.row]
        cell.config(with: character)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CharactersViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            if isLoading || !hasMoreData { return }
            loadCharacters()
        }
    }
}

// MARK: - Setup NavigationBar
private extension CharactersViewController {
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
