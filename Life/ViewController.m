//
//  ViewController.m
//  Life
//
//  Created by Thomas Okken on 4/3/22.
//

#import "ViewController.h"
#import "LifeView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if(event.type == UIEventSubtypeMotionShake) {
        LifeView *view = (LifeView *) self.view;
        [view undo];
    } else
        [super motionBegan:motion withEvent:event];
}


@end
