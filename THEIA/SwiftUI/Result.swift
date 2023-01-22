//
//  Result.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct Result: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.02
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.02
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667 * 2
    
    
    //Button height ratio with respect to height
    var layerHeightRatio : Double = 0.10
    
    
    var results: Results
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(results.testType).font(.system(size: 24, weight: .semibold))
                .padding(.top, UIScreen.screenHeight * verticalSpacingRatio)
            Text(results.testDate).font(.system(size: 16, weight: .semibold)).foregroundColor(Color.gray)
            
            HStack{
                Spacer()
            }
            
            if results.annotated {
                Text("Annotated").font(.system(size: 16, weight: .bold)).underline().padding(.bottom, UIScreen.screenHeight * verticalSpacingRatio)
            } else {
                Text("Unannotated").font(.system(size: 16, weight: .bold)).underline().padding(.bottom, UIScreen.screenHeight * verticalSpacingRatio)
            }
            
        }.padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio * 2)
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

struct Result_Previews: PreviewProvider {
    static var previews: some View {
        
        let result = Results(testType: "RightSign Oral Test", testDate: "09-12-2022", annotated: true, controlLine: .Strong, testLine: .Weak)
        Result(results: result)
    }
}
