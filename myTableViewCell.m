//
//  myTableViewCell.m
//  CallPhone
//
//  Created by 邓志亮 on 15-1-6.
//  Copyright (c) 2015年 邓志亮. All rights reserved.
//

#import "myTableViewCell.h"
#import "MyConstants.h"

@implementation myTableViewCell


- (void)awakeFromNib {
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 4, 36, 36)];
        _headImage.layer.masksToBounds = YES;   //设置圆角
        _headImage.layer.cornerRadius = _headImage.frame.size.width/2.0;
        _headImage.contentMode = UIViewContentModeScaleAspectFill;  //自适应图片，避免压缩变形
        [self addSubview:_headImage];
        
        _phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 0, 140, 28)];
        _phoneNumberLabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:_phoneNumberLabel];
        
        _phoneNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 22, 120, 18)];
        _phoneNameLabel.font = [UIFont systemFontOfSize:13.0f];
        _phoneNameLabel.textColor = [UIColor grayColor];
        [self addSubview:_phoneNameLabel];
        
        _imageButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 4, 32, 32)];
        [self addSubview:_imageButton];
        
        _sepeatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0.5)];
        
        [_sepeatorImage setBackgroundColor:silverColor];
        [self addSubview:_sepeatorImage];
    }
    
    return self;
}

@end
