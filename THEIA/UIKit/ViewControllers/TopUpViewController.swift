//
//  TopUpViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/9.
//

import UIKit

class TopUpViewController: UIViewController {
    
    
    //Button References
    @IBOutlet weak var firstOptionButton: UIButton!
    
    @IBOutlet weak var secondOptionButton: UIButton!
    
    @IBOutlet weak var thirdOptionButton: UIButton!
    
    @IBOutlet weak var fourthOptionButton: UIButton!
    
    @IBOutlet weak var fifthOptionButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting up the buttons
        firstOptionButton.setupButton()
        secondOptionButton.setupButton()
        thirdOptionButton.setupButton()
        fourthOptionButton.setupButton()
        fifthOptionButton.setupButton()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
