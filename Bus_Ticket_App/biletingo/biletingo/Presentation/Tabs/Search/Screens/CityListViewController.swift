//
//  CityListViewController.swift
//  biletingo
//
//  Created by Gokhan on 9.09.2025.
//

import UIKit

protocol CityListViewControllerDelegate: AnyObject {
    func cityList(_ vc: CityListViewController, didSelect city: City)
}

final class CityListViewController: UIViewController {

    enum Context {
        case from, to
        var titleText: String { self == .from ? "Nereden" : "Nereye" }
    }

    weak var delegate: CityListViewControllerDelegate?

    private let service: CityService
    private var items: [City] = []
    fileprivate var query: String?
    private var page = 0
    private var hasMore = true
    private var isLoading = false
    private let pageSize = 30
    private let searchController = UISearchController(searchResultsController: nil)
    private let context: Context

    private let tableView = UITableView(frame: .zero, style: .plain)

    init(context: Context, service: CityService = .shared) {
        self.context = context
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = context.titleText
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) }
        )

        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self

        tableView.verticalScrollIndicatorInsets.bottom = 0

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        configureSearchUI()

        load(reset: true)
    }

    private func configureSearchUI() {
        searchController.searchBar.placeholder = "Şehir seçin"
        let tf = searchController.searchBar.searchTextField
        tf.placeholder = "Şehir seçin"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 6
        tf.layer.masksToBounds = true
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .search
    }

    fileprivate func load(reset: Bool) {
        guard !isLoading else { return }
        
        isLoading = true
        
        if reset {
            page = 0; hasMore = true; items.removeAll()
            tableView.reloadData()
        }
        
        service.fetchCities(query: query, page: page, pageSize: pageSize) { [weak self] newItems, more in
            guard let self else { return }
            
            self.items.append(contentsOf: newItems)
            self.hasMore = more
            self.isLoading = false
            self.tableView.reloadData()
            if more { self.page += 1 }
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CityListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let city = items[indexPath.row]
        var conf = UIListContentConfiguration.valueCell()
        conf.text = city.name
        let base = UIFont.preferredFont(forTextStyle: .body)
        conf.textProperties.font = UIFont.systemFont(ofSize: base.pointSize, weight: .semibold)
        conf.textProperties.adjustsFontForContentSizeCategory = true
        cell.contentConfiguration = conf
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = items[indexPath.row]
        delegate?.cityList(self, didSelect: city)
        dismiss(animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yAxis = scrollView.contentOffset.y
        let height = scrollView.contentSize.height - scrollView.bounds.height
        if height > 0, yAxis > height - 200, hasMore, !isLoading {
            load(reset: false)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension CityListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let newQ = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard newQ != query else { return }
        
        query = newQ
        load(reset: true)
    }
}
