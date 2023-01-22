//
//  ConductTestOnBoarding.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct ConductTestOnBoarding: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.007
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.1
    
    var buttonWidthRatio : Double = 0.8621495327
    
    var body: some View {
        ScrollView(.vertical){
            
            
            VStack(alignment: .leading){
                
                //Title
                Text("Conduct a test").font(.system(size: 32, weight: .bold)).padding(.top, 0)
                
                Text("Before you start").font(.system(size: 24, weight: .semibold)).padding(.top, UIScreen.screenHeight * verticalSpacingBetweenElementsRatio)
                
                Text("Important Information:").font(.system(size: 16, weight: .semibold)).underline().padding(.top, UIScreen.screenHeight * verticalSpacingBetweenElementsRatio)
        
                
                let importantInformationString =
                """
    \u{2022} This app provides a general guideline of instructions intended to guide you through the process of conducting a point-of-care self-test.
    \u{2022} The guidelines provided are not a direct copy of the instructions in the manufacturer’s manual, and instead provides paraphrased instructions for ease of use.
    \u{2022} By continuing beyond this point, you agree that THEIA will not be held liable for any misinterpretations that may occur with the instructions.
    """
                
                Text(importantInformationString).font(.system(size: 16)).padding(.top,UIScreen.screenHeight * verticalSpacingBetweenElementsRatio).padding(.leading, 10)
                
                
                Text("Results Capturing:").font(.system(size: 16, weight: .semibold)).underline().padding(.top, UIScreen.screenHeight * verticalSpacingBetweenElementsRatio)
                
                let resultsCapturingString =
                """
    \u{2022} After you conduct the test, the app will guide you to photograph the results.
    \u{2022} The results can then be either anonymously sent to our human annotators for annotation or be shared with a contact of your choice for them to tell you your results.
    """
                
                Text(resultsCapturingString).font(.system(size: 16)).padding(.top,UIScreen.screenHeight * verticalSpacingBetweenElementsRatio).padding(.leading, 10)
                
                
                Button{
                    print("Next step button pressed")
                } label: {
                    
                    Text("Next Step").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                        .background(
                            //Shadow
                            RoundedRectangle(cornerRadius: (15))
                                .fill(Color.white)
                                .shadow(radius: 2, y: 2.2)
                        ).foregroundColor(Color.black)
                        .font(.system(size: 24, weight: .semibold))
                }.padding(.top, UIScreen.screenHeight * verticalSpacingBetweenElementsRatio * 4)
                
                
                Spacer()
                
            }
                .padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio)
                .padding(.trailing, UIScreen.screenWidth / horizontalSideSpacingRatio)
            
                
                
            
        }.background(Color(hex: "F9F9F9"))
    }
}

struct ConductTestOnBoarding_Previews: PreviewProvider {
    static var previews: some View {
        ConductTestOnBoarding()
    }
}
