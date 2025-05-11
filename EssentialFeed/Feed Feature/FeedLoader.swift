//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Felipe Filgueira on 5/10/25.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
