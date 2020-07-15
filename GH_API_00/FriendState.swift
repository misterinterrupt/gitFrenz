//
//  FriendState.swift
//  GH_API_00
//
//  Created by m interrupt on 7/14/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import Foundation
import SwiftUI

typealias Friend = [String:URL]

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
    
    public func addFriend(_ name: String, _ ghURL: URL) {
        let newFriend = [name:ghURL]
        friends.append(newFriend)
    }
    
    public func clearFriends() {
        friends.removeAll()
    }
    
}

public enum Page {
    case friends
    case repos
    case activity
}
