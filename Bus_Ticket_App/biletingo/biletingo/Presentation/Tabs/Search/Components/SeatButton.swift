//
//  SeatButton.swift
//  biletingo
//
//  Created by Gokhan on 13.09.2025.
//

import UIKit

final class SeatButton: UIButton {
    
    var seat: Seat? { didSet { apply() } }
    var isDimmed: Bool = false { didSet { alpha = isDimmed ? 0.4 : 1.0 } }
    var onSelect: ((Seat, UIView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func apply() {
        
        guard let s = seat else { isHidden = true; return }
        
        isHidden = false
        setTitle("\(s.number)", for: .normal)
        
        switch s.state {
        case .empty:
            backgroundColor = .systemBackground
            layer.borderWidth = 1
            layer.borderColor = UIColor.systemGray2.cgColor
            setTitleColor(.label, for: .normal)
        case .reservedMale:
            layer.borderWidth = 0
            backgroundColor = .seatBlue
            setTitleColor(.label, for: .normal)
        case .reservedFemale:
            layer.borderWidth = 0
            backgroundColor = .seatPink
            setTitleColor(.label, for: .normal)
        case .selectedMale, .selectedFemale:
            layer.borderWidth = 0
            backgroundColor = .mainGreen
            setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: Actions
    
    @objc private func tap() {
        guard let s = seat else { return }
        onSelect?(s, self)
    }
}

