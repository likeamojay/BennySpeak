//
//  ImagesViewModel.swift
//  BennySpeak
//
//  Created by James on 11/11/25.
//

import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var results: [SearchResult] = []
    @Published var isBusy = false
    @Published var errorString = ""

    // TODO: Add Pagination support

    func search(query: String) async {
        guard var components = URLComponents(string: kApiUrl) else { return }

        let queryParams = [URLQueryItem(name: "key", value: googleApiKey), URLQueryItem(name: "cx", value: googleSearchEngineId), URLQueryItem(name: "lr", value: "lang_es"), URLQueryItem(name: "q", value: query), URLQueryItem(name: "searchType", value: "image"), URLQueryItem(name: "safe", value: "active")]
        components.queryItems = queryParams

        guard let url = components.url else { return }

        let request = URLRequest(url: url)
        
        isBusy = true
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            isBusy = false
            guard let httpResponse = response as? HTTPURLResponse else {
                errorString = "HTTP Error unknown"
                return
            }
            if httpResponse.statusCode != 200 {
                errorString = "HTTP Error \(httpResponse.statusCode)"
                return
            }
            if  CommandLine.arguments.contains("-isPerformanceTest") {
                JLAnalytics.shared.markStartTime(for: "APICallDuration")
            }
            let json = try JSONDecoder().decode(SearchResponse.self, from: data)
            if  CommandLine.arguments.contains("-isPerformanceTest") {
                JLAnalytics.shared.markStopTime(for: "APICallDuration")
            }
            if  CommandLine.arguments.contains("-isFinalPerformanceRun") {
                JLAnalytics.shared.saveReport()
            }
            
            if let items = json.items {
                results += items
            } else {
                errorString = "No items in response"
            }
        } catch let error {
            errorString = "\(error)"
        }
    }
    
}
