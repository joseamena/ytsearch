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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    private let viewModel = VideoSearcherViewModel()
    private var searchcontroller = UISearchController(searchResultsController: nil)

    private let playerView = YTPlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.searchController = searchcontroller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchcontroller.isActive = true
        title = "Videos"

        videosCollectionView.dataSource = viewModel
        videosCollectionView.delegate = viewModel
        viewModel.delegate = self

        viewModel.fetch(searchString: "guitar") {
            self.videosCollectionView.reloadData()
        }

        videosCollectionView.register(UINib(nibName: "VideoThumbnailCell", bundle: nil),
                                      forCellWithReuseIdentifier: "VideoThumbnailCell")


        //add the video player subview and make it hidden
        playerView.delegate = self
//        playerView.isHidden = true
        playerView.backgroundColor = UIColor.brown
        view.addSubview(playerView)
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

extension VideosViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        print(state)
        switch state {
        case .unstarted:
            print("unstarted")
        case .playing:
            print("playing")
            self.videosCollectionView.alpha = 1.0
            activityIndicatorView.stopAnimating()
        case .ended:
            print("ended")
        case .paused:
            print("paused")
        case .buffering:
            print("buffering")
        case .queued:
            print("queued")
            
        default:
            print("unknown")
        }
    }

    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        showAlert(message: "\(error)")
    }
}

extension VideosViewController: VideoListViewModelDelegate {
    func playVideo(with id: String) {

        UIView.animate(withDuration: 0.25) {
            self.videosCollectionView.alpha = 0.5
        }
        activityIndicatorView.startAnimating()
        playerView.load(withVideoId: id)


        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.playerView.playerState() == YTPlayerState.playing {
                return
            }
            self.playerView.stopVideo()
            self.videosCollectionView.alpha = 1.0
            self.activityIndicatorView.stopAnimating()
            self.showAlert(message: "Timeout")
        }
    }
}

//misc helper funtions
extension VideosViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true)
    }
}
