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

public class FriendState: ObservableObject {
    
    public static let shared = FriendState()
    
    private init() {
        setupCDPublishing()
    }
        
    private var cancellables = [AnyCancellable]()
    
    @Published
    var friends = [DFriend]()
    
    @Published
    var repositories = [DRepository]()

    @Published
    private(set) var menuShowing: Bool = false
    
    @Published
    private(set) var selectedPage: Page = .friends
    
    public func toggleMenu() {
        menuShowing = !menuShowing
    }
    
    public func selectPage(_ page: Page) {
        selectedPage = page
        if selectedPage == .repos {
            for friend in friends {
                fetchFriendRepos(friend.githubUsername)
            }
        }
    }
    
    func setupCDPublishing() {
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
        
        CDPublisher(request: Repository.fetchRequest(), context: CoreDataContext.shared.viewContext)
        .map {
            $0.map {
                DRepository(id: $0.id!, url: $0.url ?? URL(string: $0.name!)!, name: $0.name!, lastCommit: Date())
            }
        }
        .receive(on: DispatchQueue.main)
        .replaceError(with: [])
        .sink { [weak self] newRepos in
            self?.repositories = newRepos
        }
        .store(in: &cancellables)
    }
}

// DAO-ish extension
extension FriendState {
    
    public func addFriend(_ name: String, _ ghUsername: String) {
        let newFriend = NSEntityDescription
            .insertNewObject(forEntityName: "Friend",
                             into: CoreDataContext.shared.viewContext) as! Friend
        newFriend.id = UUID()
        newFriend.name = name
        newFriend.githubUsername = ghUsername

        CoreDataContext.shared.saveChanges()
    }
    
    public func removeFriend(_ name: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Friend")
        let predicate = NSPredicate(format: "%K == %@", "name", name)
        fetchRequest.predicate = predicate
        do {
            let records = try CoreDataContext.shared.viewContext.fetch(fetchRequest) as! [NSManagedObject]
            if let record = records.first {
                CoreDataContext.shared.viewContext.delete(record)
            }
        } catch let error as NSError {
            print("Couldn't fetch Friend to delete. \(error)")
        }
        CoreDataContext.shared.saveChanges()
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
    
    private func addRepo(_ repo: GHJSONCodable.Repository) {
        let newRepo = NSEntityDescription
            .insertNewObject(forEntityName: "Repository",
                             into: CoreDataContext.shared.viewContext) as! Repository
        newRepo.id = UUID()
        newRepo.name = repo.name

        CoreDataContext.shared.saveChanges()
    }

    public func clearRepos() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Repository")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try CoreDataContext.shared.viewContext.persistentStoreCoordinator!.execute(deleteRequest, with: CoreDataContext.shared.viewContext)
        } catch let error as NSError {
            print("Couldn't delete all Repos \(error)")
        }
        CoreDataContext.shared.saveChanges()
    }
    
}

extension FriendState {
    
    private func fetchFriendRepos(_ ghusername: String) {
        clearRepos()
        if let url = URL(string:"https://api.github.com/users/\(ghusername)/repos?type=owner&sort=pushed") {
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { output in
                    guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                        throw HTTPError.statusCode
                    }
                    return output.data
                }
                .decode(type: [GHJSONCodable.Repository].self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .replaceError(with: [])
                .eraseToAnyPublisher()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }, receiveValue: { repos in
//                    print(repos.count)
                    for repo in repos {
                        self.addRepo(repo)
                    }
                })
                .store(in: &cancellables)
        }
    }
}

public enum Page {
    case friends
    case repos
    case activity
}

enum HTTPError: LocalizedError {
    case statusCode
}
