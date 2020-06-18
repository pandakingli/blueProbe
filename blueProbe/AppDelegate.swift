//
//  AppDelegate.swift
//  blueProbe
//
//  Created by lining on 2018/1/25.
//  Copyright © 2018年 biubiublue. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

   // @IBOutlet weak var window: NSWindow!
    var mainWindowC :MainWC = MainWC()
    var myWindow : mainWindow = mainWindow()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /*
         //纯代码实现
        myWindow = mainWindow.init(contentRect: NSMakeRect(0, 0, 400, 300), styleMask:[.closable,.resizable,.titled,.miniaturizable,.resizable], backing: NSWindow.BackingStoreType.buffered, defer: true)
        myWindow.title = "测试"
        myWindow.backgroundColor = NSColor.white
        myWindow.makeKeyAndOrderFront(self)
        myWindow.center()
        */
        mainWindowC = MainWC.init(windowNibName: NSNib.Name(rawValue: "MainWC"))
        mainWindowC.window?.center()//让显示的位置居于屏幕的中心
        mainWindowC.window?.orderFront(nil)   //前置显示窗口
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

