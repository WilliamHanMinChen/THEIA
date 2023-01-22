//
//  ProfileViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/9.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, DatabaseListener {
    func onTestTypesChange(change: DataBaseChange, testTypes: [TestType]) {
        
    }
    
    
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var topupButton: UIButton!
    
    @IBOutlet weak var transactionsButton: UIButton!
    
    @IBOutlet weak var contactUsButton: UIButton!
    
    
    //Stores a referene to the database
    weak var dataBaseController: DatabaseProtocol?
    
    //Sets the listener type
    var listenerType: ListenerType = ListenerType.user
    
    //The user but in our swift object type
    var profileUser: EndUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        dataBaseController = appDelegate?.databaseController
        

        // Do any additional setup after loading the view.
        topupButton.setupButton()
        transactionsButton.setupButton()
        contactUsButton.setupButton()
        
    }
    
    //This registers this class to receive updates from the database
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataBaseController?.addListener(listener: self)
    }
    
    //This unregisters this class to receive updates from the database
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dataBaseController?.removeListener(listener: self)
    }
    
    
    //MARK: Button Actions

    @IBAction func topupAction(_ sender: Any) {
        
        performSegue(withIdentifier: "ProfileTopUpSegue", sender: nil)
    }
    
    @IBAction func transactionAction(_ sender: Any) {
        
        performSegue(withIdentifier: "ProfileTransactionsSegue", sender: nil)
    }
    
    @IBAction func contactUsAction(_ sender: Any) {
        
        performSegue(withIdentifier: "ProfileContactUsSegue", sender: nil)
    }
    
    
    
    func onAuthStateChange(user: User) {
        
        
    }
    
    func onAuthError(error: NSError) {
        
        
    }
    
    func onEndUserChange(change: DataBaseChange, user: EndUser) {
        
        print("Called on end user change")
        self.profileUser = user
        
        //Update our labels
        self.balanceLabel.text = String(format: "$%.2f", user.balance!)
        
    }
    
    
    //Signout button
    @IBAction func signoutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("Logged out")
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
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
