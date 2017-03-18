/**
 * Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
 * EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
 * and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
 */

#import "OpenGLView.h"
#import "AppDelegate.h"

#include <iostream>
#include "ar.hpp"
#include "renderer.hpp"
#include <string>
#include "AFNetworking.h"

/*
 * Steps to create the key for this sample:
 *  1. login www.easyar.com
 *  2. create app with
 *      Name: HelloARVideo
 *      Bundle ID: cn.easyar.samples.helloarvideo
 *  3. find the created item in the list and show key
 *  4. set key string bellow
 */
NSString* key = @"tuVbeuqiSyMkUtnWEuS0UyYWR6bZ06FmbdPA7vin1R2Dpdcp00D2yxghOffnY7EhcLzizVDHmHt7NQyXXKBa3rCC49sDp1RGyKMP608693a5718fe139c449d967a54ec794pafDjW2uLDNYPcfHZ9ajj5iaeXplXKr4RLwpR2HJNKxbC5srxaDO97SVc61krx3UG7Tb";

namespace EasyAR {
    namespace samples {
        
        class HelloARVideo : public AR
        {
        public:
            HelloARVideo();
            ~HelloARVideo();
            virtual void initGL(int target_num, std::vector<std::string> &n_list, std::vector<std::string> &t_list, std::vector<std::string> &v_list);
            virtual void resizeGL(int width, int height);
            virtual void render();
            virtual bool clear();
        private:
            Vec2I view_size;
            std::vector<VideoRenderer*> renderer;
            int tracked_target;
            int active_target;
            std::vector<int> texid;
            int tar_num;
            std::vector<std::string> name_list;
            std::vector<std::string> ts_list;
            std::vector<std::string> vurl_list;
            ARVideo* video;
            VideoRenderer* video_renderer;
        };
        
        HelloARVideo::HelloARVideo()
        {
            view_size[0] = -1;
            tracked_target = 0;
            active_target = 0;
            video = NULL;
            video_renderer = NULL;
        }
        
        HelloARVideo::~HelloARVideo()
        {
            for(int i = 0; i < tar_num; ++i) { // 改
                delete renderer[i];
            }
        }
        
        void HelloARVideo::initGL(int target_count, std::vector<std::string> &n_list, std::vector<std::string> &t_list, std::vector<std::string> &v_list)
        {
            tar_num = target_count;
            for(int i = 0; i < tar_num; ++i) {
                texid.push_back(0);
                renderer.push_back(new VideoRenderer);
            }
            
            augmenter_ = Augmenter();
            for(int i = 0; i < tar_num; ++i) { // 改
                renderer[i]->init();
                texid[i] = renderer[i]->texId();
            }
            name_list = n_list;
            ts_list = t_list;
            vurl_list = v_list;
        }
        
        void HelloARVideo::resizeGL(int width, int height)
        {
            view_size = Vec2I(width, height);
        }
        
