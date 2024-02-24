//
//  FinishedUploadingViewController.swift
//  THEIA
//
//  Created by William Chen on 2024/1/8.
//

import UIKit

class FinishedUploadingViewController: UIViewController {

    @IBOutlet weak var anotherOptionButton: UIButton!
    
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        anotherOptionButton.setupButton()
        finishButton.setupButton()
    }
    
    @IBAction func anotherOptionButtonPressed(_ sender: Any) {
        
        //Pop the last two view controllers
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)

    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)

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
