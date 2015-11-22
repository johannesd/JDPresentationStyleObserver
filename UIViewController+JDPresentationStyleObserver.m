//
//  UIViewController+JDPresentationStyleObserver.m
//
//  Created by Johannes Dörr on 15.08.15.
//  Copyright © 2015 Johannes Dörr. All rights reserved.
//

#import "UIViewController+JDPresentationStyleObserver.h"
#import <BlocksKit/BlocksKit.h>
#import <objc/runtime.h>


#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


#pragma mark - JDPresentationControllerDelegateMediator

@interface JDPresentationControllerDelegateMediator : NSObject <UIAdaptivePresentationControllerDelegate>
{
    NSMutableSet *styleObservers;
}

@property (nonatomic, strong, readonly) NSSet *styleObservers;
@property (nonatomic, strong) id<UIAdaptivePresentationControllerDelegate> delegate;

@end


@implementation JDPresentationControllerDelegateMediator

- (id)init
{
    if (self = [super init]) {
        styleObservers = [NSMutableSet set];
    }
    return self;
}

- (void)addStyleObserver:(id<JDPresentationControllerStyleObserver>)observer viewController:(UIViewController *)viewController
{
    [styleObservers addObject:@[[NSValue valueWithNonretainedObject:observer],
                                [NSValue valueWithNonretainedObject:viewController]]];
}

- (void)removeStyleObserver:(id<JDPresentationControllerStyleObserver>)observer
{
    NSSet *res = [styleObservers objectsPassingTest:^BOOL(NSArray  __nonnull *obj, BOOL * __nonnull stop) {
        return [obj[0] nonretainedObjectValue] == observer;
    }];
    for (NSObject *obj in res) {
        [styleObservers removeObject:obj];
    }
}

- (NSSet *)styleObservers
{
    return [styleObservers copy];
}

- (void)dealloc
{
    NSLog(@"dealloc JDPresentationControllerDelegateMediator");
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(adaptivePresentationStyleForPresentationController:)]) {
        return [self.delegate adaptivePresentationStyleForPresentationController:controller];
    }
    return UIModalPresentationNone;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    UIModalPresentationStyle style;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(adaptivePresentationStyleForPresentationController:traitCollection:)]) {
        style = [self.delegate adaptivePresentationStyleForPresentationController:controller traitCollection:traitCollection];
    }
    else {
        // Second check is a bug fix for iPhone 6 Plus
        if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular &&
                (traitCollection.displayScale != 3 || controller.presentedViewController.view.bounds.size.width > controller.presentedViewController.view.bounds.size.height)) {
            style = UIModalPresentationNone;
        }
        else {
            style = UIModalPresentationFullScreen;
        }
    }
    for (NSArray *observer in styleObservers) {
        [[observer[0] nonretainedObjectValue] presentationControllerChangedStyle:style == UIModalPresentationNone ? controller.presentedViewController.modalPresentationStyle : style
                                                                ofViewController:[observer[1] nonretainedObjectValue]];
    }
    return style;
}

- (nullable UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(presentationController:viewControllerForAdaptivePresentationStyle:)]) {
        return [self.delegate presentationController:controller viewControllerForAdaptivePresentationStyle:style];
    }
    return nil;
}

- (void)presentationController:(UIPresentationController *)presentationController willPresentWithAdaptiveStyle:(UIModalPresentationStyle)style transitionCoordinator:(nullable id <UIViewControllerTransitionCoordinator>)transitionCoordinator
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(presentationController:willPresentWithAdaptiveStyle:transitionCoordinator:)]) {
        [self.delegate presentationController:presentationController willPresentWithAdaptiveStyle:style transitionCoordinator:transitionCoordinator];
    }
}

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(prepareForPopoverPresentation:)]) {
        [((id<UIPopoverPresentationControllerDelegate>)self.delegate) prepareForPopoverPresentation:popoverPresentationController];
    }
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(popoverPresentationControllerShouldDismissPopover:)]) {
        return [((id<UIPopoverPresentationControllerDelegate>)self.delegate) popoverPresentationControllerShouldDismissPopover:popoverPresentationController];
    }
    return TRUE;
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(popoverPresentationControllerDidDismissPopover:)]) {
        [((id<UIPopoverPresentationControllerDelegate>)self.delegate) popoverPresentationControllerDidDismissPopover:popoverPresentationController];
    }
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView  * __nonnull * __nonnull)view
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(popoverPresentationController:willRepositionPopoverToRect:inView:)]) {
        [((id<UIPopoverPresentationControllerDelegate>)self.delegate) popoverPresentationController:popoverPresentationController willRepositionPopoverToRect:rect inView:view];
    }
}

@end


@implementation UIViewController (JDPresentationStyleObserver)

+ (void)load
{
    if (!SYSTEM_VERSION_LESS_THAN(@"9")) {
        Method original, swizzled;
        original = class_getInstanceMethod(self, @selector(presentViewController:animated:completion:));
        swizzled = class_getInstanceMethod(self, @selector(jd_PresentationStyleObserver_presentViewController:animated:completion:));
        method_exchangeImplementations(original, swizzled);
        
        const SEL deallocSel  = NSSelectorFromString(@"dealloc");
        original = class_getInstanceMethod(self, deallocSel);
        swizzled = class_getInstanceMethod(self, @selector(jd_PresentationStyleObserver_dealloc));
        method_exchangeImplementations(original, swizzled);
    }
    else {
        Method original, swizzled;
        original = class_getInstanceMethod(self, @selector(viewWillAppear:));
        swizzled = class_getInstanceMethod(self, @selector(jd_PresentationStyleObserver_viewWillAppear:));
        method_exchangeImplementations(original, swizzled);
    }
}

