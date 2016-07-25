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
    let scale: Double = 0.01
    var yaw = -0.5
    var pitch: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Redis Server
        redisServer.server("10.21.161.18", onPort: 6379)
        redisServer.Command("Ping")
        redisServer.Command("set scl_pos_ee_des \(yaw) 0.8 \(pitch)")
        
        // CoreMotion functions
        manager.deviceMotionUpdateInterval = 0.01
        
        manager.startDeviceMotionUpdates(to: OperationQueue.main(), withHandler: {
            deviceManager, error in
            
            if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) <= 25.00 {
                print("Tilt forward")
                self.pitch += self.scale
                self.redisServer.Command("set scl_pos_ee_des \(self.yaw) 0.8 \(self.pitch)")
            } else if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) >= 75.00 {
                print("Tilt backward")
                self.pitch -= self.scale
                self.redisServer.Command("set scl_pos_ee_des \(self.yaw) 0.8 \(self.pitch)")
            }
            
            if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) <= -25.00 {
                print("Tilt right")
                self.yaw += self.scale
                self.redisServer.Command("set scl_pos_ee_des \(self.yaw) 0.8 \(self.pitch)")
            } else if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) >= 25.00 {
                print("Tilt left")
                self.yaw -= self.scale
                self.redisServer.Command("set scl_pos_ee_des \(self.yaw) 0.8 \(self.pitch)")
            }
            
            
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

