//
//  GIFSearcherViewModel.swift
//  GIFSearcher
//
//  Created by Viviana Uscocovich-Mena on 11/22/17.
//  Copyright © 2017 Jose Mena. All rights reserved.
//

import UIKit

protocol VideoListViewModelDelegate {
    func playVideo(with id: String)
}

class VideoSearcherViewModel : NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

    var delegate: VideoListViewModelDelegate?
    var videos : [YTVideo] = []
    private let serialQueue = DispatchQueue(label: "com.joseamena.serial")
    private var cache = LRUCache<URL,UIImage>(size: 10)
    let columns: CGFloat = 2.0
    let inset: CGFloat = 8.0
    let spacing: CGFloat = 8.0

    private class URLFetcher: LRUFetcher<URL> {
        override func fetch(key: URL, completion: ((Data?, Error?) -> Void)?) {
            let sessionFetcher = VideoService.shared.service.fetcherService.fetcher(withURLString: key.absoluteString)
            sessionFetcher.authorizer = VideoService.shared.service.authorizer
            sessionFetcher.beginFetch { (data, error) in
                completion?(data, error)
            }
        }
    }

    private let fetcher = URLFetcher()

    override init() {
        super.init()
        cache.fetcher = fetcher
    }


    public func fetch(searchString: String, completion: @escaping () -> Void) {

        let stringArray = searchString.lowercased().components(separatedBy: " ")
        var queryString = ""
        
        for i in 0..<stringArray.count {
            if i != stringArray.count - 1 {
                queryString += stringArray[i] + "+"
            } else {
                queryString += stringArray[i]
            }
        }
        videos.removeAll()
        VideoService.shared.fetchSearch(queryString: queryString, completionHandler: { (res, error) -> Void in
            if let error = error {
                print(error)
                return
            }
            print("we are in thread \(Thread.current), and main is \(Thread.main)")
            if (Thread.isMainThread) {
                print("we are in the main thread")
            } else {
                print("we are not in the main thread")
            }

            guard let searchResults = res as? [GTLRYouTube_SearchResult] else { return }

            for result in searchResults {
                let video = YTVideo(with: result)
                self.videos.append(video)
            }
            completion()
        })
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
//            serialQueue.async {
//                let video = self.videos[indexPath.row]
//                guard let videoURLString = video.thumbnails?.defaultProperty?.url else { return }
//                let videoURL = URL(fileURLWithPath: videoURLString)
//                _ = self.cache.getValue(key: videoURL, completion: { (data, error) -> Void in
//                    
//                })
//            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("cancel prefetching for \(indexPaths)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoThumbnailCell",
                                                      for: indexPath) as! VideoThumbnailCell

        if indexPath.row >= videos.count {
            return cell
        }
        let video = videos[indexPath.row]
        cell.videoDescription.text = video.description
        cell.title.text = video.title
        cell.channel.text = video.channelTitle
        print("channel id: \(video.channelId ?? "none")")
        print("width: \(video.thumbnailWidth) height: \(video.thumbnailHeight)")
        serialQueue.async {
            guard let urlString = video.thumbnails?.high?.url else { return }

            guard let url = URL(string: urlString) else { return }

            DispatchQueue.main.async {

                let image = self.cache.getValue(key: url, completion: {(data, error) in
                    //called if the image was nil
                    if let error = error {
                        print(error)
                        return
                    }
                    if let data = data, let img = UIImage(data: data) {
                        cell.thumbnailView.image = img
                        self.cache.set(value: img, forKey: url) //set it on the LRUCache
                    }
                })

                if let image = image {
                    cell.thumbnailView.image = image
                }
            }
        }
        return cell
    }
    
}

extension VideoSearcherViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item \(indexPath.row)\n")
        guard let videoId = videos[indexPath.row].videoId else {
            print("no videoID")
            return
        }
        delegate?.playVideo(with: videoId)
    }
}

extension VideoSearcherViewModel: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var width: CGFloat
        var height: CGFloat

        let minimumSpacing:CGFloat = 10.0
        if UIDevice.current.orientation == UIDeviceOrientation.portrait ||
            UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown{
            width = collectionView.frame.size.width - 2 * minimumSpacing
            height = width * 4 / 3
        } else {
            width = (collectionView.frame.size.width - 2 * minimumSpacing) / 2
            height = width * 1.2
        }

        return CGSize(width: width, height: height)
    }
}

