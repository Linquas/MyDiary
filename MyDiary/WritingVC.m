//
//  WritingVC.m
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "WritingVC.h"
#import "PlaceHoldUITextView.h"
#import "RealmManager.h"
#import "NSDate+YearMonthDay.h"
#import "Diary.h"
#import "DatabaseServices.h"
@import Firebase;


@interface WritingVC ()
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *titleTextView;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottonView;
@property (weak, nonatomic) PlaceHoldUITextView *activeField;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;
@property (nonatomic) BOOL isKeyBoardShowed;
@property (nonatomic) CGSize kbSize;


@end


@implementation WritingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.titleTextView.delegate = self;
    self.contentTextView.delegate = self;
    
    [self.dismissBtn setHidden:YES];
    
    self.isKeyBoardShowed = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.titleTextView becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.titleTextView endEditing:YES];
    [self.contentTextView endEditing:YES];
    self.isKeyBoardShowed = NO;
}

- (void)setNewYPositionWithView:(UIView *)view Y:(CGFloat) y{
    CGRect newFrame = view.frame;
    newFrame.origin.y += y;
    [view setFrame:newFrame];
}

//button

- (IBAction)dimissKeyBoardBtn:(id)sender {
    [self dismissKeyboard];
}

- (IBAction)closeBtn:(id)sender {
    UIAlertController* closeAlert = [UIAlertController alertControllerWithTitle:@"你的日記尚未存擋" message:@"你不寫了嗎？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* close = [UIAlertAction actionWithTitle:@"是的"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      [self dismissKeyboard];
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  }];
    [closeAlert addAction:close];
    UIAlertAction *resume = [UIAlertAction actionWithTitle:@"繼續寫"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                         [closeAlert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [closeAlert addAction:resume];
    [self presentViewController:closeAlert animated:YES completion:nil];
}

- (IBAction)saveDiaryBtn:(id)sender {
    if ([self.titleTextView.text isEqualToString:@""] || [self.contentTextView.text isEqualToString:@""] ) {
        UIAlertController* saveAlert = [UIAlertController alertControllerWithTitle:@"空白內容" message:@"好好想想生活中的樂趣吧！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *resume = [UIAlertAction actionWithTitle:@"繼續寫"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                             [saveAlert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
        [saveAlert addAction:resume];
        [self presentViewController:saveAlert animated:YES completion:nil];
    } else {
        Diary *diary = [[Diary alloc]init];
        NSDate *today = [NSDate date];
        NSString *buff = [NSString stringWithFormat:@"%@", self.titleTextView.text];
        diary.title =buff;
        buff = [NSString stringWithFormat:@"%@", self.contentTextView.text];
        diary.text = buff;
        diary.key = [today getYearMonthDayOfTodayInInteger];
        diary.date = today;
        diary.user = [FIRAuth auth].currentUser.uid;
        
        [[DatabaseServices instance] storeDiary:diary];
        
        [[RealmManager instance] updateObject:diary];
        [self dismissKeyboard];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSInteger)getYearMonthDayOfTodayInInteger {

    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString *date =  [formatter stringFromDate:[NSDate date]];
    
    return [date integerValue];
}

- (void)textFieldDidBeginEditing:(PlaceHoldUITextView *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(PlaceHoldUITextView *)textField {
    self.activeField = nil;
}

//Keyboard setting

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)noti {
    //move up bottom view
    NSDictionary* info = [noti userInfo];
    //get size of KeyBoard
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.kbSize = kbSize;
    if (!self.isKeyBoardShowed) {
        [self setNewYPositionWithView:self.bottonView Y:-self.kbSize.height];
        self.isKeyBoardShowed = YES;
    }
    [self.dismissBtn setHidden:NO];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification{
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= self.kbSize.height;
    
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    //move down bottom view
    if (self.isKeyBoardShowed) {
        [self setNewYPositionWithView:self.bottonView Y:self.kbSize.height];
        self.isKeyBoardShowed = NO;
    }
    [self.dismissBtn setHidden:YES];
}


@end
