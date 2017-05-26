//
//  FlutterStatusController.swift
//  FlutterBar
//
//  Created by Chris Bracken on 25/5/17.
//  Copyright © 2017 Chris Bracken. All rights reserved.
//

import Cocoa

enum BuildStatus {
  case passing
  case failing
  case unknown
}

class FlutterStatusController : NSObject {
  let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)

  override init() {
    super.init()

    statusItem.menu = FlutterStatusController.createStatusMenu(target: self)

    if let button = statusItem.button {
      button.image = #imageLiteral(resourceName: "StatusBarIconRed")
      button.image?.isTemplate = true
    }
  }

  private class func createStatusMenu(target: AnyObject) -> NSMenu {
    let statusMenu = NSMenu(title: "FlutterBar")

    let openItem = NSMenuItem(title: "Open Dashboard...", action: #selector(FlutterStatusController.openDashboard(sender:)), keyEquivalent: "")
    openItem.target = target
    statusMenu.addItem(openItem)

    let quitItem = NSMenuItem(title: "Quit", action: #selector(FlutterStatusController.quit(sender:)), keyEquivalent: "")
    quitItem.target = target
    statusMenu.addItem(quitItem)

    return statusMenu
  }

  func openDashboard(sender: NSMenuItem) {
    let dashboardUrl = URL(string: "https://flutter-dashboard.appspot.com/build.html")!
    NSWorkspace.shared().open(dashboardUrl)
  }

  func quit(sender: NSMenuItem) {
    NSApplication.shared().terminate(self)
  }

  func poll(interval: TimeInterval) {
    Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [weak self] timer in self?.updateStatus() })
  }

  func updateStatus() {
    let requestUrl = URL(string: "https://flutter-dashboard.appspot.com/api/public/build-status")!
    let request = URLRequest(url: requestUrl)
    let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
      guard let data = data else {
        return
      }
      do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: String] {
          if let result = json["AnticipatedBuildStatus"] {
            let status = result == "Succeeded" ? BuildStatus.passing : BuildStatus.failing
            DispatchQueue.main.async {
              self?.updateStatusIcon(status: status)
            }
          }
        }
      } catch let parseError {
        print("JSON parsing error: \(parseError)");
      }
    }
    task.resume()
  }

  func updateStatusIcon(status: BuildStatus) {
    if let image = statusItem.button?.image {
      if (status == .passing) {
        image.isTemplate = true
      } else if (status == .failing) {
        image.isTemplate = false
      }
    }
  }
}
