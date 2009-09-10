//
//  LocalhostrClient.m
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "LocalhostrClient.h"


@implementation LocalhostrClient

- (void) processReturnValue: (NSString *) returnValue
{
	NSArray *rets = [returnValue componentsSeparatedByString:@","];
	[self messageDelegateSuccess: [rets objectAtIndex: 0]];
}


- (void) performUploadWithFile: (NSString *) filename
{
	NSMutableURLRequest *req = [self buildUploadRequestWithURL:@"http://www.localhostr.com/api" andFilename: filename];
	//NSURLConnection *connection =kPasteboardTypeFileURLPromise
	[[NSURLConnection alloc] initWithRequest:req delegate:self];
}


- (NSMutableURLRequest *) buildUploadRequestWithURL: (NSString *) url andFilename: (NSString *) filename
{
	
	NSString *file = [filename lastPathComponent];
	
	NSString *protocol = [[filename pathComponents] objectAtIndex: 0];
	NSLog(@"protocol: %@",protocol);
	
	NSData *(^openImageBlock)(NSString *);
	if ([protocol isEqualToString:@"http:"])
	{
		openImageBlock = ^(NSString *fileURI)
		{
			return (NSData*)[NSData dataWithContentsOfURL:[NSURL URLWithString:fileURI] options:0 error:nil];
		};
	}
	else
	{
		openImageBlock = ^(NSString *fileURI)
		{
			return (NSData*)[NSData dataWithContentsOfFile: fileURI options:0 error:nil];
		};
	}
	
	
	//filename = @"mutterliebe1.png";
	NSString *boundary = @"----------------------------513737a2eda2";
	
	NSURL *_url = [NSURL URLWithString: url];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
	[req setHTTPMethod:@"POST"];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	
	//NSString *imagePath = filename;//[NSString stringWithFormat:@"/Users/jrk/Desktop/%@", filename];
	NSData *imageData = openImageBlock (filename); //[NSData dataWithContentsOfFile:filename options:0 error:nil];
	

	
	//adding the body:
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n", file] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:imageData];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSInputStream *dataStream = [NSInputStream inputStreamWithData: postBody];
	
	[req setHTTPBodyStream: dataStream];
	
	//NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(progressTimer:) userInfo: dataStream repeats: YES];
	
	return req;
}

@end