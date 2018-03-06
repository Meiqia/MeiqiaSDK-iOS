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

#ifdef DEBUG
#define FILENAME [[[NSString alloc] initWithUTF8String:__FILE__] lastPathComponent]
#define MQInfo(str,...) NSLog(@"[%@,%d]↓↓",FILENAME, __LINE__);NSLog(str,##__VA_ARGS__);
#define MQError(str,...) NSLog(@"[*ERROR*][%@,%d]☟☟",FILENAME, __LINE__);NSLog(str,##__VA_ARGS__);
#else
#define MQInfo(str,...)
#define MQError(str,...)
#endif