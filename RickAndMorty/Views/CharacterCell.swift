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
        imageView.image = UIImage(systemName: "camera.aperture")
        imageView.tintColor = .customGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "WubbaLubbaDubDubRegular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        label.textColor = .customGreen
        label.shadowColor = .customLightGreen
        label.shadowOffset = .init(width: 2, height: 2)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .customBackground
        setupViews(characterView, nameLabel, descriptionLabel)
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            characterView.widthAnchor.constraint(equalToConstant: 120),
            characterView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant:  -2)
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
