//
//  ViewController.swift
//  MacOSPOC
//
//  Created by Vijayendra Kumar Madda on 26/06/25.
//

import Cocoa
import Foundation
import Network

var connection: NWConnection?

class ViewController: NSViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connect(port: 12345)
    }
    
    func connect(port: UInt16) {
        connection = NWConnection(host: "localhost", port: NWEndpoint.Port(rawValue: port) ?? 0, using: .tcp)
        connection?.stateUpdateHandler = { state in
            print("Connection state: \(state)")
        }
        connection?.start(queue: .main)
        receive()
    }
    
    func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, isComplete, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) {
                print("Received event: \(json)")
            }
            if isComplete == false {
                self.receive()
            }
        }
    }
    
    @IBAction func pairDevice(_ sender: Any) {
        let pairResult = runCommand("/usr/local/bin/idevicepair", args: ["pair"])
        print("Pair Result:\n\(pairResult)")
    }
    
    @IBAction func getDeviceInfo(_ sender: Any) {
        let infoResult = runCommand("/opt/homebrew/bin/ideviceinfo", args: ["ideviceinfo"])
        print("Device Info:\n\(infoResult)")
    }
    
    
    @IBAction func rebootDevice(_ sender: Any) {
        let rebootResult = runCommand("/usr/local/bin/idevicediagnostics", args: ["restart"])
        print("Reboot Result:\n\(rebootResult)")
        
    }
    
    @IBAction func installIpa(_ sender: Any) {
        let ipaPath = "/Users/vijayendrakumarmadda/Documents/iPa/RE/RoadShow 2025-06-26 23-56-28/Stori.ipa"
        let installResult = runCommand("/opt/homebrew/bin/ideviceinstaller", args: ["-i", ipaPath])
        print("Install IPA Result:\n\(installResult)")
    }
    
    @IBAction func uninstallIpa(_ sender: Any) {
        let unInstallResult = runCommand("/opt/homebrew/bin/ideviceinstaller", args: ["-U", "com.3frameslab.re.roadshow"])
        print("UnInstall IPA Result:\n\(unInstallResult)")
    }
    
    func runCommand(_ command: String, args: [String]) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = args
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
    
    
}
