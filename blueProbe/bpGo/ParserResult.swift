//
//  ParserResult.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
enum Result<T> {
    case success(T)
    case failure(ParserError)
}

// MARK: - Unbox

extension Result {
    
    /// 可选值，如果解析成功返回结果，解析失败返回nil
    var value: T? {
        switch self {
        case .success(let t):
            return t
        case .failure(_):
            return nil
        }
    }
    
    /// 可选值，如果解析失败返回错误原因，解析成功返回nil
    var error: ParserError? {
        switch self {
        case .success(_):
            return nil
        case .failure(let error):
            return error
        }
    }
}
