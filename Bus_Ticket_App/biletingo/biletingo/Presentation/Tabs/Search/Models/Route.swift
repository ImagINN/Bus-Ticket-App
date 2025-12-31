//
//  Route.swift
//  biletingo
//
//  Created by Gokhan on 9.09.2025.
//

import Foundation

struct Route {
    var from: String?
    var to: String?
    
    mutating func swap() {
        (from, to) = (to, from)
    }
}