        void HelloARVideo::render()
        {
            glClearColor(0.f, 0.f, 0.f, 1.f);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            Frame frame = augmenter_.newFrame();
            if(view_size[0] > 0){
                int width = view_size[0];
                int height = view_size[1];
                Vec2I size = Vec2I(1, 1);
                if (camera_ && camera_.isOpened())
                    size = camera_.size();
                if(portrait_)
                    std::swap(size[0], size[1]);
                float scaleRatio = std::max((float)width / (float)size[0], (float)height / (float)size[1]);
                Vec2I viewport_size = Vec2I((int)(size[0] * scaleRatio), (int)(size[1] * scaleRatio));
                if(portrait_)
                    viewport_ = Vec4I(0, height - viewport_size[1], viewport_size[0], viewport_size[1]);
                else
                    viewport_ = Vec4I(0, width - height, viewport_size[0], viewport_size[1]);
                if(camera_ && camera_.isOpened())
                    view_size[0] = -1;
            }
            augmenter_.setViewPort(viewport_);
            augmenter_.drawVideoBackground();
            glViewport(viewport_[0], viewport_[1], viewport_[2], viewport_[3]);
            
            AugmentedTarget::Status status = frame.targets()[0].status();
            if(status == AugmentedTarget::kTargetStatusTracked){
                int id = frame.targets()[0].target().id();
                if(active_target && active_target != id) {
                    video->onLost();
                    delete video;
                    video = NULL;
                    tracked_target = 0;
                    active_target = 0;
                }
                if (!tracked_target) {
                    if (video == NULL) {
                        for (int i = 0; i < tar_num; i ++) {
                            if(frame.targets()[0].target().name() == name_list[i]&& texid[i]) {
                                video = new ARVideo;
                                video->openStreamingVideo(vurl_list[i], texid[i]);
                                video_renderer = renderer[i];
                                break;
                            }
                        }
                        
                        
//                        if(frame.targets()[0].target().name() == std::string("argame") && texid[0]) {
//                            video = new ARVideo;
//                            video->openVideoFile("video.mp4", texid[0]);
//                            video_renderer = renderer[0];
//                        }
//                        else if(frame.targets()[0].target().name() == std::string("namecard") && texid[1]) {
//                            video = new ARVideo;
//                            video->openTransparentVideoFile("transparentvideo.mp4", texid[1]);
//                            video_renderer = renderer[1];
//                        }
//                        else if(frame.targets()[0].target().name() == std::string("idback") && texid[2]) {
//                            video = new ARVideo;
//                            video->openStreamingVideo("http://7xl1ve.com5.z0.glb.clouddn.com/sdkvideo/EasyARSDKShow201520.mp4", texid[2]);
//                            video_renderer = renderer[2];
//                        }
//                        else if(frame.targets()[0].target().name() == std::string("guanghualou") && texid[3]) {
//                            video = new ARVideo;
//                            video->openStreamingVideo("http://www.fudan.edu.cn/download/mofashu/guanghualou.mp4", texid[3]);
//                            video_renderer = renderer[3];
//                        }
                    }
                    if (video) {
                        video->onFound();
                        tracked_target = id;
                        active_target = id;
                    }
                }
                Matrix44F projectionMatrix = getProjectionGL(camera_.cameraCalibration(), 0.2f, 500.f);
                Matrix44F cameraview = getPoseGL(frame.targets()[0].pose());
                
                
                ImageTarget target = frame.targets()[0].target().cast_dynamic<ImageTarget>();
                if(tracked_target) {
                    video->update();
                    video_renderer->render(projectionMatrix, cameraview, target.size());
                }
            } else {
                if (tracked_target) {
                    video->onLost();
                    tracked_target = 0;
                }
            }
        }
        
        bool HelloARVideo::clear()
        {
            AR::clear();
            if(video){
                delete video;
                video = NULL;
                tracked_target = 0;
                active_target = 0;
            }
            return true;
        }
        
    }
}
EasyAR::samples::HelloARVideo ar;

@interface OpenGLView ()
{
}

@property(nonatomic, strong) CADisplayLink * displayLink;

- (void)displayLinkCallback:(CADisplayLink*)displayLink;

@end

@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.height = MAX(frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if(self){
        [self getCachesData];
        [self setupGL];
        EasyAR::initialize([key UTF8String]);
        [self af_get_latest_version];

    }
    return self;
}

- (void) loadTargets {
    NSLog(@"finish preparing pics and urls");
    ar.initGL(_target_count, _name_list, _timestamp_list, _vurl_list);
    [self start];
}

- (void)dealloc
{
    ar.clear();
}

- (void) af_get_latest_version {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://www.littleredhat.space/vision/api/targetmgr/targets/version" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"----- JSON: %@", responseObject);
        _af_version = responseObject[@"version"];
        NSLog(@"~~~~~ is in main Thread: %d", [NSThread isMainThread]);
        if ([_af_version isEqualToString:_version]) {
            NSLog(@"~~~~~ local version is the latest.");
            [self loadTargets];
        } else {
            NSLog(@"~~~~~ Go to download targets");
            [self af_get_latest_targets];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"~~~~~ af_get_current_version failed, Error: %@", error);
        NSLog(@"~~~~~ is in main Thread: %d", [NSThread isMainThread]);
        [self loadTargets];
    }];
}

