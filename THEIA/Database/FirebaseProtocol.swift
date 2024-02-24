//
//  FirebaseController.swift
//  RateMonash
//
//  Created by William Chen on 2022/01/10.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseController: NSObject , DatabaseProtocol{

    
    
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        
        //If the listener is a user listener or all type, update them about the units
        if listener.listenerType == .user || listener.listenerType == .all {
            listener.onEndUserChange(change: .update, user: user)
        }
        
        //If the listener is a testtype listener or all type, update them about the units
        if listener.listenerType == .testType || listener.listenerType == .all {
            listener.onTestTypesChange(change: .update, testTypes: testTypes)
        }
        
        //If the listener is a test listener or all type, update them about the units
        if listener.listenerType == .test || listener.listenerType == .all {
            listener.onTestChange(change: .update, tests: tests)
        }
        
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    
    
    //Keeps track of which delegates (listeners) to call when something is updated
    var listeners = MulticastDelegate<DatabaseListener>()
    
    //Reference to the firebase authentication system
    var authController: Auth
    
    //Reference to the firebase firestore databse
    var database: Firestore
    
    //Collection references
    var usersRef: CollectionReference?
    var testTypesRef: CollectionReference?
    var testsRef: CollectionReference?
    var annotationJobsRef: CollectionReference?
    
    
    //Holds our test types
    var testTypes: [TestType]
    
    //Holds our test types
    var tests: [Test]
    
    //Listener for the user
    var userListener: ListenerRegistration?
    
    //Reference to the current user
    var currentUser: FirebaseAuth.User?
    
    //A CustomUser object to hold all the information about the user
    var user: EndUser
    
    
    
    
    override init(){
        
        //Setup and initialise each of the firebase frameworks
        //This must be called first to configure FireBase
        FirebaseApp.configure()
        
        //Gets the firebase auth obj
        authController = Auth.auth()
        
        //Gets the firestore obj
        database = Firestore.firestore()
        
        //Set up the object that holds all the user info
        user = EndUser()
        
        testTypes = []
        tests = []
        
        super.init()
        
        
        //Setup the listeners
        setupTestTypeListener()
        setupTestListener()
        
        
        //        setupUnitsListener()
        //        setupStaffListener()
        //        setupFacilityListener()
        //        setupUnitGradeListener()
        
        //If we have a logged in user
        usersRef = database.collection("users")
        if let currentUser = Auth.auth().currentUser {
            self.currentUser = currentUser
            //Setup a listener for the user
            setupUserListener()
            Task {
                //This gets the user's name
                //self.user = await self.getUserByUID(uid: currentUser.uid)
            }
        }
        
        
    }
    
    func setupTestListener(){
        //This method will setup a snapshot listener that will listen for all changes in the staffs reference

        //First step, get a reference to the firestore collection
        testsRef = database.collection("tests")

        //Adds the listener plus a function to be called once the reference is updated
        testsRef?.addSnapshotListener() {
            (QuerySnapshot, error) in
            //Check that the snapshot is valid
            guard let querySnapshot = QuerySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }

            //If it is valid, then we call another method to parse the staffs
            self.parseTestSnapshot(snapshot: querySnapshot)
            print("Got here!!")

        }

    }

    //This function is to handle what has changed so it is reflected inside our app
    func parseTestSnapshot(snapshot: QuerySnapshot){
        //Loop through each change in our snapshot
        snapshot.documentChanges.forEach{ (change) in
            var parsedTest: Test?

            //Decode it into a staff object
            do {
                parsedTest = try change.document.data(as: Test.self)
                }
            catch {
                print(error)
                print("Unable to decode test. Is the test malformed?")
                return
            }

            //Make sure there is a staff
            guard let test = parsedTest else{
                print("Document doesnt exist")
                return
            }
            //Determine what the change was

            if change.type == .added {
                //Insert the staff into its corresponding position. It needs to match firestore in order to handle deletion and modification.
                tests.insert(test, at: Int(change.newIndex))
            }

            if change.type == .modified {
                tests[Int(change.oldIndex)] = test
            }

            if change.type == .removed {
                tests.remove(at: Int(change.oldIndex))
            }

            //After we make the changes to the staff list, pass it onto the listeners
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.test ||
                    listener.listenerType == ListenerType.all {
                    listener.onTestChange(change: .update, tests: tests)
                }
            }
        }

    }
    
    
    
    func setupTestTypeListener(){
        //This method will setup a snapshot listener that will listen for all changes in the staffs reference

        //First step, get a reference to the firestore collection
        testTypesRef = database.collection("testTypes")


        //Adds the listener plus a function to be called once the reference is updated
        testTypesRef?.addSnapshotListener() {
            (QuerySnapshot, error) in
            //Check that the snapshot is valid
            guard let querySnapshot = QuerySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }

            //If it is valid, then we call another method to parse the staffs
            self.parseTestTypesSnapshot(snapshot: querySnapshot)

        }

    }

    //This function is to handle what has changed so it is reflected inside our app
    func parseTestTypesSnapshot(snapshot: QuerySnapshot){
        //Loop through each change in our snapshot
        snapshot.documentChanges.forEach{ (change) in
            var parsedTestType: TestType?

            //Decode it into a staff object
            do {
                parsedTestType = try change.document.data(as: TestType.self)
                }
            catch {
                print(error)
                print("Unable to decode staff. Is the staff malformed?")
                return
            }

            //Make sure there is a staff
            guard let testType = parsedTestType else{
                print("Document doesnt exist")
                return
            }
            //Determine what the change was

            if change.type == .added {
                //Insert the staff into its corresponding position. It needs to match firestore in order to handle deletion and modification.
                testTypes.insert(testType, at: Int(change.newIndex))
            }

            if change.type == .modified {
                testTypes[Int(change.oldIndex)] = testType
            }

            if change.type == .removed {
                testTypes.remove(at: Int(change.oldIndex))
            }
            

            //After we make the changes to the staff list, pass it onto the listeners
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.testType ||
                    listener.listenerType == ListenerType.all {
                    listener.onTestTypesChange(change: .update, testTypes: testTypes)
                }
            }
        }

    }
    
    
    //Sets up a listener to our current user's document
    func setupUserListener(){
        print("Called User exists")
        //Get the reference to the users collection
        usersRef = database.collection("users")
        //Check there is a current user
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        guard let usersRef = usersRef else {
            return
        }
        
        //Get the users document
        let userDocRef = usersRef.document(currentUser.email!)
        
        //If we already have one, we remove it first
        if let userListener = userListener {
            userListener.remove()
        }
        
        
        userDocRef.getDocument { (document, error) in
            //Check if the document exists
            if let document = document, document.exists{
                print("User exists")
                
            } else {
                print("User doesnt exist")
                //Create the document
                usersRef.document(currentUser.email!).setData([
                    "balance" : 0.0
                        ])
                
            }
            
        }
        
        //Add a snapshot listener
        userListener = userDocRef.addSnapshotListener(){
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else{
                print("Error fetching user: \(String(describing: error))")
                return
            }
            //Parse the user info
            self.parseUserSnapshot(snapshot: querySnapshot)
        }
        
    }
    
    //This function is to handle what has changed so it is reflected inside our app
    func parseUserSnapshot(snapshot: DocumentSnapshot){

        if let balance = snapshot.data()?["balance"] as? Double {
            self.user.balance = balance
        }
        
        //For each of the listener, call the delegate function
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.all ||
                listener.listenerType == ListenerType.user {
                listener.onEndUserChange(change: .update, user: user)
            }


        }
        
    }
    
    func addNewAnnotationJob(userEmail: String) -> String {
        
        //Get the annotations collection reference
        annotationJobsRef = database.collection("annotations")
        
        //Create the document
        let documentReference = annotationJobsRef!.addDocument(data: [
            "imageLinks" : [],
            "userID" : userEmail
                ])
        
        return documentReference.documentID
    }
    
    func updateAnnotationJobLinks(annotationID: String, links: [String]) {
        //Get the annotations collection reference
        annotationJobsRef = database.collection("annotations")
        
        let documentRef = annotationJobsRef!.document(annotationID)

        // Set the "capital" field of the city 'DC'
        documentRef.updateData([
            "imageLinks": links
          ])
        
        
        print("Updated \(annotationID) with \(links)")
    }

    
    func getEndUser(){
        
        //Check if the end user exists, if not, create a document for the user and return the document
        setupUserListener()
        
    }
    
}
