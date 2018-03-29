//
//  BPSettingCenter.swift
//  blueProbe
//
//  Created by lining on 2018/3/13.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Cocoa

let kSavePathBPS = "kSavePathBPS"

class BPSettingCenter: NSObject {

    var objcNum : NSInteger = 0
    var swiftNum : NSInteger = 0
    var startTime = NSDate()
    var endTime = NSDate()
    
    var mainWindowC :MainWC = MainWC()
    var mode: makeBPMode = .inheritGO
    var keyClassName: String? = nil
    /// dot还是neato 等
    var styleType: String = "dot"
    
    /// 输出文件的格式 pdf,svg,png等
    var outPutFile: String = "svg"
    
    /// 方向：TB：上下，LR：左右
    var tblr: String = "TB"
    
    /// 是否带协议
    var haveProtocols: Bool = false
    
    var filterSet:NSMutableSet = NSMutableSet()
    var kClasses = [BPClassNode]()
    
    static let sharedInstance = BPSettingCenter()
    private override init() {}
    
    var bp_paths: String = "" {
        
        didSet {
            
            let pathValues = bp_paths.split(separator: ",")
            
            
            for path in pathValues {
                
                var isDir: ObjCBool = ObjCBool.init(false)
                
                if FileManager.default.fileExists(atPath: String(path), isDirectory: &isDir) {
                    
                    
                    if isDir.boolValue, let enumerator = FileManager.default.enumerator(atPath: String(path)) {
                        
                        while let file = enumerator.nextObject() as? String {
                            
                            if supported(file)
                            {
                                files.append("\(path)/\(file)")
                            }
                            
                        }
                        
                        
                    }
                    else
                    {
                        files = [String(path)]
                    }
                }
                else
                {
                    print("File: \(path) not exist")
                }
            }
        }
    }
    
    fileprivate var files: [String] = []
    fileprivate let semaphore = DispatchSemaphore(value: maxConcurrent)
    
    fileprivate func supported(_ file: String) -> Bool {
        if file.hasSuffix(".h") || file.hasSuffix(".m") || file.hasSuffix(".swift") {
            return true
        }
        return false
    }
    
    func saveKeyPath(kPath:String?)
    {
        
        let userDefault = UserDefaults.standard
        
        if  kPath == nil||kPath==""
        {
            userDefault.removeObject(forKey: kSavePathBPS)
        }
        else
        {
           userDefault.set(kPath, forKey: kSavePathBPS)
        }
    }
    
    func getKeyPath()->String?
    {
        let userDefault = UserDefaults.standard
   
       let pathStr = userDefault.string(forKey: kSavePathBPS)
        

        return pathStr
    }
    
    func addObjc()  {
        
        self.objcNum += 1
       
    }
    
    func addSwift()  {
        
       self.swiftNum += 1
        
    }
    
    func setStart()  {
        startTime = NSDate()
        objcNum = 0
        swiftNum = 0
    }
    
    func setEnd()  {
        endTime = NSDate()
      
    }

    func showTime()->String!  {
        let seconds = endTime.timeIntervalSince(startTime as Date)
        let ss = Int(round(seconds))
        let str = " OC文件:\(objcNum)\n swift文件:\(swiftNum) \n 耗时:\(ss)秒"
        return str
        
    }
    
    func showAlert()  {
        
        mainWindowC.stopRunningAni()
        endTime = NSDate()
        let alert:NSAlert = NSAlert()
        alert.messageText = showTime()
        alert.alertStyle = NSAlert.Style.informational
        alert.runModal()
    }
    
    func cleanAll()  {
        
        objcNum = 0
        swiftNum = 0
        kClasses.removeAll()
        filterSet.removeAllObjects()
    }
    
    func resetSuperSelect(_ arr:NSMutableArray)  {
        
        let ssuperSelect = BPSettingCenter.sharedInstance.mainWindowC.superSelect!
        ssuperSelect.removeAllItems()
        ssuperSelect.addItems(withTitles: arr as! [String])
        ssuperSelect.selectItem(at: 0)
        
    }
    

    
    
    
    
    
    
    
    
}
