//
//  ContentView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/16.
//

import SwiftUI

// 바텀 탭 페이지
enum BottomTab {
    case home, list, search, myPage
}

struct ContentView: View {
    
    @State var chatUser: ChatUser?
    @State var shouldNavigateToChatLogView = true
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @State var currentTab : BottomTab = .home
    
    init(){
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            tabView.zIndex(0)
//            bottomTabs.zIndex(1)
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

            
            Color.pink.edgesIgnoringSafeArea(.all)
                .overlay(Text("사료").font(.largeTitle))
                .tag(BottomTab.search)
                .tabItem {
                    Image(systemName: "pawprint")
                    Text("사료")
                }
            
            Color.blue.edgesIgnoringSafeArea(.all)
                .overlay(Text("마이").font(.largeTitle))
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
