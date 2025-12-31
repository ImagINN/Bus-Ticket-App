//
//  BusTrip.swift
//  biletingo
//
//  Created by Gokhan on 11.09.2025.
//

import Foundation

struct BusTrip {
    let company: String
    let logoName: String
    let departureDate: String
    let departureTime: String
    let priceText: String
    let seatType: String
    let travelTime: String
    let limitedSeatText: String
    let directionText: String
    var isExpanded: Bool = false
}

let MOCK_TRIPS: [BusTrip] = [
    .init(
        company: "Kamil Koç",
        logoName: "KamilKoc",
        departureDate: "15 Eylül Pazartesi",
        departureTime: "00:15",
        priceText: "1.500",
        seatType: "2 + 1",
        travelTime: "14s 30dk",
        limitedSeatText: "Son 1 Koltuk",
        directionText: "Ankara > Aksaray"
    ),
    .init(
        company: "Kamil Koç",
        logoName: "KamilKoc",
        departureDate: "15 Eylül Pazartesi",
        departureTime: "08:45",
        priceText: "1.250",
        seatType: "2 + 1",
        travelTime: "12s 10dk",
        limitedSeatText: "Az Koltuk",
        directionText: "Ankara > Kayseri"
    ),
    .init(
        company: "Metro",
        logoName: "Metro",
        departureDate: "16 Eylül Salı",
        departureTime: "09:45",
        priceText: "1.000",
        seatType: "2 + 1",
        travelTime: "10s 10dk",
        limitedSeatText: "",
        directionText: "Ankara > Kayseri"
    ),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "15 Eylül Pazartesi", departureTime: "00:15", priceText: "1.500", seatType: "2 + 1", travelTime: "14s 30dk", limitedSeatText: "Son 1 Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "15 Eylül Pazartesi", departureTime: "02:30", priceText: "1.200", seatType: "2 + 1", travelTime: "12s 45dk", limitedSeatText: "Az Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "15 Eylül Pazartesi", departureTime: "05:00", priceText: "1.350", seatType: "2 + 1", travelTime: "11s 20dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "15 Eylül Pazartesi", departureTime: "08:45", priceText: "1.250", seatType: "2 + 1", travelTime: "12s 10dk", limitedSeatText: "Son 2 Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "15 Eylül Pazartesi", departureTime: "10:15", priceText: "1.100", seatType: "2 + 1", travelTime: "10s 50dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "15 Eylül Pazartesi", departureTime: "12:30", priceText: "1.400", seatType: "2 + 1", travelTime: "13s 00dk", limitedSeatText: "Az Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "15 Eylül Pazartesi", departureTime: "15:00", priceText: "1.550", seatType: "2 + 1", travelTime: "14s 15dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "15 Eylül Pazartesi", departureTime: "17:45", priceText: "1.200", seatType: "2 + 1", travelTime: "11s 45dk", limitedSeatText: "Son 1 Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "15 Eylül Pazartesi", departureTime: "20:30", priceText: "1.300", seatType: "2 + 1", travelTime: "12s 40dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "15 Eylül Pazartesi", departureTime: "23:15", priceText: "1.150", seatType: "2 + 1", travelTime: "10s 30dk", limitedSeatText: "Az Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "16 Eylül Salı", departureTime: "00:45", priceText: "1.000", seatType: "2 + 1", travelTime: "10s 10dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "16 Eylül Salı", departureTime: "03:15", priceText: "1.350", seatType: "2 + 1", travelTime: "11s 30dk", limitedSeatText: "Son 3 Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "16 Eylül Salı", departureTime: "06:30", priceText: "1.200", seatType: "2 + 1", travelTime: "12s 00dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "16 Eylül Salı", departureTime: "09:45", priceText: "1.450", seatType: "2 + 1", travelTime: "13s 15dk", limitedSeatText: "Az Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "16 Eylül Salı", departureTime: "12:15", priceText: "1.250", seatType: "2 + 1", travelTime: "12s 50dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "16 Eylül Salı", departureTime: "15:30", priceText: "1.550", seatType: "2 + 1", travelTime: "14s 00dk", limitedSeatText: "Son 1 Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "16 Eylül Salı", departureTime: "18:00", priceText: "1.150", seatType: "2 + 1", travelTime: "11s 45dk", limitedSeatText: "Az Koltuk", directionText: "Ankara > Kayseri"),
    .init(company: "Kamil Koç", logoName: "KamilKoc", departureDate: "16 Eylül Salı", departureTime: "21:15", priceText: "1.300", seatType: "2 + 1", travelTime: "12s 30dk", limitedSeatText: "", directionText: "Ankara > Kayseri"),
    .init(company: "Metro", logoName: "Metro", departureDate: "16 Eylül Salı", departureTime: "23:45", priceText: "1.200", seatType: "2 + 1", travelTime: "11s 10dk", limitedSeatText: "Son 2 Koltuk", directionText: "Ankara > Kayseri"),

]

