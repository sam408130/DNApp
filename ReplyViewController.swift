//
//  ReplyViewController.swift
//  DNApp
//
//  Created by Meng To on 2015-03-11.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit

protocol ReplyViewControllerDelegate: class {
    func replyViewControllerDidSend(controller: ReplyViewController)
}

class ReplyViewController: UIViewController {

    var story: JSON = []
    var comment: JSON = []
    @IBOutlet weak var replyTextView: UITextView!
    weak var delegate: ReplyViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        replyTextView.becomeFirstResponder()
    }

    @IBAction func sendButtonDidTouch(sender: AnyObject) {
        view.showLoading()
        let token = LocalStore.getToken()!
        let body = replyTextView.text
        
        if let storyId = story["id"].int {
            DNService.replyStoryWithId(storyId, token: token, body: body, response: { (successful) -> () in
                self.view.hideLoading()
                if successful {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.replyViewControllerDidSend(self)
                } else {
                    self.showAlert()
                }
            })
        }
        
        if let commentId = comment["id"].int {
            DNService.replyCommentWithId(commentId, token: token, body: body, response: { (successful) -> () in
                self.view.hideLoading()
                if successful {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.delegate?.replyViewControllerDidSend(self)
                } else {
                    self.showAlert()
                }
            })
        }
    }
    
    func showAlert() {
        var alert = UIAlertController(title: "Oh noes.", message: "Something went wrong. Your message wasn't sent. Please try again and save your text just in case.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}













