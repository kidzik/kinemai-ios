//
//  VideoFragmentSelectionViewController.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 15/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import PryntTrimmerView

import NextLevel
import AVFoundation

import MagicalRecord
import MBProgressHUD

class VideoFragmentSelectionViewController: UIViewController
{
    var originalVideo: NextLevelClip!
    
    internal var player: AVPlayer!
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.trimmerView.handleColor = UIColor.white
        self.trimmerView.mainColor = UIColor.darkGray
        self.trimmerView.positionBarColor = UIColor.clear
        
        self.trimmerView.delegate = self
        self.trimmerView.minDuration = 3
        self.trimmerView.maxDuration = 5
        
        let item = AVPlayerItem(asset: self.originalVideo.asset!)
        self.player = AVPlayer(playerItem: item)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let videoLayer = AVPlayerLayer(player: self.player)
        videoLayer.frame = CGRect(origin: .zero, size: self.playerView.bounds.size)
        videoLayer.videoGravity = AVLayerVideoGravityResizeAspect
        self.playerView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.playerView.layer.addSublayer(videoLayer)
        
        self.trimmerView.asset = self.originalVideo.asset!
        
        if let startTime = self.trimmerView.startTime
            , let endTime = self.trimmerView.endTime
        {
            var startTimeSec = Double(startTime.value)
            startTimeSec /= Double(startTime.timescale)
            
            var endTimeSec = Double(endTime.value)
            endTimeSec /= Double(endTime.timescale)
            
            print("---- ----")
            print("Start time sec: \(startTimeSec)")
            print("End time sec: \(endTimeSec)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func processAndUploadVideo()
    {
        let asset = self.originalVideo.asset!
        print("Creating export session encoder")
        guard let exportSession = AVAssetExportSession(
            asset: asset
            , presetName: AVAssetExportPresetHighestQuality) else
        {
            self.showAlertFailedToExport()
            return
        }
        
        let startTime = self.trimmerView.startTime!
        let duration = self.trimmerView.endTime! - startTime
        print("Duration is \(duration)")
        
        exportSession.timeRange = CMTimeRangeMake(startTime, duration)
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        
        let creationDate = Date()
        let fileName = "\(creationDate.timeIntervalSince1970).mp4"
        var outputURL = URL.docsDirectory
        outputURL = outputURL.appendingPathComponent(fileName)
        print("Output url: '\(outputURL.absoluteString)'")
        
        exportSession.outputURL = outputURL
        
        exportSession.exportAsynchronously { 
            [weak self] in
            guard let wSelf = self else { return }
            
            DispatchQueue.main.async {
                switch exportSession.status
                {
                case .failed:
                    wSelf.showAlertFailedToExport()
                case .completed:
                    wSelf.uploadVideoToServerAndSaveToDatabase(videoURL: outputURL, creationDate: creationDate)
                default:
                    break
                }
            }
        }
    }
    
    init()
    {
        fatalError("---- Call init(coder:) instead ----")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        fatalError("---- Call init(coder:) instead ----")
    }
    
    private func showAlertFailedToExport()
    {
        let vc = UIAlertController(
            title: "Error occurred"
            , message: "Failed to export the selected clip. Please, try again later"
            , preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        vc.addAction(ok)
        self.present(vc, animated: true, completion: nil)
    }
    
    private func showAlertFailedToUpload()
    {
        let vc = UIAlertController(
            title: "Error occurred"
            , message: "Failed to upload the selected clip. Please, check your Wi-Fi connection and try again later"
            , preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        vc.addAction(ok)
        self.present(vc, animated: true, completion: nil)
    }
    
    private func uploadVideoToServerAndSaveToDatabase(videoURL: URL, creationDate: Date)
    {
        print("Upload video attempt")
        let clip = NextLevelClip.clip(withUrl: videoURL, infoDict: nil)
        
        let HUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        HUD.label.text = "Uploading. Please, wait..."
        Backend.uploadVideo(videoURL: videoURL, creationDate: creationDate) {
            [weak self]
            videoIdOrNil in
            guard let wSelf = self else { return }
            
            DispatchQueue.main.async {
                HUD.hide(animated: true)
                
                if let videoID = videoIdOrNil
                {
                    wSelf.originalVideo.removeFile()
                    
                    var durationSec = Double(clip.duration.value)
                    durationSec /= Double(clip.duration.timescale)
                    
                    print("---- Uploaded video duration: \(durationSec)----")
                    
                    var thumbnailFileName: String? = nil
                    if let thumbnail = clip.thumbnailImage
                        , let png = UIImagePNGRepresentation(thumbnail)
                    {
                        let fileName = "\(creationDate.timeIntervalSince1970).png"
                        var thumbURL = URL.docsDirectory
                        thumbURL = thumbURL.appendingPathComponent(fileName)
                        
                        do
                        {
                            try png.write(to: thumbURL, options: .atomic)
                            thumbnailFileName = fileName
                        }
                        catch
                        {
                            print("Failed to write png thumbnail")
                        }
                    }
                    
                    let ctx = NSManagedObjectContext.mr_default()
                    
                    let uploadedVideo = UploadedVideo.mr_createEntity(in: ctx)
                    uploadedVideo?.creationDate = creationDate as NSDate
                    uploadedVideo?.processingStatus = UploadedVideo.ProcessingStatus.isProcessing
                    uploadedVideo?.videoID = videoID
                    uploadedVideo?.thumbnailFileName = thumbnailFileName
                    
                    ctx.mr_saveToPersistentStoreAndWait()
                    
                    UIApplication.shared.registerForPushNotifications()
                    wSelf.navigationController?.popViewController(animated: true)
                    
                    print("---- VideoClip uploaded. VideoID: \(videoID) ----")
                }
                else
                {
                    wSelf.showAlertFailedToUpload()
                }
                
                try? FileManager.default.removeItem(at: videoURL)
            }
        }
    }
}

// MARK: -
// MARK: TrimmerViewDelegate
extension VideoFragmentSelectionViewController: TrimmerViewDelegate
{
    func didChangePositionBar(_ playerTime: CMTime)
    {
        player.seek(to: playerTime)
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime)
    {
        
    }
}
