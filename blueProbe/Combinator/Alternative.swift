//
//  Alternative.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Runes
/// 左侧parser成功返回左侧的结果，否则返回右侧parser的结果
func <|> <T>(lhs: Parser<T>, rhs: Parser<T>) -> Parser<T> {
    return lhs.or(rhs)
}

extension Parser {
    func or(_ other: Parser<T>) -> Parser<T> {
        return Parser(parse: { (tokens) -> Result<(T, Tokens)> in
            let r = self.parse(tokens)
            switch r {
            case .success(_):
                return r
            case .failure(_):
                return other.parse(tokens) // 左侧失败时不消耗输入
            }
        })
    }
}
