//
//  HelpViewController.swift
//  biletingo
//
//  Created by Gokhan on 6.09.2025.
//

import UIKit

final class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let customNavBarAppearance = UINavigationBarAppearance()
        customNavBarAppearance.configureWithOpaqueBackground()
        customNavBarAppearance.backgroundColor = .mainRed
        customNavBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 12)
        ]
        
        navigationItem.standardAppearance = customNavBarAppearance
        navigationItem.scrollEdgeAppearance = customNavBarAppearance
        navigationItem.compactAppearance = customNavBarAppearance
        
     }

}
