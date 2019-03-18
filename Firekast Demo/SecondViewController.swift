//
//  SecondViewController.swift
//  Firekast Demo
//
//  Created by François Rouault on 20/04/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

import UIKit
import Firekast
//import CoreMedia

class SecondViewController: UIViewController, FKPlayerDelegate {
    
    @IBOutlet weak var ibPlayer: UIView!
    @IBOutlet weak var ibButton: UIButton!
    @IBOutlet weak var ibLoading: UIActivityIndicatorView!
    @IBOutlet weak var ibPlayerState: UILabel!
    
    let player = FKPlayer() // 1. initializes player
    
    var isLoading: Bool = false {
        didSet {
            ibLoading.isHidden = !isLoading
            ibButton.isHidden = isLoading
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        template()
        player.delegate = self // 2. set delegate
        player.show(in: ibPlayer) // 3. displays player
        //        player.videoGravity = .resizeAspectFill
        //        player.showPlaybackControls = false
    }
    
    private func template() {
        ibPlayerState.text = ""
        
        ibButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        ibButton.layer.cornerRadius = 8
        ibButton.layer.borderWidth = 1
        ibButton.layer.borderColor = UIColor.black.cgColor
        
        ibButton.setTitle("Play stream", for: .normal)
        ibLoading.isHidden = true
    }
    
    @IBAction func clickButton(_ sender: Any) {
        if let stream = internal_latest_stream {
            isLoading = true
            player.play(stream)
        } else {
            ibPlayerState.text = "First make a stream and come back here to watch it. Or edit source code."
//            isLoading = true
//            let stream = FKStream(withoutDataExceptStreamId: "bm60nwimigt0an081")
//            player.play(stream)
////            player.play(stream, at: CMTime(seconds: 3.5, preferredTimescale: 1)) // will start the video at t=3.5 seconds
        }
    }
    
}

extension SecondViewController {
    func player(_ player: FKPlayer, willPlay stream: FKStream, unless error: Error?) {
        isLoading = false
        if let error = error {
            ibPlayerState.text = "☠️ \(error) ☠️"
        }
    }
    
    func player(_ player: FKPlayer, stateDidChanged state: FKPlayer.State) {
        ibPlayerState.text = "Player state: \(state)"
    }
}
