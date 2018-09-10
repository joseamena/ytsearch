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

    private class URLFetcher: LRUFetcher<URL, UIImage> {
        override func fetch(key: URL, completion: ((UIImage?, Error?) -> Void)?) {
            let sessionFetcher = VideoService.shared.service.fetcherService.fetcher(withURLString: key.absoluteString)
            sessionFetcher.authorizer = VideoService.shared.service.authorizer
            sessionFetcher.beginFetch { (data, error) in
                if let error = error {
                    completion?(nil, error)
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    completion?(image, nil)
                }
            }
        }
    }

    private let fetcher = URLFetcher()

    override init() {
        super.init()
        cache.fetcher = fetcher
    }


    public func fetch(searchString: String, searchType: String?, completion: @escaping () -> Void) {

        videos.removeAll()
        VideoService.shared.fetchSearch(queryString: searchString,
                                        searchType: searchType,
                                        completionHandler: { (res, error) -> Void in
                                            
                                            if let error = error {
                                                print(error)
                                                return
                                            }

                                            print(Thread.current)
                                            guard let videos = res as? [YTVideo] else { return }
                                            self.videos = videos

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
        let videoDuration = video.duration ?? ""
        let title = (video.title ?? "") + " (" + videoDuration + ")"
        cell.title.text = title
        cell.channel.text = video.channelTitle
        cell.channelImage.layer.borderWidth = 1
        cell.channelImage.layer.masksToBounds = false
        cell.channelImage.layer.borderColor = UIColor.lightGray.cgColor
        cell.channelImage.layer.cornerRadius = cell.channelImage.frame.height/2
        cell.channelImage.clipsToBounds = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = video.date {
            let dateString = formatter.string(from: date)
            cell.date.text = "Published on: " + dateString
        }

        //load video thumbnail
        serialQueue.async {
            guard let urlString = video.thumbnails?.high?.url else { return }
            guard let url = URL(string: urlString) else { return }

            DispatchQueue.main.async {

                self.cache.getValue(key: url, completion: { (image, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let image = image {
                        cell.thumbnailView.image = image
                    }
                })
            }
        }

        //load channel thumbnail
        serialQueue.async {
            guard let urlString = video.channelThumbnails?.high?.url else { return }
            guard let url = URL(string: urlString) else { return }

            DispatchQueue.main.async {
                self.cache.getValue(key: url, completion: { (image, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    if let image = image {
                        cell.channelImage.image = image
                    }
                })
            }
        }
        return cell
    }
    
}

extension VideoSearcherViewModel: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= videos.count {
            return
        }
        guard let videoId = videos[indexPath.row].id else {
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
            UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown {
            width = collectionView.frame.size.width - 2 * minimumSpacing
        } else {
            width = (collectionView.frame.size.width - 2 * minimumSpacing) / 2
        }

        //TODO: fix hardcoded values
        height = width * 3 / 4  //the video ratio
        height += 88 + 54   //add
        return CGSize(width: width, height: height)
    }
}

