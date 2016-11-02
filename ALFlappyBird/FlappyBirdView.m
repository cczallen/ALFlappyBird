//
//  FlappyBirdView.m
//  ALFlappyBird
//
//  Created by allenlee on 2016/9/13.
//  Copyright © 2016年 allenlee. All rights reserved.
//

#define GetRandomBetween(min,max) (arc4random()%(max-min+1) +min)

#define NumberOfPillars 15
#define PillarsVerticalGap (140)
#define BirdFallsSpeed 4
#define PillarsMovesSpeed 1.2
#define EachBirdFlyHeight (60)



#import "FlappyBirdView.h"

@interface FlappyBirdView ()

@property (strong, nonatomic) CADisplayLink *displayLink;
@property (strong, nonatomic) CALayer *bird;
@property (strong, nonatomic) CALayer *pillarsLayer;
@property (strong, nonatomic) NSMutableArray<CALayer *> *pillars;

@end

@implementation FlappyBirdView

- (void)commonInit {
  self.backgroundColor = [UIColor brownColor];
  [self restartGame];
}

- (void)restartGame {
  (self.displayLink)? [self.displayLink invalidate] : nil;
  self.displayLink = nil;
  
  [self.pillars removeAllObjects];
  [self.pillarsLayer removeFromSuperlayer];
  [self.bird removeFromSuperlayer];
  
  [self createLayers];
  [self startDisplayLink];
}

- (void)createLayers {
  // add pillars
  self.pillarsLayer = ({
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.frame = self.bounds;
    layer;
  });
  [self.layer addSublayer:self.pillarsLayer];
  
  self.pillars = [NSMutableArray array];
  NSInteger numberOfPillars = NumberOfPillars;
  CGFloat currentX = CGRectGetWidth(self.bounds);
  CGFloat pillarWidth = 60;
  CGFloat pillarMinHeight = 130;
  CGFloat pillarsVerticalGap = PillarsVerticalGap;
  CGFloat pillarsHorizntalGap = 140;
  for (int i=0; i<numberOfPillars; i++) {
    CGFloat pillarActualHeight;
    CGColorRef pillarBackgroundColor = [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1].CGColor;
    
    // upper pillar
    CGFloat randomHeight = GetRandomBetween(0, (int)(CGRectGetHeight(self.bounds) * 0.3));
    pillarActualHeight = pillarMinHeight + randomHeight;
    CALayer *upperPillar = ({
      CALayer *layer = [CALayer layer];
      layer.cornerRadius = 4;
      layer.backgroundColor = pillarBackgroundColor;
      layer.frame = CGRectMake(currentX, 0, pillarWidth, pillarActualHeight);
      layer;
    });
    [self.pillarsLayer addSublayer:upperPillar];
    [self.pillars addObject:upperPillar];
    
    // lower pillar
    CGFloat lowerPillarY = CGRectGetMaxY(upperPillar.frame) + pillarsVerticalGap;
    pillarActualHeight = CGRectGetHeight(self.pillarsLayer.frame) - lowerPillarY;
    
    CALayer *lowerPillar = ({
      CALayer *layer = [CALayer layer];
      layer.cornerRadius = 4;
      layer.backgroundColor = pillarBackgroundColor;
      layer.frame = CGRectMake(currentX, lowerPillarY, pillarWidth, pillarActualHeight);
      layer;
    });
    [self.pillarsLayer addSublayer:lowerPillar];
    [self.pillars addObject:lowerPillar];
    
    currentX += (pillarWidth + pillarsHorizntalGap);
  }
  
  // add bird
  self.bird = ({
    CALayer *layer = [CALayer layer];
    UIImage *twitterBirdImage = [UIImage imageNamed:@"twitter-128"];
    layer.contents = (id)twitterBirdImage.CGImage;
//    layer.backgroundColor = [UIColor yellowColor].CGColor;
    layer.bounds = CGRectMake(0, 0, 40, 40);
    layer.cornerRadius = layer.bounds.size.width * 0.5;
    layer.position = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    layer;
  });
  [self.layer addSublayer:self.bird];
  
  // swing animation
  CABasicAnimation *swingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  swingAnimation.fromValue = @(M_PI * 2 * -0.08);
  swingAnimation.toValue = @(M_PI * 2 * 0.08);
  swingAnimation.autoreverses = YES;
  swingAnimation.repeatCount = NSUIntegerMax;
  swingAnimation.duration = 1.0;
  [self.bird addAnimation:swingAnimation forKey:@"SwingAnimation"];
}

