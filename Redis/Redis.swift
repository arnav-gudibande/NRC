import Foundation
import CocoaAsyncSocket

class Redis: NSObject,  GCDAsyncSocketDelegate {
    
    //Alloc GCDAsyncSocket
    var Socket: GCDAsyncSocket?
    
    /*============================================================
     // Server Open Connection
     ============================================================*/
    func server(endPoint: String, onPort: UInt16){
        
        //Check For Socket Condition
        if !(Socket != nil) {
            
            //Assign Delegeate to Self Queue
            Socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
            
        }
        
        var err: NSError?
        
        /*============================================================
         GCDAsyncSocket ConnectToHost Throw Error so you must handle
         this with Try [Try!], do, Catch.
         ============================================================*/
        
        do{
            //Assign Function Constants
            try Socket!.connectToHost(endPoint, onPort: onPort)
        }catch {
            //Error
            print(err)
        }
        
        //Read Send Data
        Socket?.readDataWithTimeout(2, tag: 1)
    }
    
    
    //Server Confirmation
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        print("Connected to Redis!")
    }
    
    /*============================================================
     // Read Data From Redis Server [NSUTF8StringEncoding]
     ============================================================*/
    
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        let Recieved: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
        print(Recieved)
    }
    
    /*===============================================================
     // Send Command [I Will create Full SET and Upload it to Github]
     =================================================================*/
    
    func Command(Command: String){
        let request: String = Command + "\r\n"
        let data: NSData = request.dataUsingEncoding(NSUTF8StringEncoding)!
        Socket!.writeData(data, withTimeout: 1.0, tag: 0)
        
    }
    
}