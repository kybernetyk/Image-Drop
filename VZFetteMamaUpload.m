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
@end
