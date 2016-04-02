//
//  ViewController.swift
//  Women On Call
//
//  Created by Pivotal on 2016-03-28.
//  Copyright © 2016 Chi Ladies Hack. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        let urlPath:String = "http://www.womenoncall.org/api/v1/users/login"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let jsonPost = "login=\(username)&password=\(password)"
        print(jsonPost)
        request.HTTPBody =  jsonPost.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
        }
                task.resume()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

