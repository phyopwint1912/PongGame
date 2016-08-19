//
//  GameViewController.swift
//  PongGame
//
//  Created by Phyo Pwint  on 17/5/16.
//  Copyright (c) 2016 Phyo Pwint . All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var ROOMNAME: String!
    var ISMASTER: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView

            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFit
            
            scene.ROOM_NAME = ROOMNAME
            scene.isMaster = ISMASTER
            
            skView.presentScene(scene)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.callInitialVC), name: "callInitialVC", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.disconnectedAlert), name: "disconnectedAlert", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.connectedAlert), name: "connectedAlert", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.callSettingAction), name: "callSettingAction", object: nil)
        
    }
    
    func callInitialVC(){
        let storyboardName: String = "Main"
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("initialVC")
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func disconnectedAlert(notification:NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let msgTitle: String = userInfo["msgTitle"]!
        let errorMessage: String = userInfo["errorMessage"]!
        let alertController = UIAlertController(title: msgTitle , message: errorMessage, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.callInitialVC()
        }

        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func connectedAlert(notification:NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let msgTitle: String = userInfo["msgTitle"]!
        let errorMessage: String = userInfo["errorMessage"]!
        let alertController = UIAlertController(title: msgTitle , message: errorMessage, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        // Add the actions
        alertController.addAction(OKAction)
        // Present the controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func callSettingAction(notification:NSNotification) {

        let optionMenu = UIAlertController(title: "Choose Your Option", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let option1 = UIAlertAction(title: "Reset", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.callInitialVC()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        optionMenu.addAction(option1)
        optionMenu.addAction(cancelAction)
        
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = self.view
                currentPopoverpresentioncontroller.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 1.0, 1.0)
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                self.presentViewController(optionMenu, animated: true, completion: nil)
            }
        }
        else{
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let skView: SKView = (self.view as! SKView)
        skView.presentScene(nil)
        //remove everything from memory
    }
}
