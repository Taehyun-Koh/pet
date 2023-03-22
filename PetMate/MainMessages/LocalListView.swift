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
                self.currLocal = document.get("location") as! String
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
                    if user?.uid != self.currUser && user?.location == self.currLocal{
                        print("append!")
                        self.users.append(user!)
                    }


                })
                
//                self.errorMessage = "유저들 가져오기 성공"
            }
    }
}

struct LocalListView: View {
    
//    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = LocalListViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) { user in
                    HStack {
                        HStack {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                            VStack() {
                                HStack {
                                    Text(user.pet_name)
                                        .lineLimit(1)
                                        .bold()
                                        .padding(.leading)
                                    if user.pet_gender == "male"{
                                        Image("male")
                                            .resizable()
                                            .frame(width: 15,height: 15)
                                            .scaledToFit()
                                    }
                                    else if user.pet_gender == "female"{
                                        Image("female")
                                            .resizable()
                                            .frame(width: 15,height: 15)
                                            .scaledToFit()
                                        
                                    }
                                    Text("|").font(.caption)
                                    Text(user.age)
                                        .font(.caption)
                                        .lineLimit(1)
                                    Text(user.gender)
                                        .font(.caption)
                                        .lineLimit(1)
                                    Spacer()
 
                                }
                                HStack{
                                    Text(user.pet_breed)
                                         .font(.caption)
                                         .lineLimit(1)
                                         .padding(.leading)
                                    Text("·")
                                    Text(user.pet_age)
                                        .font(.caption)
                                        .lineLimit(1)
                                    Spacer()
                                }

                                HStack {
                                    Spacer()
           

                                }
                            }
                            NavigationLink {
                                ChatLogView(vm: ChatLogViewModel(chatUser: user))
                            } label: {
                                Image(systemName: "paperplane.fill").foregroundColor(.gray)
//                                Text("채팅")
//                                    .frame(width: 25, height: 25)
//                                    .background(Circle().fill(Color.gray))
//                                    .padding(.leading, 10)
                            }
                            
                            
                        }
                        
                        .padding()
                        .background(Rectangle().fill(Color.white))
                        .cornerRadius(10)
                    }.padding(.trailing)
//                        presentationMode.wrappedValue.dismiss()
//                        didSelectNewUser(user)
                    Divider()
                }
            }.navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack{
                            VStack {
                                HStack{
                                    Text("홈").bold()
                                        .font(.system(size: 25))
                                    Spacer()
                                    Image(systemName: "mappin.and.ellipse")
                                        .resizable()
                                        .frame(width: 25,height: 25)
                                    Text(vm.currLocal)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.black)
                                }

                            }
                            Spacer()
                        }
                        

                    }
                }
//                .toolbar {
//                    ToolbarItemGroup(placement: .navigationBarLeading) {
//                        Button {
//                            presentationMode.wrappedValue.dismiss()
//                        } label: {
//                            Text("Cancel")
//                        }
//                    }
//                }
        }
    }
}
struct LocalListView_Previews: PreviewProvider {
    static var previews: some View {

        ContentView()

//        MainMessageView()
    }
}
