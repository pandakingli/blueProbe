//
//  GoMaker.swift
//  blueProbe
//
//  Created by biubiu on 2018/2/26.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Foundation
import Cocoa


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
            let alert:NSAlert = NSAlert()
            alert.messageText = "Error: missing command: /usr/bin/which！"
            alert.alertStyle = NSAlert.Style.informational
            alert.runModal()

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
            let alert:NSAlert = NSAlert()
            alert.messageText = "Error: '\(executable)' not exist! \(help)"
            alert.alertStyle = NSAlert.Style.informational
            alert.runModal()
            return ""
        }
        
        let process = Process()
        process.launchPath = path
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
    private let process: Process
    
    init(process: Process) {
        self.process = process
        
        let pipe = Pipe()
        self.process.standardOutput = pipe
        outputHandle = pipe.fileHandleForReading
    }
    
    func launch() {
        process.launch()
        process.waitUntilExit()
    }
    
    lazy var stdout: String = {
        let data = outputHandle.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }()
}
