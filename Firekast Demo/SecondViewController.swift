//
//  SecondViewController.swift
//  Firekast Demo
//
//  Created by François Rouault on 20/04/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

import UIKit
import Firekast

class SecondViewController: UIViewController, FKPlayerDelegate {
    
    @IBOutlet weak var ibPlayer: UIView!
    @IBOutlet weak var ibButton: UIButton!
    @IBOutlet weak var ibLoading: UIActivityIndicatorView!
    
    let player = FKPlayer() // 1. initializes player
    
    var isLoading: Bool = false {
        didSet {
            ibLoading.isHidden = !isLoading
            ibButton.isEnabled = !isLoading
            ibButton.setTitle("", for: .normal)
        }
    }
    
    var isPlaying: Bool = false {
        didSet {
            ibButton.setTitle(isPlaying ? "Stop" : "Play latest stream", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        template()
        player.show(in: ibPlayer) // 2. displays player
    }
    
    private func template() {
        ibButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        ibButton.layer.cornerRadius = 8
        ibButton.layer.borderWidth = 1
        ibButton.layer.borderColor = UIColor.black.cgColor
        
        ibButton.setTitle("Play latest stream", for: .normal)
        ibLoading.isHidden = true
    }
    
    @IBAction func clickButton(_ sender: Any) {
        if player.state == .playing {
            isPlaying = false
            player.stop()
        } else if let stream = internal_latest_stream {
            isLoading = true
            player.play(stream: stream.id, delegate: self)
        } else {
            print("First make a stream and then watch it :)")
            //            player.play(stream: "another_stream_id", delegate: self)
        }
    }
    
}

extension SecondViewController {
    func player(_ player: FKPlayer, willPlay stream: FKStream?, unless error: NSError?) {
        isLoading = false
        if let error = error {
            print("Player error: \(error)")
        }
    }
    
    func player(_ player: FKPlayer, videoDurationIsAvailable duration: TimeInterval) {
    
    }
    
    func player(_ player: FKPlayer, stateDidChanged state: FKPlayer.State) {
        print("Player state changed to \(state)")
        isLoading = state != .stopped && state != .playing
        isPlaying = state != .stopped
    }
}
