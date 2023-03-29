//
//  LocalListView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/13.
//

import SwiftUI
import SDWebImageSwiftUI

class LocalListViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    @Published var currUser = FirebaseManager.shared.auth.currentUser?.uid
    @Published var currLocal = ""

    
    init(){

        fetchCurrentUser()
        fetchAllUsers()
        
    }
    func fetchCurrentUser() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print("Failed to fetch current user:", error)
                return
            }
            
            self.chatUser = try? snapshot?.data(as: ChatUser.self)
            FirebaseManager.shared.currentUser = self.chatUser
        }
    }
    private func fetchAllUsers(){
        
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

                    self.users.append(user!)

                })
                
//                self.errorMessage = "유저들 가져오기 성공"
            }
    }
}

struct LocalListView: View {
    
//    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    static let BackgroundColor = Color("TextBackground")
    @ObservedObject var vm = LocalListViewModel()
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) { user in
                    if user.location == self.vm.chatUser?.location{
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
                                        if user.pet_age == "puppy"{
                                            Text("퍼피")
                                                .font(.caption)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        else if user.pet_age == "adult"{
                                            Text("어덜트")
                                                .font(.caption)
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        if user.pet_age == "senior"{
                                            Text("시니어")
                                                .font(.caption)
                                                .lineLimit(1)
                                            Spacer()
                                        }

                                    }
                                    HStack{
                                        Image(systemName: "note.text").foregroundColor(.gray)
                                        Text(user.introduce)
                                            .foregroundColor(.black)
                                            .font(.caption)
                                            .padding(3)
                                            .background(ColorManager.BackgroundColor)
                                            .padding(.top,1)
                                            .padding(.leading)
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
                    }
                    
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
                                    Text(self.vm.chatUser?.location ?? "재설정")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.black)
                                }

                            }
                            Spacer()
                        }
                        

                    }
                }
        }
    }
}
struct LocalListView_Previews: PreviewProvider {
    static var previews: some View {

        ContentView()

//        MainMessageView()
    }
}
