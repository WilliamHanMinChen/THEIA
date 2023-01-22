//
//  ItemSetup.swift
//  COVIDGuide
//
//  Created by William Chen on 2022/12/13.
//

import UIKit

//Helper function to setup items that can be scanned
extension BarcodeScannerViewController{
    
    
    //Setup the items
    func itemSetup(){
        
        //Item object
        var kitkat = Item()
        
        kitkat.name = "Nestle KitKat"
        kitkat.itemDescription = "Break off a finger of the iconic original KitKat Milk Chocolate Bar when you next need a break. Just unwrap, snap and savour the deliciously smooth milk chocolate. 2 crisp batch baked wafer fingers, smothered in rich milk chocolate Made with 100% certified sustainable cocoa"
        kitkat.ingredients = "Sugar, Milk Solids, Wheat Flour, Cocoa Butter^, Vegetable Fat Emulsifier ( Soy Lecithin), Cocoa Mass^, Choc Paste ( Milk, Wheat, Soy ), Emulsifiers ( Soy Lecithin, 476), Cocoa^, Raising Agent (Sodium Bicarbonate), Salt, Yeast, Processing Aid ( Wheat ), Flavour. Contains Milk, Wheat, Gluten, Soy. May Contain Tree Nuts. Product Contains 67% Milk Chocolate and 33% Wafer Fingers. Milk Chocolate Contains Minimum 22% Cocoa Solids, 25% Milk Solids. ^ Rainforest Alliance Certified Tm Cocoa. Find Out More at Ra.Org."
        kitkat.healthStarRating = 0.5
        
        //Setup the nutrition infromation
        let nutritionPerServing = NutritionInformation(energy: 370, protein: 1.2, fat:4.6, saturatedFat: 2.6, carbohydrate: 10.4, sugars: 8.6, sodium: 14)
        
        let nutritionPer100 = NutritionInformation(energy: 2170, protein: 6.8, fat: 27.1, saturatedFat: 15.5, carbohydrate: 61.1, sugars: 50.8, sodium: 80)
        
        kitkat.nutritionInformationPerServing = nutritionPerServing
        kitkat.nutritionInformationPer100 = nutritionPer100
        
        //Setup the contact information
        let contactInformation = ContactInformation(address: "1 Homebush Bay Dr, Rhodes NSW 2138, Australia", phoneNumber: ["Australia" : "1800025361", "New Zealand" : "0800830840"], website: "www.nestle.com.au")
        
        kitkat.contactInformation = contactInformation
        
        
        
        
        
        
        
    }
    
    
    
    
}
