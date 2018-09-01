//
//  YTVideo.swift
//  ytsearch
//
//  Created by Jose on 9/1/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import Foundation

struct YTVideo {
    let description: String?
    let channelTitle: String?
    let channelId: String?
    let title: String?
    let thumbnails: GTLRYouTube_ThumbnailDetails?

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
    init(with snippet: GTLRYouTube_SearchResultSnippet) {
        description = snippet.descriptionProperty
        channelTitle = snippet.channelTitle
        channelId = snippet.channelId
        title = snippet.title
        thumbnails = snippet.thumbnails
    }
}
