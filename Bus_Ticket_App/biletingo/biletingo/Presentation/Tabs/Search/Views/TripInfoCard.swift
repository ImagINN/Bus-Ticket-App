//
//  TripInfoCard.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

import UIKit

final class TripInfoCard: CardContainerView {
    private let companyRow = LabeledRowView(title: "Firma")
    private let routeRow   = LabeledRowView(title: "Rota")
    private let dateRow    = LabeledRowView(title: "Tarih")
    private let timeRow    = LabeledRowView(title: "Saat")
    private let seatsRow   = LabeledRowView(title: "Koltuklar")

    override init(title: String = "Sefer Bilgileri") {
        super.init(title: title)
        addBody([companyRow, routeRow, dateRow, timeRow, seatsRow])
    }

    required init?(coder: NSCoder) { fatalError() }

    func bind(ticket: Ticket?) {
        guard let t = ticket else { return }
        companyRow.valueLabel.text = t.company
        routeRow.valueLabel.text   = t.route
        dateRow.valueLabel.text    = t.date
        timeRow.valueLabel.text    = t.time
        seatsRow.valueLabel.text   = t.seatNumbers.map(String.init).joined(separator: ", ")
    }
}
