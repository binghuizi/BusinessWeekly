//
//  NMGViewController.h
//  PhotoBrowser
//
//  Created by John on 13-3-18.
//  Copyright (c) 2013年 John. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NNGImageViewController.h"
@interface NMGViewController : UIViewController
{
    IBOutlet UITextField  *_URLUITextField;
    IBOutlet UIButton *_openButton;
    NSURLConnection *_connection;
    NNGImageViewController *_imageViewController;
    NSMutableArray *_downloadImages;
}
- (IBAction)pressOpenButton:(id)sender;

@end
