//
//  YTVideo.swift
//  ytsearch
//
//  Created by Jose on 9/1/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import Foundation


class YTVideo: Hashable {
    
    var hashValue: Int {
        return id?.hashValue ?? 0
    }

    static func == (lhs: YTVideo, rhs: YTVideo) -> Bool {
        return lhs.id == rhs.id
    }

    var id: String?
    var description: String?
    var title: String?
    var thumbnails: GTLRYouTube_ThumbnailDetails?
    var date: Date?
    var duration: String?
    var channelId: String?
    var channelThumbnails: GTLRYouTube_ThumbnailDetails?
    var channelTitle: String?

    
//    init(with searchResult: GTLRYouTube_SearchResult) {
//        description = searchResult.snippet?.descriptionProperty
//        channelTitle = searchResult.snippet?.channelTitle
//        channelId = searchResult.snippet?.channelId
//        title = searchResult.snippet?.title
//        thumbnails = searchResult.snippet?.thumbnails
//        date = searchResult.snippet?.publishedAt?.date
//        videoId = searchResult.identifier?.videoId
//    }

    var thumbnailWidth: CGFloat {
        get {
            guard let width = thumbnails?.high?.width?.floatValue else { return 0 }
            return CGFloat(width)
        }
    }

    var thumbnailHeight: CGFloat {
        get {
            guard let height = thumbnails?.high?.height?.floatValue else { return 0 }
            return CGFloat(height)
        }
    }
}
