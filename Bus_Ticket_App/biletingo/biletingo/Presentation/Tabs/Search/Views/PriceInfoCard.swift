//
//  PriceInfoCard.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

final class PriceInfoCard: CardContainerView {
    private let totalRow = LabeledRowView(title: "Toplam")

    override init(title: String = "Fiyat Bilgileri") {
        super.init(title: title)
        addBody([totalRow])
    }
    required init?(coder: NSCoder) { fatalError() }

    func bind(totalPrice: Int?) {
        totalRow.valueLabel.text = totalPrice.map { "\($0) ₺" } ?? "-"
    }
}
