//
//  Item.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/12/13.
//

import UIKit


//This class serves the purpose of logging everyday utilities


enum ItemType{
    case Food

    
}

class Item: NSObject {
    
    //Name of the item
    var name: String?
    //Description of the item
    var itemDescription: String?
    //Health star rating of the item
    var healthStarRating: Double?
    //Ingredients list
    var ingredients: String?
    //Nutrition information
    var nutritionInformationPerServing: NutritionInformation?
    var nutritionInformationPer100: NutritionInformation?
    //Contact information
    var contactInformation: ContactInformation?

}



//Class for logging the contact information of an item
class ContactInformation: NSObject{
    
    //Address of the compant
    var address: String
    //Type of phone number : Phone number
    var phoneNumber: [String: String]
    //Website of the company
    var website: String
    
    init(address: String, phoneNumber: [String : String], website: String) {
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
    }
    
}


//Class for logging the nutrition information of an item

class NutritionInformation: NSObject{
    
    //Kj
    var energy: Double
    //g
    var protein: Double
    //g
    var fat: Double
    //g
    var saturatedFat: Double
    //g
    var carbohydrate: Double
    //g
    var sugars: Double
    //g
    //var dietaryFibre: Double
    //mg
    var sodium: Double
    
    init(energy: Double, protein: Double, fat: Double, saturatedFat: Double, carbohydrate: Double, sugars: Double, sodium: Double) {
        self.energy = energy
        self.protein = protein
        self.fat = fat
        self.saturatedFat = saturatedFat
        self.carbohydrate = carbohydrate
        self.sugars = sugars
        //self.dietaryFibre = dietaryFibre
        self.sodium = sodium
    }
    
}
