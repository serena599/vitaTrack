//
//  RecipeList.swift
//  RecipeSearch
//
//  Created by chris on 13/12/2024.
//

import SwiftUI

struct RecipeList: View {
    @State private var infoText = ""
    
    // Observe external RecipeFetcher data. When RecipeFetcher instance gets data, it provides Recipes array from database: fetcher.recipes. See RecipeFetcher class file for details
    @ObservedObject var fetcher: RecipeFetcher
    
    //Binding var show_favorite_recipes in SearchView
    @Binding var show_favorite_recipes: Bool
    
    //@Binding var selectedRecipe: Recipe in RecipeDetail
    @State var recipeToDisplay: Recipe?
    
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    
    //test code, for logics testing.
    /*
    let recipes: [Recipe] = [
        Recipe(recipe_ID: 1, recipe_name: "Grilled Meat and Egg Salad with Avocado", image_URL: "https://i2.chuimg.com/d7cb9c0430e34c69aca5f4ac7a2994a6_606w_404h.jpg", traffic_lights: ["Saturates": "green", "Salt": "green", "Surgar": "yellow", "Fat": "yellow"]),
        Recipe(recipe_ID: 2, recipe_name: "recipe2", image_URL: "12312312.jpg"),
        Recipe(recipe_ID: 3, recipe_name: "recipe3", image_URL: ""),
        Recipe(recipe_ID: 4, recipe_name: "recipe4", image_URL: ""),
        Recipe(recipe_ID: 5, recipe_name: "recipe5hvikdhkdhgksdhdkdjgh", image_URL: ""),
        Recipe(recipe_ID: 6, recipe_name: "recipe6", image_URL: ""),
        Recipe(recipe_ID: 7, recipe_name: "recipe7", image_URL: ""),
        Recipe(recipe_ID: 8, recipe_name: "recipe8", image_URL: ""),
        Recipe(recipe_ID: 9, recipe_name: "recipe9", image_URL: ""),
        Recipe(recipe_ID: 10, recipe_name: "recipe10", image_URL: "")
    ]
     */
    
    // Assume these are user's favourite recipes, when SearchView's Recommend and Favorite buttons are toggled, it will call data display here. Should actually get user database data to display, this is for logic testing
    let recipes2: [Recipe] = [
        Recipe(recipe_ID: 1, recipe_name: "Grilled Meat and Egg Salad with Avocado", image_URL: "https://i2.chuimg.com/d7cb9c0430e34c69aca5f4ac7a2994a6_606w_404h.jpg", traffic_lights: ["Saturates": "green", "Salt": "green", "Surgar": "yellow", "Fat": "yellow"]),
        Recipe(recipe_ID: 2, recipe_name: "recipe2", image_URL: "12312312.jpg"),
        Recipe(recipe_ID: 3, recipe_name: "recipe3", image_URL: ""),
        Recipe(recipe_ID: 4, recipe_name: "recipe4", image_URL: ""),
        Recipe(recipe_ID: 10, recipe_name: "recipe10", image_URL: "")
    ]

    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns) {
                // First filter out user's favorite recipes
                ForEach(show_favorite_recipes ? 
                         fetcher.recipes.filter { 
                             favoriteManager.userFavorites.contains($0.recipe_ID) 
                         } : 
                         fetcher.recipes, id: \.recipe_name) { recipe in
                    
                    NavigationLink(destination: RecipeDetail(recipeToDisplay: recipe)){
                        
                        VStack {
                            AsyncImage(url: URL(string: recipe.image_URL)) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFit()
                                        } else if phase.error != nil {
                                            Image("ImagePlaceholder").resizable()
                                        } else {
                                            ProgressView() // Show loading indicator
                                        }
                                    }
                                    .frame(width: 110, height: 140)
                            
                            Text(recipe.recipe_name)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .frame(maxHeight: 60)
                                .tint(Color.black)
                        }
                    }
                    //.padding(5)
                    //.border(Color.red)
                }
            }
            .padding()
        }
        .onAppear {
            if show_favorite_recipes {
                // If showing favorites page, get favorite recipes
                fetcher.fetchFavoriteRecipes(userID: favoriteManager.currentUserID)
            }
        }
    }
}

#Preview {
    //RecipeList()
}
