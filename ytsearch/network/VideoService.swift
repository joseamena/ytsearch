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

        service.executeQuery(query) { [weak self](ticket, obj, error) in
            var channelsDictionary = [String : YTChannel] ()
            //create YTVideo objects and query the channels and videos
            //as we need more data
            var channelsIdentifier  = ""
            var videosIdentifier = ""
            var index = 0

            guard let response = obj as? GTLRYouTube_SearchListResponse else { return }

            if let items = response.items {
                for item in items {

                    let video:YTVideo = YTVideo()
                    video.title = item.snippet?.title
                    video.description = item.snippet?.descriptionProperty
                    video.date = item.snippet?.publishedAt?.date
                    video.thumbnails = item.snippet?.thumbnails
                    video.id = item.identifier?.videoId

                    if let channelId = item.snippet?.channelId {
                        let channel = YTChannel()
                        channel.id = item.snippet?.channelId
                        channel.title = item.snippet?.channelTitle
                        channel.addVideo(video: video)
                        channelsDictionary[channelId] = channel
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
            //query the videos
            let videosQuery = GTLRYouTubeQuery_VideosList.query(withPart: "snippet,contentDetails")
            videosQuery.identifier = videosIdentifier
            self?.service.executeQuery(videosQuery) { [weak self] (ticket, obj, error) in
                if let error = error {
                    print("could not fetch videos \(error)")
                    return
                }
                var videos = [YTVideo]()
                if let response = obj as? GTLRYouTube_VideoListResponse {
                    if let items = response.items {
                        for item in items {
                            if let channelId = item.snippet?.channelId,
                                let channel = channelsDictionary[channelId], let videoId = item.identifier  {
//                                print(item.contentDetails)
                                let durationISO = item.contentDetails?.duration ?? ""
                                let index = durationISO.index(durationISO.startIndex, offsetBy: 2)
                                let temp = String(durationISO[index...])
                                let components = temp.components(separatedBy: CharacterSet(charactersIn: "HSM"))
                                var duration = ""
                                if components.count == 4 {
                                    duration = "\(components[0]):\(components[1]):\(components[2])"
                                } else if components.count == 3 {
                                    duration = "\(components[0]):\(components[1])"
                                } else if components.count == 2 {
                                    duration = components[0]
                                }

                                //TODO parse duration into a nicer format
                                guard let video = channel.getVideo(with: videoId) else { continue }
                                video.duration = duration
                                videos.append(video)
                            }
                        }
                    }
                }
                //query the channels
                let channelsQuery = GTLRYouTubeQuery_ChannelsList.query(withPart: "snippet")
                channelsQuery.identifier = channelsIdentifier
                self?.service.executeQuery(channelsQuery) { [weak self] (ticket, obj, error) in
                    if let error = error {
                        print("could not fetch channels \(error)")
                        return
                    }
                    if let response = obj as? GTLRYouTube_ChannelListResponse {
                        if let items = response.items {
                            for item in items {
                                if let channelId = item.identifier, let channel = channelsDictionary[channelId] {
                                    channel.thumbnails = item.snippet?.thumbnails
                                }
                            }
                        }
                    }
                    self?.queryCompletionHandler?(videos, error)
                    self?.queryCompletionHandler = nil
                }
            }
        }
    }

    func isLoggedIn() -> Bool {
        return false
    }
}

