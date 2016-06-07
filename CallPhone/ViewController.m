//
//  ViewController.m
//  CallPhone
//
//  Created by 邓志亮 on 15-1-2.
//  Copyright (c) 2015年 邓志亮. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import "PhoneCommon.h"
#import "myTableViewCell.h"
#import "ContactPerson.h"
#import "MyConstants.h"

@interface ViewController ()

@property(nonatomic) BOOL isAllSelected;    //指示号码是否全选
@property(nonatomic) CGRect kbOpFrame;     //记录操作键盘按钮的原始位置
@property(nonatomic) CGRect keyboardOrgFrame;   //记录键盘原始位置
@property(nonatomic) BOOL kbIsHidden;   //指示键盘是否隐藏
@property(nonatomic) int clickIndex;    //连击索引
@property(nonatomic) int numberBtnWidth;
@property(nonatomic) BOOL hasNewClick;
@property(nonatomic, retain) NSTimer* delaySearchTimer; //延迟执行搜索 for 单击
@property(nonatomic, retain) NSTimer* delayMutipleSearchTimer;  //延迟执行搜索 for 多连击
@property(nonatomic, retain) NSString* currentBtnText;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _kbOpFrame = _kbOpButton.frame;
    _clickIndex = 0;
    _hasNewClick = NO;
    
    [self genCallLayer];
    _contactsDictionary = [PhoneCommon ReadAllPeoples];
    _words = [_contactsDictionary mutableCopy];
    [self initContentView]; 
}

//滑动开始事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pointone = [touch locationInView:self.view];//获得初始的接触点
    self.startPoint  = pointone;
}
//滑动移动事件
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //imgViewTop是滑动后最后接触的View
    CGPoint pointtwo = [touch locationInView: _callView];  //获得滑动后最后接触屏幕的点
    
    if(fabs(pointtwo.x - self.startPoint.x)>100)
    {  //判断两点间的距离
        self.bMove = YES;
    }
}
//滑动结束处理事件
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches end");
    UITouch *touch = [touches anyObject];
    CGPoint pointtwo = [touch locationInView:self.view];  //获得滑动后最后接触屏幕的点
    if((fabs(pointtwo.x - self.startPoint.x)>50)&&(self.bMove))
    {
        //判断点的位置关系 左滑动
        if(pointtwo.x - self.startPoint.x>0)
        {   //左滑动业务处理
            NSLog(@"swipe left");
        }
        //判断点的位置关系 右滑动
        else
        {  //右滑动业务处理
            NSLog(@"swipe right");
        }
    }
}

//初始化页面相关数据和控件属性
-(void) initContentView
{
    //设置头部背景
    [_topView setBackgroundColor:silverColor];
    UIImageView *sepeatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, _topView.frame.size.height, _topView.frame.size.width, 0.5)];
    [sepeatorImage setBackgroundColor:[UIColor lightGrayColor]];
    [_topView addSubview:sepeatorImage];
    
    //关闭文本框自动联想和首字母大写功能
    [_searchText setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_searchText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    _searchText.keyboardType = UIKeyboardTypePhonePad;
    
    //去除TableView 空数据的底边线
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,80)];
    v.backgroundColor = [UIColor clearColor];
    _phoneTable.tableFooterView = v;
    _phoneTable.rowHeight = 45;
    
    _smsContactsTable.tableFooterView = v;
    _smsContactsTable.rowHeight = 36;
    
    //去掉默认分割线
    _phoneTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //默认不显示列表
    [_phoneTable setHidden:YES];
    
    //短信界面相关隐藏
    _callView.hidden = NO;
    _smsView.hidden = YES;
    _editButton.hidden = YES;
    
    //设置拨号面板阴影
    _btnPanelView.layer.shadowColor = [UIColor grayColor].CGColor;
    _btnPanelView.layer.shadowOffset = CGSizeMake(0, -4);
    _btnPanelView.layer.shadowOpacity = 0.2;
    _btnPanelView.layer.shadowRadius = 4;
    
    _charBtnView.layer.borderWidth = 1;
    _charBtnView.layer.borderColor = [silverColor CGColor];
    _charBtnView.layer.shadowColor = [UIColor grayColor].CGColor;
    _charBtnView.layer.shadowOffset = CGSizeMake(2, 3);
    _charBtnView.layer.shadowOpacity = 0.2;
    _charBtnView.layer.shadowRadius = 4;
    
    
}
/*
    生成拨号相关按钮
 */
