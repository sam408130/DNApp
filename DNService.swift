//
//  DNService.swift
//  DNApp
//
//  Created by Meng To on 2015-03-09.
//  Copyright (c) 2015 Meng To. All rights reserved.
//

import Alamofire

struct DNService {
    
    // Doc: http://developers.news.layervault.com
    
    private static let baseURL = "https://api-news.layervault.com"
    private static let clientID = "750ab22aac78be1c6d4bbe584f0e3477064f646720f327c5464bc127100a1a6d"
    private static let clientSecret = "53e3822c49287190768e009a8f8e55d09041c5bf26d0ef982693f215c72d87da"
    
    private enum ResourcePath: Printable {
        case Login
        case Stories
        case StoryId(storyId: Int)
        case StoryUpvote(storyId: Int)
        case StoryReply(storyId: Int)
        case CommentUpvote(commentId: Int)
        case CommentReply(commentId: Int)
        
        var description: String {
            switch self {
            case .Login: return "/oauth/token"
            case .Stories: return "/api/v1/stories"
            case .StoryId(let id): return "/api/v1/stories/\(id)"
            case .StoryUpvote(let id): return "/api/v1/stories/\(id)/upvote"
            case .StoryReply(let id): return "/api/v1/stories/\(id)/reply"
            case .CommentUpvote(let id): return "/api/v1/comments/\(id)/upvote"
            case .CommentReply(let id): return "/api/v1/comments/\(id)/reply"
            }
        }
    }
    
    static func storiesForSection(section: String, page: Int, response: (JSON) -> ()) {
        let urlString = baseURL + ResourcePath.Stories.description + "/" + section
        let parameters = [
            "page": toString(page),
            "client_id": clientID
        ]
        Alamofire.request(.GET, urlString, parameters: parameters).responseJSON { (_, _, data, _) -> Void in
            let stories = JSON(data ?? [])
            response(stories)
        }
    }
    
    static func storyForId(storyId: Int, response: (JSON) -> ()) {
        let urlString = baseURL + ResourcePath.StoryId(storyId: storyId).description
        let parameters = [
            "client_id": clientID
        ]
        Alamofire.request(.GET, urlString, parameters: parameters).responseJSON { (_, _, data, _) -> Void in
            let story = JSON(data ?? [])
            response(story)
        }
    }
    
    static func loginWithEmail(email: String, password: String, response: (token: String?) -> ()) {
        let urlString = baseURL + ResourcePath.Login.description
        let parameters = [
            "grant_type": "password",
            "username": email,
            "password": password,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        Alamofire.request(.POST, urlString, parameters: parameters).responseJSON { (_, _, data, _) -> Void in
            let json = JSON(data!)
            let token = json["access_token"].string
            response(token: token)
        }
    }
    
    static func upvoteStoryWithId(storyId: Int, token: String, response: (successful: Bool) -> ()) {
        let urlString = baseURL + ResourcePath.StoryUpvote(storyId: storyId).description
        upvoteWithUrlString(urlString, token: token, response: response)
    }
    
    static func upvoteCommentWithId(commentId: Int, token: String, response: (successful: Bool) -> ()) {
        let urlString = baseURL + ResourcePath.CommentUpvote(commentId: commentId).description
        upvoteWithUrlString(urlString, token: token, response: response)
    }
    
    private static func upvoteWithUrlString(urlString: String, token: String, response: (successful: Bool) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Alamofire.request(request).responseJSON { (_, urlResponse, _, _) in
            let successful = urlResponse?.statusCode == 200
            response(successful: successful)
        }
    }
    
    static func replyStoryWithId(storyId: Int, token: String, body: String, response: (successful: Bool) -> ()) {
        let urlString = baseURL + ResourcePath.StoryReply(storyId: storyId).description
        replyWithUrlString(urlString, token: token, body: body, response: response)
    }
    
    static func replyCommentWithId(commentId: Int, token: String, body: String, response: (successful: Bool) -> ()) {
        let urlString = baseURL + ResourcePath.CommentReply(commentId: commentId).description
        replyWithUrlString(urlString, token: token, body: body, response: response)
    }
    
    private static func replyWithUrlString(urlString: String, token: String, body: String, response: (successful: Bool) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.HTTPBody = "comment[body]=\(body)".dataUsingEncoding(NSUTF8StringEncoding)
        
        Alamofire.request(request).responseJSON { (_, _, data, _) -> Void in
            let json = JSON(data!)
            if let comment = json["comment"].string {
                response(successful: true)
            } else {
                response(successful: false)
            }
        }
    }
}















