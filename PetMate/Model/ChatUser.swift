//
//  ChatUser.swift
//  pet
//
//  Created by 고태현 on 2023/03/10.
//


import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, nickname, profileImageUrl, gender, age, location, pet_age,pet_breed,pet_name,pet_size,pet_gender,introduce: String
    let pet_neut : Bool
    let keyword : [String: Int]
}

