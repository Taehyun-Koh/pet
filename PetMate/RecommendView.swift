//
//  RecommendView.swift
//  PetMate
//
//  Created by 고태현 on 2023/03/23.
//

import SwiftUI
import WrappingHStack
import SDWebImageSwiftUI

class RecommendViewModel: ObservableObject{
    
    @Published var chatUser: ChatUser?
    @Published var allfeeds = [Items]()
    @Published var feeds = [Items]()
    @Published var errorMessage = ""
    @Published var UserKeyword = [String]()
    @Published var UserKeywordNum = [Int]()
    @Published var UserKeyDict = [String: Int]()
    @Published var scoreDict = [Double: Items]()
    
    init(){
        fetchCurrentUser()
        fetchPreferenceFeed()
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
    
    func fetchPreferenceFeed(){
        UserKeyword = [String]()
        UserKeywordNum = [Int]()
        UserKeyDict = [String: Int]()
        scoreDict = [Double: Items]()
        feeds = [Items]()
        
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
            guard let allKeyword = try? snapshot?.data(as: ChatUser.self).keyword else {return}
            let sortedKeyword = allKeyword.sorted { $0.1 > $1.1 }
            
            for kw in sortedKeyword {
                if self.UserKeyword.count >= 6 {
                    break
                }
                self.UserKeyword.append(kw.0)
                self.UserKeywordNum.append(kw.1)
            }
            
            for kw in sortedKeyword{
                self.UserKeyDict[kw.0] = kw.1
            }
            
            FirebaseManager.shared.firestore.collection(currPetAge ?? "")
                .getDocuments { documentSnapshot, err in
                    if let err = err{
                        self.errorMessage = "failed to fetch data: \(err)"
                        print(self.errorMessage)
                        return
                    }
                    documentSnapshot?.documents.forEach({ snapshot in
                        let item = try? snapshot.data(as: Items.self)
                        let similarity = self.solution(self.UserKeyword, item!.keyword)
                        
                        self.allfeeds.append(item!)
                        self.scoreDict[Double(similarity)] = item!

                    })
                    
                    let feedDict = self.scoreDict.sorted { $0.0 > $1.0 }

                    for kww in feedDict {
                        if self.feeds.count >= 20{
                            break
                        }
                        self.feeds.append(kww.1)
                    }
                }
            

        }
        

    }
    
    func fetchAllFeed(){
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
            
            FirebaseManager.shared.firestore.collection(currPetAge ?? "")
                .getDocuments { documentSnapshot, err in
                    if let err = err{
                        self.errorMessage = "failed to fetch data: \(err)"
                        print(self.errorMessage)
                        return
                    }
                    documentSnapshot?.documents.forEach({ snapshot in
                        let item = try? snapshot.data(as: Items.self)
                        self.allfeeds.append(item!)

                    })
                }
        }
    }
    
    private func solution(_ arr1:[String], _ arr2:[String]) -> Double {
        
        if arr1.isEmpty && arr2.isEmpty { return 1 }
        
        let a = intersect(arr1, other: arr2)
        let b = sumArrayCount(arr1, other: arr2)
        
        let rst = Double(a) / Double(b)
        
        return rst + Double.random(in: 0.000000000000000000000000000000000000000000000000000000000000000 ... 0.000000000000000000000000000000000000000000000000000000000000001 )
    }
    
    private func sumArrayCount(_ base: [String], other: [String]) -> Int {
        let sameArray = intersect(base, other: other)
        
        return base.count + other.count - sameArray
    }

    private func intersect(_ base: [String], other: [String]) -> Int {
        var result = 0
        var dic: [String:Int] = [:]
        other.forEach {
            if dic[$0] != nil {
                dic[$0]! += 1
            } else { dic[$0] = 1}
        }
        base.forEach {
            if let v = dic[$0], v >= 1 {
                result += 1
                dic[$0]! -= 1
            }
        }
        return result
    }
    
}


struct RecommendView: View {
    
    static let BackgroundColor = Color("TextBackground")
    @ObservedObject private var vm = RecommendViewModel()
    @State private var random: Bool = true
    
