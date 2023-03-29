//
//  ContentView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/16.
//

import SwiftUI

// 바텀 탭 페이지
enum BottomTab {
    case home, list, search, myPage, favorite
}
class ContentViewModel : ObservableObject{
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
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
    
}
struct ContentView: View {
    
    @State var chatUser: ChatUser?
    @State var shouldNavigateToChatLogView = true
    @State var shouldShowLogOutOptions = false
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @ObservedObject private var vm = ContentViewModel()

    @State var currentTab : BottomTab = .home
    
    init(){
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            tabView.zIndex(0)
//            bottomTabs.zIndex(1)
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
            })
        }
    }
}

//MARK: - 뷰
extension ContentView {
    
    // 탭뷰
    var tabView : some View {
        TabView (selection: $currentTab) {
            
            LocalListView()
                .tag(BottomTab.home)
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }

            
            MainMessageView()
                .tag(BottomTab.list)
                .tabItem {
                    Image(systemName: "message")
                    Text("채팅")
                }

            RecommendView()
                .tag(BottomTab.search)
                .tabItem {
                    Image(systemName: "pawprint")
                    Text("사료")
                }
            ProfileView()
                .tag(BottomTab.myPage)
                .tabItem {
                    Image(systemName: "person")
                    Text("마이")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
