//
//  InitialViewController.swift
//  PongGame
//
//  Created by Phyo Pwint  on 2/6/16.
//  Copyright © 2016 Phyo Pwint . All rights reserved.
//

import UIKit


class InitialViewController: UIViewController, SSRadioButtonControllerDelegate, SKYLINKConnectionLifeCycleDelegate, SKYLINKConnectionRemotePeerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var txtRoomName: UITextField!
    @IBOutlet weak var btnChild: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnMaster: UIButton!
    var IS_MASTER: String!
    var ROOM_NAME: String!
    var radioButtonController: SSRadioButtonsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnStart.hidden = true
        radioButtonController = SSRadioButtonsController(buttons: btnChild, btnMaster)
        radioButtonController!.delegate = self
        radioButtonController!.shouldLetDeSelect = true
        txtRoomName.delegate = self
        ROOM_NAME = txtRoomName.text
        
    }
    
    @IBAction func btnExit(sender: AnyObject) {
        exit(0)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        if (textField === txtRoomName)
        {
            txtRoomName.resignFirstResponder()
            let value = txtRoomName.text
            if value != "" {
                ROOM_NAME = value
            }
            else {
                ROOM_NAME = "myroom"
            }
        }
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func didSelectButton(aButton: UIButton?) {
        NSLog("Selected Button Is \(aButton?.currentTitle!)")
        if(aButton?.currentTitle! == "Player1") {
            IS_MASTER = "true"
            self.btnStart.hidden = false
            aButton!.setTitleColor(ButtonColor, forState: UIControlState.Selected)
        }
        else if(aButton?.currentTitle! == "Player2") {
            IS_MASTER = "false"
            self.btnStart.hidden = false
            aButton!.setTitleColor(ButtonColor, forState: UIControlState.Selected)
        }
        else {
            self.btnStart.hidden = true
        }
        
    }
    
    //goToGame
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "goToGame") {
            //let destinationNavigationController = segue.destinationViewController as! UINavigationController
            //let vc = destinationNavigationController.topViewController as! GameViewController
            let vc = segue.destinationViewController as! GameViewController
            vc.ROOMNAME = self.ROOM_NAME
            vc.ISMASTER = self.IS_MASTER
        }
    }
}
