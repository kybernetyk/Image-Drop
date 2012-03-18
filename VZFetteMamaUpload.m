//
//  VZFetteMamaUpload.m
//  Image Drop
//
//  Created by Leon Szpilewski on 3/18/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "VZFetteMamaUpload.h"
#import "NSString+Additions.h"

@implementation VZFetteMamaUpload
- (NSDictionary *) postFields
{
	NSMutableDictionary *postFields = [NSMutableDictionary dictionary];
	
	[postFields setObject: data forKey: @"infile"];
	
	return postFields;
}


- (NSString *) hostUploadURL
{
	return @"http://fettemama.org:6502/";
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response     // IN
{
	//LOG(6, ("%s: self:0x%p\n", __func__, self));
	
	NSLog(@"received response: %@",[response URL]);
	
	[self messageDelegateSuccess: [[response URL] absoluteString]];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data                // IN
{
	return;	
}

@end
