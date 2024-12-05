//
//  CharacterCell.swift
//  RickAndMorty
//
//  Created by Варвара Уткина on 02.12.2024.
//

import UIKit

protocol CellModelRepresentable {
    var viewModel: CharacterCellViewModelProtocol? { get }
}

final class CharacterCell: UITableViewCell, CellModelRepresentable {
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
        label.text = ""
        return label
    }()
    
    var viewModel: CharacterCellViewModelProtocol? {
        didSet {
            updateView()
        }
    }
    
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
    
    func updateView() {
        activityIndicator.startAnimating()
        guard let viewModel = viewModel as? CharacterCellViewModel else { return }
        
        nameLabel.text = viewModel.characterName
        
        if characterView.image == nil {
            viewModel.loadImageData { [weak self] imageData in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    if let imageData {
                        self.characterView.image = UIImage(data: imageData)
                    } else {
                        self.characterView.image = UIImage(systemName: "person")
                    }
                }
            }
        }
        
        viewModel.loadEpisodes { [weak self] description in
            guard let self else { return }
            DispatchQueue.main.async {
                self.descriptionLabel.text = description
                guard let tableView = self.superview as? UITableView else { return }
                tableView.reloadData()
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

