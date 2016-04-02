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
    var title = "Default Title"
    var contact = "No Contact Information Available"
    var skill = "No Skill Listed"
    
    init(title: String, contact: String, skill: String) {
        self.title = title
        self.contact = contact
        self.skill = skill
    }
}

class OrganizationsViewController: UITableViewController {
    
    var objects = NSMutableArray()
    
    func setUpWith(data: NSDictionary) {
        print("HERE'S SOME DATA")
        print(data)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data_request()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //This method makes the http request
    func data_request() {
        
        let apiKey = "API_KEY"
        //let paramString = "?api_key=" + apiKey
        let url:NSURL = NSURL(string: "http://www.womenoncall.org/api/v1/organizations?api_key="+apiKey)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        //this is how you would add query params or request body to your request
        
        //request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            //stringified json in the response. You could print this to see it al as a string.
            if let json: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                if let items = json["organizations"] as? NSArray {
                    
                    for item in items {
                        // construct your model objects here
                        print(item["name"])
//                        let organization = Organization(
//                            id: item["id"] as! Int,
//                            name: item["name"] as! String,
//                            zipCode: item["zip_code"] as! String)
//                        
                        //self.insertNewObject(organization)
                    }
                    
                    let posting1 = Posting(
                        title: "Awesome Posting",
                        contact: "me@me.com",
                        skill: "Public Relations")
                    let posting2 = Posting(
                        title: "Also Awesome Posting",
                        contact: "you@you.com",
                        skill: "Space Flight")
                    
                    self.insertNewObject(posting1)
                    self.insertNewObject(posting2)
                }
            }
            
        }
        
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: AnyObject) {
        objects.insertObject(sender, atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PostingTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostingTableViewCell
        let posting = objects[indexPath.row] as! Posting
        
        cell.titleLabel.text = posting.title
        cell.postingNameLabel.text = posting.contact
        cell.postingSkillLabel.text = posting.skill

        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
   
    
}
