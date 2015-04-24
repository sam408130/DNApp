//
//  StoriesTableViewController.swift
//  DNApp
//
//  Created by Meng To on 2015-03-07.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit

class StoriesTableViewController: UITableViewController, StoryTableViewCellDelegate, MenuViewControllerDelegate, LoginViewControllerDelegate {
    
    let transitionManager = TransitionManager()
    var stories: JSON! = []
    var isFirstTime = true
    var section = ""
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    func refreshStories() {
        loadStories(section, page: 1)
        SoundPlayer.play("refresh.wav")
    }
    
    func loadStories(section: String, page: Int) {
        DNService.storiesForSection(section, page: page) { (JSON) -> () in
            self.stories = JSON["stories"]
            self.tableView.reloadData()
            self.view.hideLoading()
            self.refreshControl?.endRefreshing()
        }
        if LocalStore.getToken() == nil {
            loginButton.title = "Login"
            loginButton.enabled = true
        } else {
            loginButton.title = ""
            loginButton.enabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadStories("", page: 1)
        
        refreshControl?.addTarget(self, action: "refreshStories", forControlEvents: UIControlEvents.ValueChanged)
        
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!], forState: UIControlState.Normal)
        
        loginButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Avenir Next", size: 18)!], forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if isFirstTime {
            view.showLoading()
            isFirstTime = false
        }
    }

    @IBAction func menuButtonDidTouch(sender: AnyObject) {
        performSegueWithIdentifier("MenuSegue", sender: self)
    }
    
    @IBAction func loginButtonDidTouch(sender: AnyObject) {
        performSegueWithIdentifier("LoginSegue", sender: self)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StoryCell") as! StoryTableViewCell
        
        let story = stories[indexPath.row]
        cell.configureWithStory(story)
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("WebSegue", sender: indexPath)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: StoryTableViewCellDelegate
    
    func storyTableViewCellDidTouchUpvote(cell: StoryTableViewCell, sender: AnyObject) {
        if let token = LocalStore.getToken() {
            let indexPath = tableView.indexPathForCell(cell)!
            let story = stories[indexPath.row]
            let storyId = story["id"].int!
            DNService.upvoteStoryWithId(storyId, token: token, response: { (successful) -> () in
                println(successful)
            })
            LocalStore.saveUpvotedStory(storyId)
            cell.configureWithStory(story)
        } else {
            performSegueWithIdentifier("LoginSegue", sender: self)
        }
    }
    
    func storyTableViewCellDidTouchComment(cell: StoryTableViewCell, sender: AnyObject) {
        performSegueWithIdentifier("CommentsSegue", sender: cell)
    }
    
    // MARK: MenuViewControllerDelegate

    func menuViewControllerDidTouchTop(controller: MenuViewController) {
        view.showLoading()
        loadStories("", page: 1)
        navigationItem.title = "Top Stories"
        section = ""
    }

    func menuViewControllerDidTouchRecent(controller: MenuViewController) {
        view.showLoading()
        loadStories("recent", page: 1)
        navigationItem.title = "Recent Stories"
        section = "recent"
    }
    
    func menuViewControllerDidTouchLogout(controller: MenuViewController) {
        loadStories(section, page: 1)
        view.showLoading()
    }
    
    // MARK: Misc
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CommentsSegue" {
            let toView = segue.destinationViewController as! CommentsTableViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            toView.story = stories[indexPath.row]
        }
        if segue.identifier == "WebSegue" {
            let toView = segue.destinationViewController as! WebViewController
            let indexPath = sender as! NSIndexPath
            let url = stories[indexPath.row]["url"].string!
            toView.url = url
            
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
            
            toView.transitioningDelegate = transitionManager
        }
        if segue.identifier == "MenuSegue" {
            let toView = segue.destinationViewController as! MenuViewController
            toView.delegate = self
        }
        if segue.identifier == "LoginSegue" {
            let toView = segue.destinationViewController as! LoginViewController
            toView.delegate = self
        }
    }
    
    // MARK: LoginViewControllerDelegate

    func loginViewControllerDidLogin(controller: LoginViewController) {
        loadStories(section, page: 1)
        view.showLoading()
    }

}
