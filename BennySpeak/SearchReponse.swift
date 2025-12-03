//
//  SearchResponse.swift
//  BennySpeak
//
//  Created by James on 11/11/25.
//

import Foundation

// Top-level response
struct SearchResponse: Decodable{
    let kind: String
    let items: [SearchResult]?
    // you can include other fields if you need them (url, queries, searchInformation, etc)
}

// Individual result in the items array
struct SearchResult: Decodable, Identifiable {
    let id: UUID = UUID()
    let kind: String
    let title: String
    let htmlTitle: String
    let link: String
    let displayLink: String
    let snippet: String?
    let htmlSnippet: String
    let cacheId: String?
    let formattedUrl: String?
    let htmlFormattedUrl: String?
    let fileFormat: String?
    let mime: String?
    let image: SearchImage?
    enum CodingKeys: String, CodingKey {
        case kind, title, htmlTitle, link, displayLink, snippet, htmlSnippet, cacheId, formattedUrl, htmlFormattedUrl, fileFormat, mime, image
    }
}

// Nested image object for SearchResult
struct SearchImage: Decodable {
    let height: Int?
    let thumbnailLink: String?
    let thumbnailWidth: Int?
    let width: Int?
    let byteSize: Int?
    let contextLink: String?
    let thumbnailHeight: Int?
}
