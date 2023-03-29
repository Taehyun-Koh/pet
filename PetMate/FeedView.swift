//
//  FeedView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/25.
//

import SwiftUI

class FeedViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    
    var feed : Items?
    
    init(feed: Items?) {
        self.feed = feed
    }
    
}

struct FeedView: View {
    
    @ObservedObject var vm: FeedViewModel
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Text(vm.feed?.product_name ?? "가져오지 못함")
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}
