//
//  ViewController.swift
//  Women On Call
//
//  Created by Pivotal on 2016-03-28.
//  Copyright © 2016 Chi Ladies Hack. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.layer.cornerRadius = 5
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "login-background.png")?.drawInRect(self.view.bounds)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://www.womenoncall.org/api/v1/users/login")!)

        let jsonPost = "login=\(usernameTextField.text!)&password=\(passwordTextField.text!)"
        request.HTTPMethod = "POST"
        request.HTTPBody =  jsonPost.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            
            print(dataString)
            if let json: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                if (json["error"] == nil) {
                    let vc : OrganizationsViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("organizationsViewController") as! OrganizationsViewController
                    vc.setUpWith(json)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.showViewController(vc, sender: vc)
                    }
                } else {
                    let dialog = UIAlertController(title: "Error",
                                                   message: "Incorrect username or password.",
                                                   preferredStyle: UIAlertControllerStyle.Alert)
                    dialog.addAction(UIAlertAction(title: "Please Try Again", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(dialog, animated: false, completion: nil)
                }
            }
            
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.view.endEditing(true)
    }    
}

