//
//  GoMaker.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation


class GoMaker {
    
    // MARK: - Public
    
    /// 执行Shell指令
    ///
    /// - Parameters:
    ///   - executable: 可执行文件的名称
    ///   - args:       参数
    ///   - help:       失败时附加的信息
    /// - Returns:      执行结果输出
    @discardableResult
    static func execute(_ executable: String, _ args: String..., help: String = "") -> String {
        // check which
        guard FileManager.default.fileExists(atPath: "/usr/bin/which") else {
            print("Error: missing command: /usr/bin/which")
            return ""
        }
        
        // 查找可执行文件的路径
        func pathForExecutable(executable: String) -> String? {
            guard !executable.contains("/") else {
                return executable
            }
            
            if executable == "dot"||executable == "fdp"||executable == "neato"||executable == "twopi"||executable == "circo"||executable == "sfdp" 
            {
                return "/usr/local/bin/"+executable
            }
            
            let path = GoMaker.execute("/usr/bin/which", executable)
            return path.isEmpty ? nil : path
        }
        
        guard let path = pathForExecutable(executable: executable) else {
            print("Error: '\(executable)' not exist! \(help)")
            return ""
        }
 
        
        let process = Process()
        process.launchPath = path//"/usr/local/bin/dot" // path
        process.arguments = args
        
        let command = Command(process: process)
        command.launch()
        
        // 如果结果只有一行, 去掉最后的回车
        var output = command.stdout
        let firstnewline = output.index(of: "\n")
        if firstnewline == nil || output.index(after: firstnewline!) == output.endIndex {
            output = output.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return output
    }
}

fileprivate class Command {
    
    private let outputHandle: FileHandle
    private let erroutputHandle: FileHandle
    private let process: Process
    private var outstring:String
    
    init(process: Process) {
        self.process = process
        self.outstring = ""
        let pipe = Pipe()
        let errpipe = Pipe()
        self.process.standardOutput = pipe
        self.process.standardError = errpipe
        
        outputHandle = pipe.fileHandleForReading
        erroutputHandle = errpipe.fileHandleForReading
    }
    
    func launch() {
        process.launch()
         process.waitUntilExit()
        let data = outputHandle.readDataToEndOfFile()
        
        let errdata = erroutputHandle.readDataToEndOfFile()
        
            //outputHandle.readDataToEndOfFile()
       // outpipe.fileHandleForReading.availableData
        outstring =  String(data: data, encoding: .utf8) ?? ""
        
       
    }
    
    lazy var stdout: String = {
        //let data = outputHandle.readDataToEndOfFile()
        //return String(data: data, encoding: .utf8) ?? ""
        
        return self.outstring
    }()
}
