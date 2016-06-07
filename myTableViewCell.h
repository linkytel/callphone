//
//  myTableViewCell.h
//  CallPhone
//
//  Created by 邓志亮 on 15-1-6.
//  Copyright (c) 2015年 邓志亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myTableViewCell : UITableViewCell

@property(strong, nonatomic) UILabel *phoneNumberLabel;
@property(strong, nonatomic) UILabel *phoneNameLabel;
@property(strong, nonatomic) UIButton *imageButton;
@property(strong, nonatomic) UIImageView *headImage;
@property(strong, nonatomic) UIImageView *sepeatorImage;

@end
