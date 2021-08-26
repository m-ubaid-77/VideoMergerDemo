//
//  VideoCollectionViewCell.m
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import "VideoCollectionViewCell.h"

@implementation VideoCollectionViewCell

-(void) setUpUIForObject:(PHAsset*)videoAsset{
    
    video = videoAsset;
    
    PHImageManager* manager = [PHImageManager defaultManager];
    PHImageRequestOptions* option = [PHImageRequestOptions new];
    //UIImage* thumbnail = [UIImage new];
    [option setSynchronous:TRUE];
    
    [manager requestImageForAsset:video targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            self.videoThumbImageView.image = result;
        }
    }];

}

@end
