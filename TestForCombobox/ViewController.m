//
//  ViewController.m
//  TestForCombobox
//
//  Created by mac on 15/4/20.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "ViewController.h"
#import "CustomComboBox.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet CustomComboBox *combobox;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.combobox.options = @[@"a",@"b",@"c"];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
