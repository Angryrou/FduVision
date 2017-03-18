//
//  ViewController.m
//  FduVision
//
//  Created by Kawhi Lu on 2016/10/29.
//  Copyright © 2016年 Kawhi Lu. All rights reserved.
//

#import "ViewController.h"

//#import <MediaPlayer/MediaPlayer.h>

@interface ViewController ()

@end

@implementation ViewController

-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    [_playerLayer removeFromSuperlayer];
    
}

- (void)introMV {
    NSString *welcomeVideoAFile = [[NSBundle mainBundle] pathForResource:@"DefaultContent/intro" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:welcomeVideoAFile];
//    AVPlayer *player = [AVPlayer playerWithURL:url];
    
    // First create an AVPlayerItem
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    AVPlayer *player = [[[AVPlayer alloc] initWithPlayerItem:playerItem] autorelease];
  
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //set player layer frame and attach it to our view
    _playerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _playerLayer.masksToBounds = YES;
    _playerLayer.borderColor = [UIColor redColor].CGColor;
    _playerLayer.borderWidth = 0;
    [self.view.layer addSublayer:_playerLayer];
    //play the video
    [player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // init add intro.
//    [self introMV];
    [self performSelectorOnMainThread:@selector(introMV) withObject:nil waitUntilDone:NO];
    // 读数据，并与下载数据比较，进行更新。
    self.glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self.glView setOrientation:self.interfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // view即将出现，进行图片的load，开启ar，同时异步进行刷新
//    [self.glView ar_start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // view即将关闭，ar clear, 把数据存下
    [self.glView stop];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.glView setOrientation:toInterfaceOrientation];
}

@end
