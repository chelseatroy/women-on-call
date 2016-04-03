//
//  ViewController.swift
//  Women On Call
//
//  Created by Pivotal on 2016-03-28.
//  Copyright © 2016 Chi Ladies Hack. All rights reserved.
//

import UIKit

class Organization {
    let id: Int
    let name: String
    let zipCode: String
    
    init(id: Int, name: String, zipCode: String) {
        self.id = id
        self.name = name
        self.zipCode = zipCode
    }
}

class Posting {
    let orgId: Int?
    let title: String?
    let description: String?
    let contact: String?
    let skill: String?
    
    init(orgId: Int, title: String, description: String, contact: String, skill: String) {
        self.orgId = orgId
        self.title = title
        self.description = description
        self.contact = contact
        self.skill = skill
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var organizationIDs = NSMutableArray()
    var allPostings = NSMutableArray()
    var apiKey = String()
    var skills = NSArray()
    
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
                    self.setUpUser(json)
                    self.data_request()
                    // Do any additional setup after loading the view, typically from a nib.
                    
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
    
    func setUpUser (json: NSDictionary) {
        let user = json["api_user"]
        let volunteer = user!["volunteer_profile"]
        if let apiKey = user!["api_key"] as? String {
            self.apiKey = apiKey
        }
        if let skills = volunteer!!["skills"] as? NSArray {
            self.skills = skills
        }
    }
    
    //This method makes the http request
    func data_request() {
        let session = NSURLSession.sharedSession()
        
        let organizationURL:NSURL = NSURL(string: "http://www.womenoncall.org/api/v1/organizations?api_key="+self.apiKey)!
        let request = NSMutableURLRequest(URL: organizationURL)
        request.HTTPMethod = "GET"
        organization_task(session, request: request, apiKey: self.apiKey)
    }
    
    func organization_task(session: NSURLSession, request: NSMutableURLRequest, apiKey: String) {
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            //stringified json in the response. You could print this to see it al as a string.
            if let json: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                if let items = json["organizations"] as? NSArray {
                    for item in items {
                        // construct your model objects here
                        let city = item["city"] as? String
                        if city != nil && city  == "Chicago" {
                            self.organizationIDs.addObject(item["id"] as! Int)
                            print("organizationIDs ::  "+(String(item["id"])))
                        }
                    }
                }
            }
            let postingsURL:NSURL = NSURL(string: "http://www.womenoncall.org/api/v1/postings?api_key="+apiKey)!
            let postingRequest = NSMutableURLRequest(URL: postingsURL)
            request.HTTPMethod = "GET"
            self.postings_task(session, request: postingRequest)
        }
        
        task.resume()
    }
    
    func postings_task(session: NSURLSession, request: NSMutableURLRequest) {
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            //stringified json in the response. You could print this to see it al as a string.
            //let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            //print(dataString)
            
            if let json: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                if let items = json["postings"] as? NSArray {
                    for item in items {
                        // construct your model objects here
                        let currentId = item["organization_id"] as! Int
                        if self.organizationIDs .containsObject(currentId) {
                            let posting = Posting(
                                orgId: item["organization_id"] as! Int,
                                title: item["title"] as! String,
                                description: item["custom_project_description"] as! String,
                                contact: item["contact"] as! String,
                                skill: item["skill"] as! String)
                            
                            if self.skills.containsObject(posting.skill!) {
                                //self.insertNewObject(posting)
                                self.allPostings.addObject(posting)
                                print("posting ::  "+(String(item["organization_id"])))
                            }
                        }
                    }
                }
            }
            
            let vc : OrganizationsViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("organizationsViewController") as! OrganizationsViewController
            vc.setUpWith(self.allPostings)
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.showViewController(vc, sender: vc)
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

