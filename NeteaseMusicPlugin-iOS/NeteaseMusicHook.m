//
//  NeteaseMusicHook.m
//  NeteaseMusicPlugin-iOS
//
//  Created by Jesse Zhu on 2017/5/12.
//
//

#import "NeteaseMusicHook.h"

@implementation SongModel
@end

@implementation ResModel
@end

NSString *apiServer = @"http://127.0.0.1:8123";

@implementation NSObject (NeteaseMusicHook)

+ (void)hookNeteaseMusic {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        hookMethod(objc_getClass("NMHttpRequest"), @selector(parseResult), [self class], @selector(hook_parseResult));
        hookMethod(objc_getClass("NMHttpRequest"), @selector(initWithUrlString:), [self class], @selector(hook_initWithUrlString:));
        hookMethod(objc_getClass("NMAppDelegate"), @selector(checkUpdate:), [self class], @selector(hook_checkUpdate:));
        hookMethod(objc_getClass("NMAdBackgroundView"), @selector(showAd:), [self class], @selector(hook_showAd:));
        hookMethod(objc_getClass("NMMVAdBannerView"), @selector(initWithFrame:), [self class], @selector(hook_initWithFrame:));
        hookClassMethod(objc_getClass("CloudMusicCoSDK"), @selector(decryptData:), [self class], @selector(hook_decryptData:));
    });
}

- (id *)hook_initWithFrame:(id)arg {
    NSLog(@"=== hook_initWithFrame ===");
    return NULL;
}

- (BOOL)hook_showAd:(id)arg {
    NSLog(@"=== hook_showAd ===");
    return FALSE;
}

- (BOOL)hook_checkUpdate:(id)arg {
    NSLog(@"=== hook_checkUpdate ===");
    return FALSE;
}

- (id *)hook_initWithUrlString:(id)url {
    NSLog(@"=== hook_initWithUrlString === %@", url);
    id* request = [self hook_initWithUrlString:url];
    if (![url containsString:@"https"]) {
        NSString* ip = [NSString stringWithFormat:@"202.114.79.%d", (arc4random() % 255) + 1];
        NSDictionary* header = [[NSDictionary alloc] initWithObjectsAndKeys:ip, @"X-REAL-IP", nil];
        [self setHeader:header];
        [header release];
    }

    return request;
}

- (NSString *)replaceWithRegExp:(NSString *)inputStr :(NSString *)pattern :(NSString *)replacement{
    NSError *error = nil;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSString *resultStr = inputStr;
    resultStr = [regExp stringByReplacingMatchesInString:inputStr
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, inputStr.length)
                                            withTemplate:replacement];
    return resultStr;
}


- (NSString *)hook_decryptData:(id)data {
    NSLog(@"=== hook_decryptData ===");
    NSString *content = [self hook_decryptData:data];
//    NSLog(@"Content %@", content);
    
    JSONModelError *error = nil;
    ResModel *res = [[ResModel alloc] initWithString:content error:&error];
    if (error) {
        NSLog(@"Cannot parse JSON: %@", error);
        [res release];
        return content;
    }
    error = nil;
    NSArray *songArr = [SongModel arrayOfModelsFromDictionaries:[res data] error:&error];
    if (error) {
        NSLog(@"Cannot parse JSON: %@", error);
        [res release];
        return content;
    }
    [res release];
    if ([songArr count] > 0 && [songArr[0] code] != 200) {
//        NSLog(@"\n%@", songArr[0]);
        
        NSLog(@"Song is null, send to api server");
        NSString *urlStr = [NSString stringWithFormat:@"%@/api/plugin", apiServer];
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        NSURLResponse *response = nil;
        NSError *error;
        NSData *result = nil;
        result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!result || !response) {
            NSLog(@"Cannot get song from api server");
            return content;
        }
        
        NSString *resultStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        //            NSString *errorDesc = [error localizedDescription];
        
        //            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        //            NSInteger statusCode = [httpResponse statusCode];
        //
        NSLog(@"result %@", resultStr);

        [url release];
        resultStr = [resultStr autorelease];
        return resultStr;
    }

    return content;
}



- (NSDictionary *)hook_parseResult {
    NSString* url = [self urlString];
    NSLog(@"=== hook_parseResult === %@", url);
    NSDictionary *res = [self hook_parseResult];
    NSLog(@"%@", [self responseHeader]);
    
    if ([url containsString:@"/api/song/enhance/player/url"]) {
        return res;
    }
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *documentTXTPath = [documentsDirectory stringByAppendingPathComponent:@"data.txt"];
//    
//    NSString *savedString = [NSString stringWithFormat:@"%@\n%@\n\n", url, jsonString];
//    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
//    [myHandle seekToEndOfFile];
//    [myHandle writeData:[savedString dataUsingEncoding:NSUTF8StringEncoding]];
    
    if ([url containsString:@"/api/ad/get"] ||
        [url containsString:@"/api/ios/version"]
    ) {
        NSString* jsonString = @"{}";
        NSLog(@"json %@", jsonString);
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary* res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        return res;
    }

    if ([url containsString:@"detail"] ||
        [url containsString:@"playlist"] ||
        [url containsString:@"privilege"] ||
        [url containsString:@"search"] ||
        [url containsString:@"batch"]
    ) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:res
                                                           options:0
                                                             error:&error];
        
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"json %@", jsonString);
            
            NSString* replaced = [self replaceWithRegExp:jsonString :@"\"st\":-.*?," :@"\"st\":0,"];
            [jsonString release];
            replaced = [self replaceWithRegExp:replaced :@"\"fee\":.*?," :@"\"fee\":0,"];
            replaced = [self replaceWithRegExp:replaced :@"\"pl\":0," :@"\"pl\":320000,"];
            replaced = [self replaceWithRegExp:replaced :@"\"dl\":0," :@"\"dl\":320000,"];
            replaced = [self replaceWithRegExp:replaced :@"\"fl\":0," :@"\"pl\":320000,"];
            replaced = [self replaceWithRegExp:replaced :@"\"cp\":0," :@"\"cp\":1,"];
            replaced = [self replaceWithRegExp:replaced :@"\"subp\":0," :@"\"subp\":1,"];
            replaced = [self replaceWithRegExp:replaced :@"\"sp\":0," :@"\"sp\":7,"];
            replaced = [self replaceWithRegExp:replaced :@"\"abroad\":1," :@""];
            //        NSString *savedString = [NSString stringWithFormat:@"Replaced\n%@\n%@\n\n", url, jsonString];
            //        [myHandle seekToEndOfFile];
            //        [myHandle writeData:[savedString dataUsingEncoding:NSUTF8StringEncoding]];
            
            jsonData = [replaced dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary* res = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            
            return res;
        }
    }
    
    return res;
}

@end

static void __attribute__((constructor)) initialize(void) {
    NSLog(@"+++ NeteaseMusicPlugin Loaded +++");
    
    [NSObject hookNeteaseMusic];
}
