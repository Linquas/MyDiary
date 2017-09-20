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
#import "OpenWeatherAPI.h"
#import "HttpResponseErrorCode.h"
#import "Weather.h"
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
@property (nonatomic) BOOL editExistDiary;
@property (nonatomic) BOOL isUsingFirebase;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttomViewYConstraint;

@property (strong, nonatomic) CLLocationManager *loactionManager;
@property (strong, nonatomic) CLLocation *currentLocation;

@end


@implementation WritingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isKeyBoardShowed = NO;
    [self.dismissBtn setHidden:YES];
    
    if (self.diary) {
        self.editExistDiary = YES;
        self.titleTextView.text = self.diary.title;
        self.contentTextView.text = self.diary.text;
    } else {
        self.editExistDiary = NO;
    }
    
    self.isUsingFirebase = [[NSUserDefaults standardUserDefaults] boolForKey:@"UsingFirebase"];
    [self registerForKeyboardNotifications];
    
    self.titleTextView.delegate = self;
    self.contentTextView.delegate = self;
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.loactionManager = [[CLLocationManager alloc]init];
        self.loactionManager.delegate = self;
        [self.loactionManager requestWhenInUseAuthorization];
        self.loactionManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.loactionManager startUpdatingLocation];
    }
}

- (IBAction)dimissKeyBoardBtn:(id)sender {
    [self dismissKeyboard];
}

- (IBAction)closeBtn:(id)sender {
    UIAlertController* closeAlert = [UIAlertController alertControllerWithTitle:@"你的日記尚未存擋" message:@"你不寫了嗎？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* close = [UIAlertAction actionWithTitle:@"是的"
                                                    style:UIAlertActionStyleDestructive
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
        if (self.editExistDiary) {
            Diary *diary = [[Diary alloc]init];
            NSString *buff = [NSString stringWithFormat:@"%@", self.titleTextView.text];
            diary.title =buff;
            buff = [NSString stringWithFormat:@"%@", self.contentTextView.text];
            diary.text = buff;
            diary.key = self.diary.key;
            diary.date = self.diary.date;

            [self getWeatherAndLocationAndSaveWithDiary:diary];
            [self setDiaryUidAndSaveToFirebase:diary];

            [self dismissKeyboard];
            [self.presentingViewController.presentingViewController dismissViewControllerAnimated: true completion: nil];
        } else {
            Diary *diary = [[Diary alloc]init];
            NSDate *today = [NSDate date];
            NSString *buff = [NSString stringWithFormat:@"%@", self.titleTextView.text];
            diary.title =buff;
            buff = [NSString stringWithFormat:@"%@", self.contentTextView.text];
            diary.text = buff;
            diary.key = [today timeInInteger];
            diary.date = today;
        
            [self getWeatherAndLocationAndSaveWithDiary:diary];

        }
        [self dismissKeyboard];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- Private method
- (void)dismissKeyboard {
    [self.titleTextView endEditing:YES];
    [self.contentTextView endEditing:YES];
    self.isKeyBoardShowed = NO;
}

- (void)setDiaryUidAndSaveToFirebase:(Diary*)diary {
    if (self.isUsingFirebase) {
        [[DatabaseServices instance] storeDiary:diary];
        diary.user = [FIRAuth auth].currentUser.uid;
    } else {
        diary.user = [[NSUserDefaults standardUserDefaults] stringForKey:@"ID"];
    }
}

#pragma mark - TextView Delegate
- (void)textFieldDidBeginEditing:(PlaceHoldUITextView *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(PlaceHoldUITextView *)textField {
    self.activeField = nil;
}


#pragma mark - Keyboard delegate and Setting
// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)noti {
    //move up bottom view
    NSDictionary* info = [noti userInfo];
    //get size of KeyBoard
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.kbSize = kbSize;
    if (!self.isKeyBoardShowed) {
        self.buttomViewYConstraint.constant = self.kbSize.height;
        self.isKeyBoardShowed = YES;
//        NSLog(@"%@", self.bottonView.debugDescription);
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
        self.buttomViewYConstraint.constant = 0;
        self.isKeyBoardShowed = NO;
    }
    [self.dismissBtn setHidden:YES];
}

// Called when the keyboard frame change and update bottom view's frame
- (void)keyboardWillChange:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.kbSize = kbSize;
    self.buttomViewYConstraint.constant = self.kbSize.height;
}

#pragma mark - CLLocation Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = locations[0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.loactionManager stopUpdatingLocation];
}

- (void)getWeatherAndLocationAndSaveWithDiary:(Diary*)diary {
    __weak WritingVC *weakself = self;
    [[OpenWeatherAPI requestWithCompleteBlock:^(id data) {
        WritingVC *innerSelf = weakself;
        NSDictionary *json = data;
        Weather *w = [innerSelf jsonParser:json];
        if (w) {
            diary.weather = w.weatherDescription;
            diary.loaction = w.location;
        }
        [self setDiaryUidAndSaveToFirebase:diary];
        [[RealmManager instance] updateObject:diary];
        
    } failedBlock:^(NSInteger statusCode, NSInteger errorCode) {
        
        NSLog(@"Status Code: %i", (int)statusCode);
        NSLog(@"Error Code: %i", (int)errorCode);
        [self setDiaryUidAndSaveToFirebase:diary];
        [[RealmManager instance] updateObject:diary];
        
    }] getWeatherDataWithCityGPSCordinate:self.currentLocation];
}


- (Weather*)jsonParser:(id)jsonData {
    if ([jsonData isKindOfClass:[NSDictionary class]] || jsonData ) {
        NSString *cityName = [jsonData objectForKey:@"name"];
        
        if ([[jsonData objectForKey:@"weather"] isKindOfClass:[NSArray class]]) {
            NSArray *weather = [jsonData objectForKey:@"weather"];
            NSDictionary *weatherData = weather[0];
            NSString *description = [weatherData objectForKey:@"description"];
            return [[Weather alloc]initWithWeatherDescription:description withLocation:cityName];
        }
    }
    return nil;
}


@end
