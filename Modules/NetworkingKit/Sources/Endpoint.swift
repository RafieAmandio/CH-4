//
//  Endpoint.swift
//  CH-4
//
//  Created by Dwiki on 08/08/25.
//

import Foundation

public struct Endpoint<Response: Decodable> {
  public var path: String
  public var query: [URLQueryItem] = []
  public var method: String = "GET"

  public init(path: String, query: [URLQueryItem] = [], method: String = "GET") {
    self.path = path
    self.query = query
    self.method = method
  }
}
