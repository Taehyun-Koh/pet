//
//  ContentView.swift
//  Food delivery
//
//  Created by Usman Mukhtar on 21/07/2020.
//

import SwiftUI

class MainProductViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var products = [Products]()
    @Published var errorMessage = ""
    
    init(){
        fetchCurrentUser()
        fetchAllProducts()
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
    
    func fetchAllProducts(){
        FirebaseManager.shared.firestore.collection("product")
            .getDocuments { documentSnapshot, err in
                if let err = err{
                    self.errorMessage = "failed to fetch data: \(err)"
                    print(self.errorMessage)
                    return
                }
                documentSnapshot?.documents.forEach({ snapshot in
                    let item = try? snapshot.data(as: Products.self)
                    self.products.append(item!)

                })
            }
    }
    
}


struct MainProductView: View {
    var body: some View {
        FoodDeliverView()
    }
}

struct MainProductView_Previews: PreviewProvider {
    static var previews: some View {
        MainProductView()
    }
}

struct FoodDeliverView: View {
    @ObservedObject private var vm = MainProductViewModel()
    var columns = Array(repeating: GridItem(.flexible()), count: 2)
    @State var categoryIndex : String = "간식"
    @State var text = ""
    var body: some View {
        ZStack {
            VStack (alignment: .leading){
                Text("반려동물용품")
                    .bold()
                    .font(.system(size: 30))
                
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                    SearchBar(text: $text)
                        .padding(.top, 10)
                    
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30){
                        ForEach(categories, id: \.self){data in
                            Categories(data: data, index: $categoryIndex)
                        }
                    }
                }
                .padding(.top, 30)

                ScrollView(.vertical, showsIndicators: false){
                    LazyVGrid(columns: columns, spacing: 20){
                        ForEach(vm.products){ food in
                            let pname : String = food.product_name
                            let pcategory : String = food.category
                            if pname.contains(text) || text.isEmpty {
                                if pcategory == categoryIndex{
                                    ZStack{
                                        VStack {
                                            AsyncImage(url: URL(string: food.imageURL)) { image in
                                                image.resizable()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .frame(height: 150)
                                            HStack{
                                                Text(food.product_name)
                                                    .fontWeight(.bold)
                                                Spacer()
                                            }
                                            HStack{
                                                if food.price_before != "할인없음"{
                                                    Text(food.price_before).foregroundColor(.gray)
                                                        .strikethrough()
                                                    Text(food.discount).foregroundColor(.red)
                                                    Spacer()
                                                }
                                                
                                                
                                            }.font(.system(size: 15))
                                            HStack{
                                                (Text(food.price)+Text("원")).bold().foregroundColor(.black)
                                                Spacer()
                                            }
                                            
                                            HStack{
                                                if food.review != "리뷰없음"{
                                                    
                                                    Text(food.review.dropLast(3)).foregroundColor(.gray)
                                                    Spacer()
                                                }
                                                else{
                                                    Text("0개 후기").foregroundColor(.gray)
                                                    Spacer()
                                                }
                                                Spacer()

                                                Link(destination: URL(string: food.link )!, label: {
                                                    Image(systemName: "arrowshape.turn.up.right").foregroundColor(.black)
                                                })

                                                
                                            }.font(.system(size: 15))
                                        }
                                    }
                                    
                                    .padding(.horizontal, 1)
                                    .padding(.vertical, 20)

                                }

                            }


                        }
                    }
                }

                
                Spacer()
            }.padding(.top, 20)
        }
        .padding(.horizontal, 10)
    }
}

struct Categories: View {

    var data: String
    @Binding var index: String
    
    var body: some View{
        VStack(spacing: 8 ){
            Text(data)
                .font(.system(size: 16))
                .fontWeight(index == data ? .bold : .none)
                .foregroundColor(Color(index == data ? "mainfont" : "subfont"))
            
            Capsule()
                .fill(Color("mainfont"))
                .frame(width: 30, height: 4)
                .opacity(index == data ? 1 : 0)
        }.onTapGesture {
            index = data
        }
    }
}

var categories = ["건강관리", "간식", "위생/배변", "미용/목욕", "급식기/급수기", "하우스/울타리", "이동장", "의류/액세서리", "목줄/인식표/리드줄", "장난감"]


