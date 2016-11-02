//
//  ViewController.m
//  ALFlappyBird
//
//  Created by allenlee on 2016/9/13.
//  Copyright © 2016年 allenlee. All rights reserved.
//

#import "ViewController.h"
#import "FlappyBirdView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet FlappyBirdView *flappyBirdView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.flappyBirdView commonInit];
  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
  [self.flappyBirdView addGestureRecognizer:tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)tap:(UITapGestureRecognizer *)sender {
  [self.flappyBirdView birdFly];
}

@end
