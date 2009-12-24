//
//  TwittPicMessageWindowController.m
//  ImgDrop
//
//  Created by jrk on 24/12/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "TwittPicMessageWindowController.h"


@implementation TwittPicMessageWindowController
@synthesize message;
@synthesize delegate;

- (void)windowWillClose:(NSNotification *)notification
{
	//message our delegate that we're done
	//or maybe dont
	//[delegate twittPicMessageWindowController: self didFinishWithMessage: nil];		
	//autorelease the controller as we are not keeping any reference to it in the app's main window
	[self autorelease];
	//self will be autoreleased in the delegate
}

- (void) dealloc
{
	NSLog(@"TwittPicMessageWindowController deallocing");
	[super dealloc];
}


- (IBAction) performCancel: (id) sender
{
	NSLog(@"delegate: %@",delegate);

	[delegate twittPicMessageWindowController: self didFinishWithMessage: nil];	
	[[self window] close];
}

- (IBAction) performSend: (id) sender
{
	NSLog(@"delegate: %@",delegate);
	//[self retain];
	[delegate twittPicMessageWindowController: self didFinishWithMessage: [self message]];
	
	[[self window] close];
}

@end
