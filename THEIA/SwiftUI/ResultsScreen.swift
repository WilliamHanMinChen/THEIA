//
//  ResultsScreen.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import SwiftUI

struct ResultsScreen: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.03
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.1792656587
    
    var buttonWidthRatio : Double = 0.8621495327
    
    //State indicating which filter the user is applying
    @State var filter = "All"
    
    var filters = ["All", "Annotated", "Unannotated"]
    
    
    //All results
    var allResults : [Results] = [
        Results(testType: "RightSign Oral Test", testDate: "09-12-2022", annotated: false, controlLine: .Strong, testLine: .Weak),
        Results(testType: "RightSign Oral Test", testDate: "07-12-2022", annotated: true, controlLine: .Strong, testLine: .Strong),
        Results(testType: "RightSign Nasal Test", testDate: "01-12-2022", annotated: true, controlLine: .Strong, testLine: .NotPresent),
        Results(testType: "RightSign Oral Test", testDate: "09-11-2022", annotated: true, controlLine: .Strong, testLine: .NotPresent),
        Results(testType: "RightSign Oral Test", testDate: "09-09-2022", annotated: true, controlLine: .Strong, testLine: .Weak)]
    
    
    //Modify the segmented control appearance
    init(){
        
        UISegmentedControl.appearance().selectedSegmentTintColor = .clear
        
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.primary), .font: UIFont.systemFont(ofSize: 16, weight: .heavy)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.secondary), .font: UIFont.systemFont(ofSize: 16, weight: .regular)], for: .normal)
        
    }
    
    var body: some View {
        
        ScrollView(.vertical){
            VStack(alignment: .leading){
                //Title
                Text("Results").font(.system(size: 32, weight: .bold)).padding(.top, 0).padding()
                
                Picker("", selection: $filter){
                    ForEach(filters, id: \.self){
                        Text($0)
                    }
                }.pickerStyle(.segmented).padding()
                
                ForEach(getResults()) { results in                    Result(results: results)
                }
                
            }
        }.background(Color.init(hex: "FAFAFA"))
    }

    
    func getResults() -> [Results]{
        var filteredResults : [Results] = []
        
        //Depending on the picker index we display different list
        if filter == "All"{
            filteredResults = allResults
        } else if filter == "Annotated" {
            for result in allResults {
                if result.annotated{
                    filteredResults.append(result)
                }
            }
        } else {
            for result in allResults {
                if !result.annotated{
                    filteredResults.append(result)
                }
            }
            
        }
        return filteredResults
    }
    
    
}

struct ResultsScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let result = Results(testType: "RightSign Oral Test", testDate: "09-12-2022", annotated: false, controlLine: .Strong, testLine: .Weak)
        
        let result2 = Results(testType: "RightSign Oral Test", testDate: "07-12-2022", annotated: true, controlLine: .Strong, testLine: .Strong)
        
        
        let result3 = Results(testType: "RightSign Nasal Test", testDate: "01-12-2022", annotated: true, controlLine: .Strong, testLine: .NotPresent)
        
        let result4 = Results(testType: "RightSign Oral Test", testDate: "09-11-2022", annotated: true, controlLine: .Strong, testLine: .NotPresent)
        
        
        let result5 = Results(testType: "RightSign Oral Test", testDate: "09-09-2022", annotated: true, controlLine: .Strong, testLine: .Weak)
        
        
        var allResults : [Results] = [result, result2, result3, result4, result5]
        
        
        
        ResultsScreen()
        
    }
}
