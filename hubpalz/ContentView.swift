//
//  ContentView.swift
//  hubpalz
//
//  Created by m interrupt on 7/20/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @EnvironmentObject
    var ghModel: GHModel
    @State
    var userToSearch: String = "octocat"
    
    func closeKeyboard() {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first else { return }
        keyWindow.endEditing(true)
    }
    
    var body: some View {
        NavigationView {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("User:")
                            .foregroundColor(.white)
                        TextField("e.g. octocat", text: $userToSearch)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            self.ghModel.getNextRepositoryPageForUser(self.userToSearch)
                            self.closeKeyboard()
                        }, label: {
                            Text("Search")
                        })
                    }
                    .padding(10)
                    .background(Color(.black))
                    Spacer()
                    GeometryReader { listGeo in
                        ZStack(alignment: .center) {
                            List(self.ghModel.repositories, id: \.self) { (repo:Repository) in
                                NavigationLink(destination: RepoView(repo: repo)) {
                                    VStack(alignment: .leading) {
                                        Text(repo.name)
                                            .font(.headline)
                                        Text(repo.url)
                                            .font(.footnote)
                                    }
                                    .onAppear {
                                        if self.ghModel.repositories.last == repo {
                                            self.ghModel.getNextRepositoryPageForUser(self.userToSearch)
                                        }
                                    }
                                }
                            }
                            if self.ghModel.loading {
                                VStack {
                                    Spacer()
                                    ZStack(alignment: .center) {
                                        Color(.black)
                                            .cornerRadius(10)
                                        Text("Loading...")
                                            .foregroundColor(Color(.white))
                                    }
                                    .frame(width: (listGeo.size.width/5)*2, height: listGeo.size.height/9, alignment: .center)
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                }
                                .animation(.easeIn)
                                .transition(.opacity)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Github Repo Search"))
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
}

struct RepoView: View {
    
    var repo:Repository
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(repo.name)
                .font(.headline)
            Text(repo.url)
                .font(.footnote)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
