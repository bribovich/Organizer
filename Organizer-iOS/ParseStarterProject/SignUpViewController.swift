//
//  SignUpViewController.swift
//  Organizer-iOS
//
//  Created by Ben Ribovich on 12/1/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    
    @IBAction func onSignUp(sender: UIButton) {
        let fullNameText  = self.fullNameField.text
        let emailText = self.emailField.text
        let passwordText = self.passwordField.text
        let confirmPasswordText = self.confirmPasswordField.text
        
        let alertController = UIAlertController(title: "Invalid", message: "Username must be greater than 5 characters", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        
        alertController.addAction(OKAction)
        
        if passwordText?.characters.count < 8 {
            
            alertController.message = "Password must be greater than 8 characters"
            self.presentViewController(alertController, animated: true) {}
            
        } else if passwordText! != confirmPasswordText!{
            
            alertController.message = "Passwords do not match"
            self.presentViewController(alertController, animated: true) {}
            
        } else{
            
            let newUser = PFUser()
            newUser.username = emailText!
            newUser.email = emailText!
            newUser.password = passwordText
            newUser["fullName"] = fullNameText
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                if ((error) != nil) {
                    let errorAlertController = UIAlertController(title: "Error", message: "\(error)",preferredStyle: .Alert)
                    errorAlertController.addAction(OKAction)
                    self.presentViewController(errorAlertController, animated: true) {}
                    
                } else {
                    let OKSignUpAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
                            self.presentViewController(viewController, animated: true, completion: nil)
                        })
                    }
                    let successAlertController = UIAlertController(title: "Success", message: "Signed Up! Please verify email.",preferredStyle: .Alert)
                    successAlertController.addAction(OKSignUpAction)
                    self.presentViewController(successAlertController, animated: true) {}
                }
            })
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
