//
//  LoadingViewController.h
//  KeynoteBingo
//
//  Created by Nicklas Ansman on 01-7-2009.
//  Copyright 2009 Nicklas Ansman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadingViewControllerDelegate <NSObject>

- (void) cancelUpdate;

@end


@interface LoadingViewController : UIViewController {
	id<LoadingViewControllerDelegate> delegate;
	
	@private
	UILabel *progressLabel;
	UIButton *cancelButton;
}

@property (nonatomic, assign) id<LoadingViewControllerDelegate> delegate;

- (void) setLoadingText:(NSString *)loadingText;
- (void) updateStarted;

@end
