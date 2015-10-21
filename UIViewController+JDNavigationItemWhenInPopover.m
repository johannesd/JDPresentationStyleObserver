//
//  UIViewController+JDNavigationItemWhenInPopover.m
//
//  Created by Johannes Dörr on 12.08.15.
//  Copyright © 2015 Johannes Dörr. All rights reserved.
//

#import "UIViewController+JDNavigationItemWhenInPopover.h"
#import "UIViewController+JDPresentationStyleObserver.h"
#import <BlocksKit/BlocksKit.h>

#pragma mark - JDNavigationItem

@implementation JDNavigationItem

- (id)initWithTitle:(NSString *)title
{
    if (self = [super init]) {
        _title = title;
    }
    return self;
}

- (id)initWithNavigationItem:(UINavigationItem *)navigationItem
{
    if (self = [super init]) {
        _title = navigationItem.title;
        _leftBarButtonItems = navigationItem.leftBarButtonItems;
        _rightBarButtonItems = navigationItem.rightBarButtonItems;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc JDNavigationItem");
}

@end


#pragma mark - JDNavigationItemWhenInPopoverSwitcher

@interface JDNavigationItemWhenInPopoverSwitcher : NSObject <JDPresentationControllerStyleObserver>

@property (nonatomic, weak) UIViewController *viewController;

@end


@implementation JDNavigationItemWhenInPopoverSwitcher

- (void)presentationControllerChangedStyle:(UIModalPresentationStyle)style ofViewController:(UIViewController *)viewController
{
    JDNavigationItem *navigationItem;
    if (style == UIModalPresentationPopover) {
        navigationItem = self.viewController.navigationItemWhenInPopover;
    }
    else {
        navigationItem = self.viewController.navigationItemOtherwise;
    }
    self.viewController.navigationItem.title = navigationItem.title;
    self.viewController.navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems;
    self.viewController.navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems;
}

- (void)dealloc
{
    NSLog(@"dealloc JDNavigationItemWhenInPopoverSwitcher");
}

@end


#pragma mark - UIViewController (JDNavigationItemWhenInPopover)

@implementation UIViewController (JDNavigationItemWhenInPopover)

- (void)setNavigationItemWhenInPopover:(JDNavigationItem *)navigationItem otherwise:(JDNavigationItem *)otherwiseItem
{
    [self bk_associateValue:navigationItem withKey:@"jd_navigationItemWhenInPopover"];
    [self bk_associateValue:otherwiseItem withKey:@"jd_navigationItemOtherwise"];
    
    JDNavigationItemWhenInPopoverSwitcher *switcher = [self bk_associatedValueForKey:@"jd_navigationItemWhenInPopoverSwitcher"];
    if (switcher == nil) {
        switcher = [[JDNavigationItemWhenInPopoverSwitcher alloc] init];
        switcher.viewController = self;
        [self bk_associateValue:switcher withKey:@"jd_navigationItemWhenInPopoverSwitcher"];
        [self addPresentationControllerStyleObserver:switcher];
    }
#warning TODO: update if already presented
}

- (JDNavigationItem *)navigationItemWhenInPopover
{
    return [self bk_associatedValueForKey:@"jd_navigationItemWhenInPopover"];
}

- (JDNavigationItem *)navigationItemOtherwise
{
    return [self bk_associatedValueForKey:@"jd_navigationItemOtherwise"];
}

@end
