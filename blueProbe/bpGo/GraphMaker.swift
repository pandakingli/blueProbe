//
//  GraphMaker.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation


/// 遍历AST并生成dot
class GraphMaker {
    
    // MARK: - Public
    
    /// 在当前位置生成类图
    ///
    /// - Parameters:
    ///   - clsNodes:  类型节点数据
    ///   - protocols: 协议节点数据
    ///   - filePath:  路径，作为结果图片命名的前缀
    @discardableResult
    static func generate(classes clsNodes: [BPClassNode], protocols: [BPProtocolNode], filePath: String) -> String {
        let dot = GraphMaker()
        var nodesSet = Set<String>()
        
        dot.begin(name: "Inheritance")
        
        // class node
        for cls in clsNodes {
            // 类节点
            if !nodesSet.contains(cls.klassName) {
                nodesSet.insert(cls.klassName)
                dot.append(cls, label: "\(cls.klassName)")
            }
            
            for proto in cls.kprotocols {
                if !nodesSet.contains(proto) {
                    nodesSet.insert(proto)
                    dot.append(proto, label: "<<protocol>>\n\(proto)")
                }
                dot.point(from: cls, to: proto, emptyArrow: true, dashed: true)
            }
            
            // 父类
            if let superCls = cls.superKlass {
                if !nodesSet.contains(superCls) {
                    nodesSet.insert(superCls)
                    dot.append(superCls, label: superCls)
                }
                dot.point(from: cls, to: superCls, emptyArrow: true)
            }
        }
        
        // 剩余的Protocol
        for proto in protocols {
            if !nodesSet.contains(proto.name) {
                nodesSet.insert(proto.name)
                dot.append(proto, label: "<<protocol>>\n\(proto.name)")
            }
        }
        
        dot.end()
        
        return dot.create(file: filePath)
    }
    

    
    
    // MARK: - Private
    
    fileprivate var dot: String = ""
    
    fileprivate func create(file filePath: String) -> String {
        // 写入文件
       // let filename = URL(fileURLWithPath: filePath).lastPathComponent
       let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var showtimestr = timeFormatter.string(from: date as Date) as String
        
        let dotFile = "\(filePath+showtimestr).dot"
        let target = "\(filePath+showtimestr).png"
        
        // 创建Dot文件
        if FileManager.default.fileExists(atPath: dotFile) {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        }
        _ = FileManager.default.createFile(atPath: dotFile, contents: dot.data(using: .utf8), attributes: nil)
        
        // 生成png
        GoMaker.execute("dot", "-T", "png", dotFile, "-o", "\(target)", help: "Make sure Graphviz is successfully installed.")
        
        // 删除.dot文件
        //try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        
        return target
    }
}

// MARK: - GraphMaker Method

fileprivate extension GraphMaker {
    
    func begin(name: String) {
        dot.append(contentsOf: "digraph \(name) { node [shape=\"record\"];")
    }
    
    func end() {
        dot.append(contentsOf: "}")
    }
    
    func append<T: Hashable>(_ node: T, label: String) {
        var escaped = label
        escaped = escaped.replacingOccurrences(of: "->", with: "\\-\\>")
        escaped = escaped.replacingOccurrences(of: "<", with: "\\<")
        escaped = escaped.replacingOccurrences(of: ">", with: "\\>")
        
        dot.append(contentsOf: "\(node.hashValue) [label=\"\(escaped)\"];")
    }
    
    func point<T: Hashable, A: Hashable>(from: T, to: A, emptyArrow: Bool = false, dashed: Bool = false) {
        var style = ""
        if emptyArrow {
            style.append(contentsOf: "arrowhead = \"empty\" ")
        }
        if dashed {
            style.append(contentsOf: "style=\"dashed\"")
        }
        
        if !style.isEmpty {
            dot.append(contentsOf: "\(from.hashValue)->\(to.hashValue) [\(style)];")
        } else {
            dot.append(contentsOf: "\(from.hashValue)->\(to.hashValue);")
        }
    }
}
