//
//  GIFSearcherViewModel.swift
//  GIFSearcher
//
//  Created by Viviana Uscocovich-Mena on 11/22/17.
//  Copyright © 2017 Jose Mena. All rights reserved.
//

import UIKit

class GIFSearcherViewModel : NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    var gifInfos : [GIF]?
    private let serialQueue = DispatchQueue(label: "com.twothumbsapp.serial")
    private var cache = LRUCache<IndexPath,UIImage>(size: 25)
    let columns: CGFloat = 2.0
    let inset: CGFloat = 8.0
    let spacing: CGFloat = 8.0
    
    public func fetchTrendingGifs(completion: @escaping () -> Void) {
        NetworkClient.shared.fetchTrending(success: { (res) -> Void in
            self.gifInfos = res
            completion()
            }, failure: { (err) -> Void in
                if let error = err {
                    print(error)
                }
                print("failed to fetch trending GIFS")
        })
    }

    public func fetch(searchString: String, completion: @escaping () -> Void) {
        cache.clear()
        
        let stringArray = searchString.lowercased().components(separatedBy: " ")
        var queryString = ""
        
        for i in 0..<stringArray.count {
            if i != stringArray.count - 1 {
                queryString += stringArray[i] + "+"
            } else {
                queryString += stringArray[i]
            }
        }
        
        NetworkClient.shared.fetchSearch(queryString: queryString, success: { (res) -> Void in
            self.gifInfos = res
            completion()
            }, failure: { (err) -> Void in
                if let error = err {
                    print(error)
                }
                print("failed to fetch \(searchString)")
        })
    }
    
    public var gifCount: Int {
        if let gifInfos = gifInfos {
            return gifInfos.count
        }
        return 0
    }
    
    public func image(forItemAt indexPath: IndexPath) -> UIImage? {
        if let image = cache.getValue(key: indexPath) {
            return image
        }
        
        if let gifUrlString = gifInfos?[indexPath.row].url {
            let image = UIImage.gif(url: gifUrlString)
            if let image = image {
                cache.set(value: image, forKey: indexPath)
            }
            return image
        }
        
        return nil
    }
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            serialQueue.async {
                if let gifUrlString = self.gifInfos?[indexPath.row].url {
                    let image = UIImage.gif(url: gifUrlString)
                    if let image = image {
                        self.cache.set(value: image, forKey: indexPath)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("cancel prefetching for \(indexPaths)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
        
        guard let imageView = cell.viewWithTag(1) as? UIImageView else {
            return cell
        }
        
        serialQueue.async {
            guard let image = self.image(forItemAt: indexPath) else {
                return
            }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        return cell
    }
    
}

extension GIFSearcherViewModel: MosaicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let width = gifInfos?[indexPath.row].width,
            let height = gifInfos?[indexPath.row].height else {
                return CGSize(width: 0, height: 0)
        }
        
        return CGSize(width: width, height: height)
    }
}

extension GIFSearcherViewModel: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let maxWidth = (collectionView.frame.width / columns) - (inset + spacing)
    
        guard let width = gifInfos?[indexPath.row].width,
            let height = gifInfos?[indexPath.row].height else {
            return CGSize(width: maxWidth, height: maxWidth)
        }
        
        let scale = maxWidth / width
        let scaledheight = scale * height
        
        return CGSize(width: maxWidth, height: scaledheight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(inset, inset, inset, inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
