//
//  VideosMerger.m
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import "VideosMerger.h"
#import <Photos/PHImageManager.h>
#import <Photos/PHPhotoLibrary.h>

typedef void(^mergingBlock)(BOOL status, NSString* result);
typedef void(^conversionBlock)(BOOL status);

@implementation VideosMerger
{
    VideosDataHandler* datahandler;
    mergingBlock mergingCompletion;
    conversionBlock coversionFilesCompletion;
}


- (instancetype)initWithDataHandler:(VideosDataHandler*)dataHandler
{
    self = [super init];
    if (self) {
        datahandler = dataHandler;
    }
    return self; 
}

- (void) mergeVideosAndMusicWithCompletionHandler:(void(^)(BOOL status, NSString* result))completionHandler{
    
    mergingCompletion = completionHandler;
    
    __block VideosMerger *merger = self;
    coversionFilesCompletion = ^(BOOL status) {
        NSLog(@"Conversion Done");
        if (status) {
            NSLog(@"Converted");
            [merger mergeAndSaveVideo];
        }
    };
    
    [self convertPHAssetFilesToAVAsset:0];
}


-(void) convertPHAssetFilesToAVAsset:(int)fileIndex{
    
    PHVideoRequestOptions *option = [PHVideoRequestOptions new];
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:datahandler.videos[fileIndex] options:option resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
        
        [self->datahandler.avAssetVideosFiles addObject:avasset];
        [self convertedFileAtIndex:fileIndex];
        
    }];
}

-(void) convertedFileAtIndex:(int)index{
    
    if (index < self->datahandler.videos.count-1) {
        [self convertPHAssetFilesToAVAsset:index+1];
    } else {
        NSLog(@"Converion completed");
        coversionFilesCompletion(TRUE);
    }
}

-(AVAsset*)getCurrentVideo:(int)index{
    AVAsset* video = [datahandler.avAssetVideosFiles objectAtIndex:index];
    return video;
}

- (void)mergeAndSaveVideo
{
    NSString* musicPath = [[NSBundle mainBundle] pathForResource:[datahandler.selectedMusicFileName stringByDeletingPathExtension] ofType:@"mp3"];
    AVURLAsset* musicAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:musicPath] options:nil];
    
    AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
    
    NSMutableArray *arrayInstruction = [[NSMutableArray alloc] init];
    
    AVMutableVideoCompositionInstruction * mainInstruction =
    [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableCompositionTrack *audioTrack;
    
    audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                             preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVURLAsset *assetForSize = (AVURLAsset*)[self getCurrentVideo:0];
    
    CMTime duration = kCMTimeZero;
    
    CMTime transitionTime = CMTimeMake(1, 1);
    
    for(int i=0;i< datahandler.avAssetVideosFiles.count; i++)
    {
        AVAsset *currentAsset = [self getCurrentVideo:i]; // i take the for loop for geting the asset
        /* Current Asset is the asset of the video From the Url Using AVAsset */
        
        AVMutableCompositionTrack *currentTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [currentTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration) ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:duration error:nil];
        
        //To unMute the video own audio , commented because we want custom music in background
        //[audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, currentAsset.duration) ofTrack:[[currentAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:duration error:nil];
        
        AVMutableVideoCompositionLayerInstruction *currentAssetLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:currentTrack];
        AVAssetTrack *currentAssetTrack = [[currentAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation currentAssetOrientation  = UIImageOrientationUp;
        BOOL  isCurrentAssetPortrait  = NO;
        CGAffineTransform currentTransform = currentAssetTrack.preferredTransform;
        
        if(currentTransform.a == 0 && currentTransform.b == 1.0 && currentTransform.c == -1.0 && currentTransform.d == 0)  {currentAssetOrientation= UIImageOrientationRight; isCurrentAssetPortrait = YES;}
        if(currentTransform.a == 0 && currentTransform.b == -1.0 && currentTransform.c == 1.0 && currentTransform.d == 0)  {currentAssetOrientation =  UIImageOrientationLeft; isCurrentAssetPortrait = YES;}
        if(currentTransform.a == 1.0 && currentTransform.b == 0 && currentTransform.c == 0 && currentTransform.d == 1.0)   {currentAssetOrientation =  UIImageOrientationUp;}
        if(currentTransform.a == -1.0 && currentTransform.b == 0 && currentTransform.c == 0 && currentTransform.d == -1.0) {currentAssetOrientation = UIImageOrientationDown;}
        
        CGFloat firstAssetScaleToFitRatio = assetForSize.tracks.firstObject.naturalSize.width/assetForSize.tracks.firstObject.naturalSize.height;
        if(isCurrentAssetPortrait){
            firstAssetScaleToFitRatio = assetForSize.tracks.firstObject.naturalSize.width/assetForSize.tracks.firstObject.naturalSize.height;
            CGAffineTransform firstAssetScaleFactor = CGAffineTransformMakeScale(1,1);
            [currentAssetLayerInstruction setTransform:CGAffineTransformConcat(currentAssetTrack.preferredTransform, firstAssetScaleFactor) atTime:duration];
        }else{
            
            firstAssetScaleToFitRatio = assetForSize.tracks.firstObject.naturalSize.height/assetForSize.tracks.firstObject.naturalSize.width;
            
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(1,1);
            [currentAssetLayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(currentAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 0)) atTime:duration];
        }
        
        CMTimeRange startTimeRange = CMTimeRangeMake(duration, transitionTime);
        
        //CMTime durationBeforeAddition = duration;
        duration = CMTimeAdd(duration, currentAsset.duration);
        
        
        CMTimeRange endTimeRange = CMTimeRangeMake(CMTimeSubtract(duration, transitionTime), transitionTime);
        
        [currentAssetLayerInstruction setOpacityRampFromStartOpacity:0.0 toEndOpacity:1.0 timeRange:startTimeRange];
       
        [currentAssetLayerInstruction setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:endTimeRange];
        [arrayInstruction addObject:currentAssetLayerInstruction];
        
    }
    
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:[[musicAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
    mainInstruction.layerInstructions = arrayInstruction;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:assetForSize];

    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    mainCompositionInst.renderSize = assetForSize.tracks.firstObject.naturalSize;
    
    NSString *mergedVideoFilePath =  [[self applicationCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo%-dtemp.mp4",arc4random() % 10000]];
    
    NSURL *url = [NSURL fileURLWithPath:mergedVideoFilePath];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.videoComposition = mainCompositionInst;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
        switch (exporter.status)
        {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"AVAssetExportSessionStatusCompleted");
                self->mergingCompletion(TRUE,mergedVideoFilePath);
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@", exporter.error.description);
                self->mergingCompletion(FALSE,exporter.error.description);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@", exporter.error);
                self->mergingCompletion(FALSE,exporter.error.description);
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"Exporting!");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"Waiting");
                break;
            default:
                break;
        }
    }];
}

-(NSString *)applicationCacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
