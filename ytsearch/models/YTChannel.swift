//
//  YTChannel.swift
//  ytsearch
//
//  Created by Jose on 9/3/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import Foundation

class YTChannel {
    var id: String?
    var description: String?
    var thumbnails: GTLRYouTube_ThumbnailDetails?
    var title: String?
    private var videos = [String : YTVideo]()

    func addVideo(video: YTVideo) {
        if let id = video.id {
            videos[id] = video
        }
    }

    func getVideo(withId id: String) -> YTVideo? {
        return videos[id]
    }

    func getAllVideos() -> [YTVideo] {
        return Array(videos.values)
    }
}
