//
//  TransportTabView.swift
//  biletingo
//
//  Created by Gokhan on 7.09.2025.
//

import UIKit

enum TransportTab: Int, CaseIterable {
    case bus, flight, hotel, car, ferry
    
    var title: String {
        switch self {
        case .bus: return "Otobüs"
        case .flight: return "Uçak"
        case .hotel: return "Otel"
        case .car: return "Araç"
        case .ferry: return "Feribot"
        }
    }
    
    var ctaTitle: String {
        switch self {
        case .bus: return "Otobüs Ara"
        case .flight: return "Uçuş Ara"
        case .hotel: return "Tren Ara"
        case .car: return "Araç Ara"
        case .ferry: return "Sefer Ara"
        }
    }
    
    var symbolName: String {
        switch self {
        case .bus: return "bus"
        case .flight: return "airplane"
        case .hotel: return "bed.double.fill"
        case .car: return "car.fill"
        case .ferry: return "ferry.fill"
        }
    }
}

final class TransportTabView: UIView {
    
    var onSelectionChanged: ((TransportTab) -> Void)?
    
    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    
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
        
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 0
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = .init(width: 0, height: 2)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 6
        card.layer.borderWidth = 1
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        card.layer.borderColor = UIColor.systemGray4.cgColor
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = .init(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        container.addSubview(card)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            card.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
        
        for (idx, tab) in TransportTab.allCases.enumerated() {
            var cfg = UIButton.Configuration.plain()
            cfg.title = tab.title
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { (incoming) in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 13, weight: .medium)
                return outgoing
            }
            cfg.image = UIImage(systemName: tab.symbolName)
            cfg.imagePlacement = .top
            cfg.imagePadding = 6
            cfg.contentInsets = .init(top: 8, leading: 6, bottom: 8, trailing: 6)
            
            let btn = UIButton(configuration: cfg)
            btn.tag = idx
            btn.layer.cornerRadius = 6
            btn.addTarget(self, action: #selector(tap(_:)), for: .touchUpInside)
            style(btn, selected: idx == 0)
            buttons.append(btn)
            stack.addArrangedSubview(btn)
        }
    }
    
    @objc private func tap(_ sender: UIButton) {
        setSelected(index: sender.tag)
    }
    
    func setSelected(index: Int) {
        for (idx, btn) in buttons.enumerated() {
            style(btn, selected: idx == index)
        }
        
        if let tab = TransportTab(rawValue: index) {
            onSelectionChanged?(tab)
        }
    }
    
    private func style(_ button: UIButton, selected: Bool) {
        button.backgroundColor = selected ? .mainRed : .systemBackground
        button.configuration?.baseForegroundColor = selected ? .white : UIColor(hex: "#585858")
    }
}

