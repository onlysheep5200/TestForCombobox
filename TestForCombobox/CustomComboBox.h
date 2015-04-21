//
//  CustomComboBox.h
//  TestForCombobox
//
//  Created by mac on 15/4/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomComboBox;

@protocol CustomComboBoxDelegate <NSObject>

@required
-(void)onComboboxSelected:(NSString*)selctedItem;

@end

@interface CustomComboBox : UIView <UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UIColor* indicatorColor;
@property(nonatomic,strong) NSArray* options;
@property(nonatomic,strong) UIColor* fontColor;
@property(nonatomic,strong) UIColor* optionColor;
@property(nonatomic) id<CustomComboBoxDelegate> delegate;

@end


@interface CALayer (MXAddAnimationAndValue)

- (void)addAnimation:(CAAnimation *)anim andValue:(NSValue *)value forKeyPath:(NSString *)keyPath;

@end
