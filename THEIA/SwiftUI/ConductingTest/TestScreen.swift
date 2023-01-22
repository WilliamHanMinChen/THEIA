//
//  TestScreen.swift
//  THEIA
//
//  Created by William Chen on 2023/1/6.
//

import SwiftUI

struct TestScreen: View {
    
    @Binding var ShouldProceed: Bool
    
    var body: some View {
        Text("test").onAppear{
            self.ShouldProceed = false
        }
    }
}

//struct TestScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TestScreen(ShouldProceed: false)
//    }
//}
