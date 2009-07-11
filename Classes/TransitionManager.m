//
//  TransitionManager.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 06-7-2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TransitionManager.h"

@implementation TransitionManager

@synthesize containerView;
@synthesize newView;
@synthesize oldView;
@synthesize transitionType;
@synthesize duration;
@synthesize delegate;

- (id) init {
	if(self = [super init]) {
		containerView = nil;
		oldView = nil;
		newView = nil;
		transitionType = TransitionTypeReveal;
		duration = 0.60;
		delegate = nil;
	}
	
	return self;
}

- (void) dealloc {
	[containerView release];
	[newView release];
	[oldView release];
	[super dealloc];
}

+ (TransitionManager *) performTransition:(UIView *)container oldView:(UIView *)old newView:(UIView *)new transitionType:(TransitionType)type duration:(float)dur delegate:(id<TransitionManagerDelegate>)withDelegate {
	TransitionManager *tranitionManager = [[TransitionManager alloc] init];
	
	tranitionManager.containerView = container;
	tranitionManager.oldView = old;
	tranitionManager.newView = new;
	tranitionManager.transitionType = type;
	tranitionManager.duration = dur;
	tranitionManager.delegate = withDelegate;
	
	[tranitionManager startTransition];
	
	return [tranitionManager autorelease];
}

- (void) startTransition {	
	CGRect tempFrame;
	
	oldViewFrame = oldView.frame;
	newViewFrame = newView.frame;
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	if(transitionType == TransitionTypeMoveOver) {		
		tempFrame = newView.frame;
		tempFrame.origin.y = tempFrame.origin.y + containerView.frame.size.height;
		newView.frame = tempFrame;
		[containerView insertSubview:newView aboveSubview:oldView];
	}
	else if(transitionType == TransitionTypePushLeft) {
		tempFrame = newView.frame;
		tempFrame.origin.x = tempFrame.origin.x + containerView.frame.size.width;
		newView.frame = tempFrame;
		[containerView insertSubview:newView aboveSubview:oldView];
	}
	else if(transitionType == TransitionTypePushRight) {
		tempFrame = newView.frame;
		tempFrame.origin.x = tempFrame.origin.x - containerView.frame.size.width;
		newView.frame = tempFrame;
		[containerView insertSubview:newView aboveSubview:oldView];
	}
	else if(transitionType == TransitionTypeReveal) {
		[containerView insertSubview:newView belowSubview:oldView];
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationWillStartSelector:@selector(animationWillStart:finished:context:)];
	if(transitionType == TransitionTypeFlipRight || transitionType == TransitionTypeFlipLeft) {
		if(transitionType == TransitionTypeFlipRight)
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:containerView cache:YES];
		else
			[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:containerView cache:YES];
		
		[oldView removeFromSuperview];
		[containerView addSubview:newView];
	}
	else if(transitionType == TransitionTypePushLeft) {
		tempFrame = newView.frame;
		tempFrame.origin.x = tempFrame.origin.x - containerView.frame.size.width;
		newView.frame = tempFrame;
		
		tempFrame = oldView.frame;
		tempFrame.origin.x = tempFrame.origin.x - containerView.frame.size.width;
		oldView.frame = tempFrame;
	}
	else if(transitionType == TransitionTypePushRight) {
		tempFrame = newView.frame;
		tempFrame.origin.x = tempFrame.origin.x + containerView.frame.size.width;
		newView.frame = tempFrame;
		
		tempFrame = oldView.frame;
		tempFrame.origin.x = tempFrame.origin.x + containerView.frame.size.width;
		oldView.frame = tempFrame;
	}
	else if(transitionType == TransitionTypeReveal) {
		tempFrame = oldView.frame;
		tempFrame.origin.y = containerView.frame.size.height;
		oldView.frame = tempFrame;
	}
	else {
		tempFrame = newView.frame;
		tempFrame.origin.y = tempFrame.origin.y-containerView.frame.size.height;
		newView.frame = tempFrame;
	}
	[UIView commitAnimations];
}

- (void)animationWillStart:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if([delegate respondsToSelector:@selector(transitionWillStart:)])
		[delegate performSelector:@selector(transitionWillStart:) withObject:self];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
	newView.frame = newViewFrame;
	
	oldView.frame = oldViewFrame;
	
	[oldView removeFromSuperview];
		
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	
	if([delegate respondsToSelector:@selector(transitionDidStop:)])
		[delegate performSelector:@selector(transitionDidStop:) withObject:self];
}

@end
