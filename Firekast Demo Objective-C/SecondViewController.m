//
//  SecondViewController.m
//  Firekast Demo Objective-C
//
//  Created by François Rouault on 22/08/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"
#import "CoreMedia/CoreMedia.h"

@interface SecondViewController ()
    @property FKPlayer *player;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.player = [[FKPlayer alloc] init];
    [self.player setDelegate:self];
    [self.player showIn:_ibPlayerView];
//    [self.player setVideoGravity:FKPlayerVideoGravityResizeAspect];
//    [self.player setShowPlaybackControls:NO];
    
     // Init UI
    [self.ibLoading setHidden:TRUE];
    [self.ibStartStopButton setEnabled:TRUE];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString* title = Nil;
    if (IDStreamToPlay == nil) {
        title = @"Make a live stream with the app and click button to watch it. Or edit IDStreamToPlay in AppDelegate.m";
    } else {
        title = [[NSString alloc] initWithFormat:@"Play Stream with ID: %@", IDStreamToPlay];
    }
    [self.ibStartStopButton setTitle: title forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickStartStop:(id)sender {
    if (IDStreamToPlay != nil) {
        [self showLoading:TRUE];
        FKStream* stream = [[FKStream alloc] initWithWithoutDataExceptStreamId:IDStreamToPlay];
        [self.player play:stream at:kCMTimeZero];
    } else {
        NSLog(@"Make a live stream with the app and click button to watch it. Or edit IDStreamToPlay in AppDelegate.m");
    }
}
    
- (void)showLoading:(BOOL)loading {
    [self.ibLoading setHidden:!loading];
    [self.ibStartStopButton setHidden:loading];
}
    
- (void)player:(FKPlayer *)player willPlay:(FKStream *)stream unless:(NSError *)error {
    [self showLoading:FALSE];
    if (error != nil) {
        NSLog(@"FKPlayer error: %@", error);
    }
    // UI can be updated here or in stateDidChanged callback
}

- (void)player:(FKPlayer *)player stateDidChanged:(enum FKPlayerState)state {
    NSLog(@"FKPlayer state: %ld", (long)state);
}

@end
