//
//  BusTableViewCell.swift
//  biletingo
//
//  Created by Gokhan on 11.09.2025.
//

import UIKit

class BusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var busHeaderStackView: UIStackView!
    @IBOutlet weak var busSeatStackView: UIStackView!
    @IBOutlet weak var busExpandStackView: UIStackView!
    
    @IBOutlet weak var busLogoImageView: UIImageView!
    @IBOutlet weak var busDepartureTimeLabel: UILabel!
    @IBOutlet weak var busTicketPriceLabel: UILabel!
    
    @IBOutlet weak var busSeatTypeLabel: UILabel!
    @IBOutlet weak var busTravelTimeLabel: UILabel!
    @IBOutlet weak var busLimitedSeatWarnLabel: UILabel!
    @IBOutlet weak var busDirectionLabel: UILabel!
    
    @IBOutlet weak var busEmptySeatView: UIView!
    @IBOutlet weak var busConfirmButton: UIButton!
    @IBOutlet weak var busSeatHostView: UIView!
    @IBOutlet weak var busExpandButton: UIButton!
    @IBOutlet weak var busSelectedSeatInfo: UILabel!
    
    private var collectionView: UICollectionView!
    private var columns: [SeatColumn] = []
    private var manager: SeatSelectionManager!
    
    private var unitPriceTL: Int = 0
    private var currentTrip: BusTrip?
    
    private weak var genderPopup: GenderPopup?
    private weak var dismissOverlay: UIControl?
    
    var onSeatSelect: ((Seat) -> Void)?
    var onConfirm: ((Ticket) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupSeatsCollection()
        
        contentView.clipsToBounds = false
        
        if busSeatHostView.constraints.first(where: { $0.firstAttribute == .height }) == nil {
            let h = busSeatHostView.heightAnchor.constraint(equalToConstant: 200)
            h.priority = .required
            h.isActive = true
        }
        
        setConfirmEnabled(false)
        busSelectedSeatInfo.text = "Lütfen yukarıdan koltuk seçin"

        busExpandButton.addTarget(self, action: #selector(expandSeatView), for: .touchUpInside)
        busConfirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        closePopup()
    }
    
    private func closePopup() {
        genderPopup?.removeFromSuperview()
        dismissOverlay?.removeFromSuperview()
        genderPopup = nil
        dismissOverlay = nil
    }
    
    private func showGenderPopup(anchor: UIView, pick: @escaping (Gender)->Void) {
        closePopup()
        guard let vcView = parentViewController?.view else { return }
        
        // overlay
        let overlay = UIControl()
        overlay.backgroundColor = .clear
        overlay.translatesAutoresizingMaskIntoConstraints = false
        vcView.addSubview(overlay)
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: vcView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: vcView.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: vcView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: vcView.trailingAnchor)
        ])
        overlay.addTarget(self, action: #selector(didTapOutside), for: .touchUpInside)
        dismissOverlay = overlay
        
        // popup
        let p = GenderPopup()
        p.onPick = { [weak self] g in
            pick(g)
            self?.closePopup()
        }
        p.translatesAutoresizingMaskIntoConstraints = false
        vcView.addSubview(p)
        genderPopup = p
        
        // anchor koordinatını VC view’ına çevir
        let frame = anchor.convert(anchor.bounds, to: vcView)
        
        NSLayoutConstraint.activate([
            p.widthAnchor.constraint(equalToConstant: 200),
            p.heightAnchor.constraint(equalToConstant: 80),
            p.centerXAnchor.constraint(equalTo: vcView.leadingAnchor, constant: frame.midX),
            p.bottomAnchor.constraint(equalTo: vcView.topAnchor, constant: frame.minY - 8) // anchor'ın üstüne
        ])
        
        p.alpha = 0; p.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.18) { p.alpha = 1; p.transform = .identity }
    }
    
    @objc private func didTapOutside() { closePopup() }
    
    // expand butonuna dışarıdan tepki verdireceğiz
    var onToggleExpand: (() -> Void)?
    
    @objc private func expandSeatView() {
        onToggleExpand?()        // model güncellemesi VC’de yapılacak
    }
    
    func collapseUI() {
        busSeatStackView.isHidden = true
        busExpandButton.setTitle("İncele", for: .normal)
        closePopup()
    }
    
    func expandUI() {
        busSeatStackView.isHidden = false
        busExpandButton.setTitle("Kapat", for: .normal)
    }

    
    // MARK: Actions
    /*
    @objc private func expandSeatView() {
        busSeatStackView.isHidden.toggle()
        busExpandButton.setTitle(busSeatStackView.isHidden ? "İncele" : "Kapat", for: .normal)
        collectionView.reloadData()
    }
    */
    @objc private func didTapConfirm() {
        guard let trip = currentTrip else { return }
        guard manager.selectedCount > 0 else { return }

        let seats = manager.selectedSeatNumbers
        let total = seats.count * unitPriceTL

        let ticket = Ticket(
            route: trip.directionText,
            date: trip.departureDate,
            time: trip.departureTime,
            company: trip.company,
            totalPrice: total,
            seatNumbers: seats
        )
        onConfirm?(ticket)
    }
    
    // MARK: UI - Helper
    
    private func setupUI() {
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 6
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
        
        busExpandStackView.layer.cornerRadius = 6
        busExpandStackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        busExpandStackView.clipsToBounds = true
        busExpandStackView.layer.borderWidth = 1
        busExpandStackView.layer.borderColor = UIColor.systemGray2.cgColor
        
        busEmptySeatView.layer.borderWidth = 1
        busEmptySeatView.layer.borderColor = UIColor.systemGray2.cgColor
        
        busSeatHostView.layer.cornerRadius = 8
        busSeatHostView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        busSeatHostView.layer.borderWidth = 1
        busSeatHostView.layer.borderColor = UIColor.systemGray2.cgColor
        
        busConfirmButton.layer.cornerRadius = 8
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupSeatsCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(SeatColumnCell.self, forCellWithReuseIdentifier: SeatColumnCell.reuse)
        collectionView.register(SeatColumn22Cell.self, forCellWithReuseIdentifier: SeatColumn22Cell.reuse)
        collectionView.register(BusFrontColumnCell.self, forCellWithReuseIdentifier: BusFrontColumnCell.reuse)
        
        busSeatHostView .addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: busSeatHostView.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: busSeatHostView.leadingAnchor, constant: 6),
            collectionView.trailingAnchor.constraint(equalTo: busSeatHostView.trailingAnchor, constant: -6),
            collectionView.bottomAnchor.constraint(equalTo: busSeatHostView.bottomAnchor, constant: -12)
        ])
        
        collectionView.reloadData()
    }
    
    func configure(with trip: BusTrip) {
        currentTrip = trip
        busLogoImageView.image = UIImage(named: trip.logoName)
        busDepartureTimeLabel.text = trip.departureTime
        busTicketPriceLabel.text = trip.priceText + " TL"
        busSeatTypeLabel.text = trip.seatType
        busTravelTimeLabel.text = trip.travelTime
        busLimitedSeatWarnLabel.text = trip.limitedSeatText
        busDirectionLabel.text = trip.directionText

        busSeatStackView.isHidden = !trip.isExpanded
        busExpandButton.setTitle(trip.isExpanded ? "Kapat" : "İncele", for: .normal)
        
        unitPriceTL = extractIntPrice(from: trip.priceText)

        if trip.seatType == "2 + 1" {
            let cols = makeColumns_2p1()
            configureSeats_2p1(columns: cols)
            manager = SeatSelectionManager(allSeats: cols.flatMap { [$0.doubleGlass, $0.doubleCorridor, $0.singleGlass] }.compactMap { $0 })
        } else {
            let cols = makeColumns_2p2()
            configureSeats_2p2(columns: cols)
            manager = SeatSelectionManager(allSeats: cols.flatMap { [$0.leftTop, $0.leftBottom, $0.rightTop, $0.rightBottom] }.compactMap { $0 })
        }
        
        manager.onChange = { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.setConfirmEnabled(self.manager.selectedCount > 0)
                self.updateSelectedSeatInfo()
            }
        }

        setConfirmEnabled(manager.selectedCount > 0)
        updateSelectedSeatInfo()
    }
    
    func configureSeats_2p1(columns: [SeatColumn_2p1]) {
        self.columns = [.frontDecor] + columns.map { .twoPlusOne($0) }
        collectionView.reloadData()
    }
    
    func configureSeats_2p2(columns: [SeatColumn_2p2]) {
        self.columns = columns.map { .twoPlusTwo($0) }
        collectionView.reloadData()
    }
    
    private func setConfirmEnabled(_ enabled: Bool) {
        busConfirmButton.isEnabled = enabled
        busConfirmButton.alpha = enabled ? 1.0 : 0.5
        busConfirmButton.backgroundColor = enabled ? .mainGreen : .systemGray2
    }
    
    private func updateSelectedSeatInfo() {
        let count = manager?.selectedCount ?? 0
        if count == 0 {
            busSelectedSeatInfo.text = "Lütfen yukarıdan koltuk seçin"
        } else {
            let total = count * unitPriceTL
            busSelectedSeatInfo.text = "Toplam Fiyat: \(formatTL(total))"
        }
    }

    private func extractIntPrice(from text: String) -> Int {
        // "500", "1.250", "500,00" vs → 500
        let digits = text.compactMap { $0.isNumber ? Int(String($0)) : nil }
        return digits.reduce(0) { $0 * 10 + $1 }
    }

    private func formatTL(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "tr_TR")
        nf.numberStyle = .decimal
        let str = nf.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(str) TL"
    }
    /*
    private func showGenderPopup(anchor: UIView, pick: @escaping (Gender)->Void) {
        let p = GenderPopup()
        p.onPick = pick
        p.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(p)

        let rect = contentView.convert(anchor.bounds, from: anchor)
        NSLayoutConstraint.activate([
            p.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: rect.minY - 8),
            p.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: rect.midX),
            p.widthAnchor.constraint(equalToConstant: 200),
            p.heightAnchor.constraint(equalToConstant: 80)
        ])
        p.alpha = 0; p.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.18) { p.alpha = 1; p.transform = .identity }
    }
     */
}

