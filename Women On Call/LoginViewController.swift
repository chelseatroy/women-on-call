import UIKit

class ViewController: UIViewController {
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
        loginButton.layer.cornerRadius = 5
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        makeLoginRequest(
            username: usernameTextField.text ?? "",
            password: passwordTextField.text ?? ""
        ) { result in
            switch result {
            case let .Success(loginResponse):
                
                getOrganizations(
                    loginResponse.apiKey,
                    inCity: "Chicago"
                ) { orgsResult in
                    switch orgsResult {
                    case let .Success(orgs):
                        
                        getPostings(
                            loginResponse.apiKey,
                            forOrgs: orgs,
                            withSkills: loginResponse.skills
                        ) { postingsResult in
                            switch postingsResult {
                            case let .Success(postings):
                                NSOperationQueue.mainQueue().addOperationWithBlock {
                                    let vc : OrganizationsViewController! = self.storyboard!.instantiateViewControllerWithIdentifier("organizationsViewController") as! OrganizationsViewController
                                    vc.postings = postings
                                    self.showViewController(vc, sender: vc)
                                }
                            case .Failure:
                                print("oh no")
                            }
                        }
                        
                    case .Failure:
                        print("woops")
                    }
                }
            case let .Failure(error):
                print(error.message)
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    let dialog = UIAlertController(title: "Error",
                        message: "Incorrect username or password.",
                        preferredStyle: UIAlertControllerStyle.Alert)
                    dialog.addAction(UIAlertAction(title: "Please Try Again", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(dialog, animated: false, completion: nil)
                })
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        self.view.endEditing(true)
    }    
}

