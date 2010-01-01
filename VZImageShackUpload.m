//
//  VZImageShackUpload.m
//  ImgDrop
//
//  Created by jrk on 14/11/09.
//  Copyright 2009 flux forge. All rights reserved.
//

#import "VZImageShackUpload.h"


@implementation VZImageShackUpload
- (NSDictionary *) postFields
{
	NSMutableDictionary *postFields = [NSMutableDictionary dictionary];
	
	[postFields setObject: kImageShackDeveloperKey forKey: @"key"];
	[postFields setObject: @"no" forKey: @"rembar"];
	[postFields setObject: data forKey: @"fileupload"];
	[postFields setObject: @"yes" forKey: @"public"];
	
	return postFields;
}

- (NSString *) hostUploadURL
{
	return @"http://www.imageshack.us/upload_api.php";
}


- (void) processReturnValue: (NSString *) returnValue
{
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
	NSLog(@"UPS! no document bitch! %@",error);
}


@end
