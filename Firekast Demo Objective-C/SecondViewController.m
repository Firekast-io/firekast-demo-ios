//
//  SecondViewController.m
//  Firekast Demo Objective-C
//
//  Created by François Rouault on 22/08/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"

@interface SecondViewController ()
    @property FKPlayer *player;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.player = [[FKPlayer alloc] init];
    [self.player showIn:_ibPlayerView];
    // Init UI
    [self.ibLoading setHidden:TRUE];
    [self.ibStartStopButton setTitle:[self buttonTitle] forState:UIControlStateNormal];
    [self.ibStartStopButton setEnabled:TRUE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    
- (NSString*) buttonTitle {
    return [[NSString alloc] initWithFormat:@"Play Stream with ID: %@", IDStreamToPlay];
}

- (IBAction)clickStartStop:(id)sender {
    if ([self.player state] == Playing) {
        [self.player stop];
        [self.ibStartStopButton setTitle:[self buttonTitle] forState:UIControlStateNormal];
    } else if(IDStreamToPlay != nil) {
        [self showLoading:TRUE];
        [self.player playWithStream:IDStreamToPlay delegate:self];
    } else {
        NSLog(@"Made a live stream with the app OR edit IDStreamToPlay in AppDelegate.m");
    }
}
    
- (void)showLoading:(BOOL)loading {
    [self.ibLoading setHidden:!loading];
    [self.ibStartStopButton setEnabled:!loading];
    [self.ibStartStopButton setTitle:@"" forState:UIControlStateNormal];
}
    
- (void)player:(FKPlayer *)player willPlay:(FKStream *)stream unless:(NSError *)error {
    [self showLoading:FALSE];
    if (error != nil) {
        NSLog(@"Player error: %@", error);
    }
    // UI can be updated here or in stateDidChanged callback
}

- (void)player:(FKPlayer *)player stateDidChanged:(enum FKPlayerState)state {
    NSLog(@"stateDidChanged: %ld", (long)state);
    [self showLoading: (state != Stopped && state != Playing)];
    if (state != Stopped) {
        [self.ibStartStopButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.ibStartStopButton setTitle:[self buttonTitle] forState:UIControlStateNormal];
    }
}

- (void)player:(FKPlayer *)player videoDurationIsAvailable:(NSTimeInterval)duration {
    NSLog(@"videoDurationIsAvailable: %f", duration);
    
}
@end
