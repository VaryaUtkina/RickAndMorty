//
//  CharacterCell.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

final class CharacterCell: UITableViewCell {
    private lazy var characterView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .customGreen
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "WubbaLubbaDubDubRegular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.textColor = .customGreen
        label.shadowColor = .customLightGreen
        label.shadowOffset = .init(width: 1, height: 1)
        label.text = "Character name"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "WubbaLubbaDubDubRegular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        label.textColor = .customBlue
        label.shadowColor = .customDarkBlue
        label.shadowOffset = .init(width: 0.5, height: 0.5)
        label.text = """
            Status:
            Species: 
            Gender: 
            Origin:
            Location:
        """
        return label
    }()
    
    private let networkManager = NetworkManager.shared
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .customBackground
        setupViews(characterView, activityIndicator, nameLabel, descriptionLabel)
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(with characterData: CharacterData) {
        var episodes = """
            """
        
        activityIndicator.startAnimating()
        characterView.image = nil
        
        nameLabel.text = characterData.name
        descriptionLabel.text = "Loading episodes..."
        
        let group = DispatchGroup()
        let episodesSyncQueue = DispatchQueue(label: "com.app.episodesSyncQueue")
                
        guard let episodesSet = characterData.episodes as? Set<EpisodeData> else {
            Log.error("No episodes in characterData.")
            return
        }
            
        for episode in Array(episodesSet) {
            group.enter()
            
            networkManager.fetch(Episode.self, fromURL: episode.episodeURL) { result in
                switch result {
                case .success(let episode):
                    episodesSyncQueue.sync {
                        episodes.append("\(episode.episode): \(episode.name)\n")
                    }
                case .failure(let error):
                    Log.error(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            descriptionLabel.text = """
                Status: \(characterData.status ?? "")
                
                Origin: \(characterData.origin ?? "")
                Location: \(characterData.location ?? "")
                
                Episodes: 
                \(episodes)
                """
            
            if let tableView = superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
        }
        
        networkManager.fetchImage(from: characterData.image) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let imageData):
                activityIndicator.stopAnimating()
                characterView.image = UIImage(data: imageData)
            case .failure(let error):
                activityIndicator.stopAnimating()
                characterView.image = UIImage(systemName: "camera.aperture")
                Log.error(error)
            }
        }
    }
    
    func config(with character: Character) {
        var episodes = """
            """
        
        activityIndicator.startAnimating()
        characterView.image = nil
        
        nameLabel.text = character.name
        descriptionLabel.text = "Loading episodes..."
        
        let group = DispatchGroup()
        
        let episodesSyncQueue = DispatchQueue(label: "com.app.episodesSyncQueue")
        
        for episodeURL in character.episode {
            group.enter()
            
            networkManager.fetch(Episode.self, fromURL: episodeURL) { result in
                switch result {
                case .success(let episode):
                    episodesSyncQueue.sync {
                        episodes.append("\(episode.episode): \(episode.name)\n")
                    }
                case .failure(let error):
                    Log.error(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            
            descriptionLabel.text = """
                Status: \(character.status)
                
                Origin: \(character.origin.name)
                Location: \(character.location.name)
                
                Episodes: 
                \(episodes)
                """
            
            if let tableView = superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
        }
        
        networkManager.fetchImage(from: character.image) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let imageData):
                activityIndicator.stopAnimating()
                characterView.image = UIImage(data: imageData)
            case .failure(let error):
                activityIndicator.stopAnimating()
                characterView.image = UIImage(systemName: "camera.aperture")
                Log.error(error)
            }
        }
    }
    
    private func setupViews(_ views: UIView...) {
        views.forEach { view in
            contentView.addSubview(view)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: characterView.topAnchor, constant: -2)
        ])
        
        NSLayoutConstraint.activate([
            characterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            characterView.widthAnchor.constraint(equalTo: characterView.heightAnchor),
            characterView.widthAnchor.constraint(equalToConstant: 80),
            characterView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant:  -2)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: characterView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: characterView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: characterView.trailingAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -2)
        ])
    }
}

#Preview {
    CharacterCell()
}
