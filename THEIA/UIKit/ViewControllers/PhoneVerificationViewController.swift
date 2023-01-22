//
//  PhoneVerificationViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/9.
//

import UIKit
import FirebaseAuth

class PhoneVerificationViewController: UIViewController, UITextFieldDelegate {
    
    
    //References
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    @IBOutlet weak var verificationCodeTextfield: UITextField!
    
    @IBOutlet weak var verifyButton: UIButton!
    
    
    @IBOutlet weak var resendButton: UIButton!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyButton.setupButton()
        resendButton.setupButton()
        
        phoneNumberTextfield.delegate = self
        verificationCodeTextfield.delegate = self

        setupTextField()
        //Dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    func setupTextField(){
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
        phoneNumberTextfield.inputAccessoryView = toolbar
        verificationCodeTextfield.inputAccessoryView = toolbar
    }
    
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //If it is phone number textfield, send to the phone number
        if textField == phoneNumberTextfield{
            guard let phoneNumber = textField.text else {
                print("Failed to unwrap text from UITextfield, something went wrong")
                return
            }
            
            print("User entered \(phoneNumber)")
            
            
            //Send the phone number
            PhoneAuthProvider.provider()
              .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                  if let error = error {
                    print(error.localizedDescription)
                    return
                  }
                  // Sign in using the verificationID and the code sent to the user
                  // ...
              }
            
            
        }
        
        //print(textField.text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.text)
        textField.resignFirstResponder()
        return true
        
    }
    
    
    
    @IBAction func verifyAction(_ sender: Any) {
        
    }
    
    
    @IBAction func resendAction(_ sender: Any) {
        
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



