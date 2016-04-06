import UIKit


class OrganizationsViewController: UITableViewController {
    var postings: [VolunteerPosting] = []
    
    
//    var objects = NSMutableArray()
//    
//    func setUpWith(postings: NSArray) {
//        for posting in postings {
//            self.insertNewObject(posting)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func insertNewObject(sender: AnyObject) {
//        objects.insertObject(sender, atIndex: 0)
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//    }
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        NSLog("%d objects count", objects.count)
        return postings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PostingTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PostingTableViewCell
        let posting = postings[indexPath.row]
        
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
//        if editingStyle == .Delete {
//            postings.removeObjectAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
    }
}
