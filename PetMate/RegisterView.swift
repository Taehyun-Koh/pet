//
//  RegisterView.swift
//  pet
//
//  Created by 고태현 on 2023/03/12.
//

import SwiftUI

struct RegisterView: View {
    @Binding var firstNaviLinkActive : Bool
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var nickname = ""
    @State private var gender = ""
    @State private var age = "20"
    @State private var inputdone = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                InputTextFieldView(text: $email,
                                   placeholder: "이메일",
                                   keyboardType: .emailAddress,
                                   systemImage: "envelope")
                
                InputPasswordView(password: $password,
                                  placeholder: "비밀번호 ( 6글자 이상 )",
                                  systemImage: "lock")
                
                
                InputTextFieldView(text: $nickname,
                                   placeholder: "닉네임",
                                   keyboardType: .namePhonePad,
                                   systemImage: nil)
                
                
                HStack{
                    Text("성별").bold().padding(.trailing, 15.0)
                    Picker(selection: $gender, label: Text("gender select")){
                        Text("남성").tag("male")
                        Text("여성").tag("female")
                    }.pickerStyle(SegmentedPickerStyle())
                }
                
                HStack{
                    Text("연령대").bold()
                    Spacer()
                    Picker(selection: $age, label:Text(""), content:{
                        Text("10대").tag("10")
                        Text("20대").tag("20")
                        Text("30대").tag("30")
                        Text("40대").tag("40")
                        Text("50대").tag("50")
                        Text("60대").tag("60")
                        Text("70대").tag("70")
                        Text("80대").tag("80")
                        Text("90대").tag("90")
                    }).foregroundColor(.red)
                }
                .foregroundColor(Color.black)

                
                
                HStack{
                    
                    if (email != "" &&  password != "" && nickname != "" &&  age != "" &&  gender != "") {
                        Button(action: {
                            inputdone = "true"
                        }, label:{
                            Text("다음")
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .foregroundColor(.green)
                                .font(.system(size: 16, weight: .bold))
                                .cornerRadius(10)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.green, lineWidth: 2)
                                )
                        })
                        Spacer()
                    }
                    else{
                        Text("빈 정보를 채워주세요").foregroundColor(.red)
                    }
                    
                }
                
                if inputdone == "true"{
                    NavigationLink(destination: PetInfoView(email: $email, password: $password, nickname: $nickname, gender:$gender , age:$age,  firstNaviLinkActive:$firstNaviLinkActive), isActive: $firstNaviLinkActive){
                        Text("")
                    }
                }
                
            }
        }
        .padding()
    }
}

struct PetInfoView: View {
    
    @State private var shouldShowImagePicker = false
    @State private var petName = ""
    @State private var DogorCat = ""
    @State private var petBreed = ""
    @State private var petAge = ""
    @State private var petGender = ""
    @State private var petSize = "puppy"
    @State private var petNeutering = true
    @State var navigated = false
    @State var isloading = false
    
    
    var dogs = ["믹스견","말티즈","푸들","시바견"]
    var cats = ["사바나캣","길고양이","짬타이거"]
    
    @Binding var email : String
    @Binding var password : String
    @Binding var nickname : String
    @Binding var gender : String
    @Binding var age : String
    @Binding var firstNaviLinkActive : Bool
    
    var body: some View {
        
        NavigationView{
            
            ScrollView{
                VStack(spacing: 16){
                    HStack{
                        Spacer()
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    HStack{
                                        Image(systemName: "plus")
                                            .font(.system(size: 32))
                                            .padding(50)
                                            .foregroundColor(Color(.label))
                                            .overlay(RoundedRectangle(cornerRadius: 64)
                                                        .stroke(Color.gray, lineWidth: 2))
                                        
                                    }
                                }
                            }
                        }
                        Spacer()
                        Text("이웃들에게 보여질 반려동물 사진을 선택해주세요.")
                        Spacer()
                    }.padding(.top,10)
                    HStack{
                        Text("이름").bold()
                        TextField("ex)삐삐", text: $petName)
                            .autocapitalization(.none)
                            .padding(10)
                            .background(Color.white)
                    }
                    HStack{
                        Text("반려동물").bold().padding(.trailing, 15.0)
                        Picker(selection: $DogorCat, label: Text("")){
                            Text("강아지").tag("dog")
                            Text("고양이").tag("cat")
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    HStack{
                        Text("품종").bold()
                        Spacer()
                        if DogorCat == "dog"{
                            Picker(selection: $petBreed, label:Text(""), content:{
                                Text("선택").tag("")
                                Text("시바견").tag("siba")
                                Text("푸들").tag("poodle")
                            })
                            
                            .foregroundColor(Color.black)
                            .padding(10)
                        }
                        else if DogorCat == "cat"{
                            Picker(selection: $petBreed, label:Text(""), content:{
                                Text("선택").tag("")
                                Text("짬타이거").tag("zzamking")
                                Text("길고양이").tag("streetking")
                            })
                            
                            .foregroundColor(Color.black)
                            .padding(10)
                        }
                    }
                    HStack{
                        Text("성별").bold().padding(.trailing, 15.0)
                        Picker(selection: $petGender, label: Text("")){
                            Text("수컷").tag("male")
                            Text("암컷").tag("female")
                        }.pickerStyle(SegmentedPickerStyle())
                    }

                    HStack{
                        Text("중성화").bold().padding(.trailing, 15.0)
                        Picker(selection: $petNeutering, label: Text("")){
                            Text("함").tag(true)
                            Text("안함").tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    HStack{
                        Text("펫 나이").bold().padding(.trailing, 15.0)
                        Spacer()
                        Picker(selection: $petAge, label: Text("")){
                            Text("퍼피(1세 미만)").tag("puppy")
                            Text("어덜트(1세~7세)").tag("adult")
                            Text("시니어(7세 이상").tag("senior")
                        }
                    }
                    HStack{
                        Text("크기").bold().padding(.trailing, 15.0)
                        Picker(selection: $petSize, label: Text("")){
                            Text("소형").tag("small")
                            Text("중형").tag("mid")
                            Text("대형").tag("big")
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    Button {
                        
                        createNewAccount()
                        
                    } label: {
                        HStack {
                            Spacer()
                            Text("회원가입")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.green)
                        
                    }.cornerRadius(15)
                    
                }

            }
        }.navigationTitle(nickname + "님의 반려동물을 소개해주세요").padding(30)
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
    
    @State var loginStatusMessage = ""
    private func createNewAccount() {
        if self.image == nil{
            self.loginStatusMessage = "이웃들에게 보여질 반려동물 사진을 선택해주세요."
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "회원가입 성공! : \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {

        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "프로필 사진 저장 완료 url: \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                self.storeUserInfo(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInfo(imageProfileUrl: URL){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["email": self.email , "uid": uid, "nickname":self.nickname, "gender": self.gender,"age":self.age, "pet_gender" : self.petGender, "pet_breed": self.petBreed, "pet_size" : self.petSize, "pet_neut" : self.petNeutering, "pet_name" : self.petName,"CatOrDog" : self.DogorCat, "pet_age":self.petAge, "profileImageUrl":imageProfileUrl.absoluteString] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Success!!!!!!!!!!!!!!!!")
                firstNaviLinkActive = false

                               
            }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(firstNaviLinkActive: .constant(true))
    }
}
