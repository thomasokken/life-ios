//
//  LifeView.h
//  Life
//
//  Created by Thomas Okken on 4/3/22.
//

#ifndef LifeView_h
#define LifeView_h

#import <UIKit/UIKit.h>

@interface LifeView : UIView {
    // We don't need no UI controls
}

- (void) awakeFromNib;
- (void) drawRect:(CGRect)rect;

@end

#endif /* LifeView_h */
