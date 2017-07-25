//
//  EasyShareKit.m
//  EasyShareKit
//
//  Created by pcjbird on 2017/7/25.
//  Copyright © 2017年 Zero Status. All rights reserved.
//

#import "EasyShareKit.h"

#if __has_include(<hpple/TFHpple.h>)
#import <hpple/TFHpple.h>
#else
#import "TFHpple.h"
#endif

@implementation EasyShareInfo

-(instancetype)init
{
    if(self = [super init])
    {
        self.resolvedByMeta = FALSE;
        self.type = EasyShareType_Unknown;
        self.title = @"";
        self.desc = @"";
        self.image = @"";
        self.url = @"";
        self.create = nil;
        self.url = nil;
        self.thumbnail = nil;
        self.artwork = nil;
        self.embed_code = nil;
        self.stream = nil;
        self.duration = 0;
        self.position = nil;
        self.isbn = nil;
        self.gallery = nil;
        self.appType = EasyShareAppType_None;
        self.appName = nil;
        self.appIdentity = nil;
        self.appCountry = nil;
    }
    return self;
}

@end

@interface EasyShareKit()

@end

@implementation EasyShareKit
{
    NSString*            _url;
    NSString*            _html;
    EasyShareInfoBlock   _block;
    NSDate*              _begin;
    NSMutableArray*      _customtags;
}

-(id) initWithUrl:(NSString*)url
{
    if(self = [super init])
    {
        _url = url;
        _html = nil;
        _begin = nil;
        _customtags = [NSMutableArray array];
    }
    return self;
}

-(id) initWithHtml:(NSString*)html
{
    if(self = [super init])
    {
        _url = nil;
        _html = html;
        _begin = nil;
        _customtags = [NSMutableArray array];
    }
    return self;
}

-(void)setCustomMetaTags:(NSArray<NSString *> *)tags
{
    if(![tags isKindOfClass:[NSArray<NSString *> class]]) return;
    [_customtags removeAllObjects];
    [_customtags addObjectsFromArray:tags];
}


-(long) getCostTime
{
    if([_begin isKindOfClass:[NSDate class]])
    {
        return (long)([[NSDate date] timeIntervalSinceDate:_begin] * 1000);
    }
    return 0;
}

-(void) getWebShareInfo:(EasyShareInfoBlock)block
{
    _block = block;
    _begin = [NSDate date];
    if([_url isKindOfClass:[NSString class]])
    {
        NSURL *url = [NSURL URLWithString:_url];
        // 创建一个请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 1.得到session对象
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_block)_block(nil, [self getCostTime], error);
                });
                return;
            }
            
            [self parseData:data];
        }];
        
        //开始任务
        [task resume];
    }
    else if([_html isKindOfClass:[NSString class]])
    {
        NSData * data = [_html dataUsingEncoding:NSUTF8StringEncoding];
        [self parseData:data];
    }
    else
    {
        if(_block)
        {
            NSError*error = [NSError errorWithDomain:@"EasyShareKit" code:1000 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"无法获取分享信息，未设置URL或HTML数据。（EasyShareKit）", @"message", nil]];
            dispatch_async(dispatch_get_main_queue(), ^{
                _block(nil, [self getCostTime], error);
            });
        }
    }
}

