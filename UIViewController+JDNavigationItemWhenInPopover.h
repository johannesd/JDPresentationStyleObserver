//
//  UIViewController+JDNavigationItemWhenInPopover.h
//
//  Created by Johannes Dörr on 12.08.15.
//  Copyright © 2015 Johannes Dörr. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JDNavigationItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *leftBarButtonItems;
@property (nonatomic, strong) NSArray *rightBarButtonItems;

- (id)initWithTitle:(NSString *)title;
- (id)initWithNavigationItem:(UINavigationItem *)navigationItem;

@end


@interface UIViewController (JDNavigationItemWhenInPopover)

- (void)setNavigationItemWhenInPopover:(JDNavigationItem *)navigationItem otherwise:(JDNavigationItem *)otherwiseItem;

@property (nonatomic, strong, readonly) JDNavigationItem *navigationItemWhenInPopover;
@property (nonatomic, strong, readonly) JDNavigationItem *navigationItemOtherwise;

@end
