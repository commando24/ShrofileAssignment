//
//  SAImageCaptureVC.swift
//  ShrofileAssignment
//
//  Created by Surjeet Rajput on 17/12/17.
//  Copyright © 2017 appigizer. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class SAImageCaptureVC: UIViewController {

  @IBOutlet weak var previewView: UIView!
  var previewLayer : AVCaptureVideoPreviewLayer!
  var recordingSession = AVCaptureSession()
  
  var imageMetaData = AVCaptureMetadataOutput()
  var imageCaptureOutput = AVCaptureStillImageOutput()
  
  var shouldAddPreviewLayer = false
  
  var isRecordingStarted = false
  
  var videosUrl = [URL]()
  
  var waitingController : UIAlertController?
  var isRecodingSessionRunning = false
  
  var faceOutline : UIView?
  
  @IBOutlet weak var captureButton: UIButton!
  
  
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
    
    if recordingSession.canAddOutput(imageMetaData) {
      recordingSession.addOutput(imageMetaData)
      imageMetaData.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      imageMetaData.metadataObjectTypes = [AVMetadataObjectTypeFace]
    }
    
    if recordingSession.canAddOutput(imageCaptureOutput) {
      recordingSession.addOutput(imageCaptureOutput)
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func captureImage() {
    var videoConnection : AVCaptureConnection?
    for connection in imageCaptureOutput.connections {
      if let avConnection = connection as? AVCaptureConnection {
        for port in avConnection.inputPorts {
          if let inputPort = port as? AVCaptureInputPort, inputPort.mediaType == AVMediaTypeVideo {
            videoConnection = avConnection
          }
        }
      }
    }
    if let videoConnection = videoConnection {
      imageCaptureOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer, error) in
        if let error = error {
          print("Some Error Occured Error : \(error)")
        }else {
          if let buffer = buffer {
            if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
              let image = UIImage(data: imageData) {
              self.displayVideoPreviewForImage(image)
            }
          }
        }
      })
    }
  }
  
  func displayVideoPreviewForImage(_ image : UIImage) {
    let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
    guard let playerNVC = mainStoryBoard.instantiateViewController(withIdentifier: "SAImagePreviewNVC") as? UINavigationController,
      let previewVC = playerNVC.viewControllers.first as? SAImagePreviewVC else {
        return
    }
    previewVC.image = image
    self.present(playerNVC, animated: true, completion: nil)
  }
  
  
  @IBAction func captureButtonTapped(_ sender: UIButton) {
    captureImage()
  }
  
  func drawRectangeOnBounds(_ bounds : CGRect) {
    if let faceOutline = faceOutline {
      faceOutline.frame = bounds
    }else {
      let indicator = UIView(frame: bounds)
      indicator.frame =  bounds
      indicator.layer.borderWidth = 3
      indicator.layer.borderColor = UIColor.red.cgColor
      indicator.backgroundColor = .clear
      self.previewView.addSubview(indicator)
      self.faceOutline = indicator
    }
    
  }
  
  func convertXValue(_ x : CGFloat, y: CGFloat) -> CGFloat {
    return x*cos(Int(-90).degreesToRadians) - y*sin(Int(-90).degreesToRadians)
  }
  
  func convertYValue(_ x : CGFloat, y: CGFloat) -> CGFloat {
    return y*cos(Int(-90).degreesToRadians) - x*sin(Int(-90).degreesToRadians)
  }
  
  
}


extension SAImageCaptureVC : AVCaptureMetadataOutputObjectsDelegate {
  
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
    for metaData in metadataObjects {
      if let faceMetaData = metaData as? AVMetadataObject,
        faceMetaData.type == AVMetadataObjectTypeFace {
        let faceBounds = faceMetaData.bounds
        print("face bounds : \(faceBounds)")
        let newX = faceBounds.origin.x * self.previewView.frame.width
        let newY = faceBounds.origin.y * self.previewView.frame.height
        let newWidth = faceBounds.size.width * self.previewView.frame.height
        let newHeight = faceBounds.size.height * self.previewView.frame.width
        let transformedX = convertXValue(newX, y: newY)
        let transformedY = convertYValue(newX, y: newY)
        drawRectangeOnBounds(CGRect(x: transformedX, y: transformedY, width: newWidth, height: newHeight))
        
      }
    }
  }
  
  
}


extension Int {
  var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}



