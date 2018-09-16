//
//  FirstViewController.m
//  Firekast Demo Objective-C
//
//  Created by François Rouault on 22/08/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"

@interface FirstViewController()
    
@end

@implementation FirstViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    _streamer = [[FKStreamer alloc] initWithUseInterfaceOrientation:TRUE];
    _camera = [_streamer showCamera:Front in:_ibCameraPreview];
    // init UI
    [self showLoading:FALSE];
    [_ibStartStopButton setTitle:@"Start streaming" forState:UIControlStateNormal];
    [self refreshGoogleInterface];
    // init Google Sign In
    [[GIDSignIn sharedInstance] setDelegate:self];
    [[GIDSignIn sharedInstance] setUiDelegate:self];
    if ([[GIDSignIn sharedInstance] currentUser] == nil) {
        [[GIDSignIn sharedInstance] signInSilently];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_streamer stopStreaming];
}

- (IBAction)clickStartStop:(id)sender {
    if ([_streamer isStreaming]) {
        [_streamer stopStreaming];
    } else {
        [self showLoading:TRUE];
        NSMutableArray *outputs = [NSMutableArray new];
        NSString *youtubeAccessToken = [[[[GIDSignIn sharedInstance] currentUser] authentication] accessToken];
        if ([[self ibYoutubeSwitch] isOn] && youtubeAccessToken != nil) {
            FKOutput *youtube = [FKOutput youtubeWithAccessToken:youtubeAccessToken title:@"Hello world :Objc" extras:nil];
            [outputs addObject:youtube];
        }
        [_streamer requestStream_objc:outputs completion:^(FKStream * stream, NSError *error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
            [self->_streamer startStreamingOn:stream delegate:self];
        }];
    }
}
    
- (IBAction)clickGoogleSignOut:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
    [self refreshGoogleInterface];
}
    
-(void)refreshGoogleInterface {
    BOOL isSignedIn = [[GIDSignIn sharedInstance] currentUser] != nil;
    [_ibGoogleSignInButton setHidden:isSignedIn];
    [_ibYoutubeSwitch setOn: [_ibYoutubeSwitch isOn] && isSignedIn];
    [_ibYoutubeSwitch setEnabled:isSignedIn];
    [_ibGoogleSignOutButton setHidden:!isSignedIn];
}
    
- (void)showLoading:(BOOL)loading {
    [_ibLoading setHidden:!loading];
    [_ibStartStopButton setEnabled:!loading];
    [_ibStartStopButton setTitle:@"" forState:UIControlStateNormal];
}
    
    // MARK: Firekast Delegate

- (void)streamer:(FKStreamer * _Nonnull)streamer willStartOn:(FKStream * _Nullable)stream unless:(NSError * _Nullable)error {
    [self showLoading:FALSE];
    if (error != nil) {
        NSLog(@"Firekast start stream error: %@", error);
        return;
    }
    [_ibStartStopButton setTitle:@"Stop streaming" forState:UIControlStateNormal];
    IDStreamToPlay = self.stream.streamId;
    self.stream = stream;
}
    
- (void)streamer:(FKStreamer * _Nonnull)streamer didStopOn:(FKStream * _Nullable)stream error:(NSError * _Nullable)error {
    [_ibStartStopButton setTitle:@"Start streaming" forState:UIControlStateNormal];
    self.stream = nil;
}
    
- (void)streamer:(FKStreamer * _Nonnull)streamer networkQualityDidUpdate:(float)rating {
    
}
    
    // MARK: Google Sign In Delegate
    
    - (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
        if (user == nil) {
            NSLog(@"Google Sign In failed with error: %@", error);
            return;
        }
        GIDAuthentication *authentication = [user authentication];
        NSDate *expirationDate = [authentication accessTokenExpirationDate];
        if (authentication == nil || expirationDate == nil) {
            [[GIDSignIn sharedInstance] signOut];
            [self refreshGoogleInterface];
            return;
        }
        if ([[NSDate alloc] init] < expirationDate) {
            // At the time of writing, tokens expires after 3600 sec. It is set like that by Google (not editable).
            // Note: signInSilently does not refresh tokens automatically.
            NSLog(@"User is signed in to Google But access token has expired");
            [authentication refreshTokensWithHandler:^(GIDAuthentication *authentication, NSError *error) {
                if (error != nil) {
                    [[GIDSignIn sharedInstance] signOut];
                }
                [self refreshGoogleInterface];
            }];
        }
        [self refreshGoogleInterface];
    }
    
    - (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
        [self refreshGoogleInterface];
    }
    
@end
