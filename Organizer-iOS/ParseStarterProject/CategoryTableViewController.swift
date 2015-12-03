//
//  CategoryTableViewController.swift
//  Organizer-iOS
//
//  Created by Ben Ribovich on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CategoryTableViewController: PFQueryTableViewController {
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "Category"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Configure the PFQueryTableView
        self.parseClassName = "Category"
        //self.textKey = "title"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = true
    }
    
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.includeKey("users")
        query.includeKey("notes")
        query.whereKey("users", containsAllObjectsInArray: [PFUser.currentUser()!])
        return query
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        let cellIdentifier = "CategoryCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? PFTableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier) as? PFTableViewCell

        }
        if let object = object{
            if let descriptionLabel = cell!.viewWithTag(101) as? UILabel {
                let description = object["title"]
                descriptionLabel.text = "\(description)"
            }
            
        }

        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "createNewCategory:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func createNewCategory(sender: AnyObject){
        print("pushed button")
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "New Category", message: "Enter a name for your category", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            //textField.text = "Some default text."
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            //print("Text field: \(textField.text)")
            
            let newCategory = PFObject(className: "Category")
            newCategory["title"] = textField.text
            newCategory["users"] = [(PFUser.currentUser() as! AnyObject)]
            newCategory["creator"] = PFUser.currentUser()
            newCategory["notes"] = []
            
            newCategory.saveInBackgroundWithBlock({ (success, error) -> Void in
                if(success){
                    
                }
                
                else{
                    //Issue saving category
                    let errorAlertController = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    }
                    errorAlertController.addAction(OKAction)
                    self.presentViewController(errorAlertController, animated: true) {}
                }
            })
            
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "ShowNotesForCategory"){
            let destinationVC = segue.destinationViewController as! NoteCollectionViewController
            let selectedIndex = self.tableView.indexPathForCell(sender as! PFTableViewCell)
            destinationVC.category = self.objectAtIndexPath(selectedIndex)!
            
        }
    }


}
