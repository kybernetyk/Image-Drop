//
//  UploadSummaryWindowController.h
//  ImgDrop
//
//  Created by jrk on 04.09.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UploadSummaryWindowController : NSWindowController 
{
	IBOutlet NSTextField *summaryLabel;
	IBOutlet NSTextField *summaryTextField;
}

@property (readwrite, retain) IBOutlet NSTextField *summaryLabel;
@property (readwrite, retain) IBOutlet NSTextField *summaryTextField;

- (IBAction) copyTextFieldToPasteboard: (id) sender;

@end
