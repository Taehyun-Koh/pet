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
    @State private var location = ""
    
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
                        Text("남성").tag("남성")
                        Text("여성").tag("여성")
                    }.pickerStyle(SegmentedPickerStyle())
                }
                
                HStack{
                    Text("연령대").bold()
                    Spacer()
                    Picker(selection: $age, label:Text(""), content:{
                        Text("10대").tag("10대")
                        Text("20대").tag("20대")
                        Text("30대").tag("30대")
                        Text("40대").tag("40대")
                        Text("50대").tag("50대")
                        Text("60대").tag("60대")
                        Text("70대").tag("70대")
                        Text("80대").tag("80대")
                        Text("90대").tag("90대")
                    }).foregroundColor(.red)
                }
                .foregroundColor(Color.black)
                

                HStack{
                    Text("동네").bold()
                    Spacer()
                    if location == ""{
                        newMessageButton
                    }
                    else{
                        Text(location).foregroundColor(.black)
                    }
                }
                
                HStack{
                    
                    if (email != "" &&  password != "" && nickname != "" &&  age != "" &&  gender != "" && location != "") {
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
                    NavigationLink(destination: PetInfoView(email: $email, password: $password, nickname: $nickname, gender:$gender , age:$age, location:$location, firstNaviLinkActive:$firstNaviLinkActive), isActive: $firstNaviLinkActive){
                        Text("")
                    }
                }
                
            }
        }
        .padding()
    }
    
    @State var isShownSheet = false
    @ObservedObject var vm1 = LocationManager()
    private var newMessageButton: some View {
       
        Button {
            self.isShownSheet.toggle()
            
        } label: {
            HStack {

                Text("설정하기")
                    .font(.system(size: 16, weight: .bold))
                
            }
            .foregroundColor(.white)
            .padding()
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal,50)
        }
        .sheet(isPresented: $isShownSheet) {
            
            NavigationView{
                VStack{
                    MapViewCoordinator(locationManager: vm1).cornerRadius(10)
                    HStack{
                        Text("현재 위치가 \(vm1.currentPlace)인가요?")
                        Button {
                            isShownSheet.toggle()
                            location = vm1.currentPlace
                        } label: {
                            Text("확인")
                        }
                    }

                    
                    
                }
                .navigationTitle(vm1.currentPlace)
            }
        }
        
    }
    
}

struct PetInfoView: View {
    
    @State private var shouldShowImagePicker = false
    @State private var petName = ""
    @State private var DogorCat = ""
    @State private var petBreed = ""
    @State private var petAge = ""
    @State private var petGender = ""
    @State private var petSize = "소형"
    @State private var petNeutering = true
    @State private var introduce = ""
    @State var navigated = false
    @State var isloading = false
    
    
    @Binding var email : String
    @Binding var password : String
    @Binding var nickname : String
    @Binding var gender : String
    @Binding var age : String
    @Binding var location : String
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
                            Text("강아지").tag("강아지")
                            Text("고양이").tag("고양이")
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    HStack{
                        Text("품종").bold()
                        Spacer()
                        if DogorCat == "강아지"{
                            Picker(selection: $petBreed, label:Text(""), content:{
                                Text("선택").tag("")
                                Text("시바견").tag("시바견")
                                Text("푸들").tag("푸들")
                                Text("진돗개").tag("진돗개")
                                Text("포메라니안").tag("포메라니안")
                                Text("치와와").tag("치와와")
                                Text("시추").tag("시추")
                                Text("골든리트리버").tag("골든리트리버")
                            })
                            
                            .foregroundColor(Color.black)
                            .padding(10)
                        }
                        else if DogorCat == "고양이"{
                            Picker(selection: $petBreed, label:Text(""), content:{
                                Text("선택").tag("")
                                Text("페르시안고양이").tag("페르시안고양이")
                                Text("메인쿤").tag("메인쿤")
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
                            Text("시니어(7세 이상)").tag("senior")
                        }
                    }
                    HStack{
                        Text("크기").bold().padding(.trailing, 15.0)
                        Picker(selection: $petSize, label: Text("")){
                            Text("소형").tag("소형")
                            Text("중형").tag("중형")
                            Text("대형").tag("대형")
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                    InputTextFieldView(text: $introduce,
                                       placeholder: "소개말을 적어주세요.",
                                       keyboardType: .namePhonePad,
                                       systemImage: nil)
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
        
        let userData = ["email": self.email , "uid": uid, "nickname":self.nickname, "gender": self.gender,"age":self.age, "location":self.location,"pet_gender" : self.petGender, "pet_breed": self.petBreed, "pet_size" : self.petSize, "pet_neut" : self.petNeutering, "pet_name" : self.petName,"CatOrDog" : self.DogorCat, "pet_age":self.petAge, "profileImageUrl":imageProfileUrl.absoluteString, "introduce" : self.introduce] as [String : Any]
        
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
