//
//  KeynoteButton.m
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 29-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import "KeynoteButton.h"

@implementation KeynoteButton

@synthesize titleLabel, buttonOverlay, useButtonOverlay;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		titleLabel = [[UILabel alloc] initWithFrame:frame];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.font = [UIFont boldSystemFontOfSize:16];
		titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		titleLabel.numberOfLines = 4;
		
		titles = [[NSMutableArray alloc] initWithObjects:@"", [NSNull null], [NSNull null], [NSNull null], nil];
		images = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], [NSNull null], [NSNull null], nil];
		titleColors = [[NSMutableArray alloc] initWithObjects:titleLabel.textColor, [NSNull null], [NSNull null], [NSNull null], nil];
		
		self.buttonOverlay = [UIImage imageNamed:@"buttonOverlay.png"];
		useButtonOverlay = YES;
    }
	
    return self;
}

- (void)dealloc {
	[titleLabel release];
	[buttonOverlay release];
	[titles release];
	[titleColors release];
	[images release];
	
    [super dealloc];
}

- (void) setHighlighted:(BOOL)isHighlighted withDelay:(NSTimeInterval)delay {
	super.highlighted = isHighlighted;

	[self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:delay];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	if(event.type == UIEventTypeTouches) {
		[self setHighlighted:YES withDelay:0.2];
	}
	
	return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
	self.highlighted = NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {

	if(event.type == UIEventTypeTouches) {
		self.highlighted = NO;
		
		if([self pointInside:[touch locationInView:self] withEvent:nil]) {
			self.selected = !self.selected;
		}
		[self setNeedsDisplay];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	BOOL oldValue = self.highlighted;
	self.highlighted = NO;
	
	for(UITouch *touch in touches) {
		if([self pointInside:[touch locationInView:self] withEvent:nil]) {
			self.highlighted = YES;
			break;
		}
	}
		
	if(oldValue != self.highlighted)
		[self setNeedsDisplay];
}

- (void) setTitle:(NSString *)title forState:(UIControlState)state {
	NSUInteger index;
	
	switch (state) {
		case UIControlStateHighlighted:
			index = 1;
			break;
		case UIControlStateDisabled:
			index = 2;
			break;
		case UIControlStateSelected:
			index = 3;
			break;
		case UIControlStateNormal:
			index = 0;
			break;
		default:
			return;
	}
	
	id object = title;
	
	if(!object)
		object = [NSNull null];
	
	[titles replaceObjectAtIndex:index withObject:object];
	
	[self setNeedsDisplay];
}

- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state {
	NSUInteger index;
	
	switch (state) {
		case UIControlStateHighlighted:
			index = 1;
			break;
		case UIControlStateDisabled:
			index = 2;
			break;
		case UIControlStateSelected:
			index = 3;
			break;
		case UIControlStateNormal:
			index = 0;
			break;
		default:
			return;
	}
	
	id object = color;
	
	if(!object)
		object = [NSNull null];
	
	[titleColors replaceObjectAtIndex:index withObject:object];
	
	[self setNeedsDisplay];
}

- (void) setButtonImage:(UIImage *)image forState:(UIControlState)state {
	NSUInteger index;
	
	switch (state) {
		case UIControlStateHighlighted:
			index = 1;
			break;
		case UIControlStateDisabled:
			index = 2;
			break;
		case UIControlStateSelected:
			index = 3;
			break;
		case UIControlStateNormal:
			index = 0;
			break;
		default:
			return;
	}
	
	id object = image;
	
	if(!object)
		object = [NSNull null];
	
	[images replaceObjectAtIndex:index withObject:object];
	
	[self setNeedsDisplay];
}

- (NSString *) titleForState:(UIControlState)state {
	NSUInteger index;
	
	switch (state) {
		case UIControlStateHighlighted:
			index = 1;
			break;
		case UIControlStateDisabled:
			index = 2;
			break;
		case UIControlStateSelected:
			index = 3;
			break;
		case UIControlStateNormal:
			index = 0;
			break;
		default:
			return nil;
	}
	
	id object = [images objectAtIndex:index];
	
	return [object isKindOfClass:[NSNull class]] ? nil : object;
}

- (UIColor *) titleColorForState:(UIControlState)state {
	NSUInteger index;
	
	switch (state) {
		case UIControlStateHighlighted:
			index = 1;
			break;
		case UIControlStateDisabled:
			index = 2;
			break;
		case UIControlStateSelected:
			index = 3;
			break;
		case UIControlStateNormal:
			index = 0;
			break;
		default:
			return nil;
	}
	
	id object = [images objectAtIndex:index];
	
	return [object isKindOfClass:[NSNull class]] ? nil : object;
}

- (UIImage *) buttonImageForState:(UIControlState)state {
	NSUInteger index;
	
	switch (state) {
		case UIControlStateHighlighted:
			index = 1;
			break;
		case UIControlStateDisabled:
			index = 2;
			break;
		case UIControlStateSelected:
			index = 3;
			break;
		case UIControlStateNormal:
			index = 0;
			break;
		default:
			return nil;
	}

	id object = [images objectAtIndex:index];
	
	return [object isKindOfClass:[NSNull class]] ? nil : object;
}


- (void)drawRect:(CGRect)rect {
	NSUInteger index;
	
	if(!self.enabled)
		index = 2;
	else if(self.selected)
		index = 3;
	else if(self.highlighted)
		index = 1;
	else
		index = 0;
	
	id object1 = [images objectAtIndex:index];
	id object2 = [titles objectAtIndex:index];
	id object3 = [titleColors objectAtIndex:index];
	
	if(index > 0) {
		if(index == 1) {
			if([object1 isKindOfClass:[NSNull class]])
				object1 = [images objectAtIndex:3];
			if([object2 isKindOfClass:[NSNull class]] )
				object2 = [titles objectAtIndex:3];
			if([object3 isKindOfClass:[NSNull class]])
				object3 = [titleColors objectAtIndex:3];
		}
		
		if([object1 isKindOfClass:[NSNull class]])
			object1 = [images objectAtIndex:0];
		if([object2 isKindOfClass:[NSNull class]] )
			object2 = [titles objectAtIndex:0];
		if([object3 isKindOfClass:[NSNull class]])
			object3 = [titleColors objectAtIndex:0];
	}
	
	UIImage *whichImage = object1;
	NSString *whichTitle = object2;
	UIColor *whichColor = object3;
	
	[whichImage drawInRect:rect];
	
	// Makes a 2 px inset for the label
	CGRect labelRect = CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width-4, rect.size.height-4);
	
	titleLabel.text = whichTitle;
	titleLabel.textColor = whichColor;
	[titleLabel drawTextInRect:labelRect];
	
	[buttonOverlay drawInRect:rect];
}

@end