-(void) genCallLayer{
    NSArray* callBtns = @[@"1", @"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"*",@"0",@"#",@"sent",@"call",@"back"];
    _callBtnAssistDict = @{
      @"2": @"ABC",
      @"3": @"DEF",
      @"4": @"GHI",
      @"5": @"JKL",
      @"6": @"MNO",
      @"7": @"PQRS",
      @"8": @"TUV",
      @"9": @"WXYZ"};
    
    _callBtnFullTextDict = [[NSMutableDictionary alloc]init];
    
    CGSize vSize = _btnPanelView.frame.size;
    float bw = vSize.width / 3.0;   //按钮宽度
    _numberBtnWidth = bw;
    float bh = 50.0;    //按钮高度
    float x = 0.0;  //按钮frame.x
    float y = 0.0;  //按钮frame.y
    
    for (int i=0; i < callBtns.count; i++) {
        if(i % 3 == 0){
            if(i > 0){
                x = 0.0;
                y += bh + 1.0;
            }
            
            UILabel* lbLine = [[UILabel alloc] initWithFrame:CGRectMake(0, y + bh, vSize.width, 0.5)];
            [lbLine setBackgroundColor:silverColor];
            [_btnPanelView addSubview:lbLine];
            
            [lbLine release];
        }
        NSString *buttonText = [callBtns objectAtIndex:i];
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, bw, bh)];
        
        if ([buttonText  isEqual: @"sent"]) {
            [btn setImage:[UIImage imageNamed:@"sent.png"] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        }else if([buttonText  isEqual: @"call"]){
            [btn setImage:[UIImage imageNamed:@"call.png"] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(callClick:) forControlEvents:UIControlEventTouchUpInside];
        }else if([buttonText  isEqual: @"back"]){
            [btn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
            
            [btn addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];
            //指定回退按钮长按事件
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(delLongPress:)];
            longPress.minimumPressDuration = 0.4; //定义按的时间
            [btn addGestureRecognizer:longPress];
        }else{
            [btn setTitle:buttonText forState:UIControlStateNormal];
            
            [btn setBackgroundImage:[UIImage imageNamed:@"btnbg.png"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btnbg_hl.png"] forState:UIControlStateHighlighted];

            //有字母的键
            if ([_callBtnAssistDict.allKeys containsObject:buttonText]) {
                //从字典里取出字母
                NSString* assistText = [_callBtnAssistDict objectForKey:buttonText];
                UILabel* lbAssist = [[UILabel alloc] initWithFrame:CGRectMake(0, (btn.titleLabel.frame.size.height + btn.titleLabel.frame.origin.y + 5), btn.frame.size.width, 15.0)];
                lbAssist.text = assistText;
                [lbAssist setTextAlignment:NSTextAlignmentCenter];
                [lbAssist setFont:[UIFont systemFontOfSize:12.0]];
                [lbAssist setTextColor:[UIColor grayColor]];
                [btn addSubview:lbAssist];
                
                //数字靠顶显示，给下面的字母腾空间
                btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                
                //保存按钮的所有文字
                NSString* btnFullText = [NSString stringWithFormat:@"%@%@", buttonText, assistText];
                [_callBtnFullTextDict setObject:btnFullText forKey:buttonText];
                
                [btn addTarget:self action:@selector(btnTouchDownClick:) forControlEvents:UIControlEventTouchDown];

                //指定回退按钮长按事件
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(complexBtnLongPress:)];
                longPress.minimumPressDuration = 0.4; //定义按的时间
                
                [btn addGestureRecognizer:longPress];
                
                [lbAssist release];
            }
            [btn addTarget:self action:@selector(btnTouchUpClick:) forControlEvents:UIControlEventTouchUpInside];
            if ([buttonText isEqualToString:@"1"]) {
                btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            }
        }
        
        btn.titleLabel.textColor = [UIColor blackColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:28.0f]];
        [_btnPanelView addSubview:btn];
        
        [btn release];
        x += bw;
    }
    
    _keyboardOrgFrame = _btnPanelView.frame;

    [self refreshPhoneTableViewFrame];
}

//UITableView代理实现，指定数据行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _phoneTable)
    {
        return [_words count];
    }
    else
    {
        return [_contactsDictionary count];
    }
}

