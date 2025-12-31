//
//  SeatSelectionManager.swift
//  biletingo
//
//  Created by Gokhan on 15.09.2025.
//

final class SeatSelectionManager {
    private(set) var seats: [Int: Seat]
    private let maxSelection = 5
    
    var onChange: ((Int) -> Void)?

    init(allSeats: [Seat]) {
        var dict: [Int: Seat] = [:]
        allSeats.forEach { dict[$0.number] = $0 }
        self.seats = dict
        onChange?(selectedCount)
    }

    var selectedCount: Int {
        seats.values.filter {
            $0.state == .selectedMale || $0.state == .selectedFemale
        }.count
    }

    func seat(by number: Int) -> Seat? { seats[number] }

    func isDisabled(_ number: Int) -> Bool {
        guard let s = seats[number] else { return true }
        if s.state != .empty { return false }
        return selectedCount >= maxSelection
    }

    private func neighborReservedGender(of seat: Seat) -> Gender? {

        guard let gid = seat.groupId else { return nil }

        let neighbors = seats.values.filter { $0.groupId == gid && $0.number != seat.number }

        if neighbors.contains(where: { $0.state == .reservedMale })   { return .male }
        if neighbors.contains(where: { $0.state == .reservedFemale }) { return .female }
        return nil
    }

    func canSelect(_ number: Int, as gender: Gender) -> Bool {

        guard let seat = seats[number] else { return false }
        guard seat.state == .empty else { return false }
        if selectedCount >= maxSelection { return false }
        if let must = neighborReservedGender(of: seat) { return must == gender }
        return true
    }

    func select(_ number: Int, as gender: Gender) {
        guard var s = seats[number], canSelect(number, as: gender) else { return }
        s.state = (gender == .male) ? .selectedMale : .selectedFemale
        seats[number] = s
        onChange?(selectedCount)
    }

    func toggleDeselect(_ number: Int) {
        guard var s = seats[number] else { return }
        if s.state == .selectedMale || s.state == .selectedFemale { s.state = .empty }
        seats[number] = s
        onChange?(selectedCount)
    }
}

extension SeatSelectionManager {
    var selectedSeatNumbers: [Int] {
        seats.values
            .filter { $0.state == .selectedMale || $0.state == .selectedFemale }
            .map { $0.number }
            .sorted()
    }
}
