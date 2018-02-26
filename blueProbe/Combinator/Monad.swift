//
//  Monad.swift
//  blueProbe
//
//  Created by didi on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Runes
func >>- <T, U>(lhs: Parser<T>, rhs: @autoclosure @escaping (T) -> Parser<U>) -> Parser<U> {
    return lhs.flatMap(rhs)
}

func -<< <T, U>(lhs: @autoclosure @escaping (T) -> Parser<U>, rhs: Parser<T>) -> Parser<U> {
    return rhs.flatMap(lhs)
}

extension Parser {
    func flatMap<U>(_ f: @escaping (T) -> Parser<U>) -> Parser<U> {
        return Parser<U> { (tokens) -> Result<(U, Tokens)> in
            //            guard let (l, lrest) = self.parse(tokens) else {
            //                return nil
            //            }
            //            let p = f(l)
            //            return p.parse(lrest)
            
            switch self.parse(tokens) {
            case .success(let (result, rest)):
                let p = f(result)
                return p.parse(rest)
                
            case .failure(let error):
                return .failure(error)
            }
        }
    }
}
