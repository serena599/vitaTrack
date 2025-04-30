import SwiftUI

struct NutritionGoalView2: View {
    @State private var name: String = ""
    @State private var age: Int = 25
    @State private var gender: String = "- Select -"
    @State private var status: String = "None"
    @State private var nutritionAdvice: [String: String] = [:]
    @State private var showGoalSettingView: Bool = false
    
    let genders = ["- Select -", "Male", "Female", "Other"]
    let statuses = ["None", "Pregnant", "Breastfeeding"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name (Optional)", text: $name)
                    Stepper("Age: \(age)", value: $age, in: 10...100)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("User Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Button(action: {
                        submitForm()
                        showGoalSettingView = true
                    }){
                        Text("Submit")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .background(Color.loginGreen)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("").padding(6)
            .background(
                NavigationLink(
                    destination: GoalSettingView(
                        vegetables: nutritionAdvice["Vegetables and legumes"] ?? "5",
                        fruits: nutritionAdvice["Fruit"] ?? "2",
                        grains: nutritionAdvice["Grains (cereal)"] ?? "6",
                        meat: nutritionAdvice["Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans"] ?? "2.5",
                        dairy: nutritionAdvice["Milk, yoghurt, cheese and alternatives"] ?? "2.5",
                        extras: nutritionAdvice["Allowance for additional serves from any food group*"] ?? "0"
                    ),
                    isActive: $showGoalSettingView
                ) {
                    EmptyView()
                }
            )
        }
    }

    func submitForm() {
        nutritionAdvice = calculateNutritionServes(age: age, gender: gender, status: status)
        print("User Info Submitted: Name: \(name), Age: \(age), Gender: \(gender), Status: \(status)")
    }
    
    func calculateNutritionServes(age: Int, gender: String, status: String) -> [String: String] {
        var serves: [String: String] = [:]
        
        if 1 <= age && age <= 2 {
            serves = [
                "Vegetables and legumes": "2-3",
                "Fruit": "0.5",
                "Grains (cereal)": "4",
                "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "1",
                "Milk, yoghurt, cheese and alternatives": "1-1.5",
                "Allowance for additional serves from any food group*": "0",
            ]
        } else if 2 <= age && age <= 3 {
            serves = [
                "Vegetables and legumes": "2.5",
                "Fruit": "1",
                "Grains (cereal)": "4",
                "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "1",
                "Milk, yoghurt, cheese and alternatives": "1.5",
                "Allowance for additional serves from any food group*": "0-1",
            ]
        } else if 4 <= age && age <= 8 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "4.5",
                    "Fruit": "1.5",
                    "Grains (cereal)": "4",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "1.5",
                    "Milk, yoghurt, cheese and alternatives": "2",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "4.5",
                    "Fruit": "1.5",
                    "Grains (cereal)": "4",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "1.5",
                    "Milk, yoghurt, cheese and alternatives": "1.5",
                    "Allowance for additional serves from any food group*": "0-1",
                ]
            }
        } else if 9 <= age && age <= 11 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "5",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "2.5",
                    "Allowance for additional serves from any food group*": "0-3",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "4",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "3",
                    "Allowance for additional serves from any food group*": "0-3",
                ]
            }
        } else if 12 <= age && age <= 13 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "5.5",
                    "Fruit": "2",
                    "Grains (cereal)": "6",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "3.5",
                    "Allowance for additional serves from any food group*": "0-3",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "5",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "3.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        } else if 14 <= age && age <= 18 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "5.5",
                    "Fruit": "2",
                    "Grains (cereal)": "7",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "3.5",
                    "Allowance for additional serves from any food group*": "0-5",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "7",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "3.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        } else if 19 <= age && age <= 50 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "6",
                    "Fruit": "2",
                    "Grains (cereal)": "6",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "3",
                    "Milk, yoghurt, cheese and alternatives": "2.5",
                    "Allowance for additional serves from any food group*": "0-3",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "6",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "2.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        } else if 51 <= age && age <= 70 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "5.5",
                    "Fruit": "2",
                    "Grains (cereal)": "6",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "2.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "4",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2",
                    "Milk, yoghurt, cheese and alternatives": "4",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        } else if age > 70 {
            if gender == "Male" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "4.5",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "3.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            } else if gender == "Female" {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "3",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2",
                    "Milk, yoghurt, cheese and alternatives": "4",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        }

        if status == "Pregnant" {
            if age < 18 {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "8",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "3.5",
                    "Milk, yoghurt, cheese and alternatives": "3.5",
                    "Allowance for additional serves from any food group*": "0-3",
                ]
            } else {
                serves = [
                    "Vegetables and legumes": "5",
                    "Fruit": "2",
                    "Grains (cereal)": "8.5",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "3.5",
                    "Milk, yoghurt, cheese and alternatives": "2.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        } else if status == "Breastfeeding" {
            if age < 18 {
                serves = [
                    "Vegetables and legumes": "5.5",
                    "Fruit": "2",
                    "Grains (cereal)": "9",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "4",
                    "Allowance for additional serves from any food group*": "0-3",
                ]
            } else {
                serves = [
                    "Vegetables and legumes": "7.5",
                    "Fruit": "1",
                    "Grains (cereal)": "9",
                    "Lean meat, fish, poultry, eggs, nuts, seeds, legumes, beans": "2.5",
                    "Milk, yoghurt, cheese and alternatives": "2.5",
                    "Allowance for additional serves from any food group*": "0-2.5",
                ]
            }
        }

        return serves
    }
}

struct NutritionGoalView2_Previews: PreviewProvider {
    static var previews: some View {
        NutritionGoalView2()
    }
}