//UITableViewCell 代理实现，绑定行数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _phoneTable)
    {
        NSString *cellI =[NSString stringWithFormat:@"cell%li",(long)indexPath.row];
        myTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellI];
        if (cell == nil)
        {
            cell = [[myTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellI];
        }
        
        NSString *keyWords = _searchText.text;
        NSString *phoneNumber =[_words.allKeys objectAtIndex:indexPath.row];
        ContactPerson *cp = [_words.allValues objectAtIndex:indexPath.row];
        
        //设置匹配记录关键字的高亮样式
        if (keyWords.length > 0)
        {
            NSRange hlightRange = [phoneNumber rangeOfString:keyWords];
            NSMutableAttributedString *hlightText = [[NSMutableAttributedString alloc] initWithString:phoneNumber];
            NSDictionary *hlightStyle = @{
                                          NSForegroundColorAttributeName: [UIColor redColor],
                                          NSFontAttributeName:[UIFont boldSystemFontOfSize:14]
                                          };
            [hlightText addAttributes:hlightStyle range:hlightRange];
            cell.phoneNumberLabel.attributedText = hlightText;
        }
        else
        {
            cell.phoneNumberLabel.text = phoneNumber;
        };
        [cell.headImage setImage:cp.Head.image];
        
        
        [cell.imageButton setBackgroundImage:[UIImage imageNamed:@"sms.png"] forState:UIControlStateNormal];
        [cell.imageButton addTarget:self action:@selector(smsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.imageButton.tag = indexPath.row;
        cell.phoneNameLabel.text = cp.PersonName;
        
        return cell;
    }
    else
    {
        NSString *cellI =[NSString stringWithFormat:@"smscell%li",(long)indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellI];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellI];
        }
        NSString *phoneNumber = [_contactsDictionary.allKeys objectAtIndex:indexPath.row];
        NSString *phoneName = [[_contactsDictionary.allValues objectAtIndex:indexPath.row] PersonName];
        cell.textLabel.text = phoneNumber;
        cell.detailTextLabel.text = phoneName;
        
        return cell;
    }
}

//UITableView代理实现，使行可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _smsContactsTable)
    {
        return YES;
    }
    return NO;
}

//UITableView代理实现，编辑时显示的样式
- ( UITableViewCellEditingStyle )tableView:( UITableView *)tableView editingStyleForRowAtIndexPath:( NSIndexPath *)indexPath
{
    if (tableView == _smsContactsTable)
    {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
    }
    return UITableViewCellEditingStyleNone;
}

//选择Table cell，拨打电话
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _phoneTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSString *st =[NSString stringWithFormat:@"tel://%@",[_words.allKeys objectAtIndex:indexPath.row]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:st]];
    }
}

//实现搜索方法
- (void)handleSearchForTerm:(NSString *)searchTerm
{
    NSMutableArray * keyArray = [_contactsDictionary.allKeys mutableCopy];
    _words = [_contactsDictionary mutableCopy];
    if (searchTerm.length > 0) {
        searchTerm = [searchTerm uppercaseString];
        for(NSString *pNumber in keyArray)//遍历所有的key
        {
            ContactPerson* person = [_words objectForKey:pNumber];
            //根据号码搜索
            BOOL pNumberNotFound = [pNumber rangeOfString:searchTerm].location == NSNotFound;
            //根据姓名搜索
            BOOL pNameNotFound = [person.PersonName rangeOfString:searchTerm].location == NSNotFound;
            //根据姓名全拼搜索
            BOOL pNamePYLongNotFound = [person.PersonNamePinyinLong rangeOfString:searchTerm].location == NSNotFound;
            //根据姓名简拼搜索
            BOOL pNamePYShortNotFound = [person.PersonNamePinyinShort rangeOfString:searchTerm].location == NSNotFound;
            
            if(pNumberNotFound && pNameNotFound && pNamePYLongNotFound && pNamePYShortNotFound)
            {
                [_words removeObjectForKey:pNumber];
            }
        }
    }else{
        [_words removeAllObjects];
    }
    [_phoneTable reloadData];
    [_phoneTable setHidden:[_words count] == 0];
}

//拨号数字键点击事件
- (IBAction)btnTouchUpClick:(UIButton*)sender {
    [_searchText resignFirstResponder];
    _searchText.text = [NSString stringWithFormat:@"%@%@",_searchText.text, sender.titleLabel.text];
    [self handleSearchForTerm:_searchText.text];
    NSLog(@"touch up");
}

//拨号数字键点击按下事件
- (IBAction)btnTouchDownClick:(UIButton*)sender {
    _currentBtnText = sender.titleLabel.text;
}


//拨号按钮事件
- (IBAction)callClick:(id)sender {
    NSString *st =[NSString stringWithFormat:@"tel://%@", _searchText.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:st]];
}

