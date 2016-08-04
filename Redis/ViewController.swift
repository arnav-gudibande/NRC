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
import AudioToolbox

class ViewController: UIViewController, UITextFieldDelegate {
    
    let redisServer = Redis()
    let manager = CMMotionManager()
    let yscale = 150
    let pscale = 1000
    var yaw = 32768
    var pitch = 32768
    var i = 2
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddress: UITextField!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yawLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var yawDisplay: UILabel!
    @IBOutlet weak var pitchDisplay: UILabel!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var sliderVal: UISlider!
    
    @IBAction func connectToServer(_ sender: UIButton) {
        
        if i%2==0 {
            
            connect()
            startControl()
            
            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor.green()
            
            UIView.animate(withDuration: 0.7, animations: { () -> Void in
                var connectFrame : CGRect = self.connectButton.frame
                connectFrame.origin.y-=133
                self.connectButton.frame = connectFrame
            })
            
            connectButton.setTitleColor(UIColor.red(), for: UIControlState.normal)
            connectButton.setTitle("Disconnect from Server", for: UIControlState.normal)
            resetButton.isHidden = false
            titleLabel.isHidden = true
            ipAddress.isHidden = true
            
            self.yawLabel.isHidden = false
            self.yawDisplay.isHidden = false
            self.pitchLabel.isHidden = false
            self.pitchDisplay.isHidden = false
            
            yawDisplay.text = String(yaw)
            pitchDisplay.text = String(pitch)
            
            i+=1
            
        } else if i%2 != 0 {
            
            redisServer.Command(Command: "quit")
            
            UIView.animate(withDuration: 0.7, animations: { () -> Void in
                var connectFrame : CGRect = self.connectButton.frame
                connectFrame.origin.y+=133
                self.connectButton.frame = connectFrame
            })
            
            connectButton.setTitleColor(UIColor.blue(), for: UIControlState.normal)
            connectButton.setTitle("Connect to Server", for: UIControlState.normal)
            resetButton.isHidden = true
            
            statusLabel.text = "Not Connected"
            statusLabel.textColor = UIColor.red()
            titleLabel.isHidden = false
            ipAddress.isHidden = false
            
            self.resetButton.isHidden = true
            self.yawLabel.isHidden = true
            self.yawDisplay.isHidden = true
            self.pitchLabel.isHidden = true
            self.pitchDisplay.isHidden = true
            
            i+=1
        }
        
    }
    
    @IBAction func resetPos(_ sender: AnyObject) {
        yaw = 32768
        pitch = 32768
        self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
        self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
        self.updateLabels()
    }
    
    func connect() {
        if let userTypedIP = ipAddress.text {
            redisServer.server(endPoint: userTypedIP, onPort: 6379)
        }
        
        //Setup Redis and test connection
        redisServer.server(endPoint: ipAddress.placeholder!, onPort: 6379)
        redisServer.Command(Command: "Ping")
        
        yaw = 32768
        pitch = 32768
        self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
        self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
    }
    
    // Yaw Limits -- 28000, 35000
    // Pitch Limits -- 20000, 55000
    
    func startControl() {
        
        //CoreMotion functions
        manager.deviceMotionUpdateInterval = 0.1
        
        manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { deviceManager, error in
            
            if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) <= 10.00 {
                
                // Tilt forward
                self.cutoff(v: &self.pitch, t:"P", c: 25000, bool: false)
                
                self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
                self.updateLabels()
                
            } else if ((deviceManager?.attitude.pitch)! * 180.0/M_PI) >= 75.00 {
                
                // Tilt backward
                self.cutoff(v: &self.pitch, t:"P", c: 50000, bool: true)
                self.redisServer.Command(Command: "set pitch " + "\(self.convertToHex(num: self.pitch))")
                self.updateLabels()
            }
            
            if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) <= -40.00 {
                
                // Tilt right
                self.cutoff(v: &self.yaw, t:"Y", c: 29000, bool: false)
                self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
                self.updateLabels()
                
            } else if ((deviceManager?.attitude.yaw)! * 180.0/M_PI) >= 40.00 {
                
                // Tilt Left
                self.cutoff(v: &self.yaw, t:"Y", c: 35000, bool: true)
                self.redisServer.Command(Command: "set yaw " + "\(self.convertToHex(num: self.yaw))")
                self.updateLabels()
                
            }
            
            
        })
        
    }
    
    func cutoff(v: inout Int, t: String, c: Int, bool: Bool) { // True --> +, False --> -
        
        if !bool {
            if v-1 >= c {
                if t=="P" {
                    v -= pscale
                } else if t=="Y" {
                    v -= yscale
                }
            } else {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        } else if bool {
            if v+1 <= c {
                if t=="P" {
                    v += pscale
                } else if t=="Y" {
                    v += yscale
                }
            } else {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }

    }
    
    func updateLabels() {
        DispatchQueue.main.asynchronously(execute: {
            self.yawDisplay.text = String(self.yaw)
            self.pitchDisplay.text = String(self.pitch)
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.ipAddress.placeholder = "10.21.160.61"
        self.ipAddress.delegate = self
        self.ipAddress.keyboardType = UIKeyboardType.numbersAndPunctuation
        self.ipAddress.returnKeyType = UIReturnKeyType.done
        
        self.resetButton.isHidden = true
        self.yawLabel.isHidden = true
        self.yawDisplay.isHidden = true
        self.pitchLabel.isHidden = true
        self.pitchDisplay.isHidden = true
        self.sliderVal.isHidden = true
        self.sliderLabel.isHidden = true
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
