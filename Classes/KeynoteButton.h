//
//  KeynoteButton.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 29-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeynoteButton : UIControl {
	BOOL useButtonOverlay;
	
	@protected
	UILabel *titleLabel;
	UIImage *buttonOverlay;
	NSMutableArray *titles;
	NSMutableArray *titleColors;
	NSMutableArray *images;
}

@property (nonatomic, getter=isUsingButtonOverlay) BOOL useButtonOverlay;
@property (nonatomic, retain) UIImage *buttonOverlay;
@property (nonatomic, readonly) UILabel *titleLabel;

// Setters
- (void) setTitle:(NSString *)title forState:(UIControlState)state;
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void) setButtonImage:(UIImage *)image forState:(UIControlState)state;

// Getters
- (NSString *) titleForState:(UIControlState)state;
- (UIColor *) titleColorForState:(UIControlState)state;
- (UIImage *) buttonImageForState:(UIControlState)state;

@end
