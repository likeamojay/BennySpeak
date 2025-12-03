//
//  ImagesView.swift
//  BennySpeak
//
//  Created by James Lane on 11/13/25.
//

import SwiftUI

struct ImagesView: View {
    
    @State private var currentPage: Int = 0
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText: String = ""
    @State private var selectedIndex = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background_alphabet")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .center) {
                    Spacer()
                    Group {
                        if !viewModel.errorString.isEmpty {
                            Text(viewModel.errorString)
                                .font(.largeTitle)
                                .foregroundStyle(.red)
                                .bold()
                                .padding()
                                .frame(maxHeight: .infinity)
                        } else if viewModel.isBusy {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .frame(width: 200, height: 200)
                                .padding()
                        } else {
                            VStack {
                                TabView(selection: $selectedIndex) {
                                    ForEach(viewModel.results) { searchResult in
                                        ImageRow(
                                            imageUrl: searchResult.link,
                                            name: searchResult.title,
                                            imageMeta: searchResult.image
                                        )
                                        .onTapGesture {
                                            Utilities.shared.speak(searchResult.title)
                                        }
                                    }
                                }
                                .tabViewStyle(.page)
                                .indexViewStyle(.page(backgroundDisplayMode: .never))
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    TextField("Search Here", text: $searchText)
                        .accessibilityLabel("search_text_field")
                        .submitLabel(.search)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 320)
                        .onSubmit(of: .text) {
                            guard !searchText.isEmpty else { return }
                            let lastIndex = self.viewModel.results.count
                            Task {
                                await viewModel.search(query: searchText)
                                await MainActor.run {
                                    self.selectedIndex = lastIndex
                                }
                            }
                        }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        searchText = ""
                        viewModel.results.removeAll()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            Task {
                await viewModel.search(query: "Ball") // Sample pre-loaded query
                if  CommandLine.arguments.contains("-isPerformanceTest") {
                    JLAnalytics.shared.markStopTime(for: "ScreenLoadTime")
                }
            }
        }
    }
}

#Preview {
    ImagesView()
}
