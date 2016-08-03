//
//  ViewController.swift
//  Redis
//
//  Created by Arnav Gudibande on 7/22/16.
//  Copyright © 2016 Arnav Gudibande. All rights reserved.
//

import UIKit
import CoreMotion
import Foundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    let redisServer = Redis()
    let manager = CMMotionManager()
    let scale = 200
    var yaw = 32768
    var pitch = 32768
    var i = 0
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddress: UITextField!
    
    @IBAction func connectToServer(_ sender: UIButton) {
        
        if let userTypedIP = ipAddress.text {
            redisServer.server(endPoint: userTypedIP, onPort: 6379)
        }
        
        //Setup Redis and test connection
        redisServer.server(endPoint: ipAddress.placeholder!, onPort: 6379)
        redisServer.Command(Command: "Ping")
        
        startControl()
        
        statusLabel.text = "Connected"
        statusLabel.textColor = UIColor.green()
        
    }
    
    @IBAction func resetPos(_ sender: AnyObject) {
        yaw = 32768
        pitch = 32768
        self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
        self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
    }
    
    func startControl() {
        
        //CoreMotion functions
        manager.deviceMotionUpdateInterval = 0.1
        
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { deviceManager, error in
            
            if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) <= 5.00 {
                
                // Tilt forward
                self.pitch -= self.scale
                self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
                
            } else if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) >= 85.00 {
                
                // Tilt backward
                self.pitch += self.scale
                self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
                
            }
            
            if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) <= -40.00 {
                
                // Tilt right
                self.yaw += self.scale
                self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
                
            } else if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) >= 40.00 {
                
                // Tilt Left
                self.yaw -= self.scale
                self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
                
            }
            
            
        })
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.ipAddress.placeholder = "10.21.160.61"
        self.ipAddress.delegate = self
        self.ipAddress.keyboardType = UIKeyboardType.numbersAndPunctuation
        self.ipAddress.returnKeyType = UIReturnKeyType.done
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func convertToHex(num: Int) -> String {
        return String(num)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
