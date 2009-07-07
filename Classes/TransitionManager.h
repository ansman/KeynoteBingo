//
//  TransitionManager.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 06-7-2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TransitionManager;

typedef enum {
	TransitionTypeFlipLeft,
	TransitionTypeFlipRight,
	TransitionTypeReveal,
	TransitionTypeMoveOver,
	TransitionTypePushLeft,
	TransitionTypePushRight,
} TransitionType;

@protocol TransitionManagerDelegate <NSObject>

@optional
- (void) tranistionDidStop:(TransitionManager *)transitionManager;
- (void) tranistionWillStart:(TransitionManager *)transitionManager;

@end

@interface TransitionManager : NSObject {
	UIView *containerView;
	UIView *newView;
	UIView *oldView;
	TransitionType transitionType;
	float duration;
	id<TransitionManagerDelegate> delegate;
	
	@private
	CGRect oldViewFrame;
	CGRect newViewFrame;
}

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *newView;
@property (nonatomic, retain) UIView *oldView;
@property (nonatomic, assign) TransitionType transitionType;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) id<TransitionManagerDelegate> delegate;

+ (TransitionManager *) performTransition:(UIView *)container oldView:(UIView *)old newView:(UIView *)new transitionType:(TransitionType)type duration:(float)dur delegate:(id<TransitionManagerDelegate>)withDelegate;

- (void) startTransition;

@end