//文本框代理实现 -- 当文本内容发生变化时触发
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self handleSearchForTerm:textField.text];
}

//文本框值变更事件 -- 使用键盘输入时触发
- (IBAction)searchTextEidtChanged:(UITextField *)sender {
    [self handleSearchForTerm:sender.text];
}

//文本框清除事件
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self handleSearchForTerm: @""];
    return YES;
}

//回退按钮点击事件
- (IBAction)delClick:(id)sender {
    NSString* keyWords = _searchText.text;
    if (keyWords.length > 0) {
        keyWords = [keyWords substringWithRange:NSMakeRange(0, keyWords.length -1)];
        _searchText.text = keyWords;
        [self handleSearchForTerm:keyWords];
    }
}

//回退按钮长按事件，清空文本框
-(void)delLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        _searchText.text = @"";
        [self handleSearchForTerm:@""];
    }
}

//复合按钮长按事件，切换数字和字母显示
-(void)complexBtnLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        NSLog(@"long touch");
        [gestureRecognizer locationInView:_btnPanelView];
        
        NSString* btnCharText = [_callBtnFullTextDict objectForKey:_currentBtnText];
        NSInteger btnNum = [btnCharText intValue];
        float c_x =(btnNum%3 - 1) * _numberBtnWidth;
        if (c_x < 0) {
            c_x = _numberBtnWidth * 2;
        }
        
        
        [_charBtnView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        int x = 5;
        int cbw = (_numberBtnWidth) / (btnCharText.length - 1) - x;
        //int cbw = 30;
        for (int i = 1; i < btnCharText.length; i++) {
            NSString* currChar = [[btnCharText substringFromIndex:i] substringToIndex:1];
            UIButton* charBtn = [[UIButton alloc] initWithFrame:CGRectMake(x, 4, cbw, 25)];
            [charBtn setTitle:currChar forState:UIControlStateNormal];
            [charBtn setBackgroundColor:[UIColor blueColor]];
            
            [charBtn addTarget:self action:@selector(charBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [_charBtnView addSubview:charBtn];
            [charBtn release];
            x += cbw + 1;
        }
        float c_y = (btnNum / 3 + 1) * 50;
        if(btnNum %3 == 0){
            c_y = (btnNum / 3) * 50;
        }
        [_charBtnView setFrame:CGRectMake(c_x, _btnPanelView.frame.origin.y + c_y, (cbw*(btnCharText.length-1) + 10 +btnCharText.length -2), 33)];
        [_charBtnView setHidden:NO];
    }
}

-(void) charBtnClick:(id) sender{
    [_charBtnView setHidden:YES];
    NSString* currChar = ((UIButton *)sender).titleLabel.text;
    _searchText.text = [NSString stringWithFormat:@"%@%@", _searchText.text, currChar];
    [self handleSearchForTerm:_searchText.text];
}

//列表信息图标点击事件
-(void) smsButtonClick:(UIButton *)btn
{
    NSString *phoneNumber =[_words.allKeys objectAtIndex:btn.tag];
    NSMutableArray* phoneAry = [[NSMutableArray alloc] initWithObjects:phoneNumber, nil];
    [self jumpToMessageView:phoneAry title:@"发短信" body: @""];
    //[self sendSms:phoneNumber];
}

//拨号键盘发送图标点击事件
- (IBAction)sendAction:(UIButton *)sender{
    NSString* phoneNumber = _searchText.text;
    NSMutableArray* phoneAry = [[NSMutableArray alloc] initWithObjects:phoneNumber, nil];
    [self jumpToMessageView:phoneAry title:@"发短信" body: @""];
    //[self sendSms:phoneNumber];
}

-(void) sendSms:(NSString*)smsContent{
    NSString *st =[NSString stringWithFormat:@"sms://%@",smsContent];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:st]];
}

//切换拨号和短信页面
- (IBAction)segmentedAction:(UISegmentedControl *)sender {
    [_searchText resignFirstResponder];
    switch (sender.selectedSegmentIndex) {
        case 0: //拨号界面
            [_callView setHidden:NO];
            [_smsView setHidden:YES];
            [_editButton setHidden:YES];
            break;
        case 1: //短信界面
            [_callView setHidden:YES];
            [_smsView setHidden:NO];
            [_editButton setHidden:NO];
            if (_smsContactsTable.editing == NO) {
                _smsContactsTable.editing = YES;
            }
        default:
            break;
    }
}

