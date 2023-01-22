//
//  TestTypeTableViewCell.swift
//  THEIA
//
//  Created by William Chen on 2023/1/20.
//

import UIKit

class TestTypeTableViewCell: UITableViewCell {
    
    //View container for shadow
    @IBOutlet weak var viewContainer: UIView!
    
    @IBOutlet weak var testTypeName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupLooks(){
        //Apply shadow
        viewContainer.layer.cornerRadius = 8
        viewContainer.layer.masksToBounds = false
        viewContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        viewContainer.layer.shadowColor = UIColor.gray.cgColor
        viewContainer.layer.shadowOpacity = 0.4
        viewContainer.layer.shadowRadius = 4
        
        
    }
    
    

}
