//
//  HomeScreen.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI



//Create a UIHostingController class that hosts your SwiftUI view
class HomeScreenViewHostingController: UIHostingController<HomeScreen> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: HomeScreen())
    }
}


struct HomeScreen: View {
    
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
        
        NavigationView{
            VStack(alignment: .leading,spacing: UIScreen.screenHeight * verticalSpacingBetweenElementsRatio){
                HStack(alignment: .center){
                    
                    //Title
                    Text(getTitle()).font(.system(size: 32, weight: .bold)).padding(.top, 0)

                    //Add spacer to add space between elements
                    Spacer()
                    
                    
                    NavigationLink{
                        Profile()
                    } label: {
                        Image("profile")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }

                }.padding(.top, UIScreen.screenHeight * verticalSpacingRatio)
                
                Text("What would you like to do today?").font(.system(size: 20, weight: .semibold))
                
                
                //Buttons
                NavigationLink{
                    ConductTestOnBoarding()
                } label: {
                    Text("Conduct a test").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                        .background(
                            //Shadow
                            RoundedRectangle(cornerRadius: (15))
                                .fill(Color.white)
                                .shadow(radius: 2, y: 2.2)
                        ).foregroundColor(Color.black)
                        .font(.system(size: 24, weight: .semibold))
                }
                
                //Buttons
                NavigationLink{
                    ResultsScreen()
                } label: {
                    Text("View results").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                        .background(
                            //Shadow
                            RoundedRectangle(cornerRadius: (15))
                                .fill(Color.white)
                                .shadow(radius: 2, y: 2.2)
                        ).foregroundColor(Color.black)
                        .font(.system(size: 24, weight: .semibold))
                }
                
                
                
                NavigationLink{
                    BarcodeScanning()
                } label: {
                    Text("FAQ").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
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
            

            
        }.tint(Color.black)
    }
    
    func getTitle() -> String{
        let currentDateTime = Date()
        //Get the current time
        let hour = Calendar.current.component(.hour, from: currentDateTime)
        
        var displayString = ""
        
        if hour < 12 && hour > 5 {
            displayString = "Good morning"
        } else if hour < 18 {
            displayString = "Good afternoon"
        } else {
            displayString = "Good evening"
        }
        
        return displayString
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
