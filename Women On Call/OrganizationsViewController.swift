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

class OrganizationsViewController: UITableViewController {
    
    var objects = NSMutableArray()
    var organizationIDs = NSMutableArray()
    var allPostings = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data_request()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //This method makes the http request
    func data_request() {
        
        let apiKey = "API_KEY"
        let session = NSURLSession.sharedSession()
        
        let organizationURL:NSURL = NSURL(string: "http://www.womenoncall.org/api/v1/organizations?api_key="+apiKey)!
        let request = NSMutableURLRequest(URL: organizationURL)
        request.HTTPMethod = "GET"
        organization_task(session, request: request, apiKey: apiKey)
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
                            
                            
                            self.insertNewObject(posting)
                            self.allPostings.addObject(posting)
                            print("posting ::  "+(String(item["organization_id"])))
                        }
                    }
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
        NSLog("%d objects count", objects.count)
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
