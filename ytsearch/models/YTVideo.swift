//
//  YTVideo.swift
//  ytsearch
//
//  Created by Jose on 9/1/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import Foundation

struct YTVideo {
    let videoId: String?
    let description: String?
    let channelTitle: String?
    let channelId: String?
    let title: String?
    let thumbnails: GTLRYouTube_ThumbnailDetails?
    let date: Date?

    init(with searchResult: GTLRYouTube_SearchResult) {
        description = searchResult.snippet?.descriptionProperty
        channelTitle = searchResult.snippet?.channelTitle
        channelId = searchResult.snippet?.channelId
        title = searchResult.snippet?.title
        thumbnails = searchResult.snippet?.thumbnails
        date = searchResult.snippet?.publishedAt?.date
        videoId = searchResult.identifier?.videoId
    }

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
