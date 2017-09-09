//
//  WritingVC.h
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Diary.h"

@interface WritingVC : UIViewController  <UITextViewDelegate>
@property (strong, nonatomic) Diary* diary;

@end
