//
//  CustomComboBox.m
//  TestForCombobox
//
//  Created by mac on 15/4/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "CustomComboBox.h"

@implementation CustomComboBox
{
    CAShapeLayer* indicatorLayer;
    CATextLayer* textLayer;
    BOOL isForward;
    BOOL isAnimated;
    UITableView* optionsTableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self layoutIfNeeded];
     NSLog(@"width : %f",self.bounds.size.width);
}

-(void) layoutIfNeeded
{
    //[super layoutIfNeeded];
    if(isAnimated)
    {
        NSLog(@"is animate");
        return;
    }
    //防止重绘时多画三角形
    [indicatorLayer removeFromSuperlayer];
    indicatorLayer = [[CAShapeLayer alloc]init];
    UIBezierPath* trianglePath = [[UIBezierPath alloc]init];
    [trianglePath moveToPoint:CGPointMake(0, 0)];
    [trianglePath addLineToPoint:CGPointMake(8, 0)];
    [trianglePath addLineToPoint:CGPointMake(4, 5)];
    [trianglePath closePath];
    indicatorLayer.path = trianglePath.CGPath;
    indicatorLayer.lineWidth = 1.0;
    
    //加上bounds约束该layer位置
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(indicatorLayer.path, nil, indicatorLayer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, indicatorLayer.miterLimit);
    indicatorLayer.bounds = CGPathGetBoundingBox(bound);
    
    
    if(!self.indicatorColor) {
        self.indicatorColor = [UIColor blackColor];
    }
    indicatorLayer.position = CGPointMake(self.frame.size.width-4-5,self.frame.size.height/2);//中心点的位置
    [self.layer addSublayer:indicatorLayer];
    
    NSString* text = @"默认";
    if(self.options)
    {
        text = [self.options objectAtIndex:0];
    }
    if(!self.fontColor)
        self.fontColor = [UIColor blackColor];
    CGPoint textPoint = CGPointMake((self.frame.size.width)/2, self.frame.size.height/2);
    textLayer = [self creatTextLayerWithNSString:text withColor:self.fontColor andPosition:textPoint andWidth:(self.frame.size.width-13)];
    [self.layer addSublayer:textLayer];
    
    isForward = YES;
    isAnimated = NO;
    UIGestureRecognizer* tappedRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tappedRecognizer];
    
    optionsTableView = [self createTableView];
    

    
}

-(UITableView*)createTableView
{
    UITableView* tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.layer.position.x - self.frame.size.width/2,self.layer.position.y +  self.frame.size.height, self.frame.size.width,0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 20;
    //去除线偏移
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    return tableView;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    CGFloat fontSize = 10.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

- (CATextLayer *)creatTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point andWidth:(CGFloat)sizeWidth
{
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
//    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = 10.0;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}



#pragma mark - animation

- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim andValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [self animateTableview:forward];
    
    isAnimated = YES;
    [CATransaction commit];
    isAnimated = NO;
    //indicator.fillColor = forward ? _tableView.tintColor.CGColor : _menuColor.CGColor;
    indicatorLayer.fillColor = [self.indicatorColor CGColor];
    
    complete();
}

-(void)animateTableview:(BOOL)show
{
    if(show)
    {
        CGFloat tableHeith = optionsTableView.rowHeight*[self.options count];
        optionsTableView.frame = CGRectMake(self.layer.position.x+self.frame.size.width/2, self.layer.position.y+self.frame.size.height, self.frame.size.width, 0);
        [self.superview addSubview:optionsTableView];
        [UIView animateWithDuration:0.2 animations:^(){
            optionsTableView.frame = CGRectMake(self.layer.position.x-self.frame.size.width/2, self.layer.position.y+self.frame.size.height, self.frame.size.width, tableHeith);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^(){
            optionsTableView.frame = CGRectMake(self.layer.position.x-self.frame.size.width/2, self.layer.position.y+self.frame.size.height, self.frame.size.width, 0);
        } completion:^(BOOL finished){
            [optionsTableView removeFromSuperview];
        }];
    }
}

-(void)tapped : (UIGestureRecognizer*)recognizer
{
    NSLog(@"tapped");
    [self animateIndicator:indicatorLayer Forward:isForward complete:^()
    {
        isForward = !isForward;
    }];
}

#pragma mark - tableview

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.optionColor)
        self.optionColor = [UIColor whiteColor];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:10.0];
        cell.backgroundColor = self.optionColor;
    }
    cell.textLabel.text = [self.options objectAtIndex:[indexPath row]];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.options count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//去除线偏移
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* selectedOption = self.options[[indexPath row]];
    [self.delegate onComboboxSelected:selectedOption];
    [self animateIndicator:indicatorLayer Forward:NO complete:^(){
        isForward = YES;
        [UIView animateWithDuration:0.1 animations:^(){
            isAnimated = YES;
            CATextLayer *old = textLayer;
            textLayer = [self creatTextLayerWithNSString:selectedOption withColor:self.fontColor andPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) andWidth:self.frame.size.width-13];
            [self.layer replaceSublayer:old with:textLayer];
        } completion:^(BOOL finished){
            isAnimated = NO;
        }];
    }];
}


@end

#pragma mark - CALayer Category

@implementation CALayer (MXAddAnimationAndValue)

- (void)addAnimation:(CAAnimation *)anim andValue:(NSValue *)value forKeyPath:(NSString *)keyPath
{
    [self addAnimation:anim forKey:keyPath];
    [self setValue:value forKeyPath:keyPath];
}
@end
