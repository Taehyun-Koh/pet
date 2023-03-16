//
//  ChatUser.swift
//  pet
//
//  Created by 고태현 on 2023/03/10.
//


import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, nickname, profileImageUrl, gender, age: String
}

