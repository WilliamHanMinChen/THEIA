//
//  BarcodeScanning.swift
//  THEIA
//
//  Created by William Chen on 2023/1/5.
//


///Storyboard ID: barcodeScaningView




import SwiftUI


struct BarcodeScanning: View {
    
    //Spacing ratio for the navigation title with respect to the height of the screen
    var verticalSpacingRatio : Double = 0.05
    
    //Spacing ratio between elements with respect to the height of the screen
    var verticalSpacingBetweenElementsRatio : Double = 0.007
    
    //Spacing ratio to the side of the screen with respect to the width of the screen
    var horizontalSideSpacingRatio : Double = 14.2666666667
    
    //Button height ratio with respect to height
    var buttonHeightRatio : Double = 0.1
    
    var buttonWidthRatio : Double = 0.8621495327
    
    
    
    
    @State var ReadRAT: RapidAntigenTest?
    
    @State var ShouldProceed: Bool = false
    
    var body: some View {
    
//        //We have read a RAT already, go to next screen
//        if let ReadRAT = ReadRAT{
//
//
//
//            NavigationLink(destination: TestScreen().transition(.slide), isActive: $ShouldProceed){ }
//
//
////            NavigationLink{
////                TestScreen()
////            } label: {
////
////            }
//
//        } else {
//            BarcodeScanningView(ReadRAT: $ReadRAT, shouldProceed: $ShouldProceed)
//        }
        
            
        VStack(alignment: .leading){
            //Title
            Text("Scan your test").font(.system(size: 32, weight: .bold)).padding(.top, 0).padding(.leading)
            
            BarcodeScanningView(ReadRAT: $ReadRAT, shouldProceed: $ShouldProceed).padding(.bottom, 200).background(Color.red)
                .padding(.bottom, 30)
            
            NavigationLink(destination: TestScreen(ShouldProceed: $ShouldProceed).transition(.slide), isActive: $ShouldProceed){ }
            
            NavigationLink{
                TestScreen(ShouldProceed: $ShouldProceed)
            } label: {
                Text("No outside packaging").frame(width: UIScreen.screenWidth * buttonWidthRatio,height: UIScreen.screenHeight * buttonHeightRatio)
                    .background(
                        //Shadow
                        RoundedRectangle(cornerRadius: (15))
                            .fill(Color.white)
                            .shadow(radius: 2, y: 2.2)
                    ).foregroundColor(Color.black)
                    .font(.system(size: 24, weight: .semibold))
                    .padding(.leading, UIScreen.screenWidth / horizontalSideSpacingRatio)
            }
            
            
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScanning()

    }
}

struct BarcodeScanningView: UIViewControllerRepresentable {
    
    
    
    //Create the coordinator (delegate)
    class Coordinator: NSObject, BarcodeScanningViewControllerDelegate {
        
        let barcodeScanningView: BarcodeScanningView
        
        init(barcodeScanningView: BarcodeScanningView) {
            self.barcodeScanningView = barcodeScanningView
        }
        
        func finishedScanning(readRAT: RapidAntigenTest) {
            
            barcodeScanningView.ReadRAT = readRAT
            barcodeScanningView.shouldProceed = true
            
        }
    }
    
    @Binding var ReadRAT: RapidAntigenTest?
    
    @Binding var shouldProceed: Bool
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Guidance", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "barcodeScanningView") as BarcodeScannerViewController
        
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    //To make the delegate (coordinator)
    func makeCoordinator() -> Coordinator {
        Coordinator(barcodeScanningView: self)
    }
}
