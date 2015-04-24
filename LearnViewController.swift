//
//  LearnViewController.swift
//  DNApp
//
//  Created by Meng To on 2015-01-31.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit

class LearnViewController: UIViewController {

    @IBOutlet weak var dialogView: DesignableView!
    @IBOutlet weak var bookImageView: SpringImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        dialogView.animate()
    }
    
    @IBAction func learnButtonDidTouch(sender: AnyObject) {
        bookImageView.animation = "pop"
        bookImageView.animate()
        
        openURL("http://designcode.io")
    }
    
    @IBAction func twitterButtonDidTouch(sender: AnyObject) {
        openURL("http://twitter.com/MengTo")
    }

    @IBAction func closeButtonDidTouch(sender: AnyObject) {
        dialogView.animation = "fall"
        dialogView.animateNext {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func openURL(url: String) {
        let targetURL = NSURL(string: url)
        UIApplication.sharedApplication().openURL(targetURL!)
    }
}
