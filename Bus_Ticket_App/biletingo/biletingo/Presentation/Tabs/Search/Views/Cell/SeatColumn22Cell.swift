//
//  SeatColumn22Cell.swift
//  biletingo
//
//  Created by Gokhan on 13.09.2025.
//

import UIKit

final class SeatColumn22Cell: UICollectionViewCell {
    
    private let leftTop = SeatButton()
    private let leftBottom = SeatButton()
    private let rightTop = SeatButton()
    private let rightBottom = SeatButton()
    var onSelect: ((Seat, UIView) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let left = UIStackView(arrangedSubviews: [leftTop, leftBottom])
        let right = UIStackView(arrangedSubviews: [rightTop, rightBottom])
        
        [left, right].forEach { $0.axis = .vertical; $0.spacing = 8 }
        
        let h = UIStackView(arrangedSubviews: [left, UIView(), right])
        h.axis = .horizontal; h.spacing = 12
        contentView.addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: contentView.topAnchor),
            h.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            h.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            h.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        [leftTop, leftBottom, rightTop, rightBottom].forEach { btn in
            btn.onSelect = { [weak self] seat, sender in self?.onSelect?(seat, sender) }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }

    func configure(_ c: SeatColumn_2p2, with manager: SeatSelectionManager) {
        leftTop.seat = c.leftTop; leftBottom.seat = c.leftBottom
        rightTop.seat = c.rightTop; rightBottom.seat = c.rightBottom
        [leftTop, leftBottom, rightTop, rightBottom].forEach { btn in
            if let num = btn.seat?.number { btn.isDimmed = manager.isDisabled(num) }
        }
    }
}

extension SeatColumn22Cell {
    static let reuse = "SeatColumn22Cell"
}
