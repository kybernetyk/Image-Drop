//
//  TwittPicMessageWindowController.h
//  ImgDrop
//
//  Created by jrk on 24/12/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TwittPicMessageWindowController : NSWindowController 
{
	IBOutlet NSString *message;
	
	id delegate;
}
@property (readwrite, retain) NSString *message;
@property (readwrite, assign) id delegate;

- (IBAction) performCancel: (id) sender;
- (IBAction) performSend: (id) sender;

@end
