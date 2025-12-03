//
//  BennySpeakApp.swift
//  BennySpeak
//
//  Created by James Lane on 11/11/25.
//

import SwiftUI

@main
struct BennySpeakApp: App {
    var body: some Scene {
        WindowGroup {
            ImagesView()
                .onAppear {
                    if  CommandLine.arguments.contains("-isPerformanceTest") {
                        JLAnalytics.shared.markStartTime(for: "ScreenLoadTime")
                    }
                }
        }
    }
}
