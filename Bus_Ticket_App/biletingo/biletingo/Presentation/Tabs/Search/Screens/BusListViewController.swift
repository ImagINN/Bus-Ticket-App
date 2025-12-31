//
//  BusListViewController.swift
//  biletingo
//
//  Created by Gokhan on 11.09.2025.
//

import UIKit

final class BusListViewController: UIViewController {
    
    var query: TripQuery
    private let busTableView = UITableView(frame: .zero, style: .plain)
    private var items: [BusTrip] = MOCK_TRIPS
    
    private var expandedIndexPath: IndexPath?
    
    init(query: TripQuery) {
        self.query = query
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTitleView()
        setupTable()
        applyFilterAndSort()
    }
    
    // MARK: Functions

    private func setupTitleView() {
        let fromLabel = UILabel()
        fromLabel.text = query.from
        fromLabel.textColor = .white
        fromLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        fromLabel.textAlignment = .right
        fromLabel.adjustsFontSizeToFitWidth = true
        fromLabel.minimumScaleFactor = 0.8
        
        let swapButton = UIButton(type: .system)
        swapButton.setImage(UIImage(systemName: "arrow.right.arrow.left.square"), for: .normal)
        swapButton.addTarget(self, action: #selector(didTapSwap), for: .touchUpInside)
        swapButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        let toLabel = UILabel()
        toLabel.text = query.to
        toLabel.textColor = .white
        toLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        toLabel.textAlignment = .left
        toLabel.adjustsFontSizeToFitWidth = true
        toLabel.minimumScaleFactor = 0.8
        
        let stack = UIStackView(arrangedSubviews: [fromLabel, swapButton, toLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        
        navigationItem.titleView = stack
    }
    
    private func setupTable() {
        view.addSubview(busTableView)
        busTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            busTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            busTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            busTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            busTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        busTableView.register(UINib(nibName: "BusTableViewCell", bundle: nil), forCellReuseIdentifier: BusTableViewCell.reuseId)
        
        busTableView.dataSource = self
        busTableView.delegate = self
        busTableView.rowHeight = UITableView.automaticDimension
        busTableView.estimatedRowHeight = 160
        busTableView.separatorStyle = .none
        busTableView.backgroundColor = .clear
        busTableView.showsVerticalScrollIndicator = true
        busTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
    }
    
    private func applyFilterAndSort() {
        let wantedDateStr = turkishDayString(from: query.date)
        let wantedDirection = "\(query.from) > \(query.to)"

        items = MOCK_TRIPS
            .filter { $0.departureDate == wantedDateStr && $0.directionText == wantedDirection }
            .sorted { (lhs, rhs) in
                (lhs.timeAsDate ?? .distantPast) < (rhs.timeAsDate ?? .distantPast)
            }

        if items.isEmpty {
            let label = UILabel()
            label.text = "Sonuç bulunamadı"
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .secondaryLabel
            busTableView.backgroundView = label
        } else {
            busTableView.backgroundView = nil
        }

        busTableView.reloadData()
    }
    
    // MARK: Actions
    
    @objc private func didTapSwap() {
        swap(&query.from, &query.to)
        setupTitleView()
        applyFilterAndSort()
    }
}

extension BusListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BusTableViewCell.reuseId, for: indexPath
        ) as! BusTableViewCell
        
        let trip = items[indexPath.row]
        cell.configure(with: trip)
        
        if trip.isExpanded { cell.expandUI() } else { cell.collapseUI() }
        
        cell.onToggleExpand = { [weak self, weak tableView] in
            guard let self, let tableView else { return }
            
            var reloads: [IndexPath] = []
            if let prev = self.expandedIndexPath, prev != indexPath {
                self.items[prev.row].isExpanded = false
                reloads.append(prev)
            }
            
            let willExpand = !self.items[indexPath.row].isExpanded
            self.items[indexPath.row].isExpanded = willExpand
            self.expandedIndexPath = willExpand ? indexPath : nil
            reloads.append(indexPath)
            
            tableView.reloadRows(at: reloads, with: .automatic)
        }
        
        cell.onConfirm = { [weak self] ticket in
            let vc = PaymentViewController()
            vc.ticket = ticket
            self?.navigationItem.backButtonTitle = ""
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reloads: [IndexPath] = []
        if let prev = expandedIndexPath, prev != indexPath {
            items[prev.row].isExpanded = false
            if let cell = tableView.cellForRow(at: prev) as? BusTableViewCell {
                cell.collapseUI()
            }
        }
        let willExpand = !(items[indexPath.row].isExpanded)
        items[indexPath.row].isExpanded = willExpand
        expandedIndexPath = willExpand ? indexPath : nil
        reloads.append(indexPath)
        tableView.reloadRows(at: reloads, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
}

extension BusTrip {
    var timeAsDate: Date? {
        BusListViewController.timeFormatter.date(from: departureTime)
    }
}

extension BusListViewController {
    static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "tr_TR")
        df.dateFormat = "HH:mm"
        return df
    }()

    func turkishDayString(from date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "tr_TR")
        df.dateFormat = "d MMMM EEEE"
        return df.string(from: date)
    }
}
