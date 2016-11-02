//
//  FlappyBirdView.h
//  ALFlappyBird
//
//  Created by allenlee on 2016/9/13.
//  Copyright © 2016年 allenlee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlappyBirdView : UIView

- (void)commonInit;
- (void)birdFly;
- (void)pillarsMoves:(CGPoint)moveOffset;

@end
