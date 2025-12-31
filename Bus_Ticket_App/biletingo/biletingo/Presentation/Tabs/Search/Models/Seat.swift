//
//  Seat.swift
//  biletingo
//
//  Created by Gokhan on 13.09.2025.
//

enum Gender { case male, female }

enum SeatState: Equatable {
    case empty
    case reservedMale
    case reservedFemale
    case selectedMale
    case selectedFemale
}

enum SeatColumn {
    case frontDecor
    case twoPlusOne(SeatColumn_2p1)
    case twoPlusTwo(SeatColumn_2p2)
}

struct Seat: Hashable {
    let number: Int
    let groupId: Int?
    var state: SeatState
}

struct SeatColumn_2p1 {
    let singleGlass: Seat?
    let doubleGlass: Seat?
    let doubleCorridor: Seat?
}

struct SeatColumn_2p2 {
    let leftTop: Seat?
    let leftBottom: Seat?
    let rightTop: Seat?
    let rightBottom: Seat?
}
