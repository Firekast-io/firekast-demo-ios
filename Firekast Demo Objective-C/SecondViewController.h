//
//  SecondViewController.h
//  Firekast Demo Objective-C
//
//  Created by François Rouault on 22/08/2018.
//  Copyright © 2018 Firekast. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Firekast/Firekast-Swift.h"

@interface SecondViewController : UIViewController<FKPlayerDelegate>

    @property (weak, nonatomic) IBOutlet UIView *ibPlayerView;
    @property (weak, nonatomic) IBOutlet UIButton *ibStartStopButton;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ibLoading;

@end