// MARK: Extensions

extension BusTableViewCell {
    static let reuseId = "BusTableViewCell"
}

extension BusTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        columns.count
    }
    
    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch columns[indexPath.item] {
        case .frontDecor:
            let cell = cv.dequeueReusableCell(withReuseIdentifier: BusFrontColumnCell.reuse, for: indexPath) as! BusFrontColumnCell
            return cell
        case .twoPlusOne(let col):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: SeatColumnCell.reuse, for: indexPath) as! SeatColumnCell
            cell.configure(col, with: manager)
            cell.onSelect = { [weak self] seat, sender in self?.handleSeatTap(seat: seat, anchor: sender) }
            return cell
        case .twoPlusTwo(let col):
            let cell = cv.dequeueReusableCell(withReuseIdentifier: SeatColumn22Cell.reuse, for: indexPath) as! SeatColumn22Cell
            cell.configure(col, with: manager)
            cell.onSelect = { [weak self] seat, sender in self?.handleSeatTap(seat: seat, anchor: sender) }
            return cell
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height = collectionView.bounds.height
        let available = height - (3 * 8)
        let seatSize = available / (3 + 0.75)
        let columnWidth = seatSize
        
        switch columns[indexPath.item] {
        case .frontDecor: return CGSize(width: columnWidth * 1.0, height: height)
        case .twoPlusOne: return CGSize(width: columnWidth * 1.0, height: height)
        case .twoPlusTwo: return CGSize(width: columnWidth * 1.2, height: height)
        }
    }
}

private extension BusTableViewCell {
    func handleSeatTap(seat: Seat, anchor: UIView) {
        if seat.state == .selectedMale || seat.state == .selectedFemale {
            manager.toggleDeselect(seat.number)
            collectionView.reloadData()
            return
        }

        if seat.state == .reservedMale || seat.state == .reservedFemale { return }

        showGenderPopup(anchor: anchor) { [weak self] gender in
            guard let self else { return }
            if self.manager.canSelect(seat.number, as: gender) {
                self.manager.select(seat.number, as: gender)
                self.collectionView.reloadData()
            } else {
                let ac = UIAlertController(title: "Uyarı",
                                           message: "Yan koltuk daha önce alınmış. Aynı cinsiyeti seçmelisin.",
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.parentViewController?.present(ac, animated: true)
            }
        }
        
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self, next: { $0.next as? UIView })
            .compactMap { $0.next as? UIViewController }.first
    }
}
