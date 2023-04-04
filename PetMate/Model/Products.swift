//
//  Products.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/31.
//

import SwiftUI
import Foundation
import CoreLocation
import FirebaseFirestoreSwift

struct Products: Codable, Identifiable {
    @DocumentID var id: String?
    let category, brand, brand_link, discount, feature, fullDescription, imageURL, link, price, price_before, product_name,review: String
}
