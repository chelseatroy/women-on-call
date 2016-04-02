import UIKit

class Organization {
    let id: String
    let name: String
    let zipCode: String
    
    init(id: String, name: String, zipCode: String) {
        self.id = id
        self.name = name
        self.zipCode = zipCode
    }
}

class OrganizationsViewController: UITableViewController {
    
    var objects = NSMutableArray()
    
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
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
            
            if let json: NSDictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                if let items = json["organizations"] as? NSArray {
                    
                    for item in items {
                        // construct your model objects here
                        print(item["name"])
                        let organization = Organization(
                            id: item["id"] as! String,
                            name: item["name"] as! String,
                            zipCode: item["zip_code"] as! String)
                        
                        self.insertNewObject(organization)
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
        return objects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        let object = objects[indexPath.row]
        cell.textLabel!.text = object.name
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
