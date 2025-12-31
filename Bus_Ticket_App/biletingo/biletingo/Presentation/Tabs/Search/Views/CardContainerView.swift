//
//  CardContainerView.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

class CardContainerView: UIView {
    private let titleLabel = UILabel()
    private let vstack = UIStackView()

    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray2.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 8
        layer.shadowOffset = .init(width: 0, height: 2)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .mainRed

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        vstack.axis = .vertical
        vstack.spacing = 8
        vstack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(vstack)
        [titleLabel, separator].forEach { vstack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            vstack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            vstack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            vstack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func addBody(_ views: [UIView]) { views.forEach { vstack.addArrangedSubview($0) } }
}
