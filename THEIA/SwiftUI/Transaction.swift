//
//  Transaction.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct TransactionUI: View {
    
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.02
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.02
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667 * 2
    
    
    //Button height ratio with respect to height
    var layerHeightRatio : Double = 0.10
    
    
    var transaction: TransactionObject
    
    
    var body: some View {

        
        
        VStack {
            HStack(alignment: .center){
                VStack(alignment: .leading) {
                    Text(transaction.testType).font(.system(size: 24, weight: .semibold))
                        .padding(.top, UIScreen.screenHeight * verticalSpacingRatio)
                    Text(transaction.transactionDate).font(.system(size: 16, weight: .semibold)).foregroundColor(Color.gray)
                        .padding(.bottom, UIScreen.screenHeight * verticalSpacingRatio)
                }
                
                Spacer()
                
                Text(transaction.cost).font(.system(size: 32, weight: .bold))
            }
        }
        .padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio * 2)
        .padding(.trailing, UIScreen.screenWidth / horizontalSideSpacingRatio * 2)
        .frame(minHeight: UIScreen.screenHeight * layerHeightRatio).background(
            //Shadow
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 3, y: 2)
                .padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio)
                .padding(.trailing, UIScreen.screenWidth / horizontalSideSpacingRatio)
        )
        
    }
    
}

struct Transaction_Previews: PreviewProvider {
    static var previews: some View {
        
        let transaction = TransactionObject(transactionDate: "09-12-2022", cost: "20c", testType: "RightSign Nasal Swab")
        
        TransactionUI(transaction: transaction)
    }
}
