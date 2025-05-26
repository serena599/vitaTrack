//
//  SearchView.swift
//  RecipeSearch
//
//  Created by chris on 9/12/2024.
//

import SwiftUI

struct SearchView: View {
    @State private var viewName: String = "SearchView"
    
    @State private var receipeList: [String] = []
    @State private var searchText = ""
    @State private var searhIsActive: Bool = false
    @State private var tabSelection: Int = 1
    @State private var hasResult: Bool = false
    
    @State var show_favorite_recipes: Bool
    
    @StateObject private var fetcher = RecipeFetcher()
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    
    var body: some View {
        NavigationStack() {
                
                VStack {
                    SearchBar(searchText: $searchText, parentViewName: $viewName, fetcher: fetcher)
                    
                    HStack(spacing: 10) {
                        Button {
                            if tabSelection == 1 {
                                return
                            }
                            
                            tabSelection = 1
                            
                            show_favorite_recipes = false
                            fetcher.fetchRecipes()
                            
                        } label: {
                            if tabSelection == 1 {
                                Text("Recommendation").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.white)
                                    .background(
                                        Capsule()
                                            .stroke(Color.foodPrimary, lineWidth: 0.8)
                                            .background(Color.foodPrimary)
                                    )
                                    .clipShape(Capsule())
                            } else {
                                Text("Recommendation").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.black)
                                
                            }
                        }
                        
                        Button {
                            if tabSelection == 2 {
                                return
                            }
                            
                            tabSelection = 2
                            
                            show_favorite_recipes = true
                            
                            if favoriteManager.currentUserID > 0 {
                                fetcher.fetchFavoriteRecipes(userID: favoriteManager.currentUserID)
                            } else {
                                DispatchQueue.main.async {
                                    fetcher.recipes = []
                                }
                            }
                            
                        } label: {
                            if tabSelection == 2 {
                                Text("My favorite").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.white)
                                    .background(
                                        Capsule()
                                            .stroke(Color.foodPrimary, lineWidth: 0.8)
                                            .background(Color.foodPrimary)
                                    )
                                    .clipShape(Capsule())
                            } else {
                                Text("My favorite").font(.headline)
                                    .frame(maxWidth: 170, maxHeight: 40)
                                    .foregroundColor(.black)
                            }
                        }
                        
                    }
                    .tint(Color.gray)
                    .frame(height: 40)
                    
                    RecipeList(fetcher: fetcher, show_favorite_recipes: $show_favorite_recipes)
                        .onAppear() {
                            if !fetcher.recipes.isEmpty {
                                return
                            }
                            if !show_favorite_recipes {
                                fetcher.fetchRecipes()
                            }
                        }
                }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .onAppear {
            if favoriteManager.currentUserID > 0 {
                favoriteManager.fetchUserFavorites()
            }
        }
    }
}

#Preview {
    SearchView(show_favorite_recipes: false)
}