- (void)jd_PresentationStyleObserver_presentViewController:(nonnull UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^ __nullable)(void))completion
{
    [viewControllerToPresent jd_PresentationStyleObserver_willPresentViewController:viewControllerToPresent];
    [self jd_PresentationStyleObserver_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)jd_PresentationStyleObserver_willPresentViewController:(UIViewController *)topViewController
{
    NSMutableSet *presentationStyleObservers = [self bk_associatedValueForKey:@"jd_presentationStyleObservers"];
    [self bk_weaklyAssociateValue:topViewController withKey:@"jd_topViewController"];
    if (presentationStyleObservers.count > 0) {
        JDPresentationControllerDelegateMediator *mediator = [self _getMediator:TRUE topViewController:topViewController];
        for (id<JDPresentationControllerStyleObserver> observer in presentationStyleObservers) {
            [mediator addStyleObserver:observer viewController:self];
        }
    }
    for (UIViewController *vc in self.childViewControllers) {
        [vc jd_PresentationStyleObserver_willPresentViewController:topViewController];
    }
}

- (void)jd_PresentationStyleObserver_dealloc
{
    JDPresentationControllerDelegateMediator *mediator = [self _getMediator:FALSE topViewController:nil];
    NSMutableSet *presentationStyleObservers = [self bk_associatedValueForKey:@"jd_presentationStyleObservers"];
    for (id<JDPresentationControllerStyleObserver> observer in presentationStyleObservers) {
        [mediator removeStyleObserver:observer];
    }
    [self jd_PresentationStyleObserver_dealloc];
}

- (void)jd_PresentationStyleObserver_viewWillAppear:(BOOL)animated
{
    // On systems that don't support adaptive styles, we call the observation functions on the first call of viewWillAppear instead
    BOOL didAppear = [[self bk_associatedValueForKey:@"jd_didAppear"] boolValue];
    if (didAppear) {
        return;
    }
    [self bk_associateValue:@TRUE withKey:@"jd_didAppear"];
    NSMutableSet *presentationStyleObservers = [self bk_associatedValueForKey:@"jd_presentationStyleObservers"];
    for (id<JDPresentationControllerStyleObserver> observer in presentationStyleObservers) {
        UIModalPresentationStyle style;
        if (self.navigationController != nil) {
            style = self.navigationController.modalPresentationStyle;
        }
        else if (self.tabBarController != nil) {
            style = self.tabBarController.modalPresentationStyle;
        }
        else {
            style = self.modalPresentationStyle;
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && style == UIModalPresentationPopover) {
            style = UIModalPresentationFullScreen;
        }
        [observer presentationControllerChangedStyle:style ofViewController:self];
    }
    [self jd_PresentationStyleObserver_viewWillAppear:animated];
}

- (JDPresentationControllerDelegateMediator *)_getMediator:(BOOL)createIfNil topViewController:(UIViewController *)topViewController
{
    JDPresentationControllerDelegateMediator *mediator = [topViewController bk_associatedValueForKey:@"jd_presentationControllerDelegateMediator"];
    assert(topViewController.presentationController.delegate == mediator);
    if (mediator == nil && createIfNil) {
        mediator = [[JDPresentationControllerDelegateMediator alloc] init];
        topViewController.presentationController.delegate = mediator;
        [topViewController bk_associateValue:mediator withKey:@"jd_presentationControllerDelegateMediator"];
    }
    return mediator;
}

- (void)setPresentationControllerDelegate:(id<UIAdaptivePresentationControllerDelegate>)delegate
{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        return;
    }
    JDPresentationControllerDelegateMediator *mediator = [self _getMediator:TRUE topViewController:self];
    mediator.delegate = delegate;
}

- (void)addPresentationControllerStyleObserver:(id<JDPresentationControllerStyleObserver>)observer
{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        return;
    }
    NSMutableSet *presentationStyleObservers = [self bk_associatedValueForKey:@"jd_presentationStyleObservers"];
    if (presentationStyleObservers == nil) {
        presentationStyleObservers = [NSMutableSet set];
        [self bk_associateValue:presentationStyleObservers withKey:@"jd_presentationStyleObservers"];
    }
    [presentationStyleObservers addObject:observer];
    UIViewController *topViewController = [self bk_associatedValueForKey:@"jd_topViewController"];
    if (topViewController != nil) {
        JDPresentationControllerDelegateMediator *mediator = [self _getMediator:TRUE topViewController:topViewController];
        [mediator addStyleObserver:observer viewController:self];
    }
}

- (void)removePresentationControllerStyleObserver:(id<JDPresentationControllerStyleObserver>)observer
{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        return;
    }
    NSMutableSet *presentationStyleObservers = [self bk_associatedValueForKey:@"jd_presentationStyleObservers"];
    [presentationStyleObservers removeObject:observer];
    if (presentationStyleObservers.count == 0) {
        [self bk_associateValue:nil withKey:@"jd_presentationStyleObservers"];
    }
    UIViewController *topViewController = [self bk_associatedValueForKey:@"jd_topViewController"];
    if (topViewController != nil) {
        JDPresentationControllerDelegateMediator *mediator = [self _getMediator:FALSE topViewController:topViewController];
        [mediator removeStyleObserver:observer];
    }
}

@end