//短信页面send按钮点击事件，传送联系人给系统短信界面
- (IBAction)sendSmsAction:(UIButton *)sender {
    NSArray * array = [_smsContactsTable indexPathsForSelectedRows];
    if ([array count] > 0) {
        NSMutableArray *phoneAry=[[NSMutableArray alloc]init];
        for (int i=0; i<[array count]; i++) {
            NSIndexPath *index = [array objectAtIndex:i];
            NSString *phoneNum = [_contactsDictionary.allKeys objectAtIndex:index.row];
            [phoneAry addObject:phoneNum];
        }
        [self jumpToMessageView:phoneAry title:@"发短信" body: @""];
    }
    else
    {
        [self showDialog:@"请选择联系人."];
    }
}

-(void) showDialog:(NSString*)msgContent{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgContent delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
}

//短信页面全选按钮
- (IBAction)selectClick:(UIButton *)sender {
    _isAllSelected = !_isAllSelected;
    NSInteger count = _contactsDictionary.count;
    for (int row = 0; row < count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        if (_isAllSelected) {
            [_smsContactsTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        else
        {
            [_smsContactsTable deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
    
    [_editButton setTitle:_isAllSelected ? @"反选": @"全选" forState:UIControlStateNormal];
}
//显示与隐藏键盘操作
- (IBAction)keyOpClick:(UIButton*)sender{
    if (_kbIsHidden == YES) {
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
            [_btnPanelView setFrame:CGRectMake(0, _keyboardOrgFrame.origin.y, _btnPanelView.frame.size.width,_btnPanelView.frame.size.height)];
            [_kbOpButton setTitle: @"hide keyboard" forState:UIControlStateNormal];
            [_kbOpButton setFrame:_kbOpFrame];
            
            [_searchView setFrame:CGRectMake(_searchView.frame.origin.x, _searchView.frame.origin.y, _searchView.frame.size.width, _callView.frame.size.height - (_btnPanelView.frame.size.height + _kbOpButton.frame.size.height))];
            
            [self refreshPhoneTableViewFrame];
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_btnPanelView setFrame:CGRectMake(0, _callView.frame.size.height, _btnPanelView.frame.size.width,_btnPanelView.frame.size.height)];
            [_kbOpButton setTitle: @"show keyboard" forState:UIControlStateNormal];
            [_kbOpButton setFrame:CGRectMake(_kbOpFrame.origin.x, (_callView.frame.size.height - _kbOpFrame.size.height - 10), _kbOpFrame.size.width, _kbOpFrame.size.height)];
            
            [_searchView setFrame:CGRectMake(_searchView.frame.origin.x, _searchView.frame.origin.y, _searchView.frame.size.width, _callView.frame.size.height - (_kbOpButton.frame.size.height))];
            
            [self refreshPhoneTableViewFrame];
        } completion:^(BOOL finished) {
            
        }];
        
        
    }
    _kbIsHidden = !_kbIsHidden;
}
//拨号界面点击事件，隐藏键盘
-(IBAction)viewClick:(id)sender{
    [_searchText resignFirstResponder];
    [_charBtnView setHidden:YES];
}

//退出按钮事件
- (IBAction)exitAction:(id)sender {
    exit(0);
}

-(void) refreshPhoneTableViewFrame{
    [_phoneTable setFrame: CGRectMake(_phoneTable.frame.origin.x, _phoneTable.frame.origin.y, _phoneTable.frame.size.width, (_searchView.frame.size.height - (_searchText.frame.origin.y + _searchText.frame.size.height)))];
}

//跳转至系统短信界面
-(void)jumpToMessageView : (NSMutableArray *)phoneAry title : (NSString *)title body : (NSString *)body
{
    if( [MFMessageComposeViewController canSendText] )
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = [NSArray arrayWithArray:phoneAry];
        controller.body = body;
        controller.messageComposeDelegate = self;
        //[self presentModalViewController:controller animated:YES];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    }
    else
    {
        [self showDialog:@"该设备不支持短信功能"];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
//    [self dismissModalViewControllerAnimated:YES];
    
//    switch (result) {
//        case MessageComposeResultCancelled:
//        {
//            //click cancel button
//        }
//            break;
//        case MessageComposeResultFailed:// send failed
//            break;
//            
//        case MessageComposeResultSent:
//        {
//            //do something
//        }
//            break;
//        default:
//            break;
//    } 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_searchText release];
    [_phoneTable release];
    [_smsContactsTable release];
    [_editButton release];
    [_topView release];
    [super dealloc];
}

@end
