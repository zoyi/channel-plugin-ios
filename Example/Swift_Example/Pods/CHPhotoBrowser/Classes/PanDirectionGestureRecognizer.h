//
//  PanDirectionGestureRecognizer.h
//  CHPhotoBrowser
//
//  Created by Haeun Chung on 07/11/2017.
//  Copyright © 2017 ZOYI. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum PanDirection {
  vertical,
  horizontal
} PanDirection;

@interface PanDirectionGestureRecognizer : UIPanGestureRecognizer
@property (nonatomic, assign) PanDirection direction;

- (id)init:(PanDirection)direction target:(id)target action:(SEL)action;
@end
