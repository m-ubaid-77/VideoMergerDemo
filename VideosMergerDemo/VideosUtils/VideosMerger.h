//
//  VideosMerger.h
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VideosDataHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideosMerger : NSObject

- (instancetype)initWithDataHandler:(VideosDataHandler*)dataHandler;
- (void) mergeVideosAndMusicWithCompletionHandler:(void(^)(BOOL status, NSString* resultedFileURL))completionHandler;
@end

NS_ASSUME_NONNULL_END
