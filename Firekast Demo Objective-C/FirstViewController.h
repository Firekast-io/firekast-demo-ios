//
//  FirstViewController.h
//  Firekast Demo Objective-C
//
//  Created by François Rouault on 22/08/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firekast/Firekast-Swift.h"

@interface FirstViewController : UIViewController<FKStreamerDelegate>
    
    @property (weak, nonatomic) IBOutlet UIView *ibCameraPreview;
    @property (weak, nonatomic) IBOutlet UIView *ibSocialViews;
    @property (weak, nonatomic) IBOutlet UIButton *ibStartStopButton;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ibLoading;
    
    @property FKStreamer *streamer;
    @property FKCamera *camera;
    @property FKStream *stream;
@end

