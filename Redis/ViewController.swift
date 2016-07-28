//
//  ViewController.swift
//  Redis
//
//  Created by Arnav Gudibande on 7/22/16.
//  Copyright © 2016 Arnav Gudibande. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let redisServer = Redis()
    let manager = CMMotionManager()
    let scale: Double = 0.03
    var yaw = -0.5
    var pitch: Double = 0
    var i = 0

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddress: UITextField!
    
    @IBAction func resetRedis(_ sender: AnyObject) {
        
        yaw = -0.5
        pitch = 0
        redisServer.Command("set scl_pos_ee_des "+"\"" + "\(yaw) 0.8 \(pitch)" + "\"")
        
    }
    
    @IBAction func connectToServer(_ sender: UIButton) {
            
        if let userTypedIP = ipAddress.text {
            redisServer.server(userTypedIP, onPort: 6379)
        }
        
        redisServer.server(ipAddress.placeholder!, onPort: 6379)
        redisServer.Command("Ping")
        
        startControl()
        
        statusLabel.text = "Connected"
        statusLabel.textColor = UIColor.green()
        
    }
    
    func startControl() {
        
        redisServer.Command("set scl_pos_ee_des "+"\"" + "\(yaw) 0.8 \(pitch)" + "\"")
        
        //CoreMotion functions
        manager.deviceMotionUpdateInterval = 0.1
        
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { deviceManager, error in
            
            if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) <= 25.00 {
                
                // Tilt forward
                self.pitch -= self.scale
                self.redisServer.Command("set scl_pos_ee_des "+"\"" + "\(self.yaw) 0.8 \(self.pitch)" + "\"")
                
            } else if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) >= 75.00 {
                
                // Tilt backward
                self.pitch += self.scale
                self.redisServer.Command("set scl_pos_ee_des "+"\"" + "\(self.yaw) 0.8 \(self.pitch)" + "\"")
                
            }
            
            if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) <= -25.00 {
                
                // Tilt right
                self.yaw += self.scale
                self.redisServer.Command("set scl_pos_ee_des "+"\"" + "\(self.yaw) 0.8 \(self.pitch)" + "\"")
                
            } else if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) >= 25.00 {
                
                // Tilt Left
                self.yaw -= self.scale
                self.redisServer.Command("set scl_pos_ee_des "+"\"" + "\(self.yaw) 0.8 \(self.pitch)" + "\"")
                
            }
            
            
        })
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.ipAddress.placeholder = "10.21.160.61"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

