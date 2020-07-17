//
//  FriendState.swift
//  GH_API_00
//
//  Created by m interrupt on 7/14/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import SwiftyJSON
import CoreData

typealias FriendData = [String:String]

public class FriendState: ObservableObject {
    
    public static let shared = FriendState()
    
    private init() {
        // connect CD publisher to friends, repos, activity
        CDPublisher(request: Friend.fetchRequest(), context: CoreDataContext.shared.viewContext)
        .map {
            $0.map {
                DFriend(id: $0.id!, name: $0.name!, githubUsername: $0.githubUsername!)
            }
        }
        .receive(on: DispatchQueue.main)
        .replaceError(with: [])
        .sink { [weak self] newFriends in
            self?.friends = newFriends
        }
        .store(in: &cancellables)
    }
        
    private var cancellables = [AnyCancellable]()
    
    @Published
    var friends = [DFriend]()

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
    
    public func addFriend(_ name: String, _ ghUsername: String) {
        let newFriend = NSEntityDescription
            .insertNewObject(forEntityName: "Friend",
                             into: CoreDataContext.shared.viewContext) as! Friend
        newFriend.id = UUID()
        newFriend.name = name
        newFriend.githubUsername = ghUsername

        CoreDataContext.shared.saveChanges()

        fetchFriendRepos(ghUsername)
    }
    
    public func clearFriends() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Friend")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try CoreDataContext.shared.viewContext.persistentStoreCoordinator!.execute(deleteRequest, with: CoreDataContext.shared.viewContext)
        } catch let error as NSError {
            print("Couldn't delete all Friends \(error)")
        }
        CoreDataContext.shared.saveChanges()
    }
    
    private func fetchFriendRepos(_ ghusername: String) {
//        let url = "https://api.github.com/users/\(ghusername)"
//        AF.request(url).responseJSON { response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                debugPrint(json)
//
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
}

public enum Page {
    case friends
    case repos
    case activity
}
