//
//  MergedVideoViewController.h
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 27/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideosDataHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface MergedVideoViewController : UIViewController

@property(nonatomic,strong) VideosDataHandler* dataHandler;

@end

NS_ASSUME_NONNULL_END
