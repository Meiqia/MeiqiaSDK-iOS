//
//  MQLog.h
//  MeiQiaSDK
//
//  Created by ian luo on 16/6/1.
//  Copyright © 2016年 MeiQia Inc. All rights reserved.
//


#ifndef MQLog_h
#define MQLog_h

#endif /* MQLog_h */

static BOOL MQIsLogEnabled = NO; //发布时默认关闭NO
#define FILENAME [[[NSString alloc] initWithUTF8String:__FILE__] lastPathComponent]

#define MQInfo(str, ...) {\
if(MQIsLogEnabled){\
NSLog(@"MeiQia [%@,%d]↓↓", FILENAME, __LINE__); \
NSLog(str, ##__VA_ARGS__);\
}\
}

#define MQError(str, ...){\
if(MQIsLogEnabled){\
NSLog(@"MeiQia [*ERROR*][%@,%d]☟☟", FILENAME, __LINE__); \
NSLog(str, ##__VA_ARGS__);\
}\
}
