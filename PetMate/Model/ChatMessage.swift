//
//  ChatMessage.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/16.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let timestamp: Date
}
