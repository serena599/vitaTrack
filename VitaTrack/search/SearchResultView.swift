//
//  SearchResultView.swift
//  RecipeSearch
//
//  Created by chris on 14/12/2024.
//

import SwiftUI

struct SearchResultView: View { 
    @Binding var searchText: String
    
    @State private var viewName: String = "SearchResultView"
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.dismiss) var dismiss
    
    
    //Observe external RecipeFetcher, which gets data from SearchBar's searchFetcher
    @ObservedObject var fetcher: RecipeFetcher
    
    var body: some View {
        
        //Custom navigation bar, using Serana's code for consistent format
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
            }
            
            Text("Search")
                .foregroundColor(.white)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(Color.foodPrimary)
        
        // Search results interface
        VStack(spacing: 0) {

            // Search bar
            SearchBar(searchText: $searchText, parentViewName: $viewName, fetcher: fetcher)

            // Get search results
            if !fetcher.recipes.isEmpty {
                List($fetcher.recipes, id: \.recipe_name) { $recipe in

                        HStack(spacing: 10) {
                            NavigationLink(destination: RecipeDetail(recipeToDisplay: recipe)){
                                
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
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    //HStack {
                                    Text(recipe.recipe_name)
                                        .lineLimit(2)
                                    
                                    Text(recipe.short_instruction ?? "")
                                        .foregroundStyle(.secondary)
                                        .font(.system(size: 15))
                                        .lineLimit(2)
                                }
                            }
                            
                            Spacer()

                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)) // Customize left and right margins
                        .background(Color.searchResultBackground)
                        .cornerRadius(15)
                        .overlay {
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Image(systemName: recipe.is_recommend ? "suit.heart.fill" : "suit.heart")
                                        .imageScale(.large)
                                        .tint(Color.foodPrimary)
                                        .foregroundStyle(Color.foodPrimary)
                                        .onTapGesture {
                                            recipe.is_recommend.toggle()
                                            
                                            // identify if the current recipe is already added to user's favourate
                                            
                                            // to do: add to user's favourate recipes list ..............
                                            
                                        }
                                        .padding(5)
                                    
                                    Spacer()
                                }
                                .background(Color.searchResultBackground)

                        }
                        //.border(Color.red)
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                // If search results are empty, display no results image
                Image("NoResult")
                //.border(Color.red)
                
                Spacer()
            }
        }
        .onAppear {
            fetcher.searchRecipes(searchQuery: searchText) // Avoid having no data
        }
//        .safeAreaInset(edge: .top, spacing: 0) { // Custom top safe area
//            Color.clear.frame(height: 0) // Simulate a 0-point safe area
//        }
//        .navigationBarTitleDisplayMode(.inline) //Remove navigationTitle and its occupied space
        .navigationBarBackButtonHidden(true) // Hide default back button
    }
}

#Preview {
    @Previewable @State var searchText: String = ""
    @Previewable @State var hasResult: Bool = true
    @Previewable @State var fetcher: RecipeFetcher! = nil
    
    SearchResultView(searchText: $searchText, fetcher: fetcher)
}
