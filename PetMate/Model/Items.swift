//
//  Items.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/23.
//

import SwiftUI
import Foundation
import CoreLocation
import FirebaseFirestoreSwift

struct Items: Codable, Identifiable {
    @DocumentID var id: String?
    let brand, brand_link, discount, feature, fullDescription, imageURL, link, price, price_before, product_name,review: String
    let keyword : Array<String>
}
