/**
 * Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
 * EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
 * and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <vector>

@interface OpenGLView : UIView

@property(nonatomic, strong) CAEAGLLayer * eaglLayer;
@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic) GLuint colorRenderBuffer;

@property(nonatomic) NSString *af_version;
@property(nonatomic) NSString *version;
@property int target_count;
@property std::vector<std::string> name_list;
@property std::vector<std::string> timestamp_list;
@property std::vector<std::string> vurl_list;

- (void)start;
- (void)stop;
- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;


@end
