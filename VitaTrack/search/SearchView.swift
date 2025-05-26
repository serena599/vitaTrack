//
//  SearchView.swift
//  RecipeSearch
//
//  Created by chris on 9/12/2024.
//

import SwiftUI

struct SearchView: View {
    //@State var selectedRecipe: Recipe = Recipe(title: "", image: Image("ImagePlaceholder"))
    
    @State private var viewName: String = "SearchView"
    
    @State private var receipeList: [String] = []
    @State private var searchText = ""
    @State private var searhIsActive: Bool = false
    @State private var tabSelection: Int = 1
    @State private var hasResult: Bool = false
    
    
    @State var show_favorite_recipes: Bool
    
    //test code, initial a recipe list
//    @State var recommend_recipes: [Recipe] = []
    
    // Instance to handle requests and get database data from node.js
    @StateObject private var fetcher = RecipeFetcher()
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    
    var body: some View {
        
        // send request to get recommendation recipe list
        //recommend_recipes = fetcher.recipes
        
        //ScrollView {
  
        NavigationStack() {
                
                VStack {
                    // search bar
                    SearchBar(searchText: $searchText, parentViewName: $viewName, fetcher: fetcher)
                    
                    // debuug for navigation
                    //Text("\(tabSelection) is selected")
                    
                    // meal navigation
                    HStack(spacing: 10) {
                        // meal lists navigation tabs (4)
                        
                        //Recommendation
                        Button {
                            // Already in recommendation tab, do nothing
                            if tabSelection == 1 {
                                return
                            }
                            
                            // Switch to recommendation tab
                            tabSelection = 1
                            
                            // Switch to recommendation list and fetch all recipes
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
                        
                        
                        //My favorite
                        Button {
                            // Already in favorite tab, do nothing
                            if tabSelection == 2 {
                                return
                            }
                            
                            // Switch to favorites tab
                            tabSelection = 2
                            
                            // Switch to favorites view
                            show_favorite_recipes = true
                            
                            // Get details of user's favorite recipes from server
                            if favoriteManager.currentUserID > 0 {
                                // Fetch the favorite recipes directly
                                fetcher.fetchFavoriteRecipes(userID: favoriteManager.currentUserID)
                            } else {
                                print("Warning: No logged in user, cannot fetch favorites data")
                                // Clear recipes if not logged in
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
                            //.cornerRadius(100)
                        }
                        
                    }
                    .tint(Color.gray)
                    .frame(height: 40)
                    //.padding(.top, 10)
                    //.border(Color.red)
                    //ScrollView {
                    
                    RecipeList(fetcher: fetcher, show_favorite_recipes: $show_favorite_recipes)
                        .onAppear() {
                            // Initial load only - this will be handled by RecipeList's own onAppear
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
            // No longer need to set hardcoded user ID, FavoriteManager now gets it from UserManager
            // If needed, favorite data refresh can still be triggered
            if favoriteManager.currentUserID > 0 {
                favoriteManager.fetchUserFavorites()
            }
        }
    }
}

#Preview {
    SearchView(show_favorite_recipes: false)
}
