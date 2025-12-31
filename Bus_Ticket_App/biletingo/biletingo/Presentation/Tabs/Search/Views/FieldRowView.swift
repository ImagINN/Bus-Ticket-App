//
//  FieldRowView.swift
//  biletingo
//
//  Created by Gokhan on 9.09.2025.
//

import UIKit

final class FieldRowView: UIView {
    
    var onTap: (() -> Void)?
    
    private let iconView: UIImageView = {
        let img = UIImageView()
        img.tintColor = .secondaryLabel
        img.setContentHuggingPriority(.required, for: .horizontal)
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .mainRed
        lbl.font = .systemFont(ofSize: 13, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
   
    private let valueLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .label
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    // MARK: Build()

    private func build() {
        backgroundColor = .clear
        addSubview(iconView)
        addSubview(stack)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            stack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])
    }
    
    @objc private func handleTap() {
        onTap?()
    }
    
    func configure(title: String, value: String?, symbolName: String) {
        titleLabel.text = title
        valueLabel.text = value ?? "Seçiniz"
        iconView.image = UIImage(systemName: symbolName)
    }
    
    func setValue(_ text: String?) {
        valueLabel.text = text
    }
}
