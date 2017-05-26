//
//  AppDelegate.swift
//  FlutterBar
//
//  Created by Chris Bracken on 25/5/17.
//  Copyright © 2017 Chris Bracken. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let flutterStatus = FlutterStatusController()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    flutterStatus.poll(interval: 30)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }
}

