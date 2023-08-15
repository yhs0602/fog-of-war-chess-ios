//
//  Coord.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/08.
//

import Foundation
import SwiftUI

struct Coord: Hashable {
    let file: Int
    let rank: Int

    var coordCode: String {
        return "\(coordLetter)\(coordNumber)"
    }

    var coordLetter: Character {
        return Character(UnicodeScalar("a".utf16.first! + UInt16(file - 1))!)
    }

    var coordNumber: Character {
        let number = 9 - rank
        return Character(String(number))
    }

    var color: Color {
        if ((file + rank) % 2 == 0) {
            return .ivory
        } else {
            return .teal
        }
    }

    init(file: Int, rank: Int) {
        self.file = file
        self.rank = rank
    }

    func isValid() -> Bool {
        return (1...8).contains(file) && (1...8).contains(rank)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(rank)
    }

    func offset(dr: Int, df: Int) -> Coord {
        return Coord(file: file + df, rank: rank + dr)
    }
}
