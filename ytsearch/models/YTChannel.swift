//
//  YTChannel.swift
//  ytsearch
//
//  Created by Jose on 9/3/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import Foundation

struct YTChannel {
    var id: String?
    var description: String?
    var thumbnails: GTLRYouTube_ThumbnailDetails?
    var title: String?
    var videos: [YTVideo]?
}
