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
    [_ibSocialViews setHidden:TRUE];
    [self showLoading:FALSE];
    [_ibStartStopButton setTitle:@"Start streaming" forState:UIControlStateNormal];
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
        [_streamer requestStream_objc:nil completion:^(FKStream * stream, NSError *error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
            [self->_streamer startStreamingOn:stream delegate:self];
        }];
    }
}
    
- (void)showLoading:(BOOL)loading {
    [_ibLoading setHidden:!loading];
    [_ibStartStopButton setEnabled:!loading];
    [_ibStartStopButton setTitle:@"" forState:UIControlStateNormal];
}

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
    
@end
