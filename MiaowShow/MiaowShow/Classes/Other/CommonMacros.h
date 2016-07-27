//
//  CommonMacros.h
//  MiaowShow
//
//  Created by 钟武 on 16/7/27.
//  Copyright © 2016年 ALin. All rights reserved.
//

#ifndef CommonMacros_h
#define CommonMacros_h

#define WEAK_REF(self) \
__block __weak typeof(self) self##_ = self; (void) self##_;

#define STRONG_REF(self) \
__block __strong typeof(self) self##_ = self; (void) self##_;

#endif /* CommonMacros_h */
