//
//  ViewController.swift
//  ytsearch
//
//  Created by Jose on 8/29/18.
//  Copyright © 2018 Jose A. Mena. All rights reserved.
//

import GoogleSignIn
import UIKit

class VideosViewController: UIViewController {

    @IBOutlet weak var videosCollectionView: UICollectionView!
    @IBOutlet weak var logOutButton: UIBarButtonItem!

    private let viewModel = VideoSearcherViewModel()
    private var searchcontroller = UISearchController(searchResultsController: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.searchController = searchcontroller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchcontroller.isActive = true
        title = "Videos"

        videosCollectionView.dataSource = viewModel
        videosCollectionView.delegate = self

        viewModel.fetch(searchString: "guitar") {
            self.videosCollectionView.reloadData()
        }

        videosCollectionView.register(UINib(nibName: "VideoThumbnailCell", bundle: nil),
                                      forCellWithReuseIdentifier: "VideoThumbnailCell")
        
    }

    @IBAction func logOut(_ sender: Any) {
        print("loging out")
        self.dismiss(animated: true, completion: nil)
        GIDSignIn.sharedInstance().signOut()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videosCollectionView.reloadData()
    }
}

extension VideosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item \(indexPath.row)\n")
    }
}

extension VideosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var width: CGFloat
        var height: CGFloat

        let minimumSpacing:CGFloat = 10.0
        if UIDevice.current.orientation == UIDeviceOrientation.portrait ||
            UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown{
            width = self.view.frame.size.width - 2 * minimumSpacing





        } else {
            width = (self.view.frame.size.width - 2 * minimumSpacing) / 2

        }

        //TODO: fix these hardcoded values
        height = width * 3 / 4  //the thumbnails have 4:3 ratio
        height += 88 + 54       //I know I need at least the image(75) and the label(54)

        return CGSize(width: width, height: height)
    }
}
