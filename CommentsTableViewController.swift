//
//  CommentsTableViewController.swift
//  DNApp
//
//  Created by Meng To on 2015-03-08.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController, CommentTableViewCellDelegate, StoryTableViewCellDelegate, ReplyViewControllerDelegate {

    var story: JSON!
    var comments: [JSON]!
    var transitionManager = TransitionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        comments = flattenComments(story["comments"].array ?? [])
        
        refreshControl?.addTarget(self, action: "reloadStory", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func shareButtonDidTouch(sender: AnyObject) {
        var title = story["title"].string ?? ""
        var url = story["url"].string ?? ""
        let activityViewController = UIActivityViewController(activityItems: [title, url], applicationActivities: nil)
        activityViewController.setValue(title, forKey: "subject")
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop]
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func reloadStory() {
        view.showLoading()
        DNService.storyForId(story["id"].int!, response: { (JSON) -> () in
            self.view.hideLoading()
            self.story = JSON["story"]
            self.comments = self.flattenComments(JSON["story"]["comments"].array ?? [])
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifer = indexPath.row == 0 ? "StoryCell" : "CommentCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifer) as! UITableViewCell
        
        if let storyCell = cell as? StoryTableViewCell {
            storyCell.configureWithStory(story)
            storyCell.delegate = self
        }
        
        if let commentCell = cell as? CommentTableViewCell {
            let comment = comments[indexPath.row - 1]
            commentCell.configureWithComment(comment)
            commentCell.delegate = self
        }
        
        return cell
    }
    
    // MARK: CommentTableViewCellDelegate

    func commentTableViewCellDidTouchUpvote(cell: CommentTableViewCell) {
        if let token = LocalStore.getToken() {
            let indexPath = tableView.indexPathForCell(cell)!
            let comment = comments[indexPath.row - 1]
            let commentId = comment["id"].int!
            DNService.upvoteCommentWithId(commentId, token: token, response: { (successful) -> () in
                
            })
            LocalStore.saveUpvotedComment(commentId)
            cell.configureWithComment(comment)
        } else {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }

    func commentTableViewCellDidTouchComment(cell: CommentTableViewCell) {
        if LocalStore.getToken() == nil {
            performSegueWithIdentifier("LoginSegue", sender: self)
        } else {
            performSegueWithIdentifier("ReplySegue", sender: cell)
        }
    }

    // MARK: StoryTableViewCellDelegate

    func storyTableViewCellDidTouchUpvote(cell: StoryTableViewCell, sender: AnyObject) {
        if let token = LocalStore.getToken() {
            let indexPath = tableView.indexPathForCell(cell)!
            let storyId = story["id"].int!
            DNService.upvoteStoryWithId(storyId, token: token, response: { (successful) -> () in
                
            })
            LocalStore.saveUpvotedStory(storyId)
            cell.configureWithStory(story)
        } else {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }

    func storyTableViewCellDidTouchComment(cell: StoryTableViewCell, sender: AnyObject) {
        if LocalStore.getToken() == nil {
            performSegueWithIdentifier("LoginSegue", sender: self)
        } else {
            performSegueWithIdentifier("ReplySegue", sender: cell)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ReplySegue" {
            let toView = segue.destinationViewController as! ReplyViewController
            if let cell = sender as? CommentTableViewCell {
                let indexPath = tableView.indexPathForCell(cell)!
                let comment = comments[indexPath.row - 1]
                toView.comment = comment
            }
            
            if let cell = sender as? StoryTableViewCell {
                toView.story = story
            }
            
            toView.delegate = self
            toView.transitioningDelegate = transitionManager
        }
    }
    
    // MARK: ReplyViewControllerDelegate
    
    func replyViewControllerDidSend(controller: ReplyViewController) {
        reloadStory()
    }
    
    // Helper
    
    func flattenComments(comments: [JSON]) -> [JSON] {
        let flattenedComments = comments.map(commentsForComment).reduce([], combine: +)
        return flattenedComments
    }
    
    func commentsForComment(comment: JSON) -> [JSON] {
        let comments = comment["comments"].array ?? []
        return comments.reduce([comment]) { acc, x in
            acc + self.commentsForComment(x)
        }
    }
}









