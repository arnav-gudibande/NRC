//
//  ViewController.swift
//  Redis
//
//  Created by Arnav Gudibande on 7/22/16.
//  Copyright © 2016 Arnav Gudibande. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let redisServer = Redis()

    override func viewDidLoad() {
        super.viewDidLoad()
        redisServer.server("127.0.0.1", onPort: 6379)
        redisServer.Command("Ping")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

