//
//  HomeScreenViewController.swift
//  THEIA
//
//  Created by William Chen on 2023/1/9.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit



class HomeScreenViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    //Buttons
    
    @IBOutlet weak var conductTestButton: UIButton!
    
    @IBOutlet weak var resultsButton: UIButton!
    
    @IBOutlet weak var FAQButton: UIButton!
    
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    //Stores a referene to the database
    weak var dataBaseController: DatabaseProtocol?
    
    
    //Haptic feedback engine
    let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        dataBaseController = appDelegate?.databaseController
        
        
        setBarButtonItem()
        //Setting up title
        navigationItem.title = getTitle()
        
        conductTestButton.setupButton()
        resultsButton.setupButton()
        FAQButton.setupButton()
        
        resultsButton.isEnabled = false
        FAQButton.isEnabled = false
        
        
    }
    
    func setBarButtonItem(){
        let containerView = UIControl(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        containerView.addTarget(self, action: #selector(handleProfile), for: .touchUpInside)
        let imageSearch = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 40, height: 40))
        imageSearch.image = UIImage(named: "profile")
        containerView.addSubview(imageSearch)
        let searchBarButtonItem = UIBarButtonItem(customView: containerView)
        searchBarButtonItem.width = 20
        navigationItem.rightBarButtonItem = searchBarButtonItem
        
        searchBarButtonItem.isAccessibilityElement = true
        searchBarButtonItem.accessibilityLabel = "Profile"
    }
    
    
    //MARK: Button actions
    
    
    @IBAction func conductTestAction(_ sender: Any) {
        //Give haptic feedback
        mediumImpact.impactOccurred()
        performSegue(withIdentifier: "HomeSelectTestTypeSegue", sender: nil)
    }
    
    @IBAction func viewResultsAction(_ sender: Any) {
        //Give haptic feedback
        mediumImpact.impactOccurred()
    }
    
    @IBAction func FAQAction(_ sender: Any) {
        //Give haptic feedback
        mediumImpact.impactOccurred()
    }
    
    
    @objc func handleProfile(){
        
        if Auth.auth().currentUser?.uid != nil {
            performSegue(withIdentifier: "HomeProfileSegue", sender: nil)

        }else{
            //user is not logged in
            appleSignin()
        }
        
        
        //performSegue(withIdentifier: "HomeToPhoneVerificationSegue", sender: nil)
    }
    
    

    func appleSignin(){
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)
        
        //Make the request controller
        let controller = ASAuthorizationController(authorizationRequests: [request])
        
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
    }
    //Night mode
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Failed")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        //Cast to AppleIDCredential Object
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            //Get the nonce
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            //Get the identity token of the user
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            //Serialise the data
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            spinner.frame = view.frame
            
            
            self.view.isUserInteractionEnabled = false
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                  // Error. If error.code == .MissingOrInvalidNonce, make sure
                  // you're sending the SHA256-hashed nonce as a hex string with
                  // your request to Apple.
                    print(error!.localizedDescription)
                  return
                }
                
                //Create the user document inside the User's Collection
                //Get the user for the database controller
                self.dataBaseController?.getEndUser()
                
                
                self.spinner.removeFromSuperview()
                self.performSegue(withIdentifier: "HomeProfileSegue", sender: nil)
                self.view.isUserInteractionEnabled = true
            }
            
        }
        
    }
    
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }

        
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    
    
    
    func getTitle() -> String{
        let currentDateTime = Date()
        //Get the current time
        let hour = Calendar.current.component(.hour, from: currentDateTime)
        
        var displayString = ""
        
        if hour < 12 && hour > 5 {
            displayString = "Good morning"
        } else if hour < 18 {
            displayString = "Good afternoon"
        } else {
            displayString = "Good evening"
        }
        
        return displayString
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


extension UIButton {
    
    func setupButton(){
        self.backgroundColor = .white
        self.layer.shadowOpacity = 0.40
        self.layer.shadowRadius = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 5
        
        self.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        self.titleLabel?.minimumScaleFactor = 0.5
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.tintColor = .black
        
        
        
    }
    
}

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


