//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Felipe Filgueira on 5/10/25.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