- (void)startDisplayLink {
  self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
  [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
  [self judge];
  [self birdMoves:CGPointMake(0, BirdFallsSpeed) animated:NO];
  [self pillarsMoves:CGPointMake(-PillarsMovesSpeed, 0)];
}

- (void)judge {
  // if loss
  if (CGRectGetMaxY(self.bird.frame) >= CGRectGetMaxY(self.frame)) {
    [self loss];
    return;
  }
  
  CGRect birdRect = self.bird.presentationLayer.frame;
  birdRect = CGRectInset(birdRect, 4, 8);
  for (CALayer *eachPillar in self.pillars) {
    CGRect pillarRect = [self.pillarsLayer convertRect:eachPillar.presentationLayer.frame toLayer:self.bird.superlayer];
    
    BOOL isLoss = CGRectIntersectsRect(birdRect, pillarRect);
    if (isLoss) {
      eachPillar.backgroundColor = [UIColor colorWithRed:142/255.0 green:68/255.0 blue:173/255.0 alpha:1].CGColor;
      [self loss];
      return;
    }
  }
  
  // if win
  CALayer *lastPillar = [self.pillars lastObject];
  CGRect lastPillarRect = [self.pillarsLayer convertRect:lastPillar.presentationLayer.frame toLayer:self.bird.superlayer];
  if (CGRectGetMaxX(lastPillarRect) < 0) {
    [self win];
  }
}

void addTextZoomInAnimation(UIView *superview, NSString *text, UIColor *textColor, void(^completion)()) {
  UILabel *label = [[UILabel alloc] init];
  label.textColor = textColor;
  label.text = text;
  label.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:40];
  [superview addSubview:label];
  [label sizeToFit];
  label.center = superview.center;
  [UIView animateWithDuration:2.0 animations:^{
    CGFloat scale = 3;
    label.transform = CGAffineTransformMakeScale(scale, scale);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.5 animations:^{
      label.alpha = 0;
    } completion:^(BOOL finished) {
      [label removeFromSuperview];
      if (completion) {
        completion();
      }
    }];
  }];
}

- (void)loss {
//  [self.bird removeAllAnimations];
  [self.displayLink setPaused:YES];
  [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  
  if (CGRectGetMaxY(self.bird.frame) < CGRectGetMaxY(self.frame)) {
    [CATransaction begin];
    [CATransaction setDisableActions:YES]; {
      self.bird.position = self.bird.presentationLayer.position;
    } [CATransaction commit];
  }
  
  // animation
  UIColor *fromColor = self.backgroundColor;
  UIColor *toColor = [UIColor colorWithRed:192/255.0 green:57/255.0 blue:43/255.0 alpha:0.9];
  CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
  colorAnimation.duration = 2.5;
  colorAnimation.fromValue = (id)fromColor.CGColor;
  colorAnimation.toValue = (id)toColor.CGColor;
  
  [self.layer addAnimation:colorAnimation forKey:@"LossAnimation"];
  
  // text
  NSString *lossText = @"YOU LOSS...";
  addTextZoomInAnimation(self, lossText, [UIColor redColor], NULL);
  
  [self performSelector:@selector(restartGame) withObject:nil afterDelay:colorAnimation.duration];
}

- (void)win {
  [self.displayLink setPaused:YES];
  [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  
  // text
  NSString *winText = @"YOU WIN!!!";
  addTextZoomInAnimation(self, winText, [UIColor whiteColor], ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"YOU WIN!!!" message:@"" preferredStyle:(UIAlertControllerStyleAlert)];
    [alertController addAction:[UIAlertAction actionWithTitle:@"New Game" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
      [self restartGame];
    }]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:NULL];
  });
}

- (BOOL)shouldBirdMoves {
  return ![self.displayLink isPaused];
}

- (BOOL)shouldPillarsMoves {
  return ![self.displayLink isPaused];
}



#pragma mark - public method

- (void)birdFly {
  CGFloat birdYOffset = -EachBirdFlyHeight;
  CGFloat estimateY = (CGRectGetMinY(self.bird.frame) + birdYOffset);
  if (estimateY > 0) {
    [self birdMoves:CGPointMake(0, birdYOffset) animated:YES];
  } else {
    [self birdMoves:CGPointMake(0, -1 * self.bird.position.y) animated:NO]; // move to 0
  }
}

- (void)birdMoves:(CGPoint)moveOffset animated:(BOOL)animated {
  if (![self shouldBirdMoves]) {
    return;
  }
  
  CGPoint pt = self.bird.position;
  pt.x += moveOffset.x;
  pt.y += moveOffset.y;
  
  [CATransaction begin];
  [CATransaction setDisableActions:!animated]; {
    self.bird.position = pt;
  } [CATransaction commit];
}

- (void)pillarsMoves:(CGPoint)moveOffset {
  if (![self shouldPillarsMoves]) {
    return;
  }
  
  CGPoint pt = self.pillarsLayer.position;
  pt.x += moveOffset.x;
  pt.y += moveOffset.y;
  
  [CATransaction begin];
  [CATransaction setDisableActions:YES]; {
    self.pillarsLayer.position = pt;
  } [CATransaction commit];
}

- (void)layoutSubviews {
  [super layoutSubviews];
}

@end
