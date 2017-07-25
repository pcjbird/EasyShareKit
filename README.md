![logo](logo.png)
[![Build Status](http://img.shields.io/travis/pcjbird/EasyShareKit/master.svg?style=flat)](https://travis-ci.org/pcjbird/EasyShareKit)
[![Pod Version](http://img.shields.io/cocoapods/v/EasyShareKit.svg?style=flat)](http://cocoadocs.org/docsets/EasyShareKit/)
[![Pod Platform](http://img.shields.io/cocoapods/p/EasyShareKit.svg?style=flat)](http://cocoadocs.org/docsets/EasyShareKit/)
[![Pod License](http://img.shields.io/cocoapods/l/EasyShareKit.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Dependency Status](https://www.versioneye.com/objective-c/EasyShareKit/badge.svg?style=flat)](https://www.versioneye.com/objective-c/EasyShareKit)

# EasyShareKit

### Easy way to parse share info from H5 page. 一种从 H5 页面获取分享数据的简便的方法。

## 什么是 H5 元标记（H5 Meta Tags）

H5 元标记，即 H5 Meta Tags，对 Open graph 协议下的常规 meta tag 进行支持和兼容，并基于国情对 OpenGraph 不适用的对象类型或属性进行有限扩展标记。可以和 OpenGraph 一起使用。

## 为什么要配置 H5 Meta Tags

传统互联网信息单元往往以 Web Page 为单位，以 URL 为线索进行索引和流转。通过定义 H5 Meta Tags，可以穿透 Web Page，准确索引互联网上的 Object，对互联网上的物体进行格式化管理。拥有格式化的 Object 数据，就可以为用户提供灵活、扩展性强、易读的内容展示模块。

## 如何定义对象（Object）类型？赞组件支持哪些对象（Object）类型？

假定我们自定义的 H5 元标记为 <font color=#f99157>**MyProject**</font> , 以下依次作为示例，您可以根据您自己的项目自定义 H5 元标记。

* 定义方式：

```
<meta property="og:type" content="对象类型" />
```

或

```
<meta name="MyProject:type" content="对象类型" />
```

定义对象类型后，通过查询对象属性表，定义对象详细属性信息。

* 赞组件支持的对象类型如下： 网页（webpage）、文章（article）、音频（audio）、图片（image）、人（person）、地点（place）、产品（product）、视频（video）、书（book）、游戏（game）、应用（app）

## 如何定义 H5 Meta Tags

假定我们自定义的 H5 元标记为 <font color=#f99157>**MyProject**</font> , 以下依次作为示例，您可以根据您自己的项目自定义 H5 元标记。

找到适合您网页的对象类型，通过对象属性表查询并设定属性值，详细的设定将带来更好的效果，最后将代码放入head中即可，下面列举两个部署实例进行说明

【视频】对象Meta代码实例：//必填

```
<meta property="og:type" content="video" />
<meta property="og:url" content="http://video.sina.com.cn/v/b/93544804-2282043583.html" />
<meta property="og:title" content="微博UDC圣诞贺岁视频首发" />
<meta property="og:description" content="【微博UDC圣诞贺岁视频首发！---微博带你分享微快乐！】还有几个小时，圣诞节就要到啦！末日后的第一个圣诞大家准备怎样度过呢？2012我要新花样！！！！~赶快动手制作一个圣诞 pinhole camera!! 和你最亲近的那个TA一起分享微快乐吧！！！" />
//选填
<meta property="og:image" content="http://ww2.sinaimg.cn/bmiddle/880538bfjw1e04w8ktfakj.jpg " />
<meta name="MyProject:video:embed_code" content="http://you.video.sina.com.cn/api/sinawebApi/outplayrefer.php/vid=93544804_2282043583_OB21THcwCDTK+l1lHz2stqkP7KQNt6nni2K2u1anIAZaQ0/XM5GQYdgD5CHWBNkEqDhATZs6cfou1xk/s.swf" />
<meta name="MyProject:video:stream" content="" />
<meta name="MyProject:video:duration" content="47" />
<meta name="MyProject:video:create_at" content="2012-12-24 16:26:05" />
<meta name="MyProject:video:update_at" content="2012-12-24 16:26:05" />
```

以上代码使用OpenGraph 和MyProject Meta Tags混合方式， MyProject Meta Tags目前支持五个OpenGraph基础属性，即

```
<meta property="og:type" content="类型" />
<meta property="og:url" content="URL地址" />
<meta property="og:title" content="标题" />
<meta property="og:image" content="图片" />
<meta property="og:description" content="描述" />
```

以上OG属性可与MyProject Meta Tags属性直接互通使用。 完全使用MyProject Meta Tag代码格式实例如下：//必填

```
<meta name ="MyProject:type" content="video" />
<meta name ="MyProject:video:url" content="视频的URL地址" />
<meta name ="MyProject:video:title" content="视频的显示名称" />
<meta name ="MyProject:video:description" content="视频的文字描述" />
//选填
<meta name ="MyProject:video:image" content="视频的缩略显示图片" />
<meta name="MyProject:video:embed_code" content="视频播放的嵌入代码" />
<meta name="MyProject:video:duration" content="视频播放的时长，单位秒" />
<meta name="MyProject:video:stream" content="视频流的链接源" />
<meta name="MyProject:video:create_at" content="用户的创建时间" />
<meta name="MyProject:video:update_at" content="用户的更新时间" />
``` 

【网页】对象Meta代码实例：//必填

```
<meta property="og:type" content="webpage" />
<meta property="og:url" content="http://sports.sina.com.cn/nba/2012-12-26/06576353009.shtml" />
<meta property="og:title" content="圣诞战总得分王!科比34+5写历史 暴强数据16年第2" />
<meta property="og:description" content="科比-布莱恩特不出意料地拿下34分并成为了圣诞大战史上得分王，不仅如此，这位34岁的神已连续9场比赛得分30+，创造了个人生涯第二好成绩并向着2003年连续16场的壮举继续迈进！" />
//选填
<meta property="og:image" content="http://i2.sinaimg.cn/ty/nba/2012-12-26/U4934P6T12D6353009F1286DT20121226070232.jpg" />
<meta name="MyProject:webpage:create_at" content="2012-12-26 06:57:00" />
<meta name="MyProject:webpage:update_at" content="2012-12-26 06:57:00" />
```

## 严格定义与非严格定义

下面A与B两种格式，其中A为严格定义，B为非严格定义，区别就在于非严格定义可省略中间段。

```
A） MyProject:video:embed_code
B） MyProject:embed_code
```

当明确定义了type对象类型时，可使用非严格定义，所有属性均会被识别为当前定义类 型；否则将不被识别。建议严格定义。

## 单个属性的多值定义

单个属性的多值定义即对某个对象属性（即标记）可同时赋予多个不同值，属性值根据表现层产品需要按顺序显示。

方法：每行定义一个属性，需要 meta 标签，同样的属性以及不同的赋值，按顺序逐行定义。示例：
image 属性定义多个值，即多张图片

```
<meta property="og:image" content="示例图片1" />
<meta property="og:image" content="示例图片2 " />
<meta property="og:image" content="示例图片3" />
<meta name="MyProject:webpage:image" content="图片示例4" />
<meta name="MyProject:webpage:image" content="图片示例5" />
```

注1：目前此方法仅对所有对象类型image属性开放，其它属性暂不支持。

注2：image属性多值定义目前可用于分享窗口预置图片。


## 对象（object）详细属性表

#### 网页（webpage）


| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | webpage，对象类型 |
| MyProject:webpage:url | string | 必填 | og:url | 网页的URL地址 |
| MyProject:webpage:title | string | 必填 | og:title | 网页的显示名称标题 |
| MyProject:webpage:description | string | 必填 | og:description | 网页的文字描述 |
| MyProject:webpage:image | string |  | og:image | 网页的显示图片 |
| MyProject:webpage:create_at | date time |  |  | 网页的创建时间 |
| MyProject:webpage:update_at | date time |  |  | 网页的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="webpage" />
<meta property="og:url" content="网页唯一URL地址" />
<meta property="og:title" content="网页标题" />
<meta property="og:description" content="网页描述" />
```

//选填

```
<meta property="og:image" content="网页的显示图片" />
<meta name="MyProject:webpage:create_at" content="网页的创建时间" />
<meta name="MyProject:webpage:update_at" content="网页的更新时间" />
```

#### 文章（article）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | article，对象类型 |
| MyProject:article:url | string | 必填 | og:url | 文章的URL地址 |
| MyProject:article:title | string | 必填 | og:title | 文章的显示名称标题 |
| MyProject:article:description | string | 必填 | og:description | 文章的文字描述 |
| MyProject:article:image | string |  | og:image | 文章的显示图片 |
| MyProject:article:create_at | date time |  |  | 文章的创建时间 |
| MyProject:article:update_at | date time |  |  | 文章的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="article" />
<meta property="og:url" content="文章的URL地址" />
<meta property="og:title" content="文章的显示名称标题" />
<meta property="og:description" content="文章的文字描述" />
```

//选填

```
<meta property="og:image" content="文章的显示图片" />
<meta name="MyProject:article:create_at" content="文章的创建时间" />
<meta name="MyProject:article:update_at" content="文章的更新时间" />
```


#### 音频（audio）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | audio，对象类型 |
| MyProject:audio:url | string | 必填 | og:url | 音频的落地页URL地址 |
| MyProject:audio:title | string | 必填 | og:title | 音频的显示名称 |
| MyProject:audio:description | string | 必填 | og:description | 音频的文字描述 |
| MyProject:audio:image | string |  | og:image | 音频的显示图片 |
| MyProject:audio:embed_code | string |  |  | 音频播放的嵌入代码 |
| MyProject:audio:stream | string |  |  | 音频流的链接源 |
| MyProject:audio:duration | string |  |  | 音频播放的时长，秒 |
| MyProject:audio:create_at | date time |  |  | 音频的创建时间 |
| MyProject:audio:update_at | date time |  |  | 音频的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="audio" />
<meta property="og:url" content="音频的落地页URL地址" />
<meta property="og:title" content="音频的显示名称" />
<meta property="og:description" content="音频的文字描述" />
```

//选填

```
<meta property="og:image" content="音频的显示图片" />
<meta name="MyProject:audio:embed_code" content="音频播放的HTML嵌入代码" />
<meta name="MyProject:audio:stream" content="音频流的链接源" />
<meta name="MyProject:audio:duration" content="音频播放的时长，秒" />
<meta name="MyProject:audio:create_at" content="音频的创建时间" />
<meta name="MyProject:audio:update_at" content="音频的更新时间" />
```

#### 视频（video）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | video，对象类型 |
| MyProject:video:url | string | 必填 | og:url | 视频的URL地址 |
| MyProject:video:title | string | 必填 | og:title | 视频的显示名称 |
| MyProject:video:description | string | 必填 | og:description | 视频的文字描述 |
| MyProject:video:image | string |  |  og:image | 视频的显示图片 |
| MyProject:video:embed_code | string | |  |  视频播放的嵌入代码 |
| MyProject:video:stream | string | |  |  视频流的链接源 |
| MyProject:video:duration | string | |  | 视频播放的时长，秒 |
| MyProject:video:create_at | date time | |  |  视频的创建时间 |
| MyProject:video:update_at | date time | |  |  视频的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="video" />
<meta property="og:url" content="视频的URL地址" />
<meta property="og:title" content="视频的显示名称" />
<meta property="og:description" content="视频的文字描述" />
```

//选填

```
<meta property="og:image" content="视频的显示图片" />
<meta name="MyProject:video:embed_code" content="视频播放的HTML嵌入代码" />
<meta name="MyProject:video:stream" content="视频流的链接源" />
<meta name="MyProject:video:duration" content="视频播放的时长，秒" />
<meta name="MyProject:video:create_at" content="视频的创建时间" />
<meta name="MyProject:video:update_at" content="视频的更新时间" />
```

#### 图片（image
| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | image，对象类型 |
| MyProject:image:url | string | 必填 | og:url | 图片的URL地址 |
| MyProject:image:title | string | 必填 | og:title | 图片的显示名称 |
| MyProject:image:description | string | 必填 | og:description | 图片的文字描述 |
| MyProject:image:image | string |  | og:image | 图片的缩略显示图 |
| MyProject:image:full_image | string | |  og:image | 图片的原始大图 |
| MyProject:image:create_at | date time |  |  | 图片的创建时间 |
| MyProject:image:update_at | date time |  |  | 图片的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="image" />
<meta property="og:url" content="图片的URL地址" />
<meta property="og:title" content="图片的显示标题" />
<meta property="og:description" content="图片的文字描述" />
```

//选填

```
<meta property="og:image" content="图片的缩略显示图" />
<meta property="MyProject:image:full_image" content="图片的原始大图" />
<meta name="MyProject:image:create_at" content="图片的创建时间" />
<meta name="MyProject:image:update_at" content="图片的更新时间" />
```
说明：`og:image`参数对应`MyProject:image:image`（缩略图）和`MyProject:image:full_image`（原始大图），若需要区分缩略图与原始大图，请分别设定`MyProject:image:image` 和`MyProject:image:full_image`，`MyProject`标记会覆盖`og`标记。

#### 人（person）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | person，对象类型 |
| MyProject:person:url | string | 必填 | og:url | 用户的URL地址 |
| MyProject:person:title | string | 必填 | og:title | 用户账号的显示名称 |
| MyProject:person:image | string |  | og:image | 用户的显示头像 |
| MyProject:person:create_at | date time |  |  | 用户的创建时间 |
| MyProject:person:update_at | date time |  |  | 用户的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="person" />
<meta property="og:url" content="用户的URL地址" />
<meta property="og:title" content="用户账号的显示名称" />
```
//选填

```
<meta property="og:image" content="用户的显示头像" />
<meta name="MyProject:person:create_at" content="用户的创建时间" />
<meta name="MyProject:person:update_at" content="用户的更新时间" />
```

#### 地点（place）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | place，对象类型 |
| MyProject:place:url | string | 必填 | og:url | 地理位置的URL地址 |
| MyProject:place:title | string | 必填 | og:title | 地理位置的显示名称 |
| MyProject:place:position | string | 必填  |  | 地理位置的坐标，经+纬+海拔 |
| MyProject:place:create_at | date time  | | | 创建时间 |
| MyProject:place:update_at | date time | | | 更新时间 |

代码示例：//必填

```
<meta property="og:type" content="place" />
<meta property="og:url" content="地理位置的URL地址" />
<meta property="og:title" content="地理位置的显示名称" />
<meta property="MyProject:place:position" content="地理位置的坐标，经+纬+海拔，符合ISO6709" />
```

#### 产品（product）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | product，对象类型 |
| MyProject:product:url | string | 必填 | og:url | 商品的URL地址 |
| MyProject:product:title | string | 必填 | og:title | 商品的显示名称标题 |
| MyProject:product:description | string | 必填 | og:description | 商品的文字描述 |
| MyProject:product:image | string |  | og:image | 商品的缩略显示图 |
| MyProject:product:full_image | string |  | og:image | 商品的原始大图 |
| MyProject:product:create_at | date time |  |  | 商品的创建时间 |
| MyProject:product:update_at | date time |  |  | 商品的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="product" />
<meta property="og:url" content="商品的URL地址" />
<meta property="og:title" content="商品的显示名称标题" />
<meta property="og:description" content="商品的文字描述" />
```
//选填

```
<meta property="og:image" content="商品的缩略显示图" />
<meta name="MyProject:product:full_image" content="商品的原始大图" />
<meta name="MyProject:product:create_at" content="商品的创建时间" />
<meta name="MyProject:product:update_at" content="商品的更新时间" />
```
说明：`og:image` 参数对应 `MyProject:product:image`（缩略图）和`MyProject:product:full_image`（原始大图），若需要区分缩略图与原始大图，请分别设定`MyProject:product:image` 和 `MyProject:product:full_image`，`MyProject` 标记会覆盖 `og` 标记。

#### 书（book）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | book，对象类型 |
| MyProject:book:url | string | 必填 | og:url | 书的URL地址 |
| MyProject:book:title | string | 必填 | og:title | 书的显示名称 |
| MyProject:book:description | string | 必填 | og:description | 书的文字描述 |
| MyProject:book:image | string |  | og:image | 书的显示图片 |
| MyProject:book:isbn | string |  |  | 10或13位数字的ISBN书号 |
| MyProject:book:create_at | date time |  |  | 书的出版时间 |

代码示例：//必填

```
<meta property="og:type" content="book" />
<meta property="og:url" content="书的URL地址" />
<meta property="og:title" content="书的显示名称" />
<meta property="og:description" content="书的文字描述" />
```
//选填

```
<meta property="og:image" content="书的显示图片" />
<meta name="MyProject:book:isbn" content="书的10或13位数字的ISBN书号" />
<meta name="MyProject:video:create_at" content="书的出版时间" />
```

#### 游戏（game）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | game，对象类型 |
| MyProject:game:url | string | 必填 | og:url | 游戏的URL地址 |
| MyProject:game:title | string | 必填 | og:title | 游戏的显示名称标题 |
| MyProject:game:description | string | 必填 | og:description | 游戏的文字描述 |
| MyProject:game:image | string | |  og:image | 游戏的缩略显示图 |
| MyProject:game:full_image | string |  | og:image | 游戏的原始大图 |
| MyProject:game:create_at | date time |  |  | 游戏的创建时间 |
| MyProject:game:update_at | date time |  |  | 游戏的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="game" />
<meta property="og:url" content="游戏的URL地址" />
<meta property="og:title" content="游戏的显示名称标题" />
<meta property="og:description" content="游戏的文字描述" />
```
//选填

```
<meta property="og:image" content="游戏的缩略显示图" />
<meta name="MyProject:game:image" content="游戏的原始大图" />
<meta name="MyProject:game:full_image" content="游戏的原始大图" />
<meta name="MyProject:game:create_at" content="游戏的创建时间" />
<meta name="MyProject:game:update_at" content="游戏的更新时间" />
```
说明： `og:image` 参数对应 `MyProject:game:image` （缩略图）和 `MyProject:game:full_image` （原始大图），若需要区分缩略图与原始大图，请分别设定 `MyProject:game:image` 和 `MyProject:game:full_image` ， `MyProject` 标记会覆盖 `og` 标记。

#### 应用（app）

| H5 Meta Tags | 数据类型 | 是否必填 | OpenGraph | 说明 |
| :-: | :-: | :-: | :-: | :-: |
| MyProject:type | string | 必填 | og:type | app，对象类型 |
| MyProject:app:url | string | 必填 | og:url | 应用的URL地址 |
| MyProject:app:title | string | 必填 | og:title | 应用的显示名称标题 |
| MyProject:app:description | string | 必填 | og:description | 应用的文字描述 |
| MyProject:app:image | string |  | og:image | 应用的显示缩略图 |
| MyProject:app:full_image | string |  | og:image | 应用的原始大图 |
| MyProject:app:create_at | date time |  |  | 应用的创建时间 |
| MyProject:app:update_at | date time |  |  | 应用的更新时间 |

代码示例：//必填

```
<meta property="og:type" content="app" />
<meta property="og:url" content="应用的URL地址" />
<meta property="og:title" content="应用的显示名称标题" />
<meta property="og:description" content="应用的文字描述" />
```
//选填

```
<meta property="og:image" content="应用的显示缩略图" />
<meta name="MyProject:app:full_image" content="应用的原始大图" />
<meta name="MyProject:app:create_at" content="应用的创建时间" />
<meta name="MyProject:app:update_at" content="应用的更新时间" />
```
说明： `og:image` 参数对应`MyProject:app:image`（缩略图）和 `MyProject:app:full_image`（原始大图），若需要区分缩略图与原始大图，请分别设定 `MyProject:app:image` 和 `MyProject:app:full_image`，`MyProject` 标记会覆盖 `og` 标记。

## 关注我们 / Follow us

<a href="https://itunes.apple.com/cn/app/iclock-simplest-always-best/id1128196970?pt=117947806&ct=com.github.pcjbird.EasyShareKit&mt=8"><img src="iClock.png" width="686" title="iClock - 一款满足“挑剔”的翻页时钟与任务闹钟"></a>

<a href="https://itunes.apple.com/cn/app/%E8%90%8C%E9%B1%BC%E8%BE%A8%E8%89%B2-%E4%B8%80%E6%AC%BE%E6%9C%89%E8%B6%A3%E7%9A%84%E9%A2%9C%E8%89%B2%E8%AF%86%E5%88%AB%E4%B8%8E%E4%BB%A3%E7%A0%81%E7%94%9F%E6%88%90%E5%B7%A5%E5%85%B7/id1234015415?pt=117947806&ct=com.github.pcjbird.EasyShareKit&mt=8"><img src="Color Sniffer.png" width="686" title="Color Sniffer - 一款有趣的颜色识别与代码生成工具"></a>

<a href="https://itunes.apple.com/cn/app/iclock-simplest-always-best/id1128196970?pt=117947806&ct=com.github.pcjbird.EasyShareKit&mt=8"><img src="iClock_appinn.png" title="iClock - 一款满足“挑剔”的翻页时钟与任务闹钟"></a>

[![Twitter URL](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=https://github.com/pcjbird/EasyShareKit)
[![Twitter Follow](https://img.shields.io/twitter/follow/pcjbird.svg?style=social)](https://twitter.com/pcjbird)
