import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    var indicator: UIActivityIndicatorView!
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        view.addSubview(indicator)
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.whiteColor()

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
                                    self.indicator.stopAnimating()
                                    self.indicator.hidesWhenStopped = true
                                    
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

