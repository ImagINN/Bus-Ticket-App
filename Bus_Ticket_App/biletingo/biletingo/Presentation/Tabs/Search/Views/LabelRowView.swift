//
//  LabelRowView.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

final class LabeledRowView: UIStackView {
    let valueLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        spacing = 8
        distribution = .equalSpacing
        translatesAutoresizingMaskIntoConstraints = false

        let t = UILabel()
        t.text = title
        t.font = .systemFont(ofSize: 14, weight: .semibold)
        t.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 16)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.text = "-"

        addArrangedSubview(t)
        addArrangedSubview(valueLabel)
    }

    required init(coder: NSCoder) { fatalError() }
}
