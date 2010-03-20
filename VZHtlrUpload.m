//
//  VZHtlrUpload.m
//  ImgDrop
//
//  Created by jrk on 27/2/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "VZHtlrUpload.h"
#import "NSString+Additions.h"

@implementation VZHtlrUpload

- (NSDictionary *) postFields
{
	NSMutableDictionary *postFields = [NSMutableDictionary dictionary];
	
	[postFields setObject: data forKey: @"upload[datafile]"];
	
	return postFields;
}

- (NSString *) hostUploadURL
{
	return @"http://htlr.org/upload/uploadFile";
}


- (void) processReturnValue: (NSString *) returnValue
{
	NSLog(@"return val: %@", returnValue);
	
	if ([returnValue containsString: @"fail" ignoringCase: YES])
	{
		[self messageDelegateFailure];
		return;
	}
	
	NSString *url = [[returnValue componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] objectAtIndex: 0];
	url = [url stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	[self messageDelegateSuccess: [NSString stringWithFormat:@"%@", url]];
	
	/*
	NSError *error;	
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithXMLString: returnValue options: NSXMLDocumentTidyHTML error: &error];
	
	if (document) 
	{
		NSArray *result = [document objectsForXQuery:@"for $img in //image_link return $img" constants:nil error:&error];
		
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
	NSLog(@"UPS! no document bitch! %@",error);*/
	//NSLog(@"HTLR RETURN: %@", returnValue);
}

@end
