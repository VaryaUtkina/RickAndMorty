//
//  CharactersViewController.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

final class CharactersViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customBackground
        setupNavigationBar()
        
        tableView.dataSource = self

    }


}

// MARK: - UITableViewDataSource
extension CharactersViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
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

//#Preview {
//    UINavigationController(rootViewController: CharactersViewController())
//}
