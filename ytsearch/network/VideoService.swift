//
//  NetworkClient.swift
//  GIFSearcher
//
//  Created by Viviana Uscocovich-Mena on 11/21/17.
//  Copyright © 2017 Jose Mena. All rights reserved.
//

import Foundation
import GoogleSignIn

protocol NetworkClientDelegate: class {

}
class VideoService: NSObject {

    public let service = GTLRYouTubeService()
    weak var delegate: NetworkClientDelegate?

    private var googleUser: GIDGoogleUser?

    var queryCompletionHandler: (([Any]?, NSError?) -> Void)?

    var user: GIDGoogleUser? {
        get {
            return googleUser
        }
        set(newValue) {
            googleUser = newValue
            service.authorizer = user?.authentication.fetcherAuthorizer()
        }
    }
    
    public static let shared: VideoService = {
        return VideoService()
    }()
    
    private override init() {
        super.init()
    }
    
    private func fetch(endpoint: String,
                       success: @escaping([Any]) -> Void,
                       failure: @escaping(Error?) -> Void) {

    }
    
    public func fetchTrending(success: @escaping ([Any]) -> Void,
                              failure: @escaping (Error?) -> (Void)) {
        fetch(endpoint: "trending?", success: success, failure: failure)
    }
    
    public func fetchSearch(queryString: String, completionHandler: (([Any]?, NSError?) -> Void)?) {

        let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        query.q = queryString
        query.maxResults = 10

        queryCompletionHandler = completionHandler
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))
    }


    @objc func displayResultWithTicket(
        ticket: GTLRServiceTicket,
        finishedWithObject response : GTLRYouTube_SearchListResponse,
        error : NSError?) {

        queryCompletionHandler?(response.items, error)
        queryCompletionHandler = nil

    }

    func isLoggedIn() -> Bool {
        return false
    }
}

