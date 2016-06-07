//
//  PhoneCommon.m
//  CallPhone
//
//  Created by 邓志亮 on 15-1-2.
//  Copyright (c) 2015年 邓志亮. All rights reserved.
//

#import "PhoneCommon.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContactPerson.h"

@interface PhoneCommon()

@end
@implementation PhoneCommon

+(NSMutableDictionary *)ReadAllPeoples
{
    NSMutableDictionary *contactsDictionary = [[NSMutableDictionary alloc]init];
    //    定义一个通讯录
    ABAddressBookRef addressBook = nil;
    //    获取通讯录
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_semaphore_signal(sema);
                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    //通讯录放到一个数组
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
    long rcount = CFArrayGetCount(results);
    
    //获取通讯录值
    for(int i = 0; i < rcount; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        
        //读取姓名
        NSString *personName = (NSString *)ABRecordCopyCompositeName(person);
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString *personPhone = nil;
        long k = ABMultiValueGetCount(phone);
        if ((personName && personName.length) && (k > 0))
        {
            for (int j = 0; j < k; j++) {
                personPhone = (NSString *)ABMultiValueCopyValueAtIndex(phone, j);
                if ((personPhone && personPhone.length)) {
                    ContactPerson *cp = [[ContactPerson alloc]init];
                    cp.PersonName = personName;
                    cp.PersonNumber = [[personPhone stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    
                    //=========== 姓名转拼音 begin ===========
                    CFMutableStringRef str = CFStringCreateMutableCopy(NULL, 0,  (__bridge CFMutableStringRef)personName);
                    CFStringTransform(str, NULL, kCFStringTransformMandarinLatin, NO);
                    CFStringTransform(str, NULL, kCFStringTransformStripDiacritics, NO);
                    
                    NSString* longPinyinName = [(NSString*)str uppercaseString];
                    NSString* shortPinyinName = @"";
                    
                    NSArray* pyAry = [longPinyinName componentsSeparatedByString:@" "];
                    for (int l=0; l<pyAry.count; l++) {
                        NSString* pitem = [pyAry objectAtIndex:l];
                        shortPinyinName = [shortPinyinName stringByAppendingString:[pitem substringToIndex:1]];
                    }
                    
                    cp.PersonNamePinyinLong = [longPinyinName stringByReplacingOccurrencesOfString:@" " withString:@""];
                    cp.PersonNamePinyinShort = shortPinyinName;
                    //=========== 拼音 end ===========
                    
                    //读取照片
                    NSData *image = (NSData*)ABPersonCopyImageData(person);
                    cp.Head = [[UIImageView alloc] initWithFrame:CGRectMake(230, 4, 36, 36)];
                    if (image) {
                        [cp.Head setImage:[UIImage imageWithData:image]];
                    }else{
                        [cp.Head setImage:[UIImage imageNamed:@"person-male.png"]];
                    }
                    [contactsDictionary setObject:cp forKey:cp.PersonNumber];
                }
            }
            
        }
        
        CFRelease(phone);
        if (personPhone != nil) [personPhone release];
        if (personName != nil) [personName release];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loadAddress"];
    CFRelease(results);
    CFRelease(addressBook);
    
    return contactsDictionary;
}
@end
