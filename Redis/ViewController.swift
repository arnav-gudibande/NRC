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
    var i = 2

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddress: UITextField!
    @IBOutlet weak var resetPos: UIButton!
    @IBOutlet weak var connectServer: UIButton!
    @IBOutlet weak var ipLabel: UILabel!
    
    @IBAction func connectToServer(_ sender: UIButton) {
        
        if i%2 == 0 {
            connect()
            startControl()

            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor.green()
            resetPos.isHidden = false
            ipAddress.isHidden = true
            ipLabel.isHidden = true
            connectServer.setTitle("Disconnect from Server", for: UIControlState.normal)
            connectServer.setTitleColor(UIColor.red(), for: UIControlState.normal)
            
            
            i+=1
            
        } else if i%2 != 0 {
            redisServer.Command(Command: "quit")
            resetPos.isHidden = true
            ipAddress.isHidden = false
            ipLabel.isHidden = false
            connectServer.setTitle("Connect to Server", for: UIControlState.normal)
            connectServer.setTitleColor(UIColor.blue() , for: UIControlState.normal)
            statusLabel.text = "Not Connected"
            statusLabel.textColor = UIColor.red()
            i+=1
        }
    }
    
    @IBAction func resetPosition(_ sender: AnyObject) {
        
        yaw = 32768
        self.redisServer.Command(Command: "set yaw " + "\(self.yaw)")
        pitch = 32768
        self.redisServer.Command(Command: "set pitch " + "\(self.pitch)")
        
    }
    
    func connect() {
        if let userTypedIP = ipAddress.text {
            redisServer.server(endPoint: userTypedIP, onPort: 6379)
        }
        
        //Setup Redis and test connection
        redisServer.server(endPoint: ipAddress.placeholder!, onPort: 6379)
        redisServer.Command(Command: "Ping")
    }
    
    func startControl() {
        
        //CoreMotion functions
        manager.deviceMotionUpdateInterval = 0.1
        
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { deviceManager, error in
            
            if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) <= 5.00 {
                
                // Tilt forward
                self.pitch -= self.scale
                self.redisServer.Command(Command: "set pitch " + "\(self.pitch)")
                
            } else if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) >= 85.00 {
                
                // Tilt backward
                self.pitch += self.scale
                self.redisServer.Command(Command: "set pitch " + "\(self.pitch)")
                
            }
            
            if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) <= -40.00 {
                
                // Tilt right
                self.yaw += self.scale
                self.redisServer.Command(Command: "set yaw " + "\(self.yaw)")
                
            } else if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) >= 40.00 {
                
                // Tilt Left
                self.yaw -= self.scale
                self.redisServer.Command(Command: "set yaw " + "\(self.yaw)")
                
            }
            
            
        })
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.resetPos.isHidden = true
        self.connectServer.setTitleColor(UIColor.blue(), for: UIControlState.normal)
        self.resetPos.setTitleColor(UIColor.blue(), for: UIControlState.normal)
        self.ipAddress.placeholder = "10.21.160.61"
        self.ipAddress.delegate = self
        self.ipAddress.keyboardType = UIKeyboardType.numbersAndPunctuation
        self.ipAddress.returnKeyType = UIReturnKeyType.done

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

