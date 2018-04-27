//
//  FirstViewController.swift
//  Firekast Demo
//
//  Created by François Rouault on 20/04/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

import UIKit
import Firekast

class FirstViewController: UIViewController, FKStreamerDelegate {
    
    @IBOutlet weak var ibCameraPreview: UIView!
    @IBOutlet weak var ibButton: UIButton!
    @IBOutlet weak var ibLoading: UIActivityIndicatorView!
    
    var streamer = FKStreamer() // 1. initializes streamer
    var camera: FKCamera!
    var stream: FKStream?
    
    var isLoading: Bool = false {
        didSet {
            ibLoading.isHidden = !isLoading
            ibButton.isEnabled = !isLoading
            ibButton.setTitle("", for: .normal)
        }
    }
    
    var isStreaming: Bool = false {
        didSet {
            ibButton.setTitle(isStreaming ? "Stop streaming" : "Start streaming", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        template()
        camera = streamer.showCamera(.front, in: ibCameraPreview) // 2. opens camera
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        streamer.stopStreaming() // it's a good practise
    }
    
    private func template() {
        ibButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        ibButton.layer.cornerRadius = 8
        ibButton.layer.borderWidth = 1
        ibButton.layer.borderColor = UIColor.black.cgColor
        
        ibButton.setTitle("Start streaming", for: .normal)
        ibLoading.isHidden = true
    }
    
    @IBAction func clickStartStop(_ sender: Any) {
        if streamer.isStreaming {
            streamer.stopStreaming()
        } else {
            isLoading = true
            streamer.requestStream { [weak self] (stream, error) in // 3. creates a stream
                guard let this = self else { return }
                guard let stream = stream else {
                    print("Error: \(String(describing: error))")
                    this.isLoading = false
                    return
                }
                this.streamer.startStreaming(on: stream, delegate: this) // 4. starts streaming firekast
            }
        }
    }
    
}

extension FirstViewController {
    func streamer(_ streamer: FKStreamer, willStartOn stream: FKStream?, unless error: FKError?) {
        self.isLoading = false
        guard let stream = stream else {
            print("Error: \(String(describing: error))")
            return
        }
        self.isStreaming = true
        self.stream = stream
    }
    
    func streamer(_ streamer: FKStreamer, didStopOn stream: FKStream?, error: FKError?) {
        self.isStreaming = false
        self.stream = nil
    }
    
    func streamer(_ streamer: FKStreamer, networkQualityDidUpdate rating: Float) {
        
    }
}
