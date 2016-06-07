//
//  ContactPerson.h
//  CallPhone
//
//  Created by 邓志亮 on 15-1-6.
//  Copyright (c) 2015年 邓志亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactPerson :NSObject

@property(nonatomic, copy) NSString* PersonNumber;  //手机号码
@property(nonatomic, copy) NSString* PersonName;    //姓名
@property(nonatomic, strong) UIImageView* Head;     //头像
@property(nonatomic, retain) NSString* PersonNamePinyinLong;    //姓名全拼
@property(nonatomic, retain) NSString* PersonNamePinyinShort;   //姓名简拼
@property(nonatomic) NSInteger Gender;      //性别

@end
