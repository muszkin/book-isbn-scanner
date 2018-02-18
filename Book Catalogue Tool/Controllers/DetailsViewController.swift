//
//  DetailsViewController.swift
//  BarcodeScanner
//
//  Created by Mikheil Gotiashvili on 7/29/17.
//  Copyright © 2017 Mikheil Gotiashvili. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


class DetailsViewController: UIViewController {
    
    var scannedCode:String?
    var resultStatus:String?
    
    var bookStatus: Bookstatus?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        print(scannedCode!)
        
        
        // Setup label and button layout
        view.addSubview(codeLabel)
        codeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        codeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        codeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        codeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if let scannedCode = scannedCode {
            codeLabel.text = scannedCode
        }
        
        view.addSubview(scanButton)
        scanButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scanButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        scanButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
        view.addSubview(sendButton)
        sendButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let codeLabel:UILabel = {
        let codeLabel = UILabel()
        codeLabel.textAlignment = .center
        codeLabel.backgroundColor = .white
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        return codeLabel
    }()
    
    lazy var result:UILabel = {
        let result = UILabel()
        result.textAlignment = .center
        result.backgroundColor = .white
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    lazy var scanButton:UIButton = {
        let scanButton = UIButton(type: .system)
        scanButton.setTitle("Scan", for: .normal)
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        scanButton.backgroundColor = .orange
        scanButton.layer.cornerRadius = 25
        scanButton.addTarget(self, action: #selector(displayScannerViewController), for: .touchUpInside)
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        
        return scanButton
    }()
    
    lazy var sendButton:UIButton = {
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        sendButton.backgroundColor = .red
        sendButton.layer.cornerRadius = 25
        sendButton.addTarget(self, action: #selector(sendData), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        return sendButton
    }()
    
    @objc func displayScannerViewController() {
        let scannerViewController = ScannerViewController()
        //navigationController?.pushViewController(scannerViewController, animated: true)
        //navigationController?.present(scannerViewController, animated: true, completion: nil)
        present(scannerViewController, animated: true, completion: nil)
    }
    
    @objc func sendData() {
        guard let url = URL(string: "http://drpiotr.pl/book/add/" + scannedCode!) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
            print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                let statusData = try JSONDecoder().decode(Bookstatus.self,from: data)
                
                DispatchQueue.main.async {
                    self.bookStatus = statusData
                    let statusRow = self.bookStatus
                    self.resultStatus = "Status: " + (statusRow?.status)! + " Error: " + (statusRow?.error)!
                    
                    self.view.addSubview(self.result)
                    self.result.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50).isActive = true
                    self.result.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
                    self.result.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
                    self.result.heightAnchor.constraint(equalToConstant: 50).isActive = true
                    if let resultText = self.resultStatus {
                        self.result.text = resultText
                    }
                }
                
            } catch let jsonError {
                print(jsonError)
            }
            
            let systemSoundId: SystemSoundID = 1004
            AudioServicesAddSystemSoundCompletion(systemSoundId, nil, nil, {(systemSoundId,_) -> Void in AudioServicesDisposeSystemSoundID(systemSoundId)}, nil)
            AudioServicesPlaySystemSound(systemSoundId)
        }.resume()
    }
}

