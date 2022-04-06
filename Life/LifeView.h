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
    UIButton *stepButton;
    UIButton *restartButton;
    UISwitch *paintSwitch;
    UILabel *scaleLabel;
    UILabel *speedLabel;
    UILabel *paintLabel;
}

@property (nonatomic, retain) IBOutlet UISlider *scaleSlider;
@property (nonatomic, retain) IBOutlet UISlider *speedSlider;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *stepButton;
@property (nonatomic, retain) IBOutlet UIButton *restartButton;
@property (nonatomic, retain) IBOutlet UISwitch *paintSwitch;
@property (nonatomic, retain) IBOutlet UILabel *scaleLabel;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UILabel *paintLabel;

- (void) awakeFromNib;
- (void) drawRect:(CGRect)rect;
- (IBAction) scaleSliderUpdated;
- (IBAction) speedSliderUpdated;
- (IBAction) stopPressed;
- (IBAction) stepPressed;
- (IBAction) restartPressed;
- (IBAction) paintToggled:(id)sender;

@end

#endif /* LifeView_h */
