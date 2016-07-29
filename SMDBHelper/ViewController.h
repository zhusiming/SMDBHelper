//
//  ViewController.h
//  SMDBHelper
//
//  Created by 朱思明 on 16/7/1.
//  Copyright © 2016年 朱思明. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UIImageView *_imageView;
}
- (IBAction)writeData:(id)sender;
- (IBAction)readData:(id)sender;


@end

