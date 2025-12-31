//
//  MainTabBarController.swift
//  biletingo
//
//  Created by Gokhan on 6.09.2025.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        
        setupAppearance()
        
        viewControllers = [
            wrap(SearchViewController(), title: "biletingo", systemIcon: "magnifyingglass", selectedIcon: nil),
            wrap(TripsViewController(), title: "Seyahatlerim", systemIcon: "suitcase", selectedIcon: "suitcase.fill"),
            wrap(CampaignsViewController(), title: "Kampanyalar", systemIcon: "gift", selectedIcon: "gift.fill"),
            wrap(HelpViewController(), title: "Yardım", systemIcon: "questionmark.circle", selectedIcon: "questionmark.circle.fill"),
            wrap(AccountViewController(), title: "Hesabım", systemIcon: "person.crop.circle", selectedIcon: "person.crop.circle.fill"),
        ]
    }
    
    // MARK: Functions
    
    private func wrap(
        _ root: UIViewController,
        title: String,
        systemIcon: String,
        selectedIcon: String?
    ) -> UINavigationController {
        root.title = title
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: systemIcon),
            selectedImage: UIImage(systemName: selectedIcon ?? systemIcon)
        )
        
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = false
        
        return nav
    }
    
    // MARK: Setups
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        tabBar.tintColor = .mainRed
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

// MARK: UITabBarControllerDelegate

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if selectedViewController == viewController {
            return false
        }
        
        UIView.performWithoutAnimation {
            tabBarController.selectedViewController = viewController
        }
        
        return false
    }
}
