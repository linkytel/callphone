//
//  ViewController.h
//  CallPhone
//
//  Created by 邓志亮 on 15-1-2.
//  Copyright (c) 2015年 邓志亮. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate>

@property(retain, nonatomic) NSMutableDictionary *contactsDictionary;
@property (nonatomic,retain) NSMutableDictionary *words;
@property (nonatomic,retain) NSMutableArray *keys;
@property (nonatomic,retain) NSDictionary* callBtnAssistDict;
@property (nonatomic,retain) NSMutableDictionary* callBtnFullTextDict;

@property (retain, nonatomic) IBOutlet UITextField *searchText;
@property (retain, nonatomic) IBOutlet UITableView *phoneTable;
@property (retain, nonatomic) IBOutlet UIView *topView;
@property (retain, nonatomic) IBOutlet UIView *bodyView;
@property (retain, nonatomic) IBOutlet UIView *callView;
@property (retain, nonatomic) IBOutlet UIView *smsView;
@property (retain, nonatomic) IBOutlet UIView *btnPanelView;
@property (retain, nonatomic) IBOutlet UIView *searchView;
@property (retain, nonatomic) IBOutlet UIView *charBtnView;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *kbOpButton;
@property (retain, nonatomic) IBOutlet UITableView *smsContactsTable;

- (void)handleSearchForTerm:(NSString *)searchTerm;
-(void) sendSms:(NSString*)smsContent;

- (IBAction)btnTouchUpClick:(UIButton*)sender;
- (IBAction)btnTouchDownClick:(UIButton*)sender;
- (IBAction)callClick:(id)sender;
- (IBAction)delClick:(id)sender;
-(IBAction)charBtnClick:(UIButton*)sender;
- (IBAction)segmentedAction:(UISegmentedControl *)sender;
- (IBAction)sendAction:(UIButton *)sender;
- (IBAction)sendSmsAction:(UIButton *)sender;
- (IBAction)selectClick:(UIButton *)sender;
- (IBAction)exitAction:(id)sender;
- (IBAction)keyOpClick:(UIButton*)sender;
- (IBAction)viewClick:(id)sender;
- (IBAction)searchTextEidtChanged:(UITextField *)sender;

@property(assign) CGPoint startPoint;
@property(assign) BOOL bMove;
@property(assign) int clicks;

@end

