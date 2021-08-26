//
//  VideosDataHandler.m
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import "VideosDataHandler.h"

@implementation VideosDataHandler

@synthesize videos,avAssetVideosFiles,selectedMusicFileName,mergedVideoFilePath;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.videos = [[NSMutableArray alloc] init];
        self.avAssetVideosFiles = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
