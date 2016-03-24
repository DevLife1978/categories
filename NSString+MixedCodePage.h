//
//  NSString+LossyConverter.h
//  LossyConverter
//
//  Created by JayDev on 2016. 3. 23..
//  Copyleft
//

#import <Foundation/Foundation.h>

@interface NSString (MixedCodePage)

+ (NSString *)stringWithData:(NSData *)data
                    encoding:(NSStringEncoding)encoding
                    useiconv:(BOOL)useiconv;
+ (NSString *)stringWithData:(NSData *)data
            CFStringEncoding:(CFStringEncoding)encoding
                    useiconv:(BOOL)useiconv;

@end