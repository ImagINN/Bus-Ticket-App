//
//  MakeColumns2p1.swift
//  biletingo
//
//  Created by Gokhan on 13.09.2025.
//

func makeColumns_2p1(totalSeats: Int = 45) -> [SeatColumn_2p1] {
    var cols: [SeatColumn_2p1] = []
    var n = 1
    var row = 0

    while n <= totalSeats {
        row += 1
        let gidDouble = row * 10 + 1
        
        let doubleGlass: Seat? = (n <= totalSeats)
        ? Seat(number: n, groupId: nil,
               state: n % 4 == 0 ? .reservedMale : .empty) : nil
        n += 1
        
        let doubleCorridor: Seat? = (n <= totalSeats)
        ? Seat(number: n, groupId: gidDouble,
               state: n % 6 == 0 ? .reservedMale : .empty) : nil
        n += 1
        
        let singleGlass: Seat? = (n <= totalSeats)
        ? Seat(number: n, groupId: gidDouble,
               state: n % 5 == 0 ? .reservedFemale : .empty) : nil
        n += 1
        
        cols.append(
            .init(
                singleGlass: singleGlass,
                doubleGlass: doubleGlass,
                doubleCorridor: doubleCorridor
            )
        )
    }
    
    return cols
}


