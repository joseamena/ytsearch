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
    private let pickerView = UIPickerView()
    private let playerView = YTPlayerView()
    private let searchTypes = ["Any", "Movie", "Episode"]
    private var selectedSearchType: String? {
        didSet {
            if selectedSearchType != oldValue {
                //perform fetch again
                guard let searchText = searchcontroller.searchBar.text else { return }
                viewModel.fetch(searchString: searchText, searchType: selectedSearchType?.lowercased()) {
                    self.videosCollectionView.reloadData()
                }
            }
        }
    }

    var pickerViewHeightConstraint : NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.searchController = searchcontroller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchcontroller.isActive = true
        searchcontroller.searchBar.delegate = self
        searchcontroller.obscuresBackgroundDuringPresentation = true
        searchcontroller.searchBar.placeholder = "Search Videos"

        definesPresentationContext = true
        title = "YT SEARCH"

        videosCollectionView.dataSource = viewModel
        videosCollectionView.delegate = viewModel
        viewModel.delegate = self


        videosCollectionView.register(UINib(nibName: "VideoThumbnailCell", bundle: nil),
                                      forCellWithReuseIdentifier: "VideoThumbnailCell")



        //add the video player
        playerView.delegate = self
        playerView.backgroundColor = UIColor.brown
        view.addSubview(playerView)

        //add picker view
        pickerView.backgroundColor = UIColor.lightGray
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        pickerViewHeightConstraint = NSLayoutConstraint(item: pickerView,
                                                        attribute: .height,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1,
                                                        constant: 0)

        pickerView.addConstraint(pickerViewHeightConstraint!)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.fetch(searchString: "", searchType: selectedSearchType?.lowercased()) {
            self.videosCollectionView.reloadData()
        }
    }

    @IBAction func logOut(_ sender: Any) {
        print("loging out")
        self.dismiss(animated: true, completion: nil)
        GIDSignIn.sharedInstance().signOut()
    }

    @IBAction func selectSearchType(_ sender: UIBarButtonItem) {
        UIView.animate(withDuration: 0.5) {
            self.pickerViewHeightConstraint?.constant = 100
            self.view.layoutIfNeeded()
        }
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
        if (!playerView.load(withVideoId: id)) {
            self.showAlert(message: "Error loading video")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if self.playerView.playerState() == YTPlayerState.playing ||
                self.playerView.playerState() == .paused {
                return
            }
            self.playerView.stopVideo()
            self.videosCollectionView.alpha = 1.0
            self.activityIndicatorView.stopAnimating()
            self.showAlert(message: "Timeout")
        }
    }
}


extension VideosViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchcontroller.dismiss(animated: true, completion: nil)
        guard let searchText = searchBar.text else { return }

        viewModel.fetch(searchString: searchText, searchType: selectedSearchType?.lowercased()) {
            self.videosCollectionView.reloadData()
        }
    }
}

extension VideosViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return searchTypes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSearchType = searchTypes[row]
        UIView.animate(withDuration: 0.5) {
            self.pickerViewHeightConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return searchTypes.count
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
