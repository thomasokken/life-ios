//
//  LifeView.h
//  Life
//
//  Created by Thomas Okken on 4/3/22.
//

#ifndef LifeView_h
#define LifeView_h

#import <UIKit/UIKit.h>

@interface LifeView : UIView<UIGestureRecognizerDelegate> {
    UISlider *scaleSlider;
    UISlider *speedSlider;
    UIButton *stopButton;
    UIButton *startButton;
    UIButton *stepButton;
    UIButton *restartButton;
}

@property (nonatomic, retain) IBOutlet UISlider *scaleSlider;
@property (nonatomic, retain) IBOutlet UISlider *speedSlider;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UIButton *stepButton;
@property (nonatomic, retain) IBOutlet UIButton *restartButton;

- (void) awakeFromNib;
- (void) drawRect:(CGRect)rect;
- (IBAction) scaleSliderUpdated;
- (IBAction) speedSliderUpdated;
- (IBAction) stopPressed;
- (IBAction) startPressed;
- (IBAction) stepPressed;
- (IBAction) restartPressed;

@end

#endif /* LifeView_h */
