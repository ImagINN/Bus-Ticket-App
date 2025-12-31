//
//  PassengerTabCell.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

final class PassengerTabCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray3.cgColor
        contentView.backgroundColor = .systemBackground
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, isSelectedTab: Bool) {
        label.text = title
        if isSelectedTab {
            contentView.layer.borderColor = UIColor.systemRed.cgColor
            contentView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            label.textColor = .systemRed
        } else {
            contentView.layer.borderColor = UIColor.systemGray3.cgColor
            contentView.backgroundColor = .systemBackground
            label.textColor = .label
        }
    }
}
