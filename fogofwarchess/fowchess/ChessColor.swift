//
//  ChessColor.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/09.
//

import Foundation

enum ChessColor: String {
    case black, white

    var opposite: ChessColor {
        return self == .black ? .white : .black
    }
}
