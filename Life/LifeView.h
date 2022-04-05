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
    UISlider *speedSlider;
}

@property (nonatomic, retain) IBOutlet UISlider *speedSlider;

- (void) awakeFromNib;
- (void) drawRect:(CGRect)rect;
- (IBAction) speedSliderUpdated;

@end

#endif /* LifeView_h */
