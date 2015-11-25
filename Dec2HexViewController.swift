//
//  Dec2HexViewController.swift
//  DecHex
//
//  Created by Toby Applegate on 04/10/2015.
//  Copyright © 2015 Toby Applegate. All rights reserved.
//

import UIKit
import WatchConnectivity

class Dec2HexViewController: UIViewController, WCSessionDelegate {
    var brain = ConverterBrain()
    let dataSession = WCSession.defaultSession()
    var facebookData = FacebookData()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerDisplay: UILabel!
    @IBOutlet weak var decInput: UITextField!
    
    @IBAction func convert(sender: UIButton) {
        convertDecToHex(decInput.text!)
    }
    @IBAction func warningmessage(sender: AnyObject) {
        showAlertController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground("backgroundTwo.jpg")
        dataSession.delegate = self
        dataSession.activateSession() //ready to recieve messages from counterpart (may not be nessassery as not sending messages back)
        facebookData.getProfilePicture {(pictureData, error) -> Void in
            if error != nil {
                print("login error: \(error!.localizedDescription)")
            }
            self.imageView.image = UIImage(data: pictureData!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func convertDecToHex(decInputFromUI : String) {
        print(decInputFromUI)
        let convertedNumber = brain.decToHex(decInputFromUI)
        print("The answer is \(convertedNumber)")
        let stringOfAnswer = String(convertedNumber)
        if stringOfAnswer == "ERROR" {
            answerDisplay.text = stringOfAnswer
            shake(answerDisplay)
        }
        else {
            answerDisplay.text = stringOfAnswer
        }
        sendMessageToWatch(decInputFromUI, convertedDecNumber: stringOfAnswer)
    }
    func sendMessageToWatch(decInputFromUI : String, convertedDecNumber : String) {
        let message = [ "originalNumber": decInputFromUI, "newDecNumber": "", "newHexNumber": convertedDecNumber]
        dataSession.sendMessage(message, replyHandler: nil, errorHandler: nil)
        //replyhandler set to nil as dont want to recieve reply, same with erorr handler
    }
    
    func shake(view: UILabel) {
        let shakeAnimation = CAKeyframeAnimation()
        shakeAnimation.keyPath = "position.x"
        shakeAnimation.values = [0, 10, -10, 10, -5, 5, -5, 0 ]
        shakeAnimation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        shakeAnimation.duration = 0.5
        shakeAnimation.additive = true
        
        view.layer.addAnimation(shakeAnimation, forKey: "shake")
    }
    
    func showAlertController() {
        let alertController = UIAlertController(
            title: "test title, hey that they both start with a 'T'",
            message: "shouldnt have pressed this button...",
            preferredStyle: .Alert)
        let cancelAction = UIAlertAction(
            title: "Ignore",
            style: UIAlertActionStyle.Destructive,
            handler: nil)
        let otherAction = UIAlertAction(
            title: "Acknowledge (does nothing)",
            style: UIAlertActionStyle.Default,
            handler: {action in print("confirm was tapped")})
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
            if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(openAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        print("done with alert controller")
    }

}
