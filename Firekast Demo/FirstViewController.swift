//
//  FirstViewController.swift
//  Firekast Demo
//
//  Created by François Rouault on 20/04/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

import UIKit
import Firekast
import GoogleSignIn

var internal_latest_stream: FKStream?

class FirstViewController: UIViewController, FKStreamerDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var ibCameraPreview: UIView!
    @IBOutlet weak var ibButton: UIButton!
    @IBOutlet weak var ibLoading: UIActivityIndicatorView!
    @IBOutlet weak var ibGoogleSignInButton: GIDSignInButton!
    @IBOutlet weak var ibGoogleSignOutButton: UIButton!
    @IBOutlet weak var ibYoutubeSwitch: UISwitch!
    @IBOutlet weak var ibCameraCapture: UIImageView!
    
    @IBOutlet weak var ibViewState: UIView!
    @IBOutlet weak var ibViewStateProgress: UIActivityIndicatorView!
    
    var streamer = FKStreamer(usecase: .portrait) // 1. initializes streamer
    var camera: FKCamera!
    var stream: FKStream?
    
    var isLoading: Bool = false {
        didSet {
            ibLoading.isHidden = !isLoading
            ibButton.isEnabled = !isLoading
            ibButton.setTitle(isLoading ? "" : (isStreaming ? "Stop streaming" : "Start streaming"), for: .normal)
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
        initGoogleSignIn()
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
        
        ibViewState.isHidden = true
        
        refreshGoogleInterface()
    }
    
    private func refreshGoogleInterface() {
        let signedIn = GIDSignIn.sharedInstance().currentUser != nil
        ibGoogleSignInButton.isHidden = signedIn
        ibYoutubeSwitch.isOn = ibYoutubeSwitch.isOn && signedIn
        ibYoutubeSwitch.isEnabled = signedIn
        ibGoogleSignOutButton.isHidden = !signedIn
    }
    
    private func initGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        if GIDSignIn.sharedInstance().currentUser == nil {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    @IBAction func clickStartStop(_ sender: Any) {
        if streamer.isStreaming {
            streamer.stopStreaming()
        } else {
            isLoading = true
            var outputs = [FKOutput]()
            if ibYoutubeSwitch.isOn, let token = GIDSignIn.sharedInstance().currentUser?.authentication?.accessToken {
                let youtubeLive = FKOutput.youtube(accessToken: token, title: "Hello world :)")
                outputs.append(youtubeLive)
            }
            streamer.requestStream(outputs: outputs) { [weak self] (stream, error) in // 3. creates a stream
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
    
    @IBAction func clickCapture(_ sender: Any) {
        guard let capture = camera?.capture() else { return }
        ibCameraCapture.image = capture
    }
    
}

// MARK: - Firekast Delegate
extension FirstViewController {
    func streamer(_ streamer: FKStreamer, willStart stream: FKStream?, unless error: NSError?) {
        self.isLoading = false
        if let error = error {
            print("Firekast start stream error: \(error)")
            self.isStreaming = false
            return
        }
        self.isStreaming = true
        internal_latest_stream = stream
        self.stream = stream
        self.ibViewStateProgress.isHidden = false
        self.ibViewState.isHidden = false
        self.ibViewState.backgroundColor = UIColor.gray
    }
    
    func streamer(_ streamer: FKStreamer, didStop stream: FKStream?, error: NSError?) {
        self.isStreaming = false
        self.stream = nil
        self.ibViewState.isHidden = true
    }
  
    func streamer(_ streamer: FKStreamer, didBecomeLive stream: FKStream) {
        self.ibViewState.backgroundColor = UIColor.red
        self.ibViewStateProgress.isHidden = true
    }
    
    func streamer(_ streamer: FKStreamer, networkQualityDidUpdate rating: Float) {
        
    }
}

// MARK: - Google Sign In
extension FirstViewController {
    
    @IBAction func handleGoogleSignOutClick(_ sender: UIButton!) {
        GIDSignIn.sharedInstance().signOut()
        refreshGoogleInterface()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        guard let user = user else {
            print("Google Sign-in failed with error: \(String(describing: error?.localizedDescription))")
            return
        }
        // Perform any operations on signed in user here.
        let _ = user.authentication.idToken // Safe to send to the server
        let userId = user.userID ?? "unknown"             // For client-side use only!
        let fullName = user.profile.name ?? "unknown"
        let email = user.profile.email ?? "unknown"
        print("Google User ID: \(userId), name: \(fullName), email: \(email)")
        
        guard let authentication = user.authentication else {
            GIDSignIn.sharedInstance().signOut()
            refreshGoogleInterface()
            return
        }
        
        guard let expirationDate = authentication.accessTokenExpirationDate, Date() < expirationDate else {
            // At the time of writing, tokens expires after 3600 sec. It is set like that by Google (not editable).
            // Note: signInSilently does not refresh tokens automatically.
            print("User is signed in to Google but access token has expired")
            authentication.refreshTokens(handler: { (authentication, error) in
                guard error == nil else {
                    GIDSignIn.sharedInstance().signOut()
                    self.refreshGoogleInterface()
                    return
                }
                self.refreshGoogleInterface()
            })
            return
        }
        refreshGoogleInterface()
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        refreshGoogleInterface()
    }
}
