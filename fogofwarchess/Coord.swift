//
//  Coord.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation

struct Coord {
    let column: Int
    let row: Int

    var coordCode: String {
        let letter = Character(UnicodeScalar("a".utf16.first! + UInt16(column))!)
        let number = 8 - row
        return "\(letter)\(number)"
    }

    init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }

    init(_ coord: (Int, Int)) {
        self.init(column: coord.0, row: coord.1)
    }

    func isValid() -> Bool {
        return (0...7).contains(column) && (0...7).contains(row)
    }
}
