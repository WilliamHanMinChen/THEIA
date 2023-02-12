//
//  TestTypesTableViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/20.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TestTypesTableViewController: UITableViewController, DatabaseListener {
    func onTestChange(change: DataBaseChange, tests: [Test]) {
        
    }
    
    
    
    //Sets the listener type
    var listenerType: ListenerType = ListenerType.testType
    
    //Stores a referene to the database
    weak var dataBaseController: DatabaseProtocol?
    
    
    //Haptic generator
    var generator = UIImpactFeedbackGenerator(style: .medium)
    
    var testTypes: [TestType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.sectionHeaderTopPadding = 32
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        dataBaseController = appDelegate?.databaseController

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testTypeCell", for: indexPath) as! TestTypeTableViewCell
        
        cell.setupLooks()
        
        //Get the current test
        let currentTest = testTypes[indexPath.section]
        cell.testTypeName.text = currentTest.testTypeName


        return cell
    }
    


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
        //Give haptic feedback
        generator.impactOccurred()
        
        //Get our current test type and perform the segue
        let testType = testTypes[indexPath.section]
        
        performSegue(withIdentifier: "TypeToInformationSegue", sender: testType)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeToInformationSegue"{
            //Get the sender
            guard let sender = sender as? TestType else {
                fatalError("Failed to cast sender to testtype!")
            }
            
            //Cast our destination
            let destination = segue.destination as! TestInformationViewController
            //Update our selected Test Type in the next VC
            destination.selectedTestType = sender
            
        }
    }
    
    //MARK: Database listener functions
    func onAuthStateChange(user: User) {
        
        
    }
    
    func onAuthError(error: NSError) {
        
    }
    
    func onEndUserChange(change: DataBaseChange, user: EndUser) {
        
    }
    
    func onTestTypesChange(change: DataBaseChange, testTypes: [TestType]) {
        self.testTypes = testTypes
        
        print(testTypes)
    }
    

}
