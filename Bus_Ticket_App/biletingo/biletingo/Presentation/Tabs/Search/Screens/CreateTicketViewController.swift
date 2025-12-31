//
//  CreateTicketViewController.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

final class CreateTicketViewController: UIViewController {

    var ticket: Ticket!
    var passengers: [PassengerInfo] = []
    var contactPhone: String = ""
    var contactEmail: String = ""

    private let infoLabel = UILabel()
    private let goSearchButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Yeni Arama", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .mainGreen
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Bilet Oluşturuldu"

        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupUI()
    }

    private func setupUI() {
        infoLabel.text = "Ödemeniz alındı, biletiniz oluşturuldu."
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(infoLabel)
        view.addSubview(goSearchButton)

        goSearchButton.addTarget(self, action: #selector(goSearchTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            goSearchButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 24),
            goSearchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            goSearchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc private func goSearchTapped() {
        let searchIndex = 0

        if let tab = tabBarController {
            tab.selectedIndex = searchIndex
            if let nav = tab.viewControllers?[searchIndex] as? UINavigationController {
                nav.popToRootViewController(animated: true)
            }
        } else if
            let tab = view.window?.rootViewController as? UITabBarController,
            let nav = tab.viewControllers?[searchIndex] as? UINavigationController {
            tab.selectedIndex = searchIndex
            nav.popToRootViewController(animated: true)
        } else {
            let searchVC = SearchViewController()
            searchVC.hidesBottomBarWhenPushed = false
            navigationController?.setNavigationBarHidden(false, animated: false)
            navigationController?.setViewControllers([searchVC], animated: true)
        }
    }

}
