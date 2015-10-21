//
//  UIViewController+JDPresentationStyleObserver.h
//
//  Created by Johannes Dörr on 15.08.15.
//  Copyright © 2015 Johannes Dörr. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JDPresentationControllerStyleObserver <NSObject>

- (void)presentationControllerChangedStyle:(UIModalPresentationStyle)style ofViewController:(UIViewController *)viewController;

@end


@interface UIViewController (JDPresentationStyleObserver)

- (void)setPresentationControllerDelegate:(id<UIAdaptivePresentationControllerDelegate>)delegate;
- (void)addPresentationControllerStyleObserver:(id<JDPresentationControllerStyleObserver>)observer;
- (void)removePresentationControllerStyleObserver:(id<JDPresentationControllerStyleObserver>)observer;

@end
