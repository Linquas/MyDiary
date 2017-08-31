//
//  PlaceHoldUITextView.h
//  MyDiary
//
//  Created by Linquas on 30/08/2017.
//  Copyright © 2017 Linquas. All rights reserved.
//


#import <UIKit/UIKit.h>


/**
 UITextView subclass that adds placeholder support like UITextField has.
 */
@interface PlaceHoldUITextView : UITextView

/**
 The string that is displayed when there is no other text in the text view. This property reads and writes the
 attributed variant.
 The default value is `nil`.
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 The attributed string that is displayed when there is no other text in the text view.
 The default value is `nil`.
 */
@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

/**
 Returns the drawing rectangle for the text views’s placeholder text.
 @param bounds The bounding rectangle of the receiver.
 @return The computed drawing rectangle for the placeholder text.
 */
- (CGRect)placeholderRectForBounds:(CGRect)bounds;

@end
