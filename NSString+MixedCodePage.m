//
//  NSString+LossyConverter.m
//  LossyConverter
//
//  Created by JayDev on 2016. 3. 23..
//  Copyleft
//

#import "NSString+MixedCodePage.h"
#import <iconv.h>

#define USE_MIXED_ENCODE 1

@implementation NSString (MixedCodePage)

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding useiconv:(BOOL)useiconv {
    NSMutableString *encodedTotalString = [NSMutableString string];
    if (useiconv) {
        
        CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(encoding);
        CFStringRef encNameRef = CFStringConvertEncodingToIANACharSetName(cfenc);
        NSLog(@"%x", cfenc);
        NSString *encName = (__bridge NSString *)encNameRef;
        iconv_t ic = iconv_open("UTF-8", [encName UTF8String]);
        iconv_t ic_utf = iconv_open("UTF-8", "UTF-8");
        
        if (ic != 0xffffffff) {
            char *src = (char *)[data bytes];
            size_t src_length = [data length];
            
            size_t dst_length = src_length * 2;
            size_t dst_left_length = dst_length;
            char *dst = malloc(src_length * 2);
            memset(dst, 0, dst_left_length);
            
            size_t offset = 0;
            BOOL change_ic = NO;
            while (YES) {
                char *temp_dst = dst + offset;
                size_t ret = iconv(change_ic ? ic_utf : ic, &src, &src_length, &temp_dst, &dst_left_length);
                
                offset = dst_length - dst_left_length;
                switch (errno) {
                    case EINVAL:
                    case EILSEQ:
                    case ESRCH:
                    {
                        if (USE_MIXED_ENCODE) {
                            if (change_ic) { // target character set or utf8, neither is source character
                                src_length -= 1;
                                src += 1;
                            }
                            // sometimes none unicode encoding mixed with utf-8
                            change_ic = !change_ic;
                        }
                        else {
                            src_length -= 1;
                            src += 1;
                        }
                    }
                        break;
                    case E2BIG:
                        break;
                    default:
                    {
                        
                    }
                        break;
                }
                if (ret != (size_t)-1) {
                    break;
                }
            }
            
            NSString *encoded = [[NSString alloc] initWithBytes:dst
                                                         length:offset
                                                       encoding:NSUTF8StringEncoding];
            if (encoded) {
                [encodedTotalString appendString:encoded];
#if  !__has_feature(objc_arc)
                [encoded release];
#endif
            }
            
            free(dst);
            iconv_close(ic);
        }
        
        iconv_close(ic_utf);
    }
    else {
        char *src = malloc([data length] + 1);
        memset(src, 0, [data length]);
        [data getBytes:src length:[data length]];
        
        char *tmp = src;
        while (*tmp) {
            if ((UInt8)*tmp < 128) {
                NSString *encoded = [[NSString alloc] initWithBytes:tmp length:1 encoding:encoding];
                if (encoded) {
                    [encodedTotalString appendString:encoded];
#if  !__has_feature(objc_arc)
                    [encoded release];
#endif
                }
                tmp += 1;
            }
            else {
                NSString *encoded = [[NSString alloc] initWithBytes:tmp length:2 encoding:encoding];
                if (encoded) {
                    [encodedTotalString appendString:encoded];
#if  !__has_feature(objc_arc)
                    [encoded release];
#endif
                    tmp += 2;
                }
                else {
                    NSString *encoded = [[NSString alloc] initWithBytes:tmp length:4 encoding:NSUTF8StringEncoding];
                    if (encoded) {
                        [encodedTotalString appendString:encoded];
#if  !__has_feature(objc_arc)
                        [encoded release];
#endif
                    }
                    tmp += 4;
                }
            }
        }
        
        free(src);
    }
    
    return  [[NSString alloc] initWithString:encodedTotalString];
}

+ (NSString *)stringWithData:(NSData *)data CFStringEncoding:(CFStringEncoding)encoding useiconv:(BOOL)useiconv{
    return [self stringWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(encoding) useiconv:useiconv];
}

@end