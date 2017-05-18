//
//  NeteaseMusicHook.h
//  NeteaseMusicPlugin-iOS
//
//  Created by Jesse Zhu on 2017/5/12.
//
//

#import "Helper.h"
#import "JSONModel.h"

@interface NSObject (NeteaseMusicHook)
+ (void)hookNeteaseMusic;
@end

@interface ComNeteaseCloudMusicCoSDKNTESJson : NSObject
+ (id)ntes_jsonDataWithUTF8:(id)arg1;
+ (id)ntes_jsonObjectWithUTF8:(id)arg1;
@end

@interface SongModel : JSONModel
@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger code;
@property (nonatomic) NSInteger br;
@property (nonatomic) NSInteger expi;
@property (nonatomic) NSInteger fee;
@property (nonatomic) NSInteger flag;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger payed;
@property (retain, nonatomic) NSString<Optional>* md5;
@property (retain, nonatomic) NSString<Optional>* type;
@property (retain, nonatomic) NSString<Optional>* url;
@property (nonatomic) float gain;
@property (nonatomic) BOOL canExtend;
@end

@interface ResModel : JSONModel
@property (nonatomic) NSInteger code;
@property (retain, nonatomic) NSArray<SongModel *> *data;
@end
