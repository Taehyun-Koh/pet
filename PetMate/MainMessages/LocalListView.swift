//
//  LocalListView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/13.
//

import SwiftUI
import SDWebImageSwiftUI

class LocalListViewModel: ObservableObject{
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    @Published var currUser = FirebaseManager.shared.auth.currentUser?.uid
    @Published var currLocal = ""
    
    init(){
        fetchAllUsers()
        
    }
    
    private func fetchAllUsers(){
        let docRef = FirebaseManager.shared.firestore.collection("users").document(self.currUser ?? "")
        docRef.getDocument(source: .cache){ (document, error) in
            if let document = document {
                self.currLocal = document.get("gender") as! String
            }else{
                print("Document does not exist in cache")
            }
            
        }
        
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentssnapshot, err in
                if let err = err{
                    self.errorMessage = "Failed to fetch users: \(err)"
                    print(self.errorMessage)
                    return
                }
                documentssnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = try? snapshot.data(as: ChatUser.self)
//                    print("hi",self.vm1.chatUser?.nickname ?? "")
                    if user?.uid != self.currUser && user?.gender == self.currLocal{
                        print("append!")
                        self.users.append(user!)
                    }


                })
                
//                self.errorMessage = "유저들 가져오기 성공"
            }
    }
}

struct LocalListView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = LocalListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50)
                                            .stroke(Color(.label), lineWidth: 2)
                                )
                            Text(user.nickname)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}
struct LocalListView_Previews: PreviewProvider {
    static var previews: some View {
//        LocalListView()
        MainMessageView()
    }
}
