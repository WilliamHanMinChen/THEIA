//
//  TransactionsTableViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

class TransactionsTableViewController: UITableViewController {
    
    var transactions: [Transaction] = []
    
    var transactionsListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Setup listener for transactions
        //Get the database instance
        let database = Firestore.firestore()
        //Gets the collection ref for our current user inside our users collection
        let userRef = database.collection("users").document((Auth.auth().currentUser?.email!)!)
        
        //Set up a snapshot listener for the transactions collection
        
        //Transaction collection reference inside the user document
        let transactionsRef = userRef.collection("transactions")
        
        //Add a snapshot listener to the scaledReview collection
        transactionsListener = transactionsRef.addSnapshotListener() {
            (querySnapshot, error) in
            //If there is an error
            if let error = error {
                print(error)
                return
            }

            //Loop through each change
            querySnapshot?.documentChanges.forEach() { change in
//                //We only care about adding since we cant modify...
//                if change.type == .added {
//                    //Get the document
//                    let snapshot = change.document
//                    //Gets the ID
//                    let id = snapshot.documentID
//                    //Gets the data held inside the documents
//                    let ratings = snapshot["ratings"] as! [Int]
//                    let userID = snapshot["userid"] as! String
//
//                    //If we havnt attempted to fetch the keywords yet, do it
//                    if !self.keywordsFetched {
//                        self.keywordsFetched = true
//                        let statementRef = snapshot["template"] as! DocumentReference
//                        //Get the reference
//                        let statementsRef = database.collection("statementTemplates")
//                        Task{
//                            do{
//                                //Get each statement and parse it
//                                let data = try await statementsRef.document(statementRef.documentID).getDocument().data()
//                                let statements = data?["statements"] as! [DocumentReference]
//                                for statement in statements{
//                                    let statementDoc = database.collection("statements").document(statement.documentID)
//                                    let statementData = try await statementDoc.getDocument()
//                                    self.keywords.append(statementData["keyword"] as! String)
//                                }
//                                //Refresh the table once the statements have been fetched
//                                self.tableView.reloadData()
//
//                            } catch{
//                                print("An error occurred \(String(describing: error))")
//                            }
//
//                        }
//                    }
//
//                    //Create the scaledreview object
//                    let scaledReview = ScaledReview(ratings: ratings, userID: userID)
//                    //Insert it into the scaledReviews list
//                    self.scaledReviews.append(scaledReview)
//               }
            }
        }
        
        
        
        
        
        
        
        
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath) as! TransactionTableViewCell

        // Configure the cell...
        
        
        cell.setupLooks()
        
        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
