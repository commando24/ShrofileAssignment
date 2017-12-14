//
//  SAPlayerVC.swift
//  ShrofileAssignment
//
//  Created by Surjeet Rajput on 13/12/17.
//  Copyright © 2017 appigizer. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreImage


struct VideoInformation : Equatable {
  var videoUrl : URL?
  var title : String
  
  static func ==(lhs : VideoInformation, rhs : VideoInformation) -> Bool {
    return lhs.title == rhs.title
  }
  
}

class SAPlayerVC: UIViewController {
  
  var videosInfomation = [VideoInformation]()
  var selectedVideo : VideoInformation?
  
  var videoUrl : URL? {
    didSet {
      let info = VideoInformation(videoUrl: videoUrl, title: "Normal")
      videosInfomation.append(info)
      selectedVideo = info
    }
  }
  var playerController = AVPlayerViewController()
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let videoUrl = selectedVideo?.videoUrl else {
      self.dismiss(animated: true, completion: nil)
      return
    }
    self.addChildVC(vc: playerController, holderView: contentView, constraintToHolder: true)
    self.playerController.player = AVPlayer(url: videoUrl)
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissButtonTapped(_:)))
    self.navigationItem.leftBarButtonItem = cancelButton
    let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped(_:)))
    self.navigationItem.rightBarButtonItem = saveButton
    applyFilterAndExportVideoFromUrl(videoUrl)
  }
  
  func dismissButtonTapped(_ sender : UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func applyFilterAndExportVideoFromUrl(_ url : URL) {
    let asset = AVAsset(url: url)
    let filter = CIFilter(name: "CIPhotoEffectTonal")!
    let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
      let source = request.sourceImage.clampingToExtent()
      filter.setValue(source, forKey: kCIInputImageKey)
      let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
      request.finish(with: output, context: nil)
    })
    if let export = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
      export.outputFileType = AVFileTypeQuickTimeMovie
      let exportUrl = URL.tempUrl()
      export.outputURL = exportUrl
      export.videoComposition = composition
      weak var weakSelf = self
      export.exportAsynchronously(completionHandler: {
        print("File successully saved.")
        DispatchQueue.main.async {
          //weakSelf?.changePlayerItemForUrl(exportUrl)
          weakSelf?.filterApplied("B & W", url: exportUrl)
        }
      })
    }
  }
  
  func filterApplied(_ name : String, url : URL) {
    let newVIdeoInfo = VideoInformation(videoUrl: url, title: name)
    videosInfomation.append(newVIdeoInfo)
    collectionView.reloadData()
  }
  
  func changePlayerItemForUrl(_ url : URL) {
    let item = AVPlayerItem(url: url)
    self.playerController.player?.replaceCurrentItem(with: item)
  }
  
  func isVideoInfomationSelected(_ info : VideoInformation) -> Bool {
    guard let currentInfo = selectedVideo else {
      return false
    }
    return info == currentInfo
  }
  
  func newVideoInformationSelected(_ info : VideoInformation) {
    selectedVideo = info
    if let url = info.videoUrl {
        changePlayerItemForUrl(url)
    }
  }
  
  
  @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
    guard let selectedVideo = selectedVideo,
      let url = selectedVideo.videoUrl else {
      return
    }
    saveVideoInGalleryAtUrl(url)
  }
  
  func saveVideoInGalleryAtUrl(_ url : URL)  {
    UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
  }
  
  
}

extension SAPlayerVC : UICollectionViewDataSource, UICollectionViewDelegate {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return videosInfomation.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoInfoCVCell", for: indexPath) as! VideoInfoCVCell
    let info = videosInfomation[indexPath.row]
    let isSelected = isVideoInfomationSelected(info)
    cell.customizeForTitle(info.title, isSelected: isSelected)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let newSelectedItem = videosInfomation[indexPath.row]
    if !isVideoInfomationSelected(newSelectedItem) {
      newVideoInformationSelected(newSelectedItem)
      collectionView.reloadData()
    }
  }
  
}



