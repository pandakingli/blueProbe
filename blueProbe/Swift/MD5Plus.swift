//
//  MD5Plus.swift
//  blueProbe
//
//  Created by lining on 2018/4/3.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import SwiftHash

public func IDA_MD5(_ input: String) -> String {
    
    return "D" + MD5(input)
}

