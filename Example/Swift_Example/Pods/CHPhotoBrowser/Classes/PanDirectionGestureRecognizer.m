//
//  PanDirectionGestureRecognizer.m
//  CHPhotoBrowser
//
//  Created by Haeun Chung on 07/11/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import "PanDirectionGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation PanDirectionGestureRecognizer : UIPanGestureRecognizer

- (id)init:(PanDirection)direction target:(id)target action:(SEL)action {
  if ((self = [super initWithTarget:target action:action])) {
    self.direction = direction;
  }
  return self;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  
  if (self.state == UIGestureRecognizerStateBegan) {
    CGPoint vel = [self velocityInView:self.view];
    switch (_direction) {
      case vertical:
        if (fabs(vel.y) > fabs(vel.x)) {
          self.state = UIGestureRecognizerStateCancelled;
        }
        break;
      case horizontal:
        if (fabs(vel.x) > fabs(vel.y)) {
          self.state = UIGestureRecognizerStateCancelled;
        }
        break;
    }
  }
}
@end
