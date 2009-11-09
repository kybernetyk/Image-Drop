//
//  ImgDropAppDelegate.h
//  ImgDrop
//
//  Created by jrk on 19.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VZUpload.h"
#import "PreferencesWindowController.h"

@interface ImgDropAppDelegate : NSObject 
{
	PreferencesWindowController *preferencesWindowController;
}

- (VZUpload *) newUploadInstance;
- (IBAction) openPreferences: (id) sender;
@end
