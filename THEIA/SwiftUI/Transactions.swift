//
//  Transactions.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct Transactions: View {
    
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.02
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.1792656587
    
    var buttonWidthRatio : Double = 0.8621495327
    
    
    //List of transactions to display
    let transaction = TransactionObject(transactionDate: "09-12-2022", cost: "20c", testType: "RightSign Nasal Swab")
    
    
    let transaction2 = TransactionObject(transactionDate: "08-12-2022", cost: "20c", testType: "RightSign Oral Swab")
    
    
    let transaction3 = TransactionObject(transactionDate: "07-12-2022", cost: "20c", testType: "RightSign Nasal Swab")
    
    
    let transaction4 = TransactionObject(transactionDate: "09-11-2022", cost: "20c", testType: "JusChek Nasal Swab")
    
    
    
    
    var body: some View {
        
        
        ScrollView(.vertical) {
            
            VStack(alignment: .leading, spacing: UIScreen.screenHeight * verticalSpacingBetweenElementsRatio){
                
                
                //Title
                Text("Transactions").font(.system(size: 32, weight: .bold)).padding(.top, 0).padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio / 2)
                
                let transactions = [transaction, transaction2, transaction3, transaction4]
                
                //Show the transactions list
                //Loop through the deals list
                ForEach(0..<transactions.count) { i in
                    
                    Transaction(transaction: transactions[i])
                }
                
                Spacer()
                
            }
            
            
        }.background(Color(hex: "F9F9F9"))
            
    }
}

struct Transactions_Previews: PreviewProvider {
    static var previews: some View {
        
        Transactions()
    }
}
