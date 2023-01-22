//
//  TopUp.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct TopUp: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.03
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.08
    
    var buttonWidthRatio : Double = 0.8621495327
    
    var body: some View {
        VStack(alignment: .leading,spacing: UIScreen.screenHeight * verticalSpacingBetweenElementsRatio){
            
            //Title
            Text("Top up").font(.system(size: 32, weight: .bold)).padding(.top, 0)
            
            
            //Buttons
            Button{
                print("$2 button pressed")
            } label: {
                
                Text("$2").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
            }
            
            Button{
                print("$4 button pressed")
            } label: {
                
                Text("$4").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
            }
            
            
            Button{
                print("$6 button pressed")
            } label: {
                
                Text("$6").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
            }
            
            Button{
                print("$8 button pressed")
            } label: {
                
                Text("$8").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
            }
            
            Button{
                print("$10 button pressed")
            } label: {
                
                Text("$10").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
            }
            
            
            Spacer()
            
        }
            .padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio)
            .padding(.trailing, UIScreen.screenWidth / horizontalSideSpacingRatio)
            .background(Color(hex: "F9F9F9"))
            
            
    }
    
}

struct TopUp_Previews: PreviewProvider {
    static var previews: some View {
        TopUp()
    }
}
