//
//  AddFood.swift
//  VitaTrack
//
//  Created by serena on 20/3/2025.
//

import Foundation

enum AddFoodCategory: String, Codable, CaseIterable {
    case vegetables = "vegetables"
    case fruits = "fruits"
    case grains = "grains"
    case meat = "meat"
    case dairy = "dairy"
    case extras = "extras"
    
    var displayName: String {
        switch self {
        case .vegetables: return "Vegetables"
        case .fruits: return "Fruits"
        case .grains: return "Grains"
        case .meat: return "Meat"
        case .dairy: return "Dairy"
        case .extras: return "Extras"
        }
    }
}
