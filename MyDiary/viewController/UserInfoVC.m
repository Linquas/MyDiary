//
//  UserInfoVC.m
//  MyDiary
//
//  Created by Linquas on 09/09/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import "UserInfoVC.h"
#import "User.h"
#import "RealmManager.h"
#import "MainPageVC.h"
@import LGButton;

@interface UserInfoVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet LGButton *done;
@property (nonatomic) id currentResponder;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgrounf;
@property (weak, nonatomic) UITextField *activeField;

@end

@implementation UserInfoVC
#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameTextField.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    [self registerForKeyboardNotifications];
}
#pragma mark - ACtions
- (IBAction)photoBtn:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)cameraBtn:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (IBAction)doneBtn:(id)sender {
    if ([self.userNameTextField.text isEqualToString:@""]) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"空白內容" message:@"你的名字是？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *resume = [UIAlertAction actionWithTitle:@"關閉"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:resume];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        User *usr = [[User alloc]init];
        NSString *buff = [NSString stringWithFormat:@"%@", self.userNameTextField.text];
        usr.fullName = buff;
        [[NSUserDefaults standardUserDefaults] setObject:buff forKey:@"ID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        usr.photo = UIImageJPEGRepresentation(self.profilePic.image, 0.9);
        usr.userId = buff;
        [[RealmManager instance]addOrUpdateObject:usr];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isOffline"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"UsingFirebase"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoggedIn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        MainPageVC *mainPageVC = [MainPageVC storyboardInstance];
        [self presentViewController:mainPageVC animated:YES completion:nil];
    }
}

- (IBAction)closeBtn:(id)sender {
    UIAlertController* closeAlert = [UIAlertController alertControllerWithTitle:@"取消離線登入" message:@"你確定要取消嗎？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* close = [UIAlertAction actionWithTitle:@"是的"
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction * action) {
                                                      [self dismissViewControllerAnimated:YES completion:nil];
                                                  }];
    [closeAlert addAction:close];
    UIAlertAction *resume = [UIAlertAction actionWithTitle:@"繼續"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                         [closeAlert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [closeAlert addAction:resume];
    [self presentViewController:closeAlert animated:YES completion:nil];
}
#pragma mark - ImagePicker delegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        self.profilePic.image = img;
    }else {
        NSLog(@"Photo picker error");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- gesture setting
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    NSLog(@"%@",touch.view.debugDescription);
    if ([touch.view isKindOfClass:[UIStackView class]]) {
        return NO;
    }
    return YES;
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

#pragma mark -- textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
    self.activeField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    [textField endEditing:YES];
    return NO;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark -- keyboard delegate
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

// Called when the keyboard frame change
- (void)keyboardWillChange:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}


@end
