//
//  ProfileView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/22.
//

import SwiftUI
import SDWebImageSwiftUI
class ProfileViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var errorMessage = ""
    @Published var isUserCurrentlyLoggedOut = false
    
    init(){
        fetchCurrentUser()

    }

    func fetchCurrentUser() {
        print("fetchcurruser in recommendView")
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
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}
struct ProfileView: View {
    
    @ObservedObject private var vm = ProfileViewModel()
    @State var shouldShowLogOutOptions = false
    @State var change = false
    @State var newNickname = ""
    @State var newIntroduce = ""
    @State var newPetAge = ""
    @State var newPetBreed = ""
    @State var newPetname = ""
    @State var newPetSize = ""
    @State var newLocation = ""

    

    
    var body: some View {
        customNavBar
    }
    
    private var customNavBar: some View {
        VStack(spacing :10){
            let email = vm.chatUser?.nickname ?? ""
            HStack{
                if !change{
                    if newNickname != "" {
                        Text(newNickname)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.leading, 15)
                    }
                    else{
                        (Text(email) + Text("님"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.leading, 15)
                    }
                }
                else{
                    HStack{
                        InputTextFieldView2(text: $newNickname,
                                           placeholder: email,
                                           keyboardType: .namePhonePad,
                                           systemImage: nil)
                        .frame(width: 100)

                    }.padding(.leading, 15)
                }
                
                Spacer()
            }
            HStack(spacing: 16) {
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(50)
                    .shadow(radius: 5)
                
                
                VStack(alignment: .leading, spacing: 4) {
                    let petname = vm.chatUser?.pet_name.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                    HStack{
                        if !change{
                            if newPetname != "" {
                                Text(newPetname)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            else{
                                Text(petname)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        else{
                            InputTextFieldView2(text: $newPetname,
                                               placeholder: petname,
                                               keyboardType: .namePhonePad,
                                               systemImage: nil)

                        }
                    }

                    
                    HStack {
                        Circle()
                            .foregroundColor(.green)
                            .frame(width: 14, height: 14)
                        Text("online")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.lightGray))
                    }
                }
                
                Spacer()
                Button {
                    change.toggle()
                } label: {
                    HStack{
                        if !change {
                            Text("변경")
                                .padding(.all, 5)
                                .font(.system(size: 16))
                                .border(Color.gray)
                                .foregroundColor(Color.gray)
                        }
                        else{
                            Button{
                                change.toggle()
                                updateInfo(item: [newNickname,newIntroduce,newPetname,newPetAge,newPetBreed,newPetSize,newLocation])

                                
                            } label : {
                                VStack{
                                    Text("저장")
                                        .padding(.all, 5)
                                        .font(.system(size: 16))
                                        .border(Color.green)
                                        .foregroundColor(Color.green)
                                }
                                }
                        }
                    }
                }
                Button {
                    shouldShowLogOutOptions.toggle()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(.label))
                }
            }
            .padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                    .destructive(Text("로그아웃"), action: {
                        print("handle sign out")
                        vm.handleSignOut()
                    }),
                        .cancel()
                ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
                LoginView(didCompleteLoginProcess: {
                    self.vm.isUserCurrentlyLoggedOut = false
                })
            
            }
            let location = vm.chatUser?.location ?? ""
            HStack{
                if !change{
                    if newLocation != "" {
                        HStack{
                            Text(newLocation)
                                .font(.system(size: 15))
                                .bold()
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading, 15)
                        
                    }
                    else{
                        HStack{
                            Text(location)
                                .font(.system(size: 15))
                                .bold()
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading,15)

                    }
                }
                else{
                    InputTextFieldView2(text: $newLocation,
                                       placeholder: location,
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                }
            }
            let introduce = vm.chatUser?.introduce ?? ""
            HStack{
                if !change{
                    if newIntroduce != "" {
                        HStack{
                            Text(newIntroduce)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading, 15)
                        
                    }
                    else{
                        HStack{
                            Text(introduce)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading,15)

                    }
                }
                else{
                    InputTextFieldView2(text: $newIntroduce,
                                       placeholder: introduce,
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                }
            }
            Divider()
                .padding()
            let petage = vm.chatUser?.pet_age ?? ""
            HStack{
                Text("펫 나이").bold().padding(.trailing, 15.0)
                    .padding(.leading, 15)
                if !change{
                    if newPetAge != "" {
                        HStack{
                            Text(newPetAge)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading, 15)
                        
                    }
                    else{
                        HStack{
                            if petage == "puppy" {
                                Text("퍼피")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }
                            else if petage == "adult"{
                                Text("성견")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }
                            else if petage == "old"{
                                Text("노견")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }


                            Spacer()
                        }.padding(.leading,15)

                    }
                }
                else{
                    Picker(selection: $newPetAge, label: Text("")){
                        Text("퍼피").tag("puppy")
                        Text("성견").tag("adult")
                        Text("노견").tag("old")
                    }.pickerStyle(SegmentedPickerStyle())
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                }
            }
            let petsize = vm.chatUser?.pet_size ?? ""
            HStack{
                Text("펫 크기").bold().padding(.trailing, 15.0)
                    .padding(.leading, 15)
                if !change{
                    if newPetSize != "" {
                        HStack{
                            Text(newPetSize)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading, 15)
                        
                    }
                    else{
                        HStack{
                            Text(petsize)
                                .font(.system(size: 18))
                                .foregroundColor(.black)

                            Spacer()
                        }.padding(.leading,15)

                    }
                }
                else{
                    Picker(selection: $newPetSize, label: Text("")){
                        Text("소형").tag("소형")
                        Text("중형").tag("중형")
                        Text("대형").tag("대형")
                    }.pickerStyle(SegmentedPickerStyle())
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                }
            }
            .padding(.top, 5)
            let breed = vm.chatUser?.pet_breed ?? ""
            HStack{
                Text("견종").bold().padding(.trailing, 15.0)
                    .padding(.leading, 15)
                if !change{
                    if newPetBreed != "" {
                        HStack{
                            Text(newPetBreed)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading, 15)
                        
                    }
                    else{
                        HStack{
                            Text(breed)
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                            Spacer()
                        }.padding(.leading,15)

                    }
                }
                else{
                    InputTextFieldView2(text: $newPetBreed,
                                       placeholder: breed,
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                }
            }.padding(.top, 5)
            Spacer()
            
        }
    }
    private func updateInfo(item : [String]){

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        for (index, string) in item.enumerated() {
            print("\(index): \(string)")
            if string == "" {continue}
            
            // 닉네임
            if index == 0 {
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["nickname": string])
            }
            // 소개글
            else if index == 1 {
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["introduce": string])
            }
            // 펫 이름
            else if index == 2 {
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["pet_name": string])
            }
            // 펫 나이
            else if index == 3{
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["pet_age": string])
            }
            //품종
            else if index == 4{
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["pet_breed": string])
            }
            else if index == 5{
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["pet_size": string])
            }
            else if index == 6{
                FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["location": string])
            }
        }


    }
    
    
}
struct InputTextFieldView2: View {
    
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let systemImage: String?
    
    private let textFieldLeading: CGFloat = 30
    
    var body: some View {
        
        VStack {
            
            TextField(placeholder, text: $text)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,
                       minHeight: 44,
                       alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .padding(.leading, systemImage == nil ? textFieldLeading / 2 : textFieldLeading)
                .keyboardType(keyboardType)
                .background(
                    
                    ZStack(alignment: .leading) {
                        
                        if let systemImage = systemImage {
                            
                            Image(systemName: systemImage)
                                .font(.system(size: 24, weight: .semibold))
                                .padding(.leading, 5)
                                .foregroundColor(Color.black.opacity(0.5))
                        }
                        
                        RoundedRectangle(cornerRadius: 10,
                                         style: .continuous)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    }
                )
        }
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
//        ContentView()
    }
}
