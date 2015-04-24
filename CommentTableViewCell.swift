//
//  CommentTableViewCell.swift
//  DNApp
//
//  Created by Meng To on 2015-03-08.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate: class {
    func commentTableViewCellDidTouchUpvote(cell: CommentTableViewCell)
    func commentTableViewCellDidTouchComment(cell: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: AsyncImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var upvoteButton: SpringButton!
    @IBOutlet weak var replyButton: SpringButton!
    @IBOutlet weak var commentTextView: AutoTextView!
    weak var delegate: CommentTableViewCellDelegate?
    @IBOutlet weak var avatarLeftConstraint: NSLayoutConstraint!
    
    @IBAction func upvoteButtonDidTouch(sender: AnyObject) {
        delegate?.commentTableViewCellDidTouchUpvote(self)
        upvoteButton.animation = "pop"
        upvoteButton.force = 3
        upvoteButton.animate()
        SoundPlayer.play("upvote.wav")
    }

    @IBAction func replyButtonDidTouch(sender: AnyObject) {
        delegate?.commentTableViewCellDidTouchComment(self)
        replyButton.animation = "pop"
        replyButton.force = 3
        replyButton.animate()
    }
    
    func configureWithComment(comment: JSON) {
        let userPortraitUrl = comment["user_portrait_url"].string
        let userDisplayName = comment["user_display_name"].string!
        let userJob = comment["user_job"].string ?? ""
        let createdAt = comment["created_at"].string!
        let voteCount = comment["vote_count"].int!
        let body = comment["body"].string!
        let bodyHTML = comment["body_html"].string ?? ""
        
        avatarImageView.url = userPortraitUrl?.toURL()
        avatarImageView.placeholderImage = UIImage(named: "content-avatar-default")
        authorLabel.text = userDisplayName + ", " + userJob
        timeLabel.text = timeAgoSinceDate(dateFromString(createdAt, "yyyy-MM-dd'T'HH:mm:ssZ"), true)
        upvoteButton.setTitle(toString(voteCount), forState: UIControlState.Normal)
        commentTextView.text = body
//        commentTextView.attributedText = htmlToAttributedString(bodyHTML + "<style>*{font-family:\"Avenir Next\";font-size:16px;line-height:20px}img{max-width:300px}</style>")
        
        let commentId = comment["id"].int!
        if LocalStore.isCommentUpvoted(commentId) {
            upvoteButton.setImage(UIImage(named: "icon-upvote-active"), forState: UIControlState.Normal)
            upvoteButton.setTitle(toString(voteCount+1), forState: UIControlState.Normal)
        } else {
            upvoteButton.setImage(UIImage(named: "icon-upvote"), forState: UIControlState.Normal)
            upvoteButton.setTitle(toString(voteCount), forState: UIControlState.Normal)
        }
        
        let depth = comment["depth"].int! > 4 ? 4 : comment["depth"].int!
        if depth > 0 {
            avatarLeftConstraint.constant = CGFloat(depth) * 20 + 25
            separatorInset = UIEdgeInsets(top: 0, left: CGFloat(depth) * 20 + 15, bottom: 0, right: 0)
        } else {
            avatarLeftConstraint.constant = 10
            separatorInset = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
        }
    }
}











