//
//  RepositoryModel.swift
//  hubpalz
//
//  Created by m interrupt on 7/20/20.
//  Copyright © 2020 m interrupt. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class GHModel: ObservableObject {
    
    @Published
    var repositories:[Repository] = []
    @Published
    var loading = false
    private var currentSearch = ""
    
    private var repoPagesRetrieved = 0
    private var pageSize = 25

    var cancellables: [AnyCancellable] = []
    
    init() {
        
    }
    
    func getNextRepositoryPageForUser(_ userName: String) {
        let newSearch = userName.trimmingCharacters(in: CharacterSet(charactersIn: " / \\")).lowercased()
        if newSearch.isEmpty { return }
        if self.currentSearch != newSearch {
            self.repoPagesRetrieved = 0
            self.repositories.removeAll(keepingCapacity: false)
            self.currentSearch = newSearch
        }
        let bgq = DispatchQueue.global(qos: .background)
        self.loading = true
        bgq.async { [unowned self] in
            if let apiURL = URL(string: "https://api.github.com/users/\(userName)/repos?type=owner&sort=pushed&direction=desc&page=\(self.repoPagesRetrieved+1)&per_page=\(self.pageSize)") {
                print("attempted to load: \(apiURL)")
                URLSession.shared.dataTaskPublisher(for: apiURL)
                .tryMap{ output in
                    guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                        throw HTTPError.statusCode
                    }
                    return output.data
                }
                .decode(type: [Repository].self, decoder: JSONDecoder())
                .replaceError(with: [])
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .sink(receiveCompletion: { completion in
                    switch(completion) {
                    case .finished:
                        break
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }, receiveValue: { repos in
                    print("repos recieved: \(repos.count)")
                    self.loading = false
                    if repos.count == 0 { return }
                    self.repositories.append(contentsOf: repos)
                    self.repoPagesRetrieved += 1
                })
                .store(in: &(self.cancellables))
            }
        }
    }
}

enum HTTPError: LocalizedError {
    case statusCode
}

struct Repository: Codable, Hashable {
    let id: Int
    let name: String
    let url: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case url = "html_url"
    }
}

