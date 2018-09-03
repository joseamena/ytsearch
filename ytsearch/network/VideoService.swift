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

    var queryCompletionHandler: (([Any]?, Error?) -> Void)?

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
    
    public func fetchSearch(queryString: String, searchType: String?, completionHandler: (([Any]?, Error?) -> Void)?) {

        let query = GTLRYouTubeQuery_SearchList.query(withPart: "snippet")
        query.q = queryString
        query.type = "video"
        query.videoType = searchType
        query.maxResults = 10

        queryCompletionHandler = completionHandler
//        service.executeQuery(query,
//                             delegate: self,
//                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:)))

        service.executeQuery(query) { [weak self](ticket, obj, error) in
            var videosDictionary = [String : YTVideo] ()
            //create YTVideo objects and query the channels and videos
            //as we need more data
            var channelsIdentifier  = ""
            var videosIdentifier = ""
            var index = 0

            guard let response = obj as? GTLRYouTube_SearchListResponse else { return }

            if let items = response.items {
                for item in items {

                    var video:YTVideo = YTVideo()
                    video.title = item.snippet?.title
                    video.description = item.snippet?.description
                    video.date = item.snippet?.publishedAt?.date
                    video.thumbnails = item.snippet?.thumbnails
                    video.id = item.identifier?.videoId
                    video.channel.id = item.snippet?.channelId
                    video.channel.title = item.snippet?.channelTitle

                    if let videoId = video.id {
                        videosDictionary[videoId] = video
                    }
                    if let channelId = item.snippet?.channelId {
                        channelsIdentifier += "\(channelId)"
                        if index < items.count {
                            channelsIdentifier += ","
                        }
                    }
                    if let videoId = item.identifier?.videoId {
                        videosIdentifier += "\(videoId)"
                        if index < items.count {
                            videosIdentifier += ","
                        }
                    }
                    index += 1
                }
            }

            //nest the queries so that we call the completion handler when all is done
            //query the channels
            //        let channelsQuery = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet")
            //        channelsQuery.identifier = channelsIdentifier
            //        service.executeQuery(channelsQuery) { (ticket, obj, error) in
            //            if let error = error {
            //                print("could not fetch channels \(error)")
            //                return
            //            }
            //            if let response = obj as? GTLRYouTube_ChannelListResponse {
            //                for item in response.items! {
            //                    print(item)
            //                }
            //            }
            //        }

            //query the videos
            let videosQuery = GTLRYouTubeQuery_VideosList.query(withPart: "snippet")
            videosQuery.identifier = videosIdentifier
            self?.service.executeQuery(videosQuery) { [weak self] (ticket, obj, error) in
                if let error = error {
                    print("could not fetch videos \(error)")
                    return
                }
                if let response = obj as? GTLRYouTube_VideoListResponse {
                    if let items = response.items {
                        for item in items {
                            if let id = item.identifier, let video = videosDictionary[id] {
                                print(item.fileDetails?.durationMs)
                                video.durationMs = item.fileDetails?.durationMs?.intValue ?? 0
                            }
                        }
                    }
                }

                self?.queryCompletionHandler?(Array(videosDictionary.values), error)
                self?.queryCompletionHandler = nil
        }
    }


//    @objc func displayResultWithTicket(
//        ticket: GTLRServiceTicket,
//        finishedWithObject response : GTLRYouTube_SearchListResponse,
//        error : NSError?) {
//
//        var videosDictionary = [String : YTVideo] ()
//        //create YTVideo objects and query the channels and videos
//        //as we need more data
//        var channelsIdentifier  = ""
//        var videosIdentifier = ""
//        var index = 0
//        if let items = response.items {
//            for item in items {
//
//                var video:YTVideo = YTVideo()
//                video.title = item.snippet?.title
//                video.description = item.snippet?.description
//                video.date = item.snippet?.publishedAt?.date
//                video.thumbnails = item.snippet?.thumbnails
//                video.id = item.identifier?.videoId
//                video.channel.id = item.snippet?.channelId
//                video.channel.title = item.snippet?.channelTitle
//
//                if let videoId = video.id {
//                    videosDictionary[videoId] = video
//                }
//                if let channelId = item.snippet?.channelId {
//                    channelsIdentifier += "\(channelId)"
//                    if index < items.count {
//                        channelsIdentifier += ","
//                    }
//                }
//                if let videoId = item.identifier?.videoId {
//                    videosIdentifier += "\(videoId)"
//                    if index < items.count {
//                        videosIdentifier += ","
//                    }
//                }
//                index += 1
//            }
//        }
//
//        //nest the queries so that we call the completion handler when all is done
//        //query the channels
////        let channelsQuery = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet")
////        channelsQuery.identifier = channelsIdentifier
////        service.executeQuery(channelsQuery) { (ticket, obj, error) in
////            if let error = error {
////                print("could not fetch channels \(error)")
////                return
////            }
////            if let response = obj as? GTLRYouTube_ChannelListResponse {
////                for item in response.items! {
////                    print(item)
////                }
////            }
////        }
//
//        //query the videos
//        let videosQuery = GTLRYouTubeQuery_VideosList.query(withPart: "snippet")
//        videosQuery.identifier = videosIdentifier
//        service.executeQuery(videosQuery) { [weak self] (ticket, obj, error) in
//            if let error = error {
//                print("could not fetch videos \(error)")
//                return
//            }
//            if let response = obj as? GTLRYouTube_VideoListResponse {
//                if let items = response.items {
//                    for item in items {
//                        if let id = item.identifier, var video = videosDictionary[id] {
//                            video.durationMs = item.fileDetails?.durationMs?.intValue ?? 0
//                        }
//                    }
//                }
//            }
//            self?.queryCompletionHandler?(response.items, error)
//            self?.queryCompletionHandler = nil
//        }



    }

    func isLoggedIn() -> Bool {
        return false
    }
}

