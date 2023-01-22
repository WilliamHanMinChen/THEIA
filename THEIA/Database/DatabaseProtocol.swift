//
//  DatabaseProtocol.swift
//  THEIA
//
//  Created by William Chen on 2023/01/10
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase


//This is to differentiate what action is being applied
enum DataBaseChange {
    case add
    case remove
    case update
}

//Specifies what type of data each listener is dealing with
enum ListenerType {
    case auth
    case unit
    case all
    case user
    case testType
}


protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType {get set}
    //This method is responsible when the authentication state is changed
    func onAuthStateChange(user: FirebaseAuth.User)
    //This method is responsible for when an error occurs during authentication
    func onAuthError(error: NSError)
    
//    //When units, staffs or faciltiies list changes these listener functions are called
//    func onUnitsChange(change: DataBaseChange, units: [Unit])
//    func onStaffsChange(change: DataBaseChange, staffs: [TeachingStaff])
//    func onFacilitiesChange(change: DataBaseChange, facilites: [Facility])
    
    //When the user details changes
    func onEndUserChange(change: DataBaseChange, user: EndUser)
    
    func onTestTypesChange(change: DataBaseChange, testTypes: [TestType])
    
//    //When the other user details changes
//    func onUserInfoChange(change: DataBaseChange, units: [Unit], staffs: [TeachingStaff], facilities: [Facility], likedWrittenReviews: [String], dislikedWrittenReviews: [String], user: CustomUser)
    
    
    
    
}



protocol DatabaseProtocol: AnyObject {
    
    
    
    //func deleteAccount()
    
    //Adds a class as a listener
    func addListener(listener: DatabaseListener)
    
    //Removes a class as a listener
    func removeListener(listener: DatabaseListener)
    
    //Get our EndUser
    func getEndUser()
    

}
