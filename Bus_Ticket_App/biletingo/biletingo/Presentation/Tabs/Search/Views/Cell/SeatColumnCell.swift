//
//  SeatColumnCell.swift
//  biletingo
//
//  Created by Gokhan on 13.09.2025.
//

import UIKit

final class SeatColumnCell: UICollectionViewCell {
    
    private let doubleGlass = SeatButton()
    private let doubleCorridor = SeatButton()
    private let singleGlass = SeatButton()
    
    private let corridor: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "footprint") ?? UIImage(systemName: "shoeprints.fill")
        img.contentMode = .scaleAspectFit
        img.tintColor = .secondaryLabel
        img.clipsToBounds = true
        return img
    }()

    var onSelect: ((Seat, UIView) -> Void)?
    
    private weak var manager: SeatSelectionManager?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let v = UIStackView(arrangedSubviews: [singleGlass, doubleCorridor, corridor, doubleGlass])
        v.axis = .vertical
        v.spacing = 8
        v.alignment = .fill
        contentView.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: contentView.topAnchor),
            v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            v.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            doubleGlass.heightAnchor.constraint(equalTo: doubleGlass.widthAnchor),
            doubleCorridor.heightAnchor.constraint(equalTo: doubleCorridor.widthAnchor),
            singleGlass.heightAnchor.constraint(equalTo: singleGlass.widthAnchor),
            
            corridor.heightAnchor.constraint(equalTo: doubleGlass.widthAnchor, multiplier: 0.75)
        ])
        
        corridor.preferredSymbolConfiguration = .init(scale: .small)
        
        [doubleGlass, doubleCorridor, singleGlass].forEach { btn in
            btn.onSelect = { [weak self] seat, sender in
                if let latest = self?.manager?.seat(by: seat.number) { self?.onSelect?(latest, sender) }
                else { self?.onSelect?(seat, sender) }
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }

    func configure(_ col: SeatColumn_2p1, with manager: SeatSelectionManager) {
        self.manager = manager

        if let s = col.doubleGlass { doubleGlass.seat = manager.seat(by: s.number) ?? s } else { doubleGlass.seat = nil }
        if let s = col.doubleCorridor { doubleCorridor.seat = manager.seat(by: s.number) ?? s } else { doubleCorridor.seat = nil }
        if let s = col.singleGlass { singleGlass.seat = manager.seat(by: s.number) ?? s } else { singleGlass.seat = nil }

        [doubleGlass, doubleCorridor, singleGlass].forEach { btn in
            if let num = btn.seat?.number { btn.isDimmed = manager.isDisabled(num) }
        }
    }
}

extension SeatColumnCell {
    static let reuse = "SeatColumnCell"
}
