//
//  ContactUs.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct ContactUs: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.02
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.10
    
    var buttonWidthRatio : Double = 0.8621495327
    

    
    var body: some View {
        
        VStack(alignment: .leading, spacing: UIScreen.screenHeight * verticalSpacingBetweenElementsRatio){
            
            //Title
            Text("Contact Us").font(.system(size: 32, weight: .bold)).padding(.top, 0)
            
            Text("Creators: ").font(.system(size: 24, weight: .semibold))
            
            
            let william = """

William Chen

Email:

hche0162@student.monash.edu
"""
            Text(william).font(.system(size: 20))
            
            let erika = """

Erika Lay

Email:

elay0001@student.monash.edu
"""
            Text(erika).font(.system(size: 20))
            
            HStack{
                Spacer()
            }
            
            
            
            Button {
                print("Share the app pressed")
                
            } label: {
                Text("Share the app").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
            }
            
            Spacer()
            
            
        }.padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio)
            .padding(.trailing, UIScreen.screenWidth / horizontalSideSpacingRatio)
            .background(Color(hex: "F9F9F9"))
        
        
        
        
        
        
    }
    
    
}

struct ContactUs_Previews: PreviewProvider {
    static var previews: some View {
        ContactUs()
    }
}
