//
//  VideoThumbnailCell.swift
//  ytsearch
//
//  Created by Jose on 9/1/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import UIKit

class VideoThumbnailCell: UICollectionViewCell {
    @IBOutlet weak var channel: UILabel!
    @IBOutlet weak var channelImage: UIImageView!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    
    @IBOutlet weak var thumbnailView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

}
