//
//  EasyShareKit.h
//  EasyShareKit
//
//  Created by pcjbird on 2017/7/25.
//  Copyright © 2017年 Zero Status. All rights reserved.
//
//  框架名称:EasyShareKit
//  框架功能:Easy way to parse share info from H5 page. 一种从 H5 页面获取分享数据的简便的方法。
//  修改记录:
//     pcjbird    2017-07-25  Version:1.0.0 Build:201707250001
//                            1.第一个版本。

#import <Foundation/Foundation.h>

//! Project version number for EasyShareKit.
FOUNDATION_EXPORT double EasyShareKitVersionNumber;

//! Project version string for EasyShareKit.
FOUNDATION_EXPORT const unsigned char EasyShareKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <EasyShareKit/PublicHeader.h>


//分享类型
typedef enum
{
    EasyShareType_Unknown,            //位置（unknown）
    EasyShareType_Webpage,            //网页（webpage）
    EasyShareType_Article,            //文章（article）
    EasyShareType_Audio,              //音频（audio）
    EasyShareType_Image,              //图片（image）
    EasyShareType_Gallery,            //图集（gallery）
    EasyShareType_Person,             //人（person）
    EasyShareType_Place,              //地点（place）
    EasyShareType_Product,            //产品（product）
    EasyShareType_Video,              //视频（video）
    EasyShareType_Book,               //书（book）
    EasyShareType_Game,               //游戏（game）
    EasyShareType_App,                //应用（app）
}EasyShareType;

//App类型
typedef enum
{
    EasyShareAppType_None,            //不是App类型
    EasyShareAppType_iPhone,          //iPhone应用
    EasyShareAppType_iPad,            //iPad应用
    EasyShareAppType_GooglePlay,      //Google Play Android应用
}EasyShareAppType;

//分享信息
@interface EasyShareInfo : NSObject

//是否通过meta设置
@property(nonatomic, assign) BOOL     resolvedByMeta;

//类型
@property(nonatomic, assign) EasyShareType type;

//标题
@property(nonatomic, strong) NSString* title;
//描述
@property(nonatomic, strong) NSString* desc;
//图标
@property(nonatomic, strong) NSString* image;
//链接
@property(nonatomic, strong) NSString* url;

//创建时间
@property(nonatomic, strong) NSDate*   create;
//更新时间
@property(nonatomic, strong) NSDate*   update;


//缩略图
@property(nonatomic, strong) NSString* thumbnail;
//原图
@property(nonatomic, strong) NSString* artwork;

//嵌入代码
@property(nonatomic, strong) NSString* embed_code;
//视频流链接源
@property(nonatomic, strong) NSString* stream;
//时长，单位秒
@property(nonatomic, assign) unsigned long duration;

//位置
@property(nonatomic, strong) NSString* position;

//isbn
@property(nonatomic, strong) NSString* isbn;

//图集
@property(nonatomic, strong) NSArray* gallery;

//app类型
@property(nonatomic, assign) EasyShareAppType appType;

//app名称
@property(nonatomic, strong) NSString* appName;

//app上线国家
@property(nonatomic, strong) NSString* appCountry;

//app在商店里的唯一编号
@property(nonatomic, strong) NSString* appIdentity;

@end

/**
 param shareInfo 分享信息数据
 param cost      耗时，单位ms
 param error     发生的错误
 */
typedef void (^EasyShareInfoBlock) (EasyShareInfo*shareInfo, long cost, NSError* error);

@interface EasyShareKit : NSObject

-(id) initWithUrl:(NSString*)url;
-(id) initWithHtml:(NSString*)html;
-(void) setCustomMetaTags:(NSArray<NSString*>*)tags;
-(void) getWebShareInfo:(EasyShareInfoBlock)block;

@end
