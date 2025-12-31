//
//  GenderPopupView.swift
//  biletingo
//
//  Created by Gokhan on 14.09.2025.
//

import UIKit

final class GenderPopup: UIView {
    var onPick: ((Gender) -> Void)?
    private let maleBtn = UIButton(type: .custom)
    private let femaleBtn = UIButton(type: .custom)

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 8

        // sadece görsel ayarla
        maleBtn.setImage(UIImage(named: "man"), for: .normal)
        femaleBtn.setImage(UIImage(named: "woman"), for: .normal)

        // yazı paddinglerini sıfırla
        maleBtn.setTitle(nil, for: .normal)
        femaleBtn.setTitle(nil, for: .normal)
        maleBtn.imageView?.contentMode = .scaleAspectFit
        femaleBtn.imageView?.contentMode = .scaleAspectFit

        maleBtn.addTarget(self, action: #selector(pickMale), for: .touchUpInside)
        femaleBtn.addTarget(self, action: #selector(pickFemale), for: .touchUpInside)

        let s = UIStackView(arrangedSubviews: [maleBtn, femaleBtn])
        s.axis = .horizontal
        s.spacing = 16
        s.distribution = .fillEqually
        addSubview(s)
        s.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            s.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            s.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            s.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            s.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])
    }

    @objc private func pickMale()  { onPick?(.male);  removeFromSuperview() }
    @objc private func pickFemale(){ onPick?(.female); removeFromSuperview() }
}
