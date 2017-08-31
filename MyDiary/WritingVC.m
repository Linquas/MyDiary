//
//  WritingVC.m
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "WritingVC.h"
#import "PlaceHoldUITextView.h"
#define kOFFSET_FOR_KEYBOARD 80.0
#define TEXTCOLOR [UIColor colorWithRed:0.53 green:0.71 blue:0.76 alpha:1.0]
#define FONTNAME @"Helvetica Neue"
#define WEEKDAYS [@"Sunday",@"Monday",@"Tuseday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"]
#define MONTHS [@"January",@"February",@"March",@"April",@"May",@"June",@"July",@"August",@"September",@"October",@"November",@"December"]

@interface WritingVC ()
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *titleTextView;
@property (weak, nonatomic) IBOutlet PlaceHoldUITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottonView;
@property (weak, nonatomic) PlaceHoldUITextView *activeField;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;
@property (weak, nonatomic) IBOutlet UILabel *monthLAbel;
@property (weak, nonatomic) IBOutlet UILabel *dayLAbel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (nonatomic) BOOL isKeyBoardShowed;
@property (nonatomic) CGSize kbSize;


@end


@implementation WritingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.titleTextView.textContainer.maximumNumberOfLines = 1;
    self.titleTextView.delegate = self;
    self.titleTextView.attributedPlaceholder = [self generateAttributedStringWithString:@"Title" Color:TEXTCOLOR FontName:FONTNAME FontSize:35.0];
    
    self.contentTextView.delegate = self;
    self.contentTextView.attributedPlaceholder = [self generateAttributedStringWithString:@"Diary" Color:TEXTCOLOR FontName:FONTNAME FontSize:20.0];
    
    [self.dismissBtn setHidden:YES];
    self.isKeyBoardShowed = NO;
    
    [self updateDate];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.titleTextView becomeFirstResponder];
}

- (void)updateDate {
    NSArray *weekdays = @WEEKDAYS;
    NSArray *months = @MONTHS;
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *components = [calendar components:unitFlags fromDate:today];
    
    self.dayLAbel.text = [NSString stringWithFormat:@"%d",(int)[components day]];
    self.weekdayLabel.text = [NSString stringWithFormat:@"%@",[weekdays objectAtIndex:[components weekday] - 1]];
    self.yearLabel.text = [NSString stringWithFormat:@"%d",(int)[components year]];
    self.monthLAbel.text = [NSString stringWithFormat:@"%@",[months objectAtIndex:[components month] - 1]];
    
    
    NSLog(@"weekday: %ld",(long)[components weekday]);
    NSLog(@"%@", components.debugDescription);
}

- (void) dismissKeyboard {
    [self.titleTextView endEditing:YES];
    [self.contentTextView endEditing:YES];
    self.isKeyBoardShowed = NO;
}

- (void)setNewYPositionWithView:(UIView *)view Y:(CGFloat) y{
    CGRect newFrame = view.frame;
    newFrame.origin.y += y;
    [view setFrame:newFrame];
}

- (NSMutableAttributedString*)generateAttributedStringWithString:(NSString*)str Color:(UIColor*)color FontName:(NSString*) fontname FontSize:(NSInteger) fontsize {
    
    NSMutableDictionary *attrDict = [NSMutableDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    UIFont *font = [UIFont fontWithName:fontname size:fontsize];
    [attrDict setObject:font forKey:NSFontAttributeName];
    return [[NSMutableAttributedString alloc] initWithString:str attributes: attrDict];
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
