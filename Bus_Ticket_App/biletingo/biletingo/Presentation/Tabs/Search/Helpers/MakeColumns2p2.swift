//
//  MakeColumns2p2.swift
//  biletingo
//
//  Created by Gokhan on 13.09.2025.
//

func makeColumns_2p2(totalSeats: Int = 46) -> [SeatColumn_2p2] {
    var cols: [SeatColumn_2p2] = []
    var n = 1
    var row = 0

    while n <= totalSeats {
        row += 1
        let gidLeft  = row * 10 + 1
        let gidRight = row * 10 + 2
        let lt: Seat? = (n <= totalSeats) ? Seat(number: n, groupId: gidLeft,  state: n % 3 == 0 ? .reservedMale   : .empty) : nil; n += 1
        let lb: Seat? = (n <= totalSeats) ? Seat(number: n, groupId: gidLeft,  state: n % 5 == 0 ? .reservedFemale : .empty) : nil; n += 1
        let rt: Seat? = (n <= totalSeats) ? Seat(number: n, groupId: gidRight, state: n % 7 == 0 ? .reservedFemale : .empty) : nil; n += 1
        let rb: Seat? = (n <= totalSeats) ? Seat(number: n, groupId: gidRight, state: n % 4 == 0 ? .reservedMale   : .empty) : nil; n += 1
        cols.append(.init(leftTop: lt, leftBottom: lb, rightTop: rt, rightBottom: rb))
    }
    return cols
}
