//
//  RouteFormView.swift
//  biletingo
//
//  Created by Gokhan on 9.09.2025.
//

import UIKit

final class RouteFormView: UIView {
    
    var onFromTap: (() -> Void)?
    var onToTap: (() -> Void)?
    var onSwapTap: (() -> Void)?
    
    private let fromRow = FieldRowView()
    private let toRow = FieldRowView()
    
    private let swapButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.tintColor = UIColor.systemGray4
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        let img = UIImage(systemName: "arrow.up.arrow.down.square", withConfiguration: symbolConfig)
        btn.setImage(img, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private(set) var route = Route() //okuma izni herkese açık, ama yeni değer atama sadece sınıfın (RouteFormView) içinde mümkün
    
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
        backgroundColor = .systemBackground
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 6
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = .init(width: 0, height: 2)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        container.addSubview(verticalStack)
        container.addSubview(swapButton)
        
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.layer.opacity = 0.3
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStack.addArrangedSubview(fromRow)
        verticalStack.addArrangedSubview(separator)
        verticalStack.addArrangedSubview(toRow)
        
        fromRow.configure(title: "NEREDEN", value: route.from, symbolName: "mappin")
        toRow.configure(title: "NEREYE", value: route.to, symbolName: "mappin")
        
        fromRow.onTap = { [weak self] in self?.onFromTap?() }
        toRow.onTap = { [weak self] in self?.onToTap?() }
        
        swapButton.addTarget(self, action: #selector(swapTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            swapButton.centerYAnchor.constraint(equalTo: verticalStack.centerYAnchor),
            swapButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            swapButton.widthAnchor.constraint(equalToConstant: 36),
            swapButton.heightAnchor.constraint(equalToConstant: 36),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
    }
    
    @objc private func swapTapped() {
        if route.from == nil { route.from = "Seçiniz" }
        if route.to == nil { route.to = "Seçiniz" }
        
        route.swap()
        fromRow.setValue(route.from)
        toRow.setValue(route.to)
        onSwapTap?()
    }
    
    func configure(with route: Route) {
        self.route = route
        fromRow.setValue(route.from)
        toRow.setValue(route.to)
    }
    
    func setFrom(_ name: String?) {
        route.from = name
        fromRow.setValue(name)
    }
    
    func setTo(_ name: String?) {
        route.to = name
        toRow.setValue(name)
    }
}
