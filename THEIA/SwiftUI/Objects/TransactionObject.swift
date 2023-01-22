//
//  Transaction.swift
//  THEIA
//
//  Created by William Chen on 2023/1/4.
//

import UIKit

class TransactionObject: NSObject {
    
    var transactionDate: String
    var cost : String
    var testType: String
    
    init(transactionDate: String, cost: String, testType: String) {
        self.transactionDate = transactionDate
        self.cost = cost
        self.testType = testType
    }
    

}
