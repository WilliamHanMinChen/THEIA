//
//  SearchTestsTableViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/2/9.
//

import UIKit
import Firebase
import FirebaseAuth

class SearchTestsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UITextFieldDelegate, DatabaseListener {
    func onAuthStateChange(user: User) {
        
    }
    
    func onAuthError(error: NSError) {
        
    }
    
    func onEndUserChange(change: DataBaseChange, user: EndUser) {
        
    }
    
    func onTestTypesChange(change: DataBaseChange, testTypes: [TestType]) {
        
    }
    
    func onTestChange(change: DataBaseChange, tests: [Test]) {
        
        var newTests:[Test] = []
        //If it is within the testtype barcodes
        for test in tests {
            if ((testType?.barCodes?.contains(test.id ?? "")) != nil){
                newTests.append(test)
            }
        }
        self.tests = newTests
        
        updateSearchResults(for: navigationItem.searchController!)
        
        tableView.reloadData()
    }
    
    
    //Stores a referene to the database
    weak var dataBaseController: DatabaseProtocol?
    
    //Sets the listener type
    var listenerType: ListenerType = ListenerType.test
    
    //List of tests we are scanning for
    var tests: [Test] = []
    
    var filteredTests : [Test] = []
    
    var testType: TestType?
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        //Check if there is search text to be accessed, if so then lower case it
        guard let searchText = searchController.searchBar.text?.lowercased() else{
            return
        }
        //Get the current selected index for scope bar
        guard let searchController = navigationItem.searchController else {
            return
            
        }
        
        if searchText.count > 0 {
            //Searches whether the unit name or the unit code contains what the user has typed
            filteredTests = tests.filter({ (test: Test) -> Bool in
                return (test.name?.lowercased().contains(searchText) ?? false || test.name?.lowercased().contains(searchText) ?? false)})
                
            }
        else {
            // If there is no text to search for then just display the entirity of everything
            filteredTests = tests
        }
        //Reloads the tableView
        tableView.reloadData()
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        //Search Controller
        //Initialises an UISearchController
        let searchController = UISearchController(searchResultsController: nil)
        //Sets the delegate of the search controller to be this class
        searchController.searchResultsUpdater = self
        //Register to listen for scopebar changes
        searchController.searchBar.delegate = self
        //Try changing this to see what happens
        searchController.obscuresBackgroundDuringPresentation = false //If this is true it darkens the foreground when typing in the search bar
        //The placeholder text
        searchController.searchBar.placeholder = "Search for tests"
        searchController.searchBar.showsScopeBar = true
        //Add corner to textfield
        searchController.searchBar.searchTextField.layer.cornerRadius = 10
        let textField =  searchController.searchBar.searchTextField
        navigationItem.hidesSearchBarWhenScrolling = false
        //This tells the navigationItem that the search controller we just created is the one it should use
        navigationItem.searchController = searchController

        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        //Set the delegate of the textfield
        searchController.searchBar.searchTextField.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        dataBaseController = appDelegate?.databaseController
        
        
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
        return filteredTests.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testTypeCell", for: indexPath) as! TestTypeTableViewCell
        
        
        let test = filteredTests[indexPath.section]
        cell.testTypeName.text = test.name
        
        cell.setupLooks()

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTest = filteredTests[indexPath.section]
        
        performSegue(withIdentifier: "SearchToOnboardingSegue", sender: selectedTest)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToOnboardingSegue"{
            
            let selectedTest = sender as! Test
            //Set our next VC's scanned test
            let destination = segue.destination as! TestInformationViewController
            
            destination.scannedTest = selectedTest
        }
    }
    

}
