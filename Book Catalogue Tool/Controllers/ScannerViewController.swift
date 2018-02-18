//
//  ScannerViewController.swift
//  Book Catalogue Tool
//
//  Created by Piotr Mucha on 17.02.2018.
//  Copyright © 2018 Piotr Mucha. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


class ScannerViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var captureDevice:AVCaptureDevice?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var currentCode:String = ""
    
    let codeFrame:UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Book isbn scanner"
        view.backgroundColor = .white
        
        captureDevice = AVCaptureDevice.default(for: .video)
        if let captureDevice = captureDevice {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                let captureSession = AVCaptureSession()
                captureSession.addInput(input)
                
                let captureMetaData = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetaData)
                
                captureMetaData.setMetadataObjectsDelegate(self, queue: .main)
                
                captureMetaData.metadataObjectTypes = [.ean13]
                
                captureSession.startRunning()
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer!)
                
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
                self.view.addGestureRecognizer(gesture)
                
            } catch {
                print("Error Device Input")
            }
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            codeFrame.frame = CGRect.zero
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let stringCodeValue = metadataObject.stringValue else { return }
        currentCode = stringCodeValue
        view.addSubview(codeFrame)
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        codeFrame.frame = barcodeObject.bounds

        let systemSoundId: SystemSoundID = 1016  // to play apple's built in sound, no need for upper 3 lines
        AudioServicesAddSystemSoundCompletion(systemSoundId, nil, nil, {(systemSoundId,_) -> Void in AudioServicesDisposeSystemSoundID(systemSoundId)}, nil)
        AudioServicesPlaySystemSound(systemSoundId)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayDetailsViewController(scannedCode: String) {
        let detailsViewController = DetailsViewController()
        detailsViewController.scannedCode = scannedCode
        //navigationController?.pushViewController(detailsViewController, animated: true)
        present(detailsViewController, animated: true, completion: nil)
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        displayDetailsViewController(scannedCode: currentCode)
    }

}
