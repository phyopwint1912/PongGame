//
//  GameScene.swift
//  PongGame
//
//  Created by Phyo Pwint  on 17/5/16.
//  Copyright (c) 2016 Phyo Pwint . All rights reserved.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene, SKYLINKConnectionLifeCycleDelegate, SKYLINKConnectionRemotePeerDelegate, SKYLINKConnectionMessagesDelegate, SKPhysicsContactDelegate {
    var ballPosX : AnyObject!
    var ballPosY : AnyObject!
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    var isMaster: String!
    var posX: AnyObject!
    var posY: AnyObject!
    var isFingerOnPlayer1 = false
    var isFingerOnPlayer2 = false
    var secondBodyTouchLocation: CGPoint!
    var secondBodyPreviousLocation: CGPoint!
    var touchPaddle: String!
    
    
    //SKSpriteNode Collection
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var LabelPlayer1: SKLabelNode!
    var LabelPlayer2: SKLabelNode!
    var LabelRoundPlace: SKLabelNode!
    var pauseLabel: SKLabelNode!
    var ball: SKSpriteNode!
    var gameMessage:SKSpriteNode!
    var peerRole: String!
    var receiverRole: String!
    
    var roundGame : Int = 1 {
        didSet {
            let round = childNodeWithName(LabelRound) as! SKLabelNode
            round.text = "Round - " + String(roundGame)
        }
    }
    
    var isPlay: Bool = true {
        didSet {
            let pause = childNodeWithName(LabelPause) as! SKLabelNode
            pause.hidden = isPlay
            if(isPlay == false) {
                pause.text = "Touch here to go to Round - " + String(roundGame)
            }
        }
    }
    
    var isStop: Bool = false {
        didSet {
            scene?.view?.paused = isStop
        }
    }
    
    var gameWon : Bool = false {
        didSet {
            let windowRect:CGRect = self.view!.window!.frame;
            let windowWidth:CGFloat = windowRect.size.width;
            let customLabel = UILabel(frame: CGRectMake(0, 0, windowWidth, 50))
            customLabel.center = self.view!.center
            customLabel.frame = CGRectMake(self.view!.bounds.minX, self.view!.bounds.midY, self.view!.frame.width, 50)
            customLabel.textAlignment = NSTextAlignment.Center
            customLabel.font = UIFont(name: customLabel.font.fontName, size: 30)
            customLabel.textColor = UIColor.whiteColor()
            customLabel.backgroundColor = UIColor.blackColor()
            customLabel.text = gameWon ? "Player 1 Lost" : "Player 2 Lost"
            self.view!.addSubview(customLabel)
        }
    }
    
    var fCount : Int = 0 { // Master won
        didSet {
            LabelPlayer1.text = player1Label + String(fCount)
        }
    }
    
    var tCount : Int = 0 { // Child Won
        didSet {
            LabelPlayer2.text = player2Label + String(tCount)
        }
    }
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        WaitingForTap(scene: self),
        Playing(scene: self),
        GameOver(scene: self)])
    
    // Skylink
   
    // ====== SET YOUR KEY / SECRET HERE TO HAVE IT BY DEFAULT. ======
    // If you don't have any key/secret, enroll at developer.temasys.com.sg
    
    let skylinkApiKey: String = ""
    let skylinkApiSecret: String = ""
    var ROOM_NAME: String!
    var skylinkConnection: SKYLINKConnection!
    var remotePeerId: String!
    var messages : NSDictionary!
    var peers : NSMutableDictionary!
    var player1Label : String!
    var player2Label : String!
    
    // MARK: - Method
    override func didMoveToView(view: SKView) {
        //drawPlayableArea()
        NSLog("Inside %@", #function)
        self.receiverRole = self.isMaster
        NSLog("IsMaster \(isMaster)")
        NSLog("RoomName \(ROOM_NAME)")
        
        //Adding Skylink SDK
        NSLog("SKYLINKConnection version = %@", SKYLINKConnection.getSkylinkVersion())
        
        //Creating configuration
        let config:SKYLINKConnectionConfig = SKYLINKConnectionConfig()
        config.video = false
        config.audio = false
        config.fileTransfer = false
        config.dataChannel = true
        
        self.messages = [:]
        self.peers = [:]
        
        ball = childNodeWithName(BallCategoryName) as! SKSpriteNode
        player1 = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
        player2 = childNodeWithName(Paddle2CategoryName) as! SKSpriteNode
        LabelPlayer1 = childNodeWithName(LabelPlayer1Mark) as! SKLabelNode
        LabelPlayer2 = childNodeWithName(LabelPlayer2Mark) as! SKLabelNode
        LabelRoundPlace = childNodeWithName(LabelRound) as! SKLabelNode
        pauseLabel = childNodeWithName(LabelPause) as! SKLabelNode
        
        if(isMaster == "true") {
            player1Label = "Player1 - "
            player2Label = "Player2 - "
        }
        else {
            player1Label = "Player2 - "
            player2Label = "Player1 - "
        }
        LabelPlayer1.text = player1Label + "0"
        LabelPlayer2.text = player2Label + "0"
        
        // Creating SKYLINKConnection
        self.skylinkConnection = SKYLINKConnection(config: config, appKey: self.skylinkApiKey)
        self.skylinkConnection.lifeCycleDelegate = self
        self.skylinkConnection.messagesDelegate = self
        self.skylinkConnection.remotePeerDelegate = self
        
        // Connecting to a room
        SKYLINKConnection.setVerbose(true)
        self.skylinkConnection.connectToRoomWithSecret(self.skylinkApiSecret, roomName: self.ROOM_NAME, userInfo: self.isMaster)
        
        //Adding Indicator and hidden things
        myActivityIndicator.center = view.center
        myActivityIndicator.startAnimating()
        
        view.addSubview(myActivityIndicator)
        ball.hidden = true
        player1.hidden = true
        player2.hidden = true
        LabelPlayer1.hidden = true
        LabelPlayer2.hidden = true
        LabelRoundPlace.hidden = true
        pauseLabel.hidden = true
        
        // define the border
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        self.physicsBody = borderBody
        
        // move freely within the scene
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        ball.physicsBody!.restitution = 1
        ball.physicsBody!.friction = 0
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.angularDamping = 0
        
        player1.physicsBody!.dynamic = false
        player1.physicsBody!.allowsRotation = false
        
        player2.physicsBody!.dynamic = false
        player2.physicsBody!.allowsRotation = false
        player2.physicsBody!.restitution = 1
        
        ball.physicsBody!.categoryBitMask = CategoryOfBody.ball
        ball.physicsBody!.contactTestBitMask = CategoryOfBody.margin
        player1.physicsBody!.categoryBitMask = CategoryOfBody.player
        player2.physicsBody!.categoryBitMask = CategoryOfBody.player
        
        let RectLow = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let LowerNode = SKNode()
        LowerNode.name = "Lower"
        LowerNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: RectLow)
        LowerNode.physicsBody!.categoryBitMask = CategoryOfBody.margin
        addChild(LowerNode)
        
        let RectUpper = CGRectMake(0, 1334, self.frame.size.width, 1)
        let UpperNode = SKNode()
        UpperNode.name = "Upper"
        UpperNode.physicsBody = SKPhysicsBody(edgeLoopFromRect: RectUpper)
        UpperNode.physicsBody!.categoryBitMask = CategoryOfBody.margin
        addChild(UpperNode)
        
        // Adding GameMessage
        if(isMaster == "true") {
            gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        }
        else if(isMaster == "false") {
            gameMessage = SKSpriteNode(imageNamed: "WaitToPlay")
        }
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        addChild(gameMessage)
        
    }
    
    // MARK: - SKYLINKConnectionMessageDelegate
    
    func connection(connection: SKYLINKConnection!, didReceiveBinaryData data: NSData!, peerId: String!) {
        NSLog("Inside %@", #function)
        let message: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data)!
        self.peers = ["message": message,
                      "peerId": peerId]
        
        let p2OriginX : CGFloat = 375
        let p2OriginY : CGFloat = 1170
        
        if(peers["message"]!.valueForKey("paddlePosition") != nil) {
            secondBodyTouchLocation = getCGpointFromString(peers["message"]!.valueForKey("paddlePosition")! as! String)
            let paddle2 = childNodeWithName(Paddle2CategoryName) as! SKSpriteNode
            let calculatePosition = CGPoint(x: secondBodyTouchLocation.x - p2OriginX, y: p2OriginY)
            let finalPosition = CGPoint(x: p2OriginX - calculatePosition.x, y: p2OriginY)
            paddle2.position = CGPointMake(finalPosition.x, p2OriginY)
        }
        
        if(isMaster == "false") {
            if(peers["message"]!.valueForKey("ballPosX") != nil && peers["message"]!.valueForKey("ballPosY") != nil) {
                posX = peers["message"]!.valueForKey("ballPosX")
                posY = peers["message"]!.valueForKey("ballPosY")
            }
            
            if(peers["message"]!.valueForKey("ballAlpha") != nil) {
                let ballAlpha: String = peers["message"]!.valueForKey("ballAlpha") as! String
                if(ballAlpha == "true") {
                    ball.alpha = 0
                }
                else if(ballAlpha == "false") {
                    ball.alpha = 1.0
                }
            }
            
            if(peers["message"]!.valueForKey("fCount") != nil) {
                let masterCount = peers["message"]!.valueForKey("fCount") as! String
                let LabelPLayer2 = childNodeWithName(LabelPlayer2Mark) as! SKLabelNode
                LabelPLayer2.text = player2Label + masterCount
            }
            
            if(peers["message"]!.valueForKey("tCount") != nil) {
                let childCount = peers["message"]!.valueForKey("tCount") as! String
                let LabelPLayer1 = childNodeWithName(LabelPlayer1Mark) as! SKLabelNode
                LabelPLayer1.text = player1Label + childCount
            }
            
            if(peers["message"]!.valueForKey("roundGame") != nil) {
                let roundOf = peers["message"]!.valueForKey("roundGame") as! String
                let round = childNodeWithName(LabelRound) as! SKLabelNode
                if(roundOf == "5") {
                    round.text = "Round - 4"
                }
                else {
                    round.text = "Round - " + roundOf
                }
            }
            
            if let isFinish: String = peers["message"]!.valueForKey("isFinished") as? String {
                if let status: String = (peers["message"]!.valueForKey("status")) as? String {
                    var returnValue: Bool = false
                    if(status == "true") {
                        returnValue = true
                    }
                    if (isFinish == "true") {
                        gameState.enterState(GameOver)
                        gameWon = returnValue
                        ball.alpha = 0
                    }
                }
            }
            
            if let isPartial: String = peers["message"]!.valueForKey("isPartial") as? String {
                if (isPartial == "true") {
                    if(peers["message"]!.valueForKey("blockPosition") != nil) {
                        let blockPosition = getCGpointFromString(peers["message"]!.valueForKey("blockPosition")! as! String)
                        let finalPositionX : CGFloat = (700 - blockPosition.x) + 50
                        let finalPositionY : CGFloat = (1284 - blockPosition.y) + 50
                        let blockSizeString : String = peers["message"]!.valueForKey("blockSize")! as! String
                        let blockSize : CGFloat = CGFloat((blockSizeString as NSString).doubleValue)
                        self.addingBlock(finalPositionX,blockY: finalPositionY,blockSize: blockSize)
                    }
                }
            }
            
            if(peers["message"]!.valueForKey("pauseMessage") != nil) {
                let pauseMessage = peers["message"]!.valueForKey("pauseMessage") as! String
                //let pause = childNodeWithName(LabelPause) as! SKLabelNode
                pauseLabel.hidden = false
                pauseLabel.text = pauseMessage
            }
            
            if(peers["message"]!.valueForKey("isLabelDismiss") != nil) {
                pauseLabel.hidden = true
            }
            
            if(peers["message"]!.valueForKey("isStartToPlay") != nil) {
                gameState.enterState(Playing)
            }
        }
        
    }
    
    // MARK: - SKYLINKConnectionLifeCycleDelegate
    
    func connection(connection: SKYLINKConnection, didConnectWithMessage errorMessage: String, success isSuccess: Bool) {
        if isSuccess {
            
            NSLog("Inside %@", #function)
        }
        else {
            let msgTitle: String = "Connection failed"
            let msg: String = errorMessage
            self.AlertMessage(msgTitle, msg:msg)
        }
    }
    
    func connection(connection: SKYLINKConnection, didDisconnectWithMessage errorMessage: String) {
        NSLog("Inside %@", #function)
        let msgTitle: String = "Disconnected"
        self.AlertMessage(msgTitle, msg:errorMessage)
    }
    
    func connection(connection: SKYLINKConnection, didJoinPeer userInfo: AnyObject, mediaProperties pmProperties: SKYLINKPeerMediaProperties, peerId: String) {
        NSLog("Inside %@", #function)
        
        self.skylinkConnection.lockTheRoom()
        self.remotePeerId = peerId
        self.receiverRole = self.isMaster
        if(userInfo as! String != "") {
            self.peerRole = userInfo as! String
        }
        else {
            self.peerRole = "false"
        }
        
        if(receiverRole == peerRole) {
            let msgTitle: String = "Disconnected"
            let errorMessage: String = "Users should not be the same role"
            self.AlertMessage(msgTitle, msg:errorMessage)
        }
        else {
            NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.performAfterConnected), userInfo: nil, repeats: false)
        }
        
    }
    
    func connection(connection: SKYLINKConnection, didLeavePeerWithMessage errorMessage: String, peerId: String) {
        NSLog("Inside %@", #function)
        self.remotePeerId = nil
        self.skylinkConnection.unlockTheRoom()
        let msgTitle = "Disconnected"
        let errorMsg = "Peer \(peerId) is left"
        self.AlertMessage(msgTitle, msg:errorMsg)
    }
    
    //MARK: Utils
    
    func addingBlock(blockX: CGFloat,blockY: CGFloat,blockSize: CGFloat) {
        let block = SKSpriteNode(imageNamed: "paddle2")
        BlockName = BlockName + String(blockSize)
        block.name = BlockName
        block.position = CGPoint(x: blockX, y: blockY)
        block.size = CGSizeMake(blockSize,20)
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
        block.physicsBody!.allowsRotation = false
        block.physicsBody!.friction = 0.0
        block.physicsBody!.affectedByGravity = false
        block.physicsBody!.dynamic = false
        block.physicsBody!.categoryBitMask = CategoryOfBody.block
        block.zPosition = 5
        block.setScale(0.0)
        addChild(block)
        let scale = SKAction.scaleTo(1.0, duration: 0.25)
        self.childNodeWithName(BlockName)!.runAction(scale)
    }
    
    func getCGpointFromString(pointString: String) -> CGPoint {
        let delimiter = ","
        let token = pointString.componentsSeparatedByString(delimiter)
        let stringX = token[0].stringByReplacingOccurrencesOfString("(", withString: "")
        let stringY = token[1].stringByReplacingOccurrencesOfString(")", withString: "")
        let pointx: CGFloat = CGFloat((stringX as NSString).doubleValue)
        let pointy: CGFloat = CGFloat((stringY as NSString).doubleValue)
        return CGPointMake(pointx,pointy)
    }
    
    
    func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = speedBallFloat
        if randomFloat(from: 0.0, to: 100.0) >= 50 {
            return -speedFactor
        } else {
            return speedFactor
        }
    }
    
    func randomFloat(from from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    func performAfterConnected() {
        myActivityIndicator.stopAnimating()
        NSNotificationCenter.defaultCenter().postNotificationName("connectedAlert",  object: nil,  userInfo:["msgTitle": "Connected",
            "errorMessage": "Successfully."])
        ball.hidden = false
        player1.hidden = false
        player2.hidden = false
        LabelPlayer1.hidden = false
        LabelPlayer2.hidden = false
        LabelRoundPlace.hidden = false
        gameState.enterState(WaitingForTap)
        
    }
    
    func AlertMessage(msg_title: String, msg:String) {
        NSLog("Inside %@", #function)
        NSNotificationCenter.defaultCenter().postNotificationName("disconnectedAlert",  object: nil,  userInfo:["msgTitle":msg_title,
            "errorMessage":msg])
        self.disConnect()
    }
    
    func disConnect() {
        NSLog("Inside %@", #function)
        self.skylinkConnection.unlockTheRoom()
        if (self.skylinkConnection != nil) {
            self.skylinkConnection.disconnect({() -> Void in
                NSNotificationCenter.defaultCenter().removeObserver(self)
            })
        }
    }
    
    
    // MARK: Events
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("Inside %@", #function)
        
        let touch = touches.first
        let positionTouch = touch!.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionTouch)
        if(touchedNode.name == "settingTap") {
            NSNotificationCenter.defaultCenter().postNotificationName("callSettingAction",  object: nil)
        }
        
        switch gameState.currentState {
            
        case is WaitingForTap:
            if(self.isMaster == "true") {
                self.messages = ["isStartToPlay" : "true"]
                self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                gameState.enterState(Playing)
            }
            isFingerOnPlayer1 = true
            isFingerOnPlayer2 = true
            
        case is Playing:
            let touch = touches.first
            let positionTouch = touch!.locationInNode(self)
            let touchedNode = self.nodeAtPoint(positionTouch)
            
            if let name = touchedNode.name
            {
                if name == LabelPause
                {
                    if (isMaster == "true") {
                        isPlay = true
                        isStop = false
                        
                        self.messages = ["isLabelDismiss" : "true"]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    }
                    if(isMaster == "false") {
                        //let pause = childNodeWithName(LabelPause) as! SKLabelNode
                        pauseLabel.hidden = true
                    }
                    
                    if(roundGame != gameStock && isMaster == "true") {
                        ball.alpha = 1.0
                        self.messages = ["ballAlpha" : "false"]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                        ball.position = CGPoint(x: 375,y: 667)
                        ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))
                        
                        var blockX : CGFloat!
                        var blockY : CGFloat!
                        var blockSize : CGFloat!
                        if(roundGame == Level1) {
                            blockX = 560
                            blockY = 485
                            blockSize = 130
                        }
                        else if(roundGame == Level2) {
                            blockX = 190
                            blockY = 890
                            blockSize = 170
                        }
                        else if(roundGame == Level3) {
                            blockX = 375
                            blockY = 667
                            blockSize = 200
                        }
                        self.addingBlock(blockX,blockY: blockY,blockSize: blockSize)
                        self.messages = ["isPartial" : "true", "blockPosition" : String(CGPoint(x: blockX, y: blockY)), "blockSize" : String(blockSize)]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    }
                }
                
            }
            
            if let getBody = physicsWorld.bodyAtPoint(positionTouch) {
                if getBody.node!.name == PaddleCategoryName {
                    isFingerOnPlayer1 = true
                    self.isFingerOnPlayer2 = false
                }
            }
            
        case is GameOver:
            NSNotificationCenter.defaultCenter().postNotificationName("callInitialVC",  object: nil)
            self.disConnect()
        default:
            break
        }
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("Inside %@", #function)
        let touch = touches.first
        let touchLocation = touch!.locationInNode(self)
        let previousLocation = touch!.previousLocationInNode(self)
        let paddle = childNodeWithName(PaddleCategoryName) as! SKSpriteNode
        var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
        paddleX = max(paddleX, paddle.size.width/2)
        paddleX = min(paddleX, size.width - paddle.size.width/2)
        paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
        self.messages = ["paddlePosition" : String(paddle.position)]
        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        NSLog("Inside %@", #function)
        isFingerOnPlayer1 = false
        isFingerOnPlayer2 = false
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBeginContact(contact: SKPhysicsContact) {
        // Create variables to handle the contact between two bodies
        
        if gameState.currentState is Playing {
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            } else {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if firstBody.categoryBitMask == CategoryOfBody.ball && secondBody.categoryBitMask == CategoryOfBody.block {
                NSLog("Ball and Block Touch")
            }
            
            if firstBody.categoryBitMask == CategoryOfBody.margin && secondBody.categoryBitMask == CategoryOfBody.ball {
                var status : Bool!
                // Implement Game Over
                if firstBody.node!.name! == "Lower" {
                    NSLog("Margin hit lower!")
                    ball.alpha = 0
                    self.messages = ["ballAlpha" : "true"]
                    self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    status = true
                    if (isMaster == "true") {
                        tCount = tCount + 1
                        roundGame = roundGame + 1
                        self.messages = ["tCount" : String(tCount), "roundGame" : String(roundGame)]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    }
                    
                }
                else if firstBody.node!.name! == "Upper" {
                    NSLog("Margine hit upper!")
                    ball.alpha = 0
                    self.messages = ["ballAlpha" : "true"]
                    self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    status = false
                    // statusArray.append(status)
                    if (isMaster == "true") {
                        fCount = fCount + 1
                        roundGame = roundGame + 1
                        self.messages = ["fCount" : String(fCount), "roundGame" : String(roundGame)]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    }
                }
                
                if(roundGame == gameStock)  {
                    roundGame = 4
                    if(tCount > fCount) {
                        status = true
                    }
                    else {
                        status = false
                    }
                    gameState.enterState(GameOver)
                    if (isMaster == "true") {
                        gameWon = status
                        self.messages = ["isFinished" : "true", "status" : String(status)]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    }
                }
                else {
                    if (isMaster == "true") {
                        isPlay = false
                        isStop = true
                        self.messages = ["pauseMessage" :  ("Round - " + String(roundGame-1) + " is completed")]
                        self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
                    }
                }
            }
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        if(remotePeerId != nil && gameState.currentState is Playing && isStop == false) {
            gameState.updateWithDeltaTime(currentTime)
            if (ballPosX != nil && ballPosY != nil && isMaster == "true") {
                self.messages = ["ballPosY" : ballPosY!,
                                 "ballPosX" : ballPosX!]
                self.skylinkConnection.sendBinaryData(NSKeyedArchiver.archivedDataWithRootObject(messages), peerId: remotePeerId)
            }
        }
    }
    
    deinit {
        //        roundGame = 1
        //        fCount = 0
        //        tCount = 0
        
        self.skylinkConnection.unlockTheRoom()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}



