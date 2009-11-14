//
//  UploadClient.m
//  ImgDrop
//
//  Created by jrk on 20.07.09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "VZUpload.h"


@implementation VZUpload
@synthesize data;
@synthesize filename;
@synthesize delegate;
@synthesize urlOfUploadHost;
@synthesize uploadMetaInformation;

#pragma mark returnvalue

- (void) dealloc
{
	NSLog(@"VZ UPLOAD DEALLOC!");
	
	[data release];
	[filename release];
	[urlOfUploadHost release];
	[uploadMetaInformation release];
	
	[super dealloc];
}

- (void) processReturnValue: (NSString *) returnValue
{
	NSLog(@"LOL THIS IS ABSTRACT!");
	[self doesNotRecognizeSelector:_cmd];
}

- (void) messageDelegateSuccess: (NSString *) urlOfUploadedPicture
{
	if ([delegate respondsToSelector:@selector(uploadClient: fileUploadSuccess: withReturnedURL:)])
		[delegate uploadClient: self fileUploadSuccess: YES withReturnedURL: urlOfUploadedPicture];	
}

#pragma mark HTTP REQ BUILDING
//- (void) performUploadWithData: (NSData *) data andFilename: (NSString *) filename
- (void) performUpload
{
	NSLog(@"LOL THIS IS ABSTRACT!");
	[self doesNotRecognizeSelector:_cmd];
	
}

//- (NSURLRequest *) buildUploadRequestWithURL: (NSString *) url Data: (NSData *) data andFilename: (NSString *) filename
- (NSURLRequest *) buildUploadRequest
{
	NSLog(@"LOL THIS IS ABSTRACT!");
	[self doesNotRecognizeSelector:_cmd];
	return nil;
	
}

#pragma mark HTTP DELEGATE
/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connectionDidFinishLoading:] --
 *
 *      Called when the upload is complete. We judge the success of the upload
 *      based on the reply we get from the server.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connectionDidFinishLoading:(NSURLConnection *)connection // IN
{
	//LOG(6, ("%s: self:0x%p\n", __func__, self));
	//[connection release];
//	NSLog(@"%i",[connection retainCount]);
	
	//[self uploadSucceeded:uploadDidSucceed];
	
	NSLog(@"connection finished!");
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didFailWithError:] --
 *
 *      Called when the upload failed (probably due to a lack of network
 *      connection).
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error              // IN
{
	//NSLog(1, ("%s: self:0x%p, connection error:%s\n",	__func__, self, [[error description] UTF8String]));
	//[connection release];
	NSLog(@"%i",[connection retainCount]);
	NSLog(@"connection failed %@",[error description]);
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didReceiveResponse:] --
 *
 *      Called as we get responses from the server.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response     // IN
{
	//LOG(6, ("%s: self:0x%p\n", __func__, self));
	
	//NSLog(@"received response: %@",response);
}


/*
 *-----------------------------------------------------------------------------
 *
 * -[Uploader(Private) connection:didReceiveData:] --
 *
 *      Called when we have data from the server. We expect the server to reply
 *      with a "YES" if the upload succeeded or "NO" if it did not.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *-----------------------------------------------------------------------------
 */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data                // IN
{
	//LOG(10, ("%s: self:0x%p\n", __func__, self));
	
	NSString *reply = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	//	LOG(10, ("%s: data: %s\n", __func__, [reply UTF8String]));
	
	/*if ([reply hasPrefix:@"YES"]) 
	 {
	 uploadDidSucceed = YES;
	 }*/
	
//	NSLog(@"received data: %@",reply);
	
	[self processReturnValue: reply];
	
	[reply release];
	
	//NSArray *rets = [reply componentsSeparatedByString:@","];
	
	/*if ([delegate respondsToSelector:@selector(uploadWindowController: fileUploadSuccess: withReturnedURL:)])
	 [delegate uploadWindowController: self fileUploadSuccess: YES withReturnedURL: [rets objectAtIndex: 0]];*/
	
}

@end
