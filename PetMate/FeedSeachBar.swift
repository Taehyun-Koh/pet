//
//  FeedSeachBar.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/31.
//



import SwiftUI

struct FeedSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("찾고 싶은 키워드를 검색해주세요.", text: $text)
                .padding(15)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .foregroundColor(Color("subfont"))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("mainfont"))
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 15)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }){
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                ).onTapGesture {
                    self.isEditing = true
                }
            
//            if isEditing {
//                Button(action: {
//                    self.isEditing = false
////                    self.text = ""
//                    
//                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                }){
//                    Image(systemName: "arrow.down")
//                }
//                .padding(.trailing, 10)
//                .transition(.move(edge: .trailing))
//            }
        }
    }
}
