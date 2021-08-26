//
//  MergedVideoViewController.m
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 27/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import "MergedVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>

@interface MergedVideoViewController ()

@property (strong,nonatomic) AVPlayerViewController *avPlayerViewController;

@property (nonatomic) AVPlayer *avPlayer;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;

@end

@implementation MergedVideoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpSystemMediaPlayer:self.dataHandler.selectedMusicFileName];
    [self createAndShowThumbImage];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void) playWithCustomMediaPlayer:(NSString*)filePath{
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    videoLayer.frame = self.view.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:videoLayer];
    
    if (self.avPlayer && self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        [self.avPlayer play];
    }
}

-(void) createAndShowThumbImage{
    
    [self getThumbnailImageFromVideoPath:_dataHandler.mergedVideoFilePath onComplete:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self->_thumbImageView setImage:image];
        });
    }];
}


-(void) getThumbnailImageFromVideoPath:(NSString*)videoPath onComplete:(void(^)(UIImage* image))completionHandler{
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    AVAssetImageGenerator* imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    [imageGenerator setAppliesPreferredTrackTransform:TRUE];
    CMTime time = CMTimeMake(1, 1);
    NSError* error;
    CGImageRef cgThumbImage = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    
    if (error) {
        NSLog(@"Error: %@",error.description);
        completionHandler(nil);
    }
    else{
        UIImage* thumbImage = [UIImage imageWithCGImage:cgThumbImage];
        completionHandler(thumbImage);
    }
    
}


-(void) setUpSystemMediaPlayer:(NSString*)filePath{
    
    
}

-(void) playWithSystemMediaPlayer:(NSString*)filePath{
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    videoLayer.frame = self.view.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:videoLayer];
    
}

- (IBAction)playButtonPressed:(id)sender {
    
    NSURL *fileURL = [NSURL fileURLWithPath:_dataHandler.mergedVideoFilePath];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    
    if (self.avPlayerViewController) {
        self.avPlayerViewController = nil;
    }
    self.avPlayerViewController=[[AVPlayerViewController alloc]init];
    self.avPlayerViewController.player = self.avPlayer;
    
    [self presentViewController:self.avPlayerViewController animated:TRUE completion:^{
        [self.avPlayerViewController.player play];
    }];
}


@end
