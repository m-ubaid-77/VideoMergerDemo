//
//  VideoCollectionViewCell.h
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>
NS_ASSUME_NONNULL_BEGIN

@interface VideoCollectionViewCell : UICollectionViewCell
{
    PHAsset* video;
}
@property (weak, nonatomic) IBOutlet UIImageView *videoThumbImageView;

-(void) setUpUIForObject:(PHAsset*)video;

@end

NS_ASSUME_NONNULL_END