-(void)parseData:(NSData*)data
{
    NSLog(@"EasyShareKit: before parse data cost %ld ms.",[self getCostTime]);
    EasyShareInfo * shareInfo = [[EasyShareInfo alloc] init];
    shareInfo.type = EasyShareType_Unknown;
    
    TFHpple* doc = [[TFHpple alloc] initWithHTMLData:data];
    
    //Basics
    TFHppleElement *titleElement = [doc peekAtSearchWithXPathQuery:@"//title"];
    if(titleElement)
    {
        shareInfo.type = EasyShareType_Webpage;
        shareInfo.title = [titleElement content];
        shareInfo.url = _url;
    }
    TFHppleElement *descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"description\"]"];
    if(descElement)
    {
        shareInfo.desc = [descElement objectForKey:@"content"];
    }
    
    //Google +/Pinterest
    titleElement =[doc peekAtSearchWithXPathQuery:@"//meta[@itemprop=\"name\"]"];
    if(titleElement)
    {
        shareInfo.resolvedByMeta = TRUE;
        shareInfo.title = [titleElement objectForKey:@"content"];
    }
    descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@itemprop=\"description\"]"];
    if(descElement)
    {
        shareInfo.resolvedByMeta = TRUE;
        shareInfo.desc = [descElement objectForKey:@"content"];
    }
    
    TFHppleElement *imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@itemprop=\"image\"]"];
    if(imageElement)
    {
        shareInfo.resolvedByMeta = TRUE;
        shareInfo.image = [imageElement objectForKey:@"content"];
    }
    
    //Twitter Card
    TFHppleElement *twitterCardElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:card\"]"];
    if(twitterCardElement)
    {
        shareInfo.resolvedByMeta = TRUE;
        NSString*twitterCardType = [twitterCardElement objectForKey:@"content"];
        titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:title\"]"];
        if(titleElement)
        {
            shareInfo.title = [titleElement objectForKey:@"content"];
        }
        descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:description\"]"];
        if(descElement)
        {
            shareInfo.desc = [descElement objectForKey:@"content"];
        }
        TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:url\"]"];
        if(urlElement)
        {
            shareInfo.url = [urlElement objectForKey:@"content"];
        }
        imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image\"]"];
        if(imageElement)
        {
            shareInfo.image = [imageElement objectForKey:@"content"];
        }
        imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image:src\"]"];
        if(imageElement)
        {
            shareInfo.image = [imageElement objectForKey:@"content"];
        }
        
        if([twitterCardType isEqualToString:@"summary"] || [twitterCardType isEqualToString:@"summary_large_image"] || [twitterCardType isEqualToString:@"photo"] || [twitterCardType isEqualToString:@"product"])
        {
            if([twitterCardType isEqualToString:@"photo"])
            {
                shareInfo.type = EasyShareType_Image;
            }
            else if([twitterCardType isEqualToString:@"product"])
            {
                shareInfo.type = EasyShareType_Product;
            }
        }
        else if([twitterCardType isEqualToString:@"gallery"])
        {
            shareInfo.type = EasyShareType_Gallery;
            NSMutableArray *gallery = [NSMutableArray array];
            
            TFHppleElement* image0Element = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image0\"]"];
            if(image0Element)
            {
                [gallery addObject:[image0Element objectForKey:@"content"]];
            }
            
            TFHppleElement* image1Element = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image1\"]"];
            if(image1Element)
            {
                [gallery addObject:[image1Element objectForKey:@"content"]];
            }
            
            TFHppleElement* image2Element = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image2\"]"];
            if(image1Element)
            {
                [gallery addObject:[image2Element objectForKey:@"content"]];
            }
            
            TFHppleElement* image3Element = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image3\"]"];
            if(image3Element)
            {
                [gallery addObject:[image3Element objectForKey:@"content"]];
            }
            shareInfo.gallery = [gallery copy];
        }
        else if([twitterCardType isEqualToString:@"app"])
        {
            shareInfo.type = EasyShareType_App;
            
            TFHppleElement* countryElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:country\"]"];
            if(countryElement)
            {
                shareInfo.appCountry = [countryElement objectForKey:@"content"];
            }
            
            TFHppleElement* nameElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:name:iphone\"]"];
            if(nameElement)
            {
                shareInfo.appType = EasyShareAppType_iPhone;
                shareInfo.appName = [nameElement objectForKey:@"content"];
            }
            nameElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:name:ipad\"]"];
            if(nameElement)
            {
                shareInfo.appType = EasyShareAppType_iPad;
                shareInfo.appName = [nameElement objectForKey:@"content"];
            }
            nameElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:name:googleplay\"]"];
            if(nameElement)
            {
                shareInfo.appType = EasyShareAppType_GooglePlay;
                shareInfo.appName = [nameElement objectForKey:@"content"];
            }
            
            TFHppleElement* idElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:id:iphone\"]"];
            if(idElement)
            {
                shareInfo.appIdentity = [idElement objectForKey:@"content"];
            }
            idElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:id:ipad\"]"];
            if(idElement)
            {
                shareInfo.appIdentity = [idElement objectForKey:@"content"];
            }
            idElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:id:googleplay\"]"];
            if(idElement)
            {
                shareInfo.appIdentity = [idElement objectForKey:@"content"];
            }
            
            urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:url:iphone\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:url:ipad\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:app:url:googleplay\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
        }
        else if([twitterCardType isEqualToString:@"player"])
        {
            shareInfo.type = EasyShareType_Video;
            
            TFHppleElement* playerElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:player\"]"];
            if(playerElement)
            {
                shareInfo.url = [playerElement objectForKey:@"content"];
            }
            
            TFHppleElement* streamElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:player:stream\"]"];
            if(streamElement)
            {
                shareInfo.stream = [streamElement objectForKey:@"content"];
            }
            
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"twitter:image\"]"];
            if(imageElement)
            {
                shareInfo.thumbnail = [imageElement objectForKey:@"content"];
            }
        }
    }
    
    //Facebook
    TFHppleElement *ogElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:title\"]"];
    if(ogElement)
    {
        shareInfo.resolvedByMeta = TRUE;
        shareInfo.type = EasyShareType_Webpage;
        shareInfo.title = [ogElement objectForKey:@"content"];
        
        TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:url\"]"];
        if(urlElement)
        {
            shareInfo.url = [urlElement objectForKey:@"content"];
        }
        
        TFHppleElement *imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:image\"]"];
        if(imageElement)
        {
            shareInfo.image = [imageElement objectForKey:@"content"];
        }
        
        TFHppleElement *descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:description\"]"];
        if(descElement)
        {
            shareInfo.desc = [descElement objectForKey:@"content"];
        }
        
        TFHppleElement *ogTypeElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:type\"]"];
        if(ogTypeElement)
        {
            NSString *ogType = [ogTypeElement objectForKey:@"content"];
            if([ogType isEqualToString:@"profile"])
            {
                shareInfo.type = EasyShareType_Person;
                NSString *profile = @"";
                TFHppleElement *firstNameElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:profile:first_name\"]"];
                if(firstNameElement)
                {
                    profile = [profile stringByAppendingString:[firstNameElement objectForKey:@"content"]];
                    profile = [profile stringByAppendingString:@" "];
                }
                TFHppleElement *lastNameElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:profile:last_name\"]"];
                if(lastNameElement)
                {
                    profile = [profile stringByAppendingString:[lastNameElement objectForKey:@"content"]];
                }
                TFHppleElement *genderElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:profile:gender\"]"];
                if(genderElement)
                {
                    profile = [profile stringByAppendingString:[NSString stringWithFormat:@"(%@)",[genderElement objectForKey:@"content"]]];
                }
                if([profile length] > 0)
                {
                    shareInfo.title = profile;
                }
            }
            else if([ogType isEqualToString:@"book"])
            {
                shareInfo.type = EasyShareType_Book;
                TFHppleElement *isbnElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:book:isbn\"]"];
                if(isbnElement)
                {
                    shareInfo.isbn = [isbnElement objectForKey:@"content"];
                }
            }
            else if([ogType isEqualToString:@"article"])
            {
                shareInfo.type = EasyShareType_Article;
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:article:published_time\"]"];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:article:modified_time\"]"];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([ogType isEqualToString:@"video.movie"] || [ogType isEqualToString:@"video.episode"]|| [ogType isEqualToString:@"video.tv_show"] || [ogType isEqualToString:@"video.other"])
            {
                shareInfo.type = EasyShareType_Video;
                TFHppleElement *durationElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:video:duration\"]"];
                if(durationElement)
                {
                    shareInfo.duration = (unsigned long)[[durationElement objectForKey:@"content"] longLongValue];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:video\"]"];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
            }
            else if([ogType isEqualToString:@"music.song"])
            {
                shareInfo.type = EasyShareType_Audio;
                TFHppleElement *durationElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:music:duration\"]"];
                if(durationElement)
                {
                    shareInfo.duration = (unsigned long)[[durationElement objectForKey:@"content"] longLongValue];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"og:audio\"]"];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
            }
        }
        
    }
    
    //Weibo
    TFHppleElement *weiboElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:type\"]"];
    if(weiboElement)
    {
        shareInfo.resolvedByMeta = TRUE;
        NSString*weiboObjectType = [weiboElement objectForKey:@"content"];
        
        if([weiboObjectType isEqualToString:@"webpage"])
        {
            shareInfo.type = EasyShareType_Webpage;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:webpage:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:webpage:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:webpage:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:webpage:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:webpage:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:webpage:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"article"])
        {
            shareInfo.type = EasyShareType_Article;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:article:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:article:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:article:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:article:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:article:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:article:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"audio"])
        {
            shareInfo.type = EasyShareType_Audio;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *durationElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:duration\"]"];
            if(durationElement)
            {
                shareInfo.duration = (unsigned long)[[durationElement objectForKey:@"content"] longLongValue];
            }
            TFHppleElement *streamElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:stream\"]"];
            if(streamElement)
            {
                shareInfo.stream = [streamElement objectForKey:@"content"];
            }
            TFHppleElement *codeElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:audio:embed_code\"]"];
            if(codeElement)
            {
                shareInfo.embed_code = [codeElement objectForKey:@"content"];
            }
        }
        else if([weiboObjectType isEqualToString:@"video"])
        {
            shareInfo.type = EasyShareType_Video;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *durationElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:duration\"]"];
            if(durationElement)
            {
                shareInfo.duration = (unsigned long)[[durationElement objectForKey:@"content"] longLongValue];
            }
            TFHppleElement *streamElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:stream\"]"];
            if(streamElement)
            {
                shareInfo.stream = [streamElement objectForKey:@"content"];
            }
            TFHppleElement *codeElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:video:embed_code\"]"];
            if(codeElement)
            {
                shareInfo.embed_code = [codeElement objectForKey:@"content"];
            }
        }
        else if([weiboObjectType isEqualToString:@"image"])
        {
            shareInfo.type = EasyShareType_Image;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:full_image\"]"];
            if(artworkElement)
            {
                shareInfo.artwork = [artworkElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:image:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"person"])
        {
            shareInfo.type = EasyShareType_Image;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:person:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:person:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:person:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:person:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:person:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"place"])
        {
            shareInfo.type = EasyShareType_Image;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:place:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:place:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            TFHppleElement *posElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:place:position\"]"];
            if(posElement)
            {
                shareInfo.position = [posElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:place:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:place:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"product"])
        {
            shareInfo.type = EasyShareType_Product;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:full_image\"]"];
            if(artworkElement)
            {
                shareInfo.artwork = [artworkElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:product:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"book"])
        {
            shareInfo.type = EasyShareType_Book;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:book:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:book:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:book:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:book:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:book:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *isbnElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:book:isbn\"]"];
            if(isbnElement)
            {
                shareInfo.isbn = [isbnElement objectForKey:@"content"];
            }
        }
        else if([weiboObjectType isEqualToString:@"game"])
        {
            shareInfo.type = EasyShareType_Game;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:full_image\"]"];
            if(artworkElement)
            {
                shareInfo.artwork = [artworkElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:game:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        else if([weiboObjectType isEqualToString:@"app"])
        {
            shareInfo.type = EasyShareType_App;
            titleElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:title\"]"];
            if(titleElement)
            {
                shareInfo.title = [titleElement objectForKey:@"content"];
            }
            descElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:description\"]"];
            if(descElement)
            {
                shareInfo.desc = [descElement objectForKey:@"content"];
            }
            TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:url\"]"];
            if(urlElement)
            {
                shareInfo.url = [urlElement objectForKey:@"content"];
            }
            imageElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:image\"]"];
            if(imageElement)
            {
                shareInfo.image = [imageElement objectForKey:@"content"];
            }
            TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:full_image\"]"];
            if(artworkElement)
            {
                shareInfo.artwork = [artworkElement objectForKey:@"content"];
            }
            TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:create_at\"]"];
            if(createElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
            TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:@"//meta[@name=\"weibo:app:update_at\"]"];
            if(updateElement)
            {
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
            }
        }
        
    }
    
    for (NSString* metaTag in _customtags) {
        //Custom Meta Tag
        TFHppleElement *metaTagElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:type\"]", metaTag]];
        if(metaTagElement)
        {
            shareInfo.resolvedByMeta = TRUE;
            NSString*metatagObjectType = [metaTagElement objectForKey:@"content"];
            
            if([metatagObjectType isEqualToString:@"webpage"])
            {
                shareInfo.type = EasyShareType_Webpage;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:webpage:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:webpage:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:webpage:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:webpage:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:webpage:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:webpage:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"article"])
            {
                shareInfo.type = EasyShareType_Article;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:article:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:article:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:article:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:article:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:article:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:article:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"audio"])
            {
                shareInfo.type = EasyShareType_Audio;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *durationElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:duration\"]", metaTag]];
                if(durationElement)
                {
                    shareInfo.duration = (unsigned long)[[durationElement objectForKey:@"content"] longLongValue];
                }
                TFHppleElement *streamElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:stream\"]", metaTag]];
                if(streamElement)
                {
                    shareInfo.stream = [streamElement objectForKey:@"content"];
                }
                TFHppleElement *codeElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:audio:embed_code\"]", metaTag]];
                if(codeElement)
                {
                    shareInfo.embed_code = [codeElement objectForKey:@"content"];
                }
            }
            else if([metatagObjectType isEqualToString:@"video"])
            {
                shareInfo.type = EasyShareType_Video;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *durationElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:duration\"]", metaTag]];
                if(durationElement)
                {
                    shareInfo.duration = (unsigned long)[[durationElement objectForKey:@"content"] longLongValue];
                }
                TFHppleElement *streamElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:stream\"]", metaTag]];
                if(streamElement)
                {
                    shareInfo.stream = [streamElement objectForKey:@"content"];
                }
                TFHppleElement *codeElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:video:embed_code\"]", metaTag]];
                if(codeElement)
                {
                    shareInfo.embed_code = [codeElement objectForKey:@"content"];
                }
            }
            else if([metatagObjectType isEqualToString:@"image"])
            {
                shareInfo.type = EasyShareType_Image;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:full_image\"]", metaTag]];
                if(artworkElement)
                {
                    shareInfo.artwork = [artworkElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:image:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"person"])
            {
                shareInfo.type = EasyShareType_Image;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:person:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:person:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:person:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:person:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:person:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"place"])
            {
                shareInfo.type = EasyShareType_Image;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:place:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:place:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                TFHppleElement *posElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:place:position\"]", metaTag]];
                if(posElement)
                {
                    shareInfo.position = [posElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:place:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:place:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"product"])
            {
                shareInfo.type = EasyShareType_Product;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:full_image\"]", metaTag]];
                if(artworkElement)
                {
                    shareInfo.artwork = [artworkElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:product:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"book"])
            {
                shareInfo.type = EasyShareType_Book;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:book:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:book:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:book:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:book:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:book:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *isbnElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:book:isbn\"]", metaTag]];
                if(isbnElement)
                {
                    shareInfo.isbn = [isbnElement objectForKey:@"content"];
                }
            }
            else if([metatagObjectType isEqualToString:@"game"])
            {
                shareInfo.type = EasyShareType_Game;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:full_image\"]", metaTag]];
                if(artworkElement)
                {
                    shareInfo.artwork = [artworkElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:game:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            else if([metatagObjectType isEqualToString:@"app"])
            {
                shareInfo.type = EasyShareType_App;
                titleElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:title\"]", metaTag]];
                if(titleElement)
                {
                    shareInfo.title = [titleElement objectForKey:@"content"];
                }
                descElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:description\"]", metaTag]];
                if(descElement)
                {
                    shareInfo.desc = [descElement objectForKey:@"content"];
                }
                TFHppleElement *urlElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:url\"]", metaTag]];
                if(urlElement)
                {
                    shareInfo.url = [urlElement objectForKey:@"content"];
                }
                imageElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:image\"]", metaTag]];
                if(imageElement)
                {
                    shareInfo.image = [imageElement objectForKey:@"content"];
                }
                TFHppleElement *artworkElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:full_image\"]", metaTag]];
                if(artworkElement)
                {
                    shareInfo.artwork = [artworkElement objectForKey:@"content"];
                }
                TFHppleElement *createElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:create_at\"]", metaTag]];
                if(createElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.create = [formatter dateFromString:[[createElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
                TFHppleElement *updateElement = [doc peekAtSearchWithXPathQuery:[NSString stringWithFormat:@"//meta[@name=\"%@:app:update_at\"]", metaTag]];
                if(updateElement)
                {
                    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    shareInfo.update = [formatter dateFromString:[[updateElement objectForKey:@"content"] stringByReplacingOccurrencesOfString:@"T" withString:@" "]];
                }
            }
            
        }
    }
    
    
    if(!shareInfo.desc || [shareInfo.desc length] <= 0)
    {
        TFHppleElement *bodyElement = [doc peekAtSearchWithXPathQuery:@"//body"];
        if(bodyElement)
        {
            NSString* bodyText = [[bodyElement content] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
            if([bodyText isKindOfClass:[NSString class]])shareInfo.desc = [bodyText substringWithRange:NSMakeRange(0, MIN(250, [bodyText length]))];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_block) _block(shareInfo, [self getCostTime], nil);
    });
}
@end

