//
//  NoteCollectionViewController.swift
//  Organizer-iOS
//
//  Created by Ben Ribovich on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class NoteCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {

    var category : PFObject?
    var startPointforDrag : CGPoint?
    var startY: CGFloat?
    var movingCell : UICollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.delegate = self
        self.collectionView!.dataSource = self
        self.collectionView?.reloadData()
        
        let screenSize = UIScreen.mainScreen().bounds
        let collectionViewFlowLayout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        collectionViewFlowLayout.itemSize = CGSizeMake(screenSize.width / 2.0, screenSize.height / 2.0)
        collectionViewFlowLayout.minimumInteritemSpacing = 0.0
        collectionViewFlowLayout.minimumLineSpacing = 20.0
        let screenshotsSectionInset = screenSize.width / 4.0
        collectionViewFlowLayout.sectionInset = UIEdgeInsetsMake(0.0, screenshotsSectionInset, 0.0, screenshotsSectionInset)
        
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "createNewNote:")
        self.navigationItem.rightBarButtonItem = createButton
        
        let panSelector = Selector("pan:")
        let vertPan = UIPanGestureRecognizer(target: self, action: panSelector)
        vertPan.delegate = self
        self.collectionView?.addGestureRecognizer(vertPan)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (category!["notes"] as! [PFObject]).count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "NoteCell"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        if let textLabel = cell.viewWithTag(201) as? UILabel {
            let text = category!["notes"]![indexPath.row]["text"] as! String
            textLabel.text = "\(text)"
        }
        
        //Swipe up to delete
        //let panSelector = Selector("pan:")
        //let cSelector = Selector("reset:")
        //let vertPan = UIPanGestureRecognizer(target: self, action: panSelector)
        //let UpSwipe = UISwipeGestureRecognizer(target: self, action: cSelector )
        //UpSwipe.direction = UISwipeGestureRecognizerDirection.Up
        //cell.addGestureRecognizer(UpSwipe)
        //cell.addGestureRecognizer(vertPan)
        
        return cell

    }
    
    func createNewNote(sender: AnyObject){

        //1. Create the alert controller.
        let alert = UIAlertController(title: "New Note", message: "Enter text", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            //textField.text = "Some default text."
        })
        
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            //print("Text field: \(textField.text)")
            
            let newNote = PFObject(className: "Note")
            newNote["text"] = textField.text
            //newNote["users"] = [(PFUser.currentUser() as! AnyObject)]
            newNote["creator"] = PFUser.currentUser()
            
            newNote.saveInBackgroundWithBlock({ (success, error) -> Void in
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
            var notes = self.category!["notes"] as! [PFObject]
            notes.append(newNote)
            self.category!["notes"] = notes
            self.category?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if(success){
                    self.collectionView?.reloadData()
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
    
    func pan(sender: UIPanGestureRecognizer){
        
        if (sender.state == UIGestureRecognizerState.Began){
            startPointforDrag = sender.locationInView(self.collectionView)
            let indexPathOfMovingCell = self.collectionView?.indexPathForItemAtPoint(sender.locationInView(self.collectionView))
            movingCell = self.collectionView?.cellForItemAtIndexPath(indexPathOfMovingCell!)
            startY = movingCell?.frame.origin.y
            
        }
        if(sender.state == UIGestureRecognizerState.Changed){
            let location = sender.locationInView(self.collectionView)
            movingCell!.frame=CGRect(x: movingCell!.frame.origin.x, y: startY! - (startPointforDrag!.y-location.y), width: movingCell!.frame.width, height: movingCell!.frame.height)
            
        }
        
        
    }
    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocityInView(self.collectionView)
        return(fabs(velocity.y) > fabs(velocity.x))
    }
    
    func reset(sender: UISwipeGestureRecognizer) {
        let cell = sender.view as! UICollectionViewCell
        let i = self.collectionView!.indexPathForCell(cell)!.item
        var nextCell : UICollectionViewCell?
        
        UIView.animateWithDuration(0.5, animations: {
            
            cell.frame=CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y - self.view.frame.height, width: cell.frame.width, height: cell.frame.height)
            print(i)
            
            if(i != (self.category!["notes"] as! [PFObject]).count - 1 ){
                nextCell = (self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forRow: i+1, inSection: 0)))!
                print(nextCell)
                nextCell!.frame = CGRect(x: nextCell!.frame.origin.x - cell.frame.width, y: nextCell!.frame.origin.y, width: nextCell!.frame.width, height: nextCell!.frame.height)
                
            }

            }, completion: { (Bool) -> Void in
                cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y + self.view.frame.height, width: cell.frame.width, height: cell.frame.height)
                if((nextCell) != nil){
                    nextCell!.frame = CGRect(x: nextCell!.frame.origin.x + cell.frame.width, y: nextCell!.frame.origin.y, width: nextCell!.frame.width, height: nextCell!.frame.height)
                }
                
                var notes = self.category!["notes"] as! [PFObject]
                notes.removeAtIndex(i)
                self.category!["notes"] = notes
                self.collectionView!.reloadData()

                
        })
        
        
    }
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