- (void) af_get_latest_targets {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://www.littleredhat.space/vision/api/targetmgr/targets" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"----- Receive links success! -----");
        NSArray *af_lists = responseObject[@"targets"];
        int latest_target_num = (int)af_lists.count;
        std::vector<std::string> latest_name_list;
        std::vector<std::string> latest_ts_list;
        std::vector<std::string> latest_vurl_list;
        std::vector<std::string> latest_iurl_list;
        

        for (int i = 0; i < latest_target_num; i ++) {
            NSString *ele = [[af_lists[i] objectForKey:@"targetId"] stringValue];
            std::string e = std::string([ele UTF8String]);
            latest_name_list.push_back(e);
            
            NSString *ts = [[af_lists[i] objectForKey:@"timestamp"] stringValue];
            std::string ts_str = std::string([ts UTF8String]);
            latest_ts_list.push_back(ts_str);
            
            latest_vurl_list.push_back(std::string([[af_lists[i] objectForKey:@"videoUrl"] UTF8String]));
            latest_iurl_list.push_back(std::string([[af_lists[i] objectForKey:@"imageUrl"] UTF8String]));
        }
        
        std::vector<int> del_list;
        std::vector<int> add_list;
        for (int i = 0; i < _target_count; i ++) {
            auto iter = std::find(latest_name_list.begin(), latest_name_list.end(), _name_list[i]);
            if(iter == latest_name_list.end()) {
                // 需要把这张图删掉
                del_list.push_back(i);
            } else {
                int index = (int) std::distance(latest_name_list.begin(), iter);
                if (latest_ts_list[index] != _timestamp_list[i]) {
                    // 需要把这张图删掉
                    del_list.push_back(i);
                }
            }
        }
        // 删图
        bool delFlag = true;
        if (del_list.size() != 0) {
            std::sort(del_list.rbegin(), del_list.rend());
            int len = (int)del_list.size();
            for (int i = 0; delFlag && i < len; i ++) {
                int idx = del_list[i];
                delFlag = [self delImg:_name_list[idx]];
                if(!delFlag) {
                    break;
                }
                _name_list.erase(_name_list.begin() + idx);
                _timestamp_list.erase(_timestamp_list.begin() + idx);
                _vurl_list.erase(_vurl_list.begin() + idx);
                _target_count --;
            }
        }
        if (delFlag == false) {
            NSLog(@"----- UPDATE FAILED! -----, error in deletion");
            NSLog(@"Now %d targets", _target_count);
            [self loadTargets];
            return;
        } else {
            NSLog(@"----- Delete Finished -----");
        }
        NSLog(@"+++++ add_list update ++++");
        for (int i = 0; i < latest_target_num; i ++) {
            auto iter = std::find(_name_list.begin(), _name_list.end(), latest_name_list[i]);
            if(iter == _name_list.end()) {
                add_list.push_back(i);
            }
        }
        NSLog(@"+++++ add_list update finished ++++");
        // 加图
        bool netIsOn = true;
        if (add_list.size() != 0) {
            int len = (int) add_list.size();
            for (int i = 0; netIsOn && i < len; i ++) {
                int idx = add_list[i];
                netIsOn = [self addImg:latest_name_list[idx] andUrl:latest_iurl_list[idx]];
                printf(" +++++ add an img named: %s\n", latest_name_list[idx].c_str());
            }
        }
        
        if (netIsOn) {
            _version = _af_version;
            _target_count = latest_target_num;
            _name_list = latest_name_list;
            _timestamp_list = latest_ts_list;
            _vurl_list = latest_vurl_list;
            NSLog(@"----- UPDATE SUCCEEDED! -----");
            NSLog(@"Now %d targets", _target_count);
            
            [self loadTargets];
        } else {
            NSLog(@"----- UPDATE FAILED! -----, error in addition");
            NSLog(@"Now %d targets", _target_count);
            [self loadTargets];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"----- af_get_current_targets failed, Error: %@", error);
        [self loadTargets];
    }];
}

- (bool) delImg:(std::string&) name {
    NSString *jpgPath = @(([[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] UTF8String] + std::string("/"+ name + ".jpg")).c_str());
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:jpgPath error:&error];
    if (error) {
        NSLog(@"----- error is %@", error.description);
        NSLog(@"----- delete img named %s located in %@ failed.", name.c_str(), jpgPath);
        return false;
    } else {
        NSLog(@"----- delete img named: %s succeeded.", name.c_str());
        return true;
    }
}

