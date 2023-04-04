//
//  FeedView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/25.
//

import SwiftUI
import WrappingHStack

class FeedViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var errorMessage = ""

    var feed : Items?


    init(feed: Items?) {
        self.feed = feed
        fetchCurrentUser()
    }
    
    
    private func fetchCurrentUser() {
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
}


struct FeedView: View {
    
    @ObservedObject var vm: FeedViewModel
    
    
    var body: some View {
        ScrollView{
            VStack {
                
                Spacer()
                HStack{
                    Text(vm.feed?.brand ?? "브랜드")
                    
                        .padding(.leading, 30)
                    Spacer()
                }
                
                
                AsyncImage(url: URL(string: vm.feed?.imageURL ?? "")) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 330, height: 330)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 10)
                {
                    HStack{
                        Text(vm.feed?.product_name ?? "")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .font(.system(size: 25))
                        
                        Spacer()
                    }
                    
                    HStack{
                        (Text(vm.feed?.price ?? "") + Text("원"))
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                            .font(.system(size: 20))
                        
                        if vm.feed?.price_before != "할인없음"{
                            Text(vm.feed?.price_before ?? "")
                                .foregroundColor(.gray)
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                                .strikethrough()
                            Text(vm.feed?.discount ?? "")
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                        }
                    }
                    Text(vm.feed?.feature ?? "")
                        .foregroundColor(.black)
                        .font(.system(size: 20))
        
                    Link(destination: URL(string: vm.feed?.link ?? "https://dogpre.com/")!, label: {
                                    Text("바로가기")
                                        .font(.system(size: 20))
                                        .frame(width: 300, height: 60)
                                        .background(Color.brown)
                                        .foregroundColor(.white)
                                        .cornerRadius(20)
                                        .padding()
                                })

                }
                .padding(.horizontal, 30)
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
        }

//        .background(
//            Image(place)
//                .resizable()
//                .scaledToFill()
//                .edgesIgnoringSafeArea(.all)
//        )
//        WrappingHStack{
//            ForEach(vm.feed?.keyword ?? [], id: \.self) { keyword in
//                HStack{
//                    Text(keyword)
//                    Text(" ")
//                }
//
//            }
//        }.frame(minWidth: 200)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}
