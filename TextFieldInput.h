//
//  TextFieldInput.h
//  TaskGnome
//
//  Created by Lion User on 17/07/2013.
//  Copyright (c) 2013 Covalent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldInput : UIView

- (void) setText:(NSString *)text;
- (NSString *) getText;
- (void) setHint:(NSString *)hint;

@end
