//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Felipe Filgueira on 5/22/25.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
