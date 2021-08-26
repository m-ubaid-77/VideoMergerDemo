//
//  ViewController.m
//  VideosMergerDemo
//
//  Created by Muhammad Ubaid on 26/08/2020.
//  Copyright © 2020 Muhammad Ubaid. All rights reserved.
//

#import "VideosViewController.h"
#import "VideosDataHandler.h"
#import "VideoCollectionViewCell.h"
#import "VideosMerger.h"
#import <Toast/Toast.h>
#import "MergedVideoViewController.h"

@interface VideosViewController ()
{
    VideosDataHandler* datahandler;
    CTAssetsPickerController *picker;
    VideosMerger* merger;
}
@property (weak, nonatomic) IBOutlet UICollectionView *videosCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mergeVideoButtonParentVideoBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noContentLabel;
@property (weak, nonatomic) IBOutlet UIView *mergerButtonParentView;

@end

@implementation VideosViewController

#pragma mark - View lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];

    datahandler = [[VideosDataHandler alloc] init];
    [self addNavigationBarRightButtons];
    
    [self reloadView];
    
}

#pragma mark - NavigationBar customized buttons

- (void)addNavigationBarRightButtons{
    
    UIImage* addVideos = [UIImage imageNamed:@"plus_icon"];
    UIImage* deleteVideos = [UIImage imageNamed:@"trash_icon"];
    
    
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithImage:addVideos style:UIBarButtonItemStylePlain target:self action:@selector(selectVideos:)];
    UIBarButtonItem* trashButton = [[UIBarButtonItem alloc] initWithImage:deleteVideos style:UIBarButtonItemStylePlain target:self action:@selector(deleteVideos:)];
    
    self.navigationItem.rightBarButtonItems = @[addButton,trashButton];
}

#pragma mark - Button Actions

- (void)selectVideos:(id)sender{
    NSLog(@"Select Videos");
    
    [self showVideosSelectionView];
}

- (void)deleteVideos:(id)sender{
    NSLog(@"Delete Videos");
    
    [datahandler.videos removeAllObjects];
    [datahandler.avAssetVideosFiles removeAllObjects];
    [self reloadView];
}
- (IBAction)mergeVideosButtonPressed:(id)sender {
    
    if (datahandler.videos.count < 2) {
        [self.view makeToast:@"Please add atleast two videos to merge" duration:3.0 position:CSToastPositionBottom];
        return;
    }
    
    [self selectMusicWithCompletionHandler:^(NSString *fileName) {
        if (fileName) {
            [self->datahandler setSelectedMusicFileName:fileName];
            [self startMergingVideos];
        }
    }];
    
}

-(void) startMergingVideos{
    
    if (merger) {
        merger = nil;
    }
    merger = [[VideosMerger alloc] initWithDataHandler:datahandler];
    
    [self.view makeToastActivity:CSToastPositionCenter];
    [merger mergeVideosAndMusicWithCompletionHandler:^(BOOL status, NSString * _Nonnull result) {
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            [self.view hideToastActivity];
            if (status) {
                NSLog(@"Result %@",result);
                [self->datahandler setMergedVideoFilePath:result];
                [self moveToNextScreen];
            }
            else{
                NSLog(@"Error %@",result);
                [self.view makeToast:result duration:3.0 position:CSToastPositionBottom];
            }
        });
    }];
}

-(void) moveToNextScreen{
    
    MergedVideoViewController* vc = (MergedVideoViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MergedVideoVC"];
    vc.dataHandler = datahandler;
    [self.navigationController pushViewController:vc animated:TRUE];
}

#pragma mark - Videos Selction from Gallery

-(void) showVideosSelectionView{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){ dispatch_async(dispatch_get_main_queue(), ^{
         // init picker
         self->picker = [[CTAssetsPickerController alloc] init];
         // set delegate
         self->picker.delegate = self;
     
         PHFetchOptions *fetchOptions = [PHFetchOptions new];
         fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];
         
         // assign options
         self->picker.assetsFetchOptions = fetchOptions;
         
         
         // Optionally present picker as a form sheet on iPad
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
             self->picker.modalPresentationStyle = UIModalPresentationFormSheet;
         
         self->picker.modalPresentationStyle = UIModalPresentationFullScreen;
         // present picker
         [self presentViewController:self->picker animated:YES completion:nil]; }); }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    [picker dismissViewControllerAnimated:true completion:nil];
    [datahandler.videos addObjectsFromArray:assets];
    [self reloadView];
    
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker{
    [picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - CollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return datahandler.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
    PHAsset* video = [datahandler.videos objectAtIndex:indexPath.item];
    [cell setUpUIForObject:video];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat width = (self.videosCollectionView.frame.size.width/2)-12;
    
    return CGSizeMake(width, width);
}

#pragma mark - Music Selection

-(void) selectMusicWithCompletionHandler:(void (^)(NSString* fileName))completionHandler{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select music" message:@"This music will be added as video background music" preferredStyle:UIAlertControllerStyleActionSheet];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
            completionHandler(nil);
        }];
    }]];

    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Music 1" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        completionHandler(@"music-1.mp3");
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Music 2" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        completionHandler(@"music-2.mp3");
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Music 3" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        completionHandler(@"music-3.mp3");
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }]];


    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - Other methods

-(void) showMergedButtonView:(BOOL)show{
    if (show) {
        self.mergeVideoButtonParentVideoBottomConstraint.constant = 0.0;
    }
    else{
        self.mergeVideoButtonParentVideoBottomConstraint.constant = -64.0;
    }
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.mergeVideoButtonParentVideoBottomConstraint.constant == -64.0) {
            [self.mergerButtonParentView setHidden:TRUE];
        }
        else{
            [self.mergerButtonParentView setHidden:FALSE];
        }
    }];
}

-(void) reloadView{
    
    if (datahandler.videos.count > 0) {
        [self showMergedButtonView:TRUE];
        [self.noContentLabel setHidden:TRUE];
        [self.videosCollectionView setHidden:FALSE];
    }
    else{
        [self showMergedButtonView:FALSE];
        [self.noContentLabel setHidden:FALSE];
        [self.videosCollectionView setHidden:TRUE];
    }
    [self.videosCollectionView reloadData];
}

@end
