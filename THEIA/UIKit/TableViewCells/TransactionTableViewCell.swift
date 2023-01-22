//
//  TransactionTableViewCell.swift
//  THEIA
//
//  Created by William Chen on 2023/1/11.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var background: UIView!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var transactionTitle: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        background.layer.cornerRadius = 18
        
        self.selectionStyle = .none
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLooks(){
        //Apply shadow
        viewContainer.layer.cornerRadius = 8
        viewContainer.layer.masksToBounds = false
        viewContainer.layer.shadowOffset = CGSize(width: 1, height: 3)
        viewContainer.layer.shadowColor = UIColor.gray.cgColor
        viewContainer.layer.shadowOpacity = 0.3
        viewContainer.layer.shadowRadius = 4
    }
    
    

}