- (bool) addImg:(std::string&) name andUrl:(std::string&) imgUrl {
    std::string fullPath = std::string("http://www.littleredhat.space/vision/") + imgUrl;
    NSURL *url = [NSURL URLWithString:@(fullPath.c_str())];
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
    if (image == nil) {
        printf("%s\n", fullPath.c_str());
        NSLog(@"+++++ image named %s download from %s failed.", name.c_str(), fullPath.c_str());
        return false;
    } else {
        NSLog(@"+++++ image named %s download from %s succeeded.", name.c_str(), fullPath.c_str());
        NSData *imgData = UIImageJPEGRepresentation(image, 1);
        NSString *jpgPath = @(([[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] UTF8String] + std::string("/" + name + ".jpg")).c_str());
        if([imgData writeToFile:jpgPath atomically:YES]) {
            NSLog(@"+++++ write img name %s to Caches succeeded.", name.c_str());
            return true;
        } else {
            NSLog(@"+++++ write img named %s to Caches failed.", name.c_str());
            return false;
        }
    }
}

- (void) getCachesData
{
    NSArray *targets = [[NSUserDefaults standardUserDefaults] objectForKey:@"targets"];
    if (targets == nil) {
        _name_list.push_back(std::string("default"));
        _timestamp_list.push_back(std::string("0"));
        _vurl_list.push_back(std::string("http://www.fudan.edu.cn/download/mofashu/guanghualou.mp4"));
        _target_count = 1;
        // cp ~/Default/default.jpg $(homeBunder)/Library/Caches/default.jpg
        NSError *error;
        if([[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"DefaultContent/default" ofType:@"jpg"] toPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/default.jpg"] error:&error]) {
            NSLog(@"~~~~~ copy jpg succeeded.");
        } else {
            NSLog(@"~~~~~ error is %@", error.description);
            NSLog(@"~~~~~ copy jpg failed.");
        }
    } else {
        NSLog(@"~~~~~ init from NSUserDefaults");
        _target_count = (int)[targets count];
        for (int i = 0; i < _target_count; i ++) {
            NSDictionary *dict = [targets objectAtIndex:i];
            _name_list.push_back([[dict objectForKey:@"name"] UTF8String]);
            _timestamp_list.push_back([[dict objectForKey:@"timestamp"] UTF8String]);
            _vurl_list.push_back([[dict objectForKey:@"vedioUrl"] UTF8String]);
        }
    }
    NSString *ver = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    if (ver == nil) {
        _version = @"init";
        NSLog(@"~~~~~ version is nil, set init");
    } else {
        _version = ver;
        NSLog(@"~~~~~ version is %@ now", _version);
    }
}

- (void)setupGL
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
    if (![EAGLContext setCurrentContext:_context])
        NSLog(@"Failed to set current OpenGL context");
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
    
}

+(BOOL)saveToDirectory:(NSString *)path data:(NSData *)data name:(NSString *)newName
{
    NSString * resultPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",newName]];
    return [[NSFileManager defaultManager] createFileAtPath:resultPath contents:data attributes:nil];
}

- (void)start{
    
    ar.initCamera();

    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    std::string cachePath = std::string([[cacPath objectAtIndex:0] UTF8String]);
    
    for (int i = 0; i < _target_count; ++i) {
        std::string str = cachePath + "/" + _name_list[i] + ".jpg";
        ar.loadFromImageNew(str, _name_list[i]);
    }
    
    ar.start();
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stop
{
    [[NSUserDefaults standardUserDefaults] setObject:_version forKey:@"version"];
    NSMutableArray *new_target_list = [NSMutableArray array];
    for (int i = 0; i < _target_count; i ++) {
        NSDictionary* dict = @{@"name":@(_name_list[i].c_str()), @"timestamp":@(_timestamp_list[i].c_str()), @"vedioUrl":@(_vurl_list[i].c_str())};
        [new_target_list addObject:dict];
    }
    NSArray *targets = [new_target_list copy];
    [[NSUserDefaults standardUserDefaults] setObject:targets forKey:@"targets"];
    NSLog(@"saved");
    ar.clear();
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    if (!((AppDelegate*)[[UIApplication sharedApplication]delegate]).active)
        return;
    ar.render();
    
    (void)displayLink;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = FALSE;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = TRUE;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = FALSE;
            break;
        default:
            break;
    }
    ar.setPortrait(isPortrait);
    ar.resizeGL(frame.size.width, frame.size.height);
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            EasyAR::setRotationIOS(270);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            EasyAR::setRotationIOS(90);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            EasyAR::setRotationIOS(180);
            break;
        case UIInterfaceOrientationLandscapeRight:
            EasyAR::setRotationIOS(0);
            break;
        default:
            break;
    }
}

@end
