//
//  SAVideoCaptureVC.swift
//  ShrofileAssignment
//
//  Created by Surjeet Rajput on 13/12/17.
//  Copyright © 2017 appigizer. All rights reserved.
//

import UIKit
import AVFoundation


let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

class SAVideoCaptureVC: UIViewController {
  
  @IBOutlet weak var startRecordingButton: UIButton!
  @IBOutlet weak var stopRecordingButton: UIButton!
  
  @IBOutlet weak var previewView: UIView!
  var previewLayer : AVCaptureVideoPreviewLayer!
  var recordingSession = AVCaptureSession()
  
  var recordingOutput = AVCaptureMovieFileOutput()
  
  var shouldAddPreviewLayer = false
  
  var isRecordingStarted = false
  
  var videosUrl = [URL]()
  
  var waitingController : UIAlertController?
  var isRecodingSessionRunning = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if setUpRecordingSession() {
      shouldAddPreviewLayer = true
      startRecordingSession()
    }else {
      //TODO: Display Error Alert.
    }
    let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(_:)))
    rightBarButton.isEnabled = false
    self.navigationItem.rightBarButtonItem = rightBarButton
//    videosUrl.append(contentsOf: URL.testingUrls())
  }
  
  func doneButtonTapped(_ sender : UIBarButtonItem) {
    if videosUrl.count == 1, let url = videosUrl.first  {
      displayVideoPreviewForUrl(url)
    }else {
      mergeVideoFromUrls(videosUrl)
    }
    self.stopRecodingSession()
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    resetCaptureVC()
    startRecordingSession()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if shouldAddPreviewLayer {
      setUpPreviewLayer()
    }
  }
  
  func resetCaptureVC() {
    startRecordingButton.isEnabled = true
    stopRecordingButton.isEnabled = false
    videosUrl.removeAll()
    self.navigationItem.rightBarButtonItem?.isEnabled = false
  }
  
  func setUpPreviewLayer() {
    previewLayer = AVCaptureVideoPreviewLayer(session: recordingSession)
    previewLayer.frame = previewView.bounds
    previewView.layer.addSublayer(previewLayer)
  }
  
  func setUpRecordingSession() -> Bool {
    recordingSession.sessionPreset = AVCaptureSessionPresetHigh
    
    let camera = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera , mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.front) // defaultDevice(withMediaType: AVMediaTypeVideo)
    if let cameraInput = try? AVCaptureDeviceInput(device: camera) {
      if recordingSession.canAddInput(cameraInput) {
        recordingSession.addInput(cameraInput)
      }
    }else {
      return false
    }
    
    let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
    if let microphoneInput = try? AVCaptureDeviceInput(device: microphone) {
      if recordingSession.canAddInput(microphoneInput) {
        recordingSession.addInput(microphoneInput)
      }
    }else {
      return false
    }
    
    if recordingSession.canAddOutput(recordingOutput) {
      recordingSession.addOutput(recordingOutput)
    }
    return true
  }
  
  
  func startRecordingSession() {
    if !recordingSession.isRunning {
      isRecodingSessionRunning = true
      DispatchQueue.main.async {
        self.recordingSession.startRunning()
      }
    }
  }
  
  func stopRecodingSession() {
    if recordingSession.isRunning {
      isRecodingSessionRunning = false
      DispatchQueue.main.async {
        self.recordingSession.stopRunning()
      }
    }
  }
  
  
  func startRecording() {
    if !recordingOutput.isRecording {
      if let connection = recordingOutput.connection(withMediaType: AVMediaTypeVideo) {
        if connection.isVideoStabilizationSupported {
          connection.preferredVideoStabilizationMode = .auto
        }
        
      }
      recordingOutput.startRecording(toOutputFileURL: tempUrl(), recordingDelegate: self)
    }
  }
  
  func stopRecoding() {
    if recordingOutput.isRecording {
      recordingOutput.stopRecording()
    }
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func startRecordingButtonClicked(_ sender: UIButton) {
    if !isRecordingStarted {
      isRecordingStarted = true
      startRecording()
      startRecordingButton.isEnabled = false
      stopRecordingButton.isEnabled = true
      self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
  }
  
  @IBAction func stopRecordingButtonClicked(_ sender: UIButton) {
    if isRecordingStarted {
        stopRecoding()
       isRecordingStarted = false
      startRecordingButton.isEnabled = true
      stopRecordingButton.isEnabled = false
      self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
  }
  
  func displayVideoPreviewForUrl(_ url : URL) {
    let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
    guard let playerNVC = mainStoryBoard.instantiateViewController(withIdentifier: "SAPlayerNVC") as? UINavigationController,
      let playerVC = playerNVC.viewControllers.first as? SAPlayerVC else {
      return
    }
    playerVC.videoUrl = url
    self.present(playerNVC, animated: true, completion: nil)
  }
  
  
}


extension SAVideoCaptureVC : AVCaptureFileOutputRecordingDelegate {
  
  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    print("Recording Started")
  }
  
  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    if error != nil {
      print("Error Occured while capturing video Error : \(error)")
    }else if outputFileURL != nil {
      videosUrl.append(outputFileURL)
//      displayVideoPreviewForUrl(outputFileURL)
      //self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    print("VIdeo Captured Successfully")
  }
  
  func tempUrl() -> URL {
    return URL.tempUrl()
  }
}

//*******************************//
//MARK: Merge and Export.
//*******************************//
extension SAVideoCaptureVC {
  
  func mergeVideoFromUrls(_ urls : [URL]) {
    var avUrlAssets = [AVURLAsset]()
    for url in urls {
      avUrlAssets.append(AVURLAsset(url: url))
    }
    
    let composition = AVMutableComposition()
    let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    var startAt = kCMTimeZero
    for avUrlAsset in avUrlAssets {
      
      //Video Part
      //let compostionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
      let timeRange = CMTimeRangeMake(kCMTimeZero, avUrlAsset.duration)
      if let track = avUrlAsset.tracks(withMediaType: AVMediaTypeVideo).first {
        do {
          try compositionVideoTrack.insertTimeRange(timeRange, of: track, at: startAt)
        }catch {
          print("Some error occured while merging tracks.")
        }
      }
      //Audio Part
      let compostionTrackAudio = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
      if let trackAudio = avUrlAsset.tracks(withMediaType: AVMediaTypeAudio).first {
        do {
          try compostionTrackAudio.insertTimeRange(timeRange, of: trackAudio, at: startAt)
        }catch {
          print("Some error occured while merging tracks.")
        }
      }
      startAt = CMTimeAdd(startAt, avUrlAsset.duration)
    }
    guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
      return
    }
    exportSession.outputFileType = AVFileTypeMPEG4
    let outputFileUrl = URL.tempUrl()
    exportSession.outputURL = outputFileUrl
    weak var weakSelf = self
    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .cancelled:
        print("Export Session Cancelled")
      case .completed:
        print("File Merge completed")
        weakSelf?.filesMergedAtUrl(outputFileUrl)
      case .failed:
        print("File Merge Failed")
        if let error = exportSession.error {
          print("Error while merging file : \(error)")
        }
      default:
        print("Some unknown status : \(exportSession.status)")
      }
    }
  }
  
  func filesMergedAtUrl(_ url : URL?) {
    guard let mergeVideoUrl = url else {
      print("Unable to merge Url ")
      return
    }
    let asset = AVAsset(url: mergeVideoUrl)
    displayVideoPreviewForUrl(mergeVideoUrl)
  }
  
  func displayWaitingAlert() {
    let alert = UIAlertController(title: "Please wait", message: "Merging videos", preferredStyle: .alert)
    waitingController = alert
    self.present(alert, animated: true, completion: nil)
  }
  
  func hideWaitingController() {
    self.waitingController?.dismiss(animated: true, completion: nil)
  }
  
  
}



extension URL {
  
  static func tempUrl() -> URL {
    let directory = docDir.appendingPathComponent(UUID().uuidString + ".mp4")
    return directory
  }
  
  static func testingUrls() -> [URL] {
    var urls = [URL]()
    let video1Url = Bundle.main.url(forResource: "sample_iPod_part1", withExtension: ".mp4")!
    let video2Url = Bundle.main.url(forResource: "sample_iPod_part1", withExtension: ".mp4")!
    urls.append(video1Url)
    urls.append(video2Url)
    return urls
    
    
    
  }
  
}




