//
//  NetworkRepository.swift
//  fogofwarchess
//
//  Created by 양현서 on 2023/08/11.
//

import Foundation
//import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class NetworkRepository {
    var ref = Database.database().reference()

    func observeChessBoard() {
        self.ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else { return }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
//                let cardData = try JSONDecoder().decode([String: CreditCard].self, from: jsonData)
            } catch let error {
                print("Error json parsing \(error)")
            }
        }
    }

}
