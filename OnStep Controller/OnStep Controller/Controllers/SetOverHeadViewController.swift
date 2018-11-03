//
//  SetOverHeadViewController.swift
//  OnStep Controller
//
//  Created by Satnam on 11/1/18.
//  Copyright © 2018 Silver Seahog. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class SetOverHeadViewController: UIViewController {
    
    var clientSocket: GCDAsyncSocket!
    var readerText: String = String()
    
    @IBOutlet var overHeadLimitBtn: CustomTextField!
    @IBOutlet var horizonLimitBtn: CustomTextField!
    @IBOutlet var uploadBtn: UIButton!
    
    @IBAction func uploadAction(_ sender: UIButton) {
        if !overHeadLimitBtn.text!.isEmpty && !horizonLimitBtn.text!.isEmpty {
            
            if !(60...90).contains(Int(overHeadLimitBtn.text!)!) || !(-30...30).contains(Int(horizonLimitBtn.text!)!) {
                print("not success")
            } else {
                print("success")
                   self.triggerConnection(cmd: ":ShsDD#:SoDD#", setTag: 0)
                // Set horizon limit // Set overhead limit
            }
            
        } else {
            print("Backlash RA or Backlash Dec can't be empty.")
        } 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtnProperties(button: uploadBtn)
        
        addTFProperties(tf: overHeadLimitBtn, placeholder: "85")
        addTFProperties(tf: horizonLimitBtn, placeholder: "30 ")
        
        navigationItem.title = "SET OVERHEAD LIMITS"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "SFUIDisplay-Bold", size: 11)!,NSAttributedString.Key.foregroundColor: UIColor.white, kCTKernAttributeName : 1.1] as? [NSAttributedString.Key : Any]
        
        self.view.backgroundColor = .black
        // Do any additional setup after loading the view.
    }
    
    func triggerConnection(cmd: String, setTag: Int) {
        
        clientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            var addr = "192.168.0.1"
            var port: UInt16 = 9999
            
            // Populate data
            if addressPort.value(forKey: "addressPort") as? String == nil {
                addressPort.set("192.168.0.1:9999", forKey: "addressPort")
                addressPort.synchronize()  // Initialize
                
            } else {
                let addrPort = (addressPort.value(forKey: "addressPort") as? String)?.components(separatedBy: ":")
                
                addr = addrPort![opt: 0]!
                port = UInt16(addrPort![opt: 1]!)!
            }
            
            try clientSocket.connect(toHost: addr, onPort: port, withTimeout: 1.5)
            let data = cmd.data(using: .utf8)
            clientSocket.write(data!, withTimeout: 1.5, tag: setTag)
            clientSocket.readData(withTimeout: 1.5, tag: setTag)
        } catch {
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SetOverHeadViewController: GCDAsyncSocketDelegate {
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        let gettext = String(data: data, encoding: .utf8)
        print("got:", gettext)
        switch tag {
        case 0:
            readerText += "\(gettext!)"
            
            let index = readerText.replacingOccurrences(of: "#", with: ",").dropLast().components(separatedBy: ",")
            print(index, readerText)
            DispatchQueue.main.async {
            }
            
        case 1:
            print("Tag 1:", gettext!)
            
        default:
            print("def")
        }
        clientSocket.readData(withTimeout: -1, tag: tag)
        // clientSocket.disconnect()
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        let address = "Server IP：" + "\(host)"
        print("didConnectToHost:", address)
        
        switch sock.isConnected {
        case true:
            print("Connected")
        case false:
            print("Disconnected")
        default:
            print("Default")
        }
        
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("Disconnected Called: ", err?.localizedDescription as Any)
    }
    
}
