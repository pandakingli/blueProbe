//
//  Functor.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Runes


func <^> <T, U>(f: @escaping (T) -> U, p: Parser<T>) -> Parser<U> {
    return p.bluemap(f)
}
/*
extension Parser {
    func map<U>(_ f: @escaping (T) -> U) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
            let r = self.parse(tokens)
            switch r {
            case .success(let (result, rest)):
                return .success((f(result), rest))
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
*/
