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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Redis Server
        redisServer.server("127.0.0.1", onPort: 6379)
        redisServer.Command("Ping")
        
        // CoreMotion functions
        manager.deviceMotionUpdateInterval = 0.01
        
        manager.startDeviceMotionUpdates(to: OperationQueue.main(), withHandler:{
            deviceManager, error in
            
            print(deviceManager?.attitude.pitch)
            print(deviceManager?.attitude.yaw)
            
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

