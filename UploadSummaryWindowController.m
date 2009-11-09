//
//  UploadSummaryWindowController.m
//  ImgDrop
//
//  Created by jrk on 04.09.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "UploadSummaryWindowController.h"


@implementation UploadSummaryWindowController
@synthesize summaryLabel;
@synthesize summaryTextField;

- (void)windowWillClose:(NSNotification *)notification
{
	//message our delegate that we're done
	//or maybe dont
	
	//autorelease the controller as we are not keeping any reference to it in the app's main window
	[self autorelease];
}

- (void) dealloc
{
	NSLog(@"uload summary controller deallocing");
	[super dealloc];
}

- (IBAction) copyTextFieldToPasteboard: (id) sender
{
//	NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
	//[item setString:[summaryTextField stringValue] forType: @"public.utf8-plain-text"];
	
	NSPasteboard *pb = [NSPasteboard generalPasteboard];

	[pb clearContents];

	NSArray *objectsToCopy = [NSArray arrayWithObjects:[summaryTextField stringValue] ,nil];
	
	BOOL OK = [pb writeObjects:objectsToCopy];
	NSLog(@"wars ok? %i",OK);
	
	[self close];
	[NSApp hide: self];
	
	//[pb writeObjects: [NSArray arrayWithObjects:item,nil]];
//	[pb setString: [summaryTextField stringValue] forType: NSStringPboardType];
//	[pb 
}

@end
