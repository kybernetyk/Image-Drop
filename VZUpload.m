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
- (BOOL) shouldApplicationHideOnDroppingImage
{
	return YES;
}


- (void) dealloc
{
	NSLog(@"VZ UPLOAD DEALLOC!");
	
	[data release];
	data = nil;
	[filename release];
	filename = nil;
	
	[urlOfUploadHost release];
	urlOfUploadHost = nil;
	
	[uploadMetaInformation release];
	uploadMetaInformation = nil;
	
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

- (void) messageDelegateFailure
{
	if ([delegate respondsToSelector:@selector(uploadClientfileUploadDidFail:)])
		[delegate uploadClientfileUploadDidFail: self];	
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
	[self messageDelegateFailure];
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

- (NSDictionary *) postFields
{
	NSLog(@"- (NSDictionary *) postFields not implemented for %@",[self className]);
	return nil;
}

- (NSString *) hostUploadURL
{
	NSLog(@"- (NSString *) hostUploadURL not implemented for %@",[self className]);
	return nil;
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


- (NSURLRequest *) buildUploadRequestWithPostFields: (NSDictionary *) postFields
{
	if (!postFields)
	{
		NSLog(@"post fields for %@ are nil!",[self className]);
		[self messageDelegateFailure];
	}
	
	NSLog(@"%@ bulding multipart post request ...", [self className]);
	
	NSString *boundary = @"----------------------------592d224d1f3a";
	
	NSURL *_url = [NSURL URLWithString: [self urlOfUploadHost]];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_url];
	[req setHTTPMethod:@"POST"];
	[req setCachePolicy: NSURLRequestReloadIgnoringLocalCacheData];
	[req setHTTPShouldHandleCookies: NO];
	
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
	[req setValue:contentType forHTTPHeaderField:@"Content-type"];
	
	
/*	NSMutableDictionary *postFields = [NSMutableDictionary dictionary];
	
	[postFields setObject: kImageShackDeveloperKey forKey: @"key"];
	[postFields setObject: @"no" forKey: @"rembar"];
	[postFields setObject: data forKey: @"fileupload"];
	[postFields setObject: @"yes" forKey: @"public"];*/
	
	NSData *postData = [self dataForPOSTWithDictionary: postFields boundary: boundary];
	[req setHTTPBody: postData];
	
	return req;
}

- (void) auth
{
	
}

- (void) performUpload
{
	if (!data || !filename)
	{
		NSLog(@"error: data or filename not set! data: %@ filename: %@",data,filename);
		[self messageDelegateFailure];
		return;
	}
	
	if (![self hostUploadURL])
	{
		NSLog(@"no upload endpoint set for %@",[self className]);
		[self messageDelegateFailure];
		return;
	}

	NSLog(@"%@ perofming upload with data length %i, filename %@ and content-type: %@",[self className],[data length],filename, [self guessedContentType]);
	
	//[self setUrlOfUploadHost: @"http://www.imageshack.us/upload_api.php"];
	
	[self setUrlOfUploadHost: [self hostUploadURL]];
	
	NSURLRequest *req = [self buildUploadRequestWithPostFields: [self postFields]];
	
	[[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
}



@end
