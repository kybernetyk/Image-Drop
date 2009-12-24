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

- (void) performUpload
{
	if (!data || !filename)
	{
		NSLog(@"error: data or filename not set! data: %@ filename: %@",data,filename);
		return;
	}
	
	NSLog(@"perofming upload with data length %i and filename %@",[data length],filename);

	//retain ourselfes so we don't get dealloced while the msg input dialog is shown
	[self retain];
	[NSApp activateIgnoringOtherApps: YES];

	
	TwittPicMessageWindowController *cont = [[TwittPicMessageWindowController alloc] initWithWindowNibName: @"TwittPicMessageWindow"];
	[cont setDelegate: self];
	[[cont window] center];
	[[cont window] makeKeyAndOrderFront: self];
	[cont showWindow: self];
	
	[NSApp activateIgnoringOtherApps: YES];
}

- (BOOL) shouldHide
{
 	return NO;
}


- (void) twittPicMessageWindowController: (id) aController didFinishWithMessage: (NSString *) aMessage
{
		
	
	NSLog(@"message: %@",aMessage);
	//[aController autorelease];
	if (!aMessage)
	{	
		[self autorelease];
		return;
	}

	[self setMessage: aMessage];
	
	[self setUrlOfUploadHost: @"http://twitpic.com/api/uploadAndPost"];
	NSURLRequest *req = [self buildUploadRequest];
	[[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}


- (void) processReturnValue: (NSString *) returnValue
{
		NSLog(@"processing return val: %@",returnValue);
	[self autorelease];
	
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
			return;
		}
		
		NSString *retval = [NSString stringWithString: [[result objectAtIndex: 0] stringValue]];
		
		[document release];
		[self messageDelegateSuccess: [NSString stringWithFormat:@"%@", retval]];
		return;
	}
	[document release];
	NSLog(@"UPS! no document bitch! %@",error);
}



- (NSURLRequest *) buildUploadRequest
{
	NSLog(@"tiwttpic build upload req");
	
	NSString *boundary = @"----------------------------592d224d1f3a";
	
	NSURL *_url = [NSURL URLWithString: [self urlOfUploadHost]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
	[req setHTTPMethod:@"POST"];
	[req setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
	[req setHTTPShouldHandleCookies: NO];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	
	
	NSMutableDictionary *postFields = [NSMutableDictionary dictionary];
	
	[postFields setObject: [self username] forKey: @"username"];
	[postFields setObject: [self password] forKey: @"password"];
	[postFields setObject: data forKey: @"media"];

	//NSLog(@"post fields: %@",postFields);
	
	if ([self message])
		[postFields setObject: [self message] forKey: @"message"];

	
	NSData *postData = [self dataForPOSTWithDictionary: postFields boundary: boundary];
	[req setHTTPBody: postData];
	
	return req;
}


//will guess the appropriate content type taking the file's extension into account
//cause FUCKING IMAGESHACK DOES NOT SUPPORT application/octet-stream and they're too lazy to detect the image type.
- (NSString *) guessedContentType
{
	
	//stolen from the php imageshack api lib
	
	/*                case 'jpg':
	 case 'jpeg':
	 return 'image/jpeg';
	 case 'png':
	 case 'bmp':
	 case 'gif':
	 return 'image/' . $ext;
	 case 'tif':
	 case 'tiff':
	 return 'image/tiff';
	 case 'mp4':
	 return 'video/mp4';
	 case 'mov':
	 return 'video/quicktime';
	 case '3gp':
	 return 'video/3gpp';
	 case 'avi':
	 return 'video/avi';
	 case 'wmv':
	 return 'video/x-ms-wmv';
	 case 'mkv':
	 return 'video/x-matroska';
	 */	 
	
	NSString *pathExtension = [[filename pathExtension] lowercaseString];
	
	if ([pathExtension isEqualToString: @"jpg"] || 
		[pathExtension isEqualToString: @"jpeg"])
	{
		return @"image/jpeg";
	}
	
	if ([pathExtension isEqualToString: @"png"] || 
		[pathExtension isEqualToString: @"bmp"] ||
		[pathExtension isEqualToString: @"gif"])
	{
		return [NSString stringWithFormat: @"image/%@",pathExtension];
	}
	if ([pathExtension isEqualToString: @"tif"] || 
		[pathExtension isEqualToString: @"tiff"])
	{
		return @"image/tiff";
	}
	
	return @"application/octet-stream"; //let's make imageshack cry
}


//this will iterate through a dictionary and create multipart post fields from it
//
//thx @ http://www.cocoadev.com/index.pl?HTTPFileUpload
//cocoa really needs a modern POST handler
- (NSData *)dataForPOSTWithDictionary:(NSDictionary *)aDictionary boundary:(NSString *)aBoundary 
{
    NSArray *myDictKeys = [aDictionary allKeys];
    NSMutableData *myData = [NSMutableData data];
    NSString *myBoundary = [NSString stringWithFormat:@"--%@\r\n", aBoundary];
    
    for(int i = 0;i < [myDictKeys count];i++) 
	{
        id myValue = [aDictionary valueForKey:[myDictKeys objectAtIndex:i]];
        [myData appendData:[myBoundary dataUsingEncoding:NSUTF8StringEncoding]];
		
        if ([myValue isKindOfClass:[NSString class]]) 
		{
            [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [myDictKeys objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:[[NSString stringWithFormat:@"%@", myValue] dataUsingEncoding:NSUTF8StringEncoding]];
        } 
		else if(([myValue isKindOfClass:[NSURL class]]) && ([myValue isFileURL])) 
		{
            [myData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], [[myValue path] lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:[NSData dataWithContentsOfFile:[myValue path]]];
        }
		else if ([myValue isKindOfClass:[NSData class]]) //that's us!
		{
			NSString *str = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [myDictKeys objectAtIndex:i], filename];
			
            [myData appendData: [str dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",[self guessedContentType]] dataUsingEncoding:NSUTF8StringEncoding]];
            [myData appendData: myValue];
		}
        
		
		
		[myData appendData:[[NSString stringWithString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
	
    [myData appendData:[[NSString stringWithFormat:@"--%@--\r\n", aBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
    return myData;
}


@end