    private var feedViewModel = FeedViewModel(feed: nil)
    @State var isFeedDetail = false
    @State var showNum = false
    @State var text = ""
    
    
    private let columns: [GridItem] = [
        GridItem(.flexible(),spacing:0),
        GridItem(.flexible(),spacing:0)
    ]
    private let rows: [GridItem] = [
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationView{
            VStack{
                HStack {
                    if random == true{
                        HStack{
                            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipped()
                                .cornerRadius(100)
                        }
                    }
                    Text("사료")
                        .bold()
                        .font(.system(size: 30))
                    
                    Spacer()
                    
                    Toggle(isOn: $random) {
                        Text(random ? "맞춤 보기" : "모두 보기")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .black))
                    .padding(.trailing)
                }
                .padding(.leading)
                if random{
                    if vm.UserKeyword.count != 0{
                        HStack{
                            if vm.chatUser?.pet_age == "puppy"{
                                Text("퍼피(~생후 1년)")
                                    .padding(.all, 5)
                                    .font(.system(size: 16))
                                    .bold()
//                                    .background(Color.gray)
                                    .foregroundColor(Color.gray)
                                    .cornerRadius(10)
                                    .padding(.leading, 15)
                                    .padding(.bottom,5)
                            }
                            else if vm.chatUser?.pet_age == "adult"{
                                Text("성견(1년 ~7년)")
                                    .padding(.all, 5)
                                    .font(.system(size: 16))
                                    .bold()
//                                    .background(Color.gray)
                                    .foregroundColor(Color.gray)
                                    .cornerRadius(10)
                                    .padding(.leading, 15)
                                    .padding(.bottom,5)
                            }
                            else if vm.chatUser?.pet_age == "old"{
                                Text("노견(7년~)")
                                    .padding(.all, 5)
                                    .font(.system(size: 16))
                                    .bold()
//                                    .background(Color.gray)
                                    .foregroundColor(Color.gray)
                                    .cornerRadius(10)
                                    .padding(.leading, 15)
                                    .padding(.bottom,5)
                            }
                            Spacer()
                            Button {
                                vm.fetchCurrentUser()
                                vm.fetchPreferenceFeed()

                            } label: {
                                Spacer()
                                HStack{
                                    Text("추천 새로고침").foregroundColor(.black)
                                        .font(.system(size:13))
                                    Image(systemName: "arrow.counterclockwise").foregroundColor(.black)
                                        .font(.system(size:13))

                                }
                            }
                        }.padding(.trailing)
                    }
                    
                    HStack {
                        if vm.UserKeyword.count == 0 {
                            Text("사료를 클릭해 선호 키워드를 만들어보세요.")
                                .padding(.all, 5)
                                .font(.system(size: 13))
                                .foregroundColor(Color.gray)
                            Button {
                                vm.fetchAllFeed()
                                random.toggle()
                            } label: {
                                Text("사료보기")
                                    .padding(.all, 5)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.blue)
                            }

                        }
                        else{
                            ForEach(Array(zip(vm.UserKeyword, vm.UserKeywordNum)), id: \.0) { item in
                                VStack {
                                    Text(item.0)
                                        .font(.system(size: 16))
                                    if showNum {
                                        Text(String(item.1))
                                    }
                                }
                                .padding(.all, 5)
                                .font(.system(size: 11))
                                .bold()
                                .background(Color.green)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                            }
                            VStack{
                                Button {
                                    showNum.toggle()
                                } label: {
                                    HStack{
                                        if !showNum {
                                            Image(systemName: "arrowtriangle.down.square.fill").foregroundColor(.gray)
                                        }
                                        else{
                                            Image(systemName: "arrowtriangle.up.square").foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }.padding(.bottom, 5)

                    ScrollView{
                        LazyVGrid(
                            columns: columns ,
                            alignment: .leading ,
                            spacing: 40,
                            pinnedViews: [.sectionHeaders]) {
                            Section{
                                ForEach(Array((vm.feeds).enumerated()), id: \.offset) { index, item in
                                    VStack{
                                        Button{
                                            updateUserKeyword(item: item.keyword, userkeyword: vm.UserKeyDict)
                                            self.feedViewModel.feed = item
                                            self.isFeedDetail.toggle()
                                            
                                        } label : {
                                            VStack{
                                                Spacer()
                                                ZStack(alignment: Alignment.topLeading){
                                                    
                                                    AsyncImage(url: URL(string: item.imageURL)) { image in
                                                        image.resizable()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .frame(width: 150, height: 150)
                                                    Text("\(index+1)")
                                                        .padding(5)
                                                        .background(.gray)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(.white)
                                                        
                                                }
                       
                                                
                                                
                                                Spacer()
                                                HStack{
                                                    Text(item.product_name)
                                                        .bold()
                                                        .foregroundColor(.black)
                                                        .multilineTextAlignment(.leading)
                                                    Spacer()
                                                }
                                                HStack{
                                                    if item.price_before != "할인없음"{
                                                        Text(item.price_before).foregroundColor(.gray)
                                                            .strikethrough()
                                                        Text(item.discount).foregroundColor(.red)
                                                        Spacer()
                                                    }
                                                    
                                                    
                                                }.font(.system(size: 15))
                                                HStack{
                                                    (Text(item.price)+Text("원")).bold().foregroundColor(.black)
                                                    Spacer()
                                                }
                                                
                                                HStack{
                                                    if item.review != "리뷰없음"{
                                                        
                                                        Text(item.review.dropLast(3)).foregroundColor(.gray)
                                                        Spacer()
                                                    }
                                                    else{
                                                        Text("0개 후기").foregroundColor(.gray)
                                                        Spacer()
                                                    }
                                                }.font(.system(size: 15))
                                                
                                                GeometryReader { geometry in
                                                    self.generateContent(in: geometry, other: item.keyword, userkeyword : vm.UserKeyword)
                                                }
                                                
                                                
                                                
                                            }
                                            .padding()
                                            


                                        }.sheet(isPresented: $isFeedDetail) {
                                            FeedView(vm: feedViewModel)
                                        }
                                    }
                                }
                                }
                                
                            }
                        }
                }
                
                else{
                    ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                        FeedSearchBar(text: $text)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                    }
                    ScrollView{
                    LazyVGrid(
                        columns: columns ,
                        alignment: .leading ,
                        spacing: 40,
                        pinnedViews: [.sectionHeaders]) {
                        Section{
                            ForEach(vm.allfeeds) { item in
                                var keyarr = item.keyword
                                if keyarr.contains(text) || text.isEmpty{
                                    VStack{
                                        Button{
                                            updateUserKeyword(item: item.keyword, userkeyword: vm.UserKeyDict)
                                            vm.fetchCurrentUser()
                                            vm.fetchPreferenceFeed()
                                            self.feedViewModel.feed = item
                                            self.isFeedDetail.toggle()
                                            
                                        } label : {
                                            VStack{
                                                Spacer()
                                                AsyncImage(url: URL(string: item.imageURL)) { image in
                                                    image.resizable()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 150, height: 150)
                                                
                                                
                                                Spacer()
                                                HStack{
                                                    Text(item.product_name)
                                                        .bold()
                                                        .foregroundColor(.black)
                                                        .multilineTextAlignment(.leading)
                                                    Spacer()
                                                }
                                                HStack{
                                                    if item.price_before != "할인없음"{
                                                        Text(item.price_before).foregroundColor(.gray)
                                                            .strikethrough()
                                                        Text(item.discount).foregroundColor(.red)
                                                        Spacer()
                                                    }
                                                    
                                                    
                                                }.font(.system(size: 15))
                                                HStack{
                                                    (Text(item.price)+Text("원")).bold().foregroundColor(.black)
                                                    Spacer()
                                                }
                                                
                                                HStack{
                                                    if item.review != "리뷰없음"{
                                                        
                                                        Text(item.review.dropLast(3)).foregroundColor(.gray)
                                                        Spacer()
                                                    }
                                                    else{
                                                        Text("0개 후기").foregroundColor(.gray)
                                                        Spacer()
                                                    }
                                                }.font(.system(size: 15))
                                                
                                                GeometryReader { geometry in
                                                    self.generateContent2(in: geometry, other: item.keyword, searchText : text)
                                                }
                                                
                                                
                                                
                                            }
                                            .padding()
                                            


                                        }.sheet(isPresented: $isFeedDetail) {
                                            FeedView(vm: feedViewModel)
                                        }
                                    }
                                }
                                
                            }
                            }
                            
                        }
                    }
                }
                }
            }
        }
    
    
    
    private func updateUserKeyword(item : [String], userkeyword : [String:Int]){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        var word = userkeyword.keys
        var count = userkeyword.values
        
        for key in item {
            var updateCount = 1
            if let idx = word.firstIndex(of: key) {
                updateCount = count[idx] + 1
            }
            FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["keyword.\(key)": updateCount])
        }
        
    }
    
    private func generateContent(in g: GeometryProxy , other : [String] , userkeyword : [String]) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(other, id: \.self) { platform in
                self.item(text: platform, userkeyword: userkeyword)
                    .padding([.horizontal, .vertical], 1)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if platform == other.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if platform == other.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item(text: String, userkeyword : [String]) -> some View {
        VStack{
            if userkeyword.contains(text){
                Text(text)
                    .padding(.all, 5)
                    .font(.system(size: 13))
                    .bold()
//                    .background(Color.green)
                    .foregroundColor(Color.green)
                    
                    .cornerRadius(10)
                    .border(Color.green)
            }
            else{
                Text(text)
                    .padding(.all, 5)
                    .font(.system(size: 13))
                    .bold()
//                    .background(Color.gray)
                    .foregroundColor(Color.gray)
                    .cornerRadius(10)
            }
        }


    }
    
    private func generateContent2(in g: GeometryProxy , other : [String] , searchText : String) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(other, id: \.self) { platform in
                self.item2(text: platform , searchText : searchText)
                    .padding([.horizontal, .vertical], 1)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if platform == other.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if platform == other.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    func item2(text: String , searchText : String) -> some View {
        VStack{
            if searchText.contains(text){
                Text(text)
                    .padding(.all, 5)
                    .font(.system(size: 13))
                    .bold()
//                    .background(Color.green)
                    .foregroundColor(Color.green)
                    .cornerRadius(10)
                    .border(Color.green)
            }
            else{
                Text(text)
                    .padding(.all, 5)
                    .font(.system(size: 13))
                    .bold()
//                    .background(Color.gray)
                    .foregroundColor(Color.gray)
                    .cornerRadius(10)
            }
        }
    }
    
}

struct RecommendView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}
