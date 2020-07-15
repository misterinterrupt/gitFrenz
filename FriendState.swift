//
//  FriendState.swift
//  GH_API_00
//
//  Created by m interrupt on 7/14/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

typealias Friend = [String:String]

public class FriendState: ObservableObject {
    
    public static let shared = FriendState()
    
    private init() {}
    
    @Published
    var friends = [Friend]()

    @Published
    private(set) var menuShowing: Bool = false
    
    @Published
    private(set) var selectedPage: Page = .friends
    
    public func toggleMenu() {
        menuShowing = !menuShowing
    }
    
    public func selectPage(_ page: Page) {
        selectedPage = page
    }
    
    public func addFriend(_ name: String, _ ghusername: String) {
        let newFriend = [name:ghusername]
        friends.append(newFriend)
        fetchFriendRepos(ghusername)
    }
    
    public func clearFriends() {
        friends.removeAll()
    }
    
    private func fetchFriendRepos(_ ghusername: String) {
        let url = "https://api.github.com/users/\(ghusername)"
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                debugPrint(json)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

public enum Page {
    case friends
    case repos
    case activity
}
