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
    static func generate(classes clsNodes: [BPClassNode], protocols: [BPProtocolNode], filePath: String, styleStr: String, outStr: String) -> String {
        let dot = GraphMaker()
        var nodesSet = Set<String>()
        
        
        
        
        
        dot.begin(name: "Inheritance")
         let center = BPSettingCenter.sharedInstance
        
        
        
        
        // class node
        for cls in clsNodes {
            // 类节点
            if !nodesSet.contains(cls.klassName) {
                nodesSet.insert(cls.klassName)
                dot.append(cls, label: "\(cls.klassName)")
            }
            
           
            if center.haveProtocols
            {
                for proto in cls.kprotocols {
                    if !nodesSet.contains(proto) {
                        nodesSet.insert(proto)
                        dot.append(proto, label: "<<protocol>>\n\(proto)")
                    }
                    dot.point(from: cls, to: proto, emptyArrow: true, dashed: true)
                }
                
               
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
        
        if center.haveProtocols
        {
            // 剩余的Protocol
            for proto in protocols {
                if !nodesSet.contains(proto.name) {
                    nodesSet.insert(proto.name)
                    dot.append(proto, label: "<<protocol>>\n\(proto.name)")
                }
            }
        }
        
        
        dot.end()
        
        return dot.create(file: filePath, styleStr: styleStr, outStr: outStr)
    }
    
    //Swift3.0 iOS获取当前时间 - 年月日时分秒星期
    
    func getTimes() -> [Int] {
        
        var timers: [Int] = [] //  返回的数组
        
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
        
        timers.append(comps.year! % 2000)  // 年 ，后2位数
        timers.append(comps.month!)            // 月
        timers.append(comps.day!)                // 日
        timers.append(comps.hour!)               // 小时
        timers.append(comps.minute!)            // 分钟
        timers.append(comps.second!)            // 秒
        timers.append(comps.weekday! - 1)      //星期
        
        return timers;
    }
    
    
    func getTimeString() -> String {
        
        var timeStr = String()
        
        let calendar: Calendar = Calendar(identifier: .gregorian)
        var comps: DateComponents = DateComponents()
        comps = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
        
        timeStr.append("\(comps.year!)")
        timeStr.append("-"+"\(comps.month!)")
        timeStr.append("-"+"\(comps.day!)")
        timeStr.append("-"+"\(comps.hour!)")
        timeStr.append("\(comps.minute!)")
        timeStr.append("\(comps.second!)")
        
        
        return timeStr;
    }

    
    
    // MARK: - Private
    
    fileprivate var dot: String = ""
    
    fileprivate func create(file filePath: String, styleStr: String, outStr: String) -> String {
        // 写入文件
       // let filename = URL(fileURLWithPath: filePath).lastPathComponent
       let date = NSDate()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let showtimestr = timeFormatter.string(from: date as Date) as String
        
        let datetimeStr = self.getTimeString()
        
        let dotFile = "\(filePath+datetimeStr).dot"
        let target = "\(filePath+datetimeStr)."+outStr
        
        // 创建Dot文件
        if FileManager.default.fileExists(atPath: dotFile) {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        }
        _ = FileManager.default.createFile(atPath: dotFile, contents: dot.data(using: .utf8), attributes: nil)
        
        // 生成png
        GoMaker.execute(styleStr, "-T", outStr, dotFile, "-o", "\(target)", help: "Make sure Graphviz is successfully installed.")
        
        // 删除.dot文件
        //try? FileManager.default.removeItem(at: URL(fileURLWithPath: dotFile))
        
        return target
    }
}

// MARK: - GraphMaker Method

fileprivate extension GraphMaker {
    
    func begin(name: String) {
        dot.append(contentsOf: "digraph \(name) { node [shape=\"record\"];"+"rankdir ="+BPSettingCenter.sharedInstance.tblr+";")
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
