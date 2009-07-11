//
//  MenuViewController.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 14-6-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate <NSObject>
- (void) newGame:(NSNumber *)boardNumber;
- (void) returnToGame;
@end


@interface MenuViewController : UIViewController {
	id<MenuViewControllerDelegate> delegate;
	
	@private
	UITextField *numberInput;
	UILabel *errorLabel;
	UIBarButtonItem *cancelButton;
}

@property (nonatomic, assign) id<MenuViewControllerDelegate> delegate;

- (void) transitionDidStop;

@end
