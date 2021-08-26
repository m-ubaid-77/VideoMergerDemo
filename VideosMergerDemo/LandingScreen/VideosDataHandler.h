//
//  VideosDataHandler.h
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideosDataHandler : NSObject

@property(nonatomic,strong) NSMutableArray* videos;
@property(nonatomic,strong) NSMutableArray* avAssetVideosFiles;
@property(nonatomic,strong) NSString* selectedMusicFileName;
@property(nonatomic,strong) NSString* mergedVideoFilePath;

@end

NS_ASSUME_NONNULL_END
