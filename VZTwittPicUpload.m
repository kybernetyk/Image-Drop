//
//  VZTwittPicUpload.m
//  ImgDrop
//
//  Created by jrk on 24/12/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "VZTwittPicUpload.h"
#import "TwittPicMessageWindowController.h"

@implementation VZTwittPicUpload
@synthesize username;
@synthesize password;
@synthesize message;

- (id) initWithUsername: (NSString *) _username Password: (NSString *) _password
{
	self = [super init];
	if (self)
	{
		[self setUsername: _username];
		[self setPassword: _password];
	}
	
	return self;
}

- (void) dealloc
{
	NSLog(@"TWITTPIC UPLOAD DEALLOC!");
	
	[username release];
	[password release];
	[message release];
	[super dealloc];
}

- (NSDictionary *) postFields
{
	NSMutableDictionary *postFields = [NSMutableDictionary dictionary];
	
	[postFields setObject: [self username] forKey: @"username"];
	[postFields setObject: [self password] forKey: @"password"];
	[postFields setObject: data forKey: @"media"];
	
	if ([self message])
		[postFields setObject: [self message] forKey: @"message"];
	
	return postFields;
}

- (NSString *) hostUploadURL
{
	return @"http://twitpic.com/api/uploadAndPost";
}


- (void) performUpload
{
	if (!data || !filename)
	{
		NSLog(@"error: data or filename not set! data: %@ filename: %@",data,filename);
		[self messageDelegateFailure];
		return;
	}
	
	NSLog(@"perofming upload with data length %i and filename %@",[data length],filename);

	//retain ourselfes so we don't get dealloced while the msg input dialog is shown
	//[self retain];
	[NSApp activateIgnoringOtherApps: YES];

	
	TwittPicMessageWindowController *cont = [[TwittPicMessageWindowController alloc] initWithWindowNibName: @"TwittPicMessageWindow"];
	[cont setDelegate: self];
	[[cont window] center];
	[[cont window] makeKeyAndOrderFront: self];
	[cont showWindow: self];
	
	[NSApp activateIgnoringOtherApps: YES];
}

- (BOOL) shouldApplicationHideOnDroppingImage
{
 	return NO;
}


- (void) twittPicMessageWindowController: (id) aController didFinishWithMessage: (NSString *) aMessage
{
	NSLog(@"message: %@",aMessage);
	//[aController autorelease];
	if (!aMessage)
	{	
		[self messageDelegateFailure];
//		[self autorelease];
		return;
	}

	[self setMessage: aMessage];

	[self setUrlOfUploadHost: [self hostUploadURL]];
	NSURLRequest *req = [self buildUploadRequestWithPostFields: [self postFields]];
	[[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
	}


- (void) processReturnValue: (NSString *) returnValue
{
		NSLog(@"processing return val: %@",returnValue);
//	[self autorelease];
	
	//let's process imageshack's answear
	
	NSError *error;	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString: returnValue options: NSXMLDocumentTidyXML error: &error];
	
	if (document) 
	{
		NSArray *result = [document objectsForXQuery:@"for $img in //mediaurl return $img" constants:nil error:&error];
		
		if ([result count] <= 0)
		{
			NSLog(@"the result was nil bitch. there seems to be an error!");
			NSLog(@"return val from image shack: %@",returnValue);
			[document release];
			[self messageDelegateFailure];
			return;
		}
		
		NSString *retval = [NSString stringWithString: [[result objectAtIndex: 0] stringValue]];
		
		[document release];
		[self messageDelegateSuccess: [NSString stringWithFormat:@"%@", retval]];
		return;
	}
	[document release];
	[self messageDelegateFailure];
	NSLog(@"UPS! no document bitch! %@",error);
}




@end
