//
//  SearchViewController.swift
//  biletingo
//
//  Created by Gokhan on 6.09.2025.
//

import UIKit

final class SearchViewController: UIViewController {

    private let tabsView = TransportTabView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainCard = MainCardView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .mainRed
        appearance.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.white
        ]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainCard.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tabsView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainCard)
                
        NSLayoutConstraint.activate([
            tabsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tabsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tabsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            scrollView.topAnchor.constraint(equalTo: tabsView.bottomAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            mainCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            mainCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        tabsView.onSelectionChanged = { [weak self] tab in self?.switchForm(for: tab) }
        tabsView.setSelected(index: TransportTab.bus.rawValue)
        
        mainCard.onFromTap = { [weak self] in self?.presentCityPicker(tag: 0)}
        mainCard.onToTap = { [weak self] in self?.presentCityPicker(tag: 1)}
        mainCard.onShowError = { [weak self] message in self?.showSimpleAlert(title: "Uyarı", message: message) }
        mainCard.onSearch = { [weak self] query in
            guard let self else { return }
            
            let vc = BusListViewController(query: query)
            navigationItem.backButtonTitle = ""
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        switchForm(for: .bus)
        
        mainCard.onFromTap = { [weak self] in self?.presentCityPicker(tag: 0) }
        mainCard.onToTap   = { [weak self] in self?.presentCityPicker(tag: 1) }
    }
    
    // MARK: Functions
    
    private func switchForm(for tab: TransportTab) {
        mainCard.apply(tab: tab)
    }
    
    private func presentCityPicker(tag: Int) {
        let ctx: CityListViewController.Context = (tag == 0) ? .from : .to
        let vc = CityListViewController(context: ctx)
        vc.delegate = self
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        nav.view.tag = tag
        present(nav, animated: true)
    }
    
    // MARK: UI - Helpers
    
    private func showSimpleAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - CityListViewControllerDelegate

extension SearchViewController: CityListViewControllerDelegate {
    func cityList(_ vc: CityListViewController, didSelect city: City) {
        let which = vc.navigationController?.view.tag ?? 0        
        if which == 0 {
            mainCard.setFrom(city.name)
        } else {
            mainCard.setTo(city.name)
        }
    }
}
