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


- (void) performUpload
{

	if (!data || !filename)
	{
		NSLog(@"error: data or filename not set! data: %@ filename: %@",data,filename);
		return;
	}
	
	NSLog(@"perofming upload with data length %i",[data length]);
	
	[self setUrlOfUploadHost: @"http://www.localhostr.com/api"];
	
	NSURLRequest *req = [self buildUploadRequest];
	
	[[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}


- (NSMutableURLRequest *) buildUploadRequest
{

	//filename = @"mutterliebe1.png";
	NSString *boundary = @"----------------------------513737a2eda2";
	
	NSURL *_url = [NSURL URLWithString: [self urlOfUploadHost]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
	[req setHTTPMethod:@"POST"];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	
	
	//adding the body:
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData: data];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r \n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[req setHTTPBody: postBody];
	
	return req;
}

@end