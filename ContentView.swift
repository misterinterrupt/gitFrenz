//
//  ContentView.swift
//  GH_API_00
//
//  Created by m interrupt on 7/14/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var friendState: FriendState
    
    init() {
        UITableView.appearance().backgroundColor = .clear // tableview background
        UITableViewCell.appearance().backgroundColor = .clear // cell background
    }
    
    var body: some View {
        
        let dragFromRight = DragGesture()
            .onEnded { dragValue in
                if dragValue.translation.width < -100 {
                    withAnimation {
                        self.friendState.toggleMenu()
                    }
                }
        }

        let dragFromLeft = DragGesture()
            .onEnded { dragValue in
                if dragValue.translation.width > 100 {
                    withAnimation {
                        if !self.friendState.menuShowing {
                            self.friendState.toggleMenu()
                        }
                    }
                }
        }

        return NavigationView {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    MainView()
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                        .background(Color(.black))
                    if (self.friendState.menuShowing) {
                        MenuView()
                            .frame(width: geo.size.width/2, height: geo.size.height, alignment: .leading)
                            .gesture(dragFromRight)
                    }
                }
            }
            .navigationBarTitle("gitfrenz", displayMode: .inline)
            .navigationBarItems(leading: (
                Button(action: {
                    withAnimation(.spring()) {
                        self.friendState.toggleMenu()
                    }
                }) {
                    Image(systemName: "line.horizontal.3")
                        .renderingMode(.original)
                        .imageScale(.large).scaleEffect(1.5)
                }
            ))
            .gesture(dragFromLeft)
        }
    }
}

struct MainView: View {
    
    @EnvironmentObject var friendState: FriendState
    
    var body: some View {
        ZStack {
            if friendState.selectedPage == .friends {
                FriendsView()
            }
            if friendState.selectedPage == .repos {
                ReposView()
            }
            if friendState.selectedPage == .activity {
                ActivityView()
            }
        }
    }
}

struct FriendsView: View {
    
    @EnvironmentObject var friendState: FriendState
    
    @State private(set) var addFriendShowing = false
    @State private(set) var removeFriendsShowing = false
    @State var newFriendName = ""
    @State var newGHUsername = ""
    
    func addFriend() {
        if newFriendName.isEmpty || newGHUsername.isEmpty { return }
        self.friendState.addFriend(newFriendName, newGHUsername)
        newFriendName = ""
        newGHUsername = ""
    }
    
    func toggleAddFriend() {
        self.addFriendShowing = !addFriendShowing
    }
    
    func toggleRemoveFriends() {
        self.removeFriendsShowing = !removeFriendsShowing
    }
    
    var body: some View {
        GeometryReader { geo in
            // full frame
            VStack(alignment: .center, spacing: 2.5) {
                HStack {
                    Text("Friends").font(.largeTitle).foregroundColor(Color(.white))
                    Button(action: {
                        withAnimation {
                            self.toggleAddFriend()
                        }
                    }) {
                        Image(systemName: self.addFriendShowing ? "x.circle" : "person.crop.circle.badge.plus")
                            .imageScale(.large)
                            .foregroundColor(Color.white)
                    }
                    Button(action: {
                        withAnimation {
                            self.toggleRemoveFriends()
                        }
                    }) {
                        Image(systemName: self.removeFriendsShowing ? "x.circle" : "person.crop.circle.badge.minus")
                            .imageScale(.large)
                            .foregroundColor(Color.white)
                    }
                }
                if(self.addFriendShowing) {
                    VStack(alignment: .leading, spacing: 2.0) {
                        HStack {
                            VStack {
                                TextField("friend's name", text: self.$newFriendName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle()).colorInvert()
                                TextField("github username", text: self.$newGHUsername)
                                    .textFieldStyle(RoundedBorderTextFieldStyle()).colorInvert()
                            }
                            Button(action: {
                                self.addFriend()
                                withAnimation {
                                    self.toggleAddFriend()
                                }
                            }) {
                                
                                Image(systemName: "return")
                                    .imageScale(.large)
                                    .foregroundColor(Color.white)
//                                    .border(Color(.white))
                                    .scaleEffect(x: 1.75, y: 1.75)
                            }
                         }
                    }
                    .transition(AnyTransition.slide)
                    .animation(.easeInOut)
                }
                VStack(alignment: .leading, spacing: 2.5) {
                    ForEach(self.friendState.friends, id: \.self) { (friend:DFriend) in
                        HStack {
                            if self.removeFriendsShowing {
                                Button(action: {
                                    withAnimation {
                                        self.friendState.removeFriend(friend.name)
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        //                                     .imageScale(.small)
                                        .foregroundColor(Color.white)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2.0) {
                                HStack {
                                    Text("name:")
                                        .foregroundColor(.gray).bold()
                                    Text(friend.name)
                                        .foregroundColor(.white)
                                }
                                HStack {
                                    Text("url:")
                                        .foregroundColor(.gray).bold()
                                    Text(friend.githubUsername)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
    .padding()
    }
}


struct ReposView: View {

    @EnvironmentObject var friendState: FriendState

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 2.5) {
                Text("Repos").font(.largeTitle).foregroundColor(Color(.white))
                    List(self.friendState.repositories, id: \.self) { (repo:DRepository) in
                    VStack(alignment: .leading) {
                        Text(repo.name)
                            .foregroundColor(.gray).bold()
                        Text(repo.url.absoluteString)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .padding()
    }
}

struct ActivityView: View {

    @EnvironmentObject var friendState: FriendState

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 2.5) {
                Text("Activity").font(.largeTitle).foregroundColor(Color(.white))
                VStack(alignment: .leading, spacing: 2.5) {
                    EmptyView()
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .padding()
    }
}

struct MenuView: View {
    
    @EnvironmentObject var friendState: FriendState
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text("friends")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
            .onTapGesture {
                self.friendState.selectPage(.friends)
                withAnimation(.spring()) {
                    self.friendState.toggleMenu()
                }
            }
            .padding(.top, 80)
            HStack {
                Image(systemName: "chevron.left.slash.chevron.right")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text("repos")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
            .onTapGesture {
                self.friendState.selectPage(.repos)
                withAnimation(.spring()) {
                    self.friendState.toggleMenu()
                }
            }
            .padding(.top, 20)
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                Text("activity")
                    .foregroundColor(.gray)
                    .font(.headline)
            }
            .onTapGesture {
                self.friendState.selectPage(.activity)
                withAnimation(.spring()) {
                    self.friendState.toggleMenu()
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
        .edgesIgnoringSafeArea(.all)
    }
}


func getTestFriends() -> FriendState {
    FriendState.shared.clearFriends()
    FriendState.shared.addFriend("test1", "test1")
    FriendState.shared.addFriend("test2", "test2")
    FriendState.shared.addFriend("test3", "test3")
    FriendState.shared.addFriend("test4", "test4")
    FriendState.shared.addFriend("test5", "test5")
    FriendState.shared.addFriend("test6", "test6")
//    FriendState.shared.toggleMenu()
    return FriendState.shared
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Color(.black)
            FriendsView()
                .environmentObject(getTestFriends())
        }
    }
}
