//
//  CameraViewController.swift
//  kinemai-ios
//
//  Created by Pavel Krasnobrovkin on 15/06/2017.
//  Copyright © 2017 Pavel Krasnobrovkin. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import NextLevel

class CameraViewController: UIViewController
{
    var viewModel: CameraScreenViewModel!
    var vcEventHandlers: CameraViewControllerEventHandlers!
    
    
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var btnSwitchCameras: UIButton!
    @IBOutlet weak var btnStartRecording: UIButton!
    @IBOutlet weak var btnStopRecording: UIButton!
    @IBOutlet weak var labelCaptureTimeLeft: UILabel!
    
    
    let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        CameraScreenAssembly.assemble(forVC: self)
    }
    
    func showAlertFailedToTakeVideo()
    {
        let vc = UIAlertController(
            title: "Failed to take Video Clip"
            , message: "Something went wrong"
            , preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        vc.addAction(ok)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func showAlertVideoClipTakenIsTooShort()
    {
        let vc = UIAlertController(
            title: "Video too short"
            , message: "Please, take a video which lasts longer or equal to 3 seconds"
            , preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        vc.addAction(ok)
        
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupBindings()
        self.vcEventHandlers.handleAfterViewDidLoad()
    }
    
    private func setupBindings()
    {
        self.viewModel.isBtnSwitchCamerasHidden
            .bind(to: self.btnSwitchCameras.reactive.isHidden)
            .dispose(in: self.disposeBag)
        
        self.viewModel.isLabelCaptureTimeLeftHidden
            .bind(to: self.labelCaptureTimeLeft.reactive.isHidden)
            .dispose(in: self.disposeBag)
        
        self.viewModel.isBtnStartRecordingHidden
            .bind(to: self.btnStartRecording.reactive.isHidden)
            .dispose(in: self.disposeBag)
        
        self.viewModel.isBtnStopRecordingHidden
            .bind(to: self.btnStopRecording.reactive.isHidden)
            .dispose(in: self.disposeBag)
        
        
        self.viewModel.labelCaptureTimeLeftText
            .bind(to: self.labelCaptureTimeLeft)
            .dispose(in: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.vcEventHandlers.handleAfterViewDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.vcEventHandlers.handleAfterViewWillDisappear()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier != "ShowFragmentSelection" { return }
        
        guard let vc = segue.destination as? VideoFragmentSelectionViewController else { return }
        
        guard let video = sender as? NextLevelClip else { return }
        
        vc.originalVideo = video
    }
    
    init()
    {
        fatalError("---- Use init(coder:) initializer instead ----")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        fatalError("---- Use init(coder:) initializer instead ----")
    }
}
