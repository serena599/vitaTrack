import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: FoodViewModel
    
    let mealType: MealType
    let editingFood: FoodItem?
    
    @State private var name: String = ""
    @State private var amount: Double = 1.0
    @State private var unit: String = "serving"
    @State private var calories: Int = 0
    @State private var selectedCategory: AddFoodCategory = .vegetables
    
    init(mealType: MealType, editingFood: FoodItem? = nil) {
        self.mealType = mealType
        self.editingFood = editingFood
        
        if let food = editingFood {
            _name = State(initialValue: food.name)
            _calories = State(initialValue: food.calories)
            _unit = State(initialValue: food.unit)
            _amount = State(initialValue: food.amount ?? 1.0)
            _selectedCategory = State(initialValue: food.addFoodCategory ?? .vegetables)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                
                Spacer()
                
                Text(editingFood == nil ? "Add Food" : "Edit Food")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    saveFood()
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
            }
            .padding()
            .background(Color.foodPrimary)
            
            ScrollView {
                VStack(spacing: 20) {
               
                    VStack(alignment: .leading) {
                        Text("Food Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextField("Enter food name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                  
                    VStack(alignment: .leading) {
                        Text("Amount")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            TextField("Enter amount", value: $amount, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                            
                            Picker("Unit", selection: $unit) {
                                Text("serving").tag("serving")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 120)
                        }
                    }
                    .padding(.horizontal)
                    
           
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        HStack {
                            TextField("Enter calories", value: $calories, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                            Text("kcal")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Food Category")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(AddFoodCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
    
    private func saveFood() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              calories > 0 else {
            return
        }
        
        if let existingFood = editingFood {
            debugPrint("Editing existing food with serverId:", existingFood.serverId ?? "nil")
            
            guard let serverId = existingFood.serverId else {
                debugPrint("Error: Cannot update food without serverId")
                return
            }
            
            let updatedFood = FoodItem(
                id: existingFood.id,
                serverId: serverId,
                recordId: existingFood.recordId,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                calories: calories,
                unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                mealType: existingFood.mealType,
                date: existingFood.date,
                imageUrl: existingFood.imageUrl,
                addFoodCategory: selectedCategory
            )
            
            Task {
                await viewModel.updateFood(updatedFood)
                await viewModel.loadFoods()
                dismiss()
            }
        } else {
            let newFood = FoodItem(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                calories: calories,
                unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: amount,
                mealType: mealType,
                date: viewModel.selectedDate,
                addFoodCategory: selectedCategory
            )
            
            Task {
                await viewModel.addFood(newFood)
                await viewModel.loadFoods()
                dismiss()
            }
        }
    }
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        AddFoodView(mealType: .breakfast)
            .environmentObject(FoodViewModel())
    }
}
