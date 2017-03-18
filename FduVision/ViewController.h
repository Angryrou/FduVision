//
//  ViewController.h
//  FduVision
//
//  Created by Kawhi Lu on 2016/10/29.
//  Copyright © 2016年 Kawhi Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface ViewController : UIViewController

@property(nonatomic, strong) OpenGLView *glView;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@end

