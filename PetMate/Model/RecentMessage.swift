//
//  RecentMessage.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/16.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable{
    @DocumentID var id: String?

    let text, nickname: String
    let fromId, toId : String
    let profileImageUrl : String
    let timestamp : Date
    
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
