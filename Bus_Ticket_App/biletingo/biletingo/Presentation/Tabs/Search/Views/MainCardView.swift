//
//  MainCardView.swift
//  biletingo
//
//  Created by Gokhan on 6.09.2025.
//

import UIKit

final class MainCardView: UIView {
    
    //let tabsView = TransportTabView()
    let form = RouteFormView()
    let date = DateFormView()
    
    var onFromTap: (() -> Void)?
    var onToTap: (() -> Void)?
    var onDateTap: (() -> Void)?
    var onSearch: ((TripQuery) -> Void)?
    var onShowError: ((String) -> Void)?
        
    //var onSelectionChanged: ((TransportTab) -> Void)?
    
    private let searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Otobüs Ara", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .mainGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let infoLabel: UILabel = {
       let lbl = UILabel()
        lbl.text = "Kesintisiz İade Hakkı ve 0 Komisyon"
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = .systemGray4
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let verticalStack = UIStackView()
    
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
        
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 0
        container.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.3
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = .init(width: 0, height: 2)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStack = UIStackView(arrangedSubviews: [form, date, searchButton, infoLabel])
        verticalStack.axis = .vertical
        verticalStack.spacing = 12
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        container.addSubview(verticalStack)
        
        searchButton.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            verticalStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            verticalStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            verticalStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),            
        ])
        
        form.onFromTap = { [weak self] in self?.onFromTap?() }
        form.onToTap = { [weak self] in self?.onToTap?() }
        date.onDateTap = { [weak self] in self?.onDateTap?() }
        
        /*
        tabsView.onSelectionChanged = { [weak self] tab in
            self?.apply(tab: tab)
            self?.onSelectionChanged?(tab)
        }
        apply(tab: .bus)
         */
    }
    
    // MARK: Actions
    
    @objc private func searchTapped() {
        let from = form.route.from?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let to = form.route.to?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let tripDate = date.currentDate
        
        guard !from.isEmpty, !to.isEmpty else {
            onShowError?("Lütfen kalkış ve varış şehirlerini seçiniz.")
            return
        }
        
        if from.caseInsensitiveCompare(to) == .orderedSame {
            onShowError?("Kalkış ve varış konumları aynı olamaz.")
            return
        }
        
        onSearch?(TripQuery(from: from, to: to, date: tripDate))
    }
    
    // MARK: Functions
    
    func setFrom(_ name: String) { form.setFrom(name) }
    
    func setTo(_ name: String) { form.setTo(name) }
    
    // MARK: UI - Helpers
    
    func apply(tab: TransportTab) {
        let isBus = (tab == .bus)
        date.isHidden = !isBus
        infoLabel.isHidden = !isBus
        
        searchButton.setTitle(tab.ctaTitle, for: .normal)
    }
}
