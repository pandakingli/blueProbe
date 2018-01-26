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
    var mainWindowController = MainWC()
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
       
        mainWindowController = MainWC.init(windowNibName: NSNib.Name(rawValue: "MainWC"))
        mainWindowController.window?.center()//让显示的位置居于屏幕的中心
        mainWindowController.window?.orderFront(nil)   //前置显示窗口
     
        
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

