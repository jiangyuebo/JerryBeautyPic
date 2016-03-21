//
//  Header.h
//  JerryBeautyPic
//
//  Created by Jerry on 16/3/21.
//  Copyright © 2016年 Jerry. All rights reserved.
//

#ifndef Header_h
#define Header_h

#define tableViewCell @"tableCell"
#define leftPicNumber 2

#define TAG_BEAUTY @"meinv"
#define TAG_LEG @"meitui"
#define TAG_SWIM_SUIT @"yongyi"
#define TAG_TIGHT @"jinshen"
#define TAG_ASS @"meitun"

#define DIRECTION_UP 0
#define DIRECTION_DOWN -1

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* Header_h */
