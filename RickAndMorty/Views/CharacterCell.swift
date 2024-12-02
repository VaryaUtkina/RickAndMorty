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
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GetSchwifty-Regular", size: 18) ?? UIFont.systemFont(ofSize: 18)
        label.textColor = .customGreen
        label.shadowColor = .customLightGreen
        label.shadowOffset = .init(width: 2, height: 2)
        label.text = "Character name"
        return label
    }()
}
