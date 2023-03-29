//
//  RecommendView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/23.
//

import SwiftUI
import WrappingHStack

class RecommendViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var feeds = [Items]()
    @Published var errorMessage = ""
    @Published var UserKeyword = [String]()


    init(){
        fetchCurrentUser()
        fetchPreferenceFeed()
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
    
    func fetchPreferenceFeed(){
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
            
            let currPetAge = try? snapshot?.data(as: ChatUser.self).pet_age
            let allKeyword = try? snapshot?.data(as: ChatUser.self).keyword.sorted {$0.1 > $1.1 }
            print(allKeyword)
            print(type(of: allKeyword))
            
            FirebaseManager.shared.firestore.collection(currPetAge ?? "")
                .getDocuments { documentSnapshot, err in
                    if let err = err{
                        self.errorMessage = "failed to fetch data: \(err)"
                        print(self.errorMessage)
                        return
                    }
                    documentSnapshot?.documents.forEach({ snapshot in
                        let item = try? snapshot.data(as: Items.self)
                        self.feeds.append(item!)
                    })
                }
        }
        
    }
    
}


struct RecommendView: View {
    
    @ObservedObject private var vm = RecommendViewModel()
    
    private var feedViewModel = FeedViewModel(feed: nil)
    @State var isFeedDetail = false
    
    private let temp = (1...10).map {"Item \($0)"}
    
    private let columns: [GridItem] = [
        GridItem(.flexible(),spacing:50)
    ]
    private let rows: [GridItem] = [
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationView{
            VStack{
                Text(vm.chatUser?.pet_name ?? "로딩중 ..")
                ScrollView{
                    LazyVGrid(
                        columns: columns ,
                        alignment: .leading ,
                        spacing: 10,
                        pinnedViews: [.sectionHeaders]) {
                        Section{
                            ForEach(vm.feeds) { item in
                                VStack{
                                    HStack{
                                        Capsule()
                                            .fill(Color.blue)
                                            .frame(width: 50, height: 50)
                                        Button{
                                            self.feedViewModel.feed = item
                                            self.isFeedDetail.toggle()
                                            
                                        } label : {
                                            VStack{
                                                    Text(item.product_name).bold()
                                                    WrappingHStack{
                                                        ForEach(item.keyword, id: \.self) { keyword in
                                                            HStack{
                                                                Text(keyword).font(.caption)
                                                                Text(" ")
                                                            }
                                                            
                                                        }
                                                    }.frame(minWidth: 200)
                                            }

                                        }.sheet(isPresented: $isFeedDetail) {
                                            FeedView(vm: feedViewModel)
                                        }
                                    }



                                }.padding()

                            }
                        } header: {
                            Text("First section")
                                .frame(maxWidth:.infinity)
                                .padding(.vertical,20)
                                .background(.green)
                        }

                    }
                }
//                ScrollView(.horizontal){
//                    LazyHGrid(rows: rows){
//                        ForEach(temp, id: \.self) { item in
//                            VStack{
//                                Capsule()
//                                    .fill(Color.blue)
//                                    .frame(width: 50, height: 50)
//                            }
//                        }
//                    }
//                }
            }
        }
    }
}

struct RecommendView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}
