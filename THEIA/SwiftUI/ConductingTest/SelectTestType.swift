//
//  SelectTestType.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct SelectTestType: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.03
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.1792656587
    
    var buttonWidthRatio : Double = 0.8621495327
    

    var body: some View {
        
        ScrollView(.vertical){
            VStack(alignment: .leading, spacing: UIScreen.screenHeight * verticalSpacingBetweenElementsRatio){
                //Title
                Text("Select test type").font(.system(size: 32, weight: .bold)).padding(.top, 0)
                
                HStack{
                    Spacer()
                }
                //Instructions text
                let instructionsText = """
Place the outside box of the test on a flat surface and display its different sides in turn to the camera. The camera will attempt to pick up the bar-code.
"""
                Text(instructionsText).font(.system(size: 16, weight: .semibold))
                
                
                
            }.padding(.leading).padding(.trailing)
        }.background(Color.init(hex: "FAFAFA")).padding(.leading, 0).padding(.trailing, 0)
    }
}

struct SelectTestType_Previews: PreviewProvider {
    static var previews: some View {
        SelectTestType()
    }
}
