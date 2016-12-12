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

#define favoriteCell @"favoriteCell"

#define DIR_NAME_IMAGES @"favorites"

#define TAG_BEAUTY @"1"
#define TAG_LEG @"2"
#define TAG_SWIM_SUIT @"3"
#define TAG_TIGHT @"4"
#define TAG_ASS @"5"
#define TAG_SPORT @"6"

#define DIRECTION_UP 0
#define DIRECTION_DOWN -1

#define MAC_FAVORITE 10

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* Header_h */
