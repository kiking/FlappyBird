//
//  GameScene.swift
//  FlappyBird
//
//  Created by 吴国权 on 2017/11/6.
//  Copyright © 2017年 NJU. All rights reserved.
//

import SpriteKit
import GameplayKit

let birdCategory: UInt32 = 0x1 << 0
let pipeCategory: UInt32 = 0x1 << 1
let floorCategory: UInt32 = 0x1 << 2
let bulletCategory: UInt32 = 0x1 << 3
let supplyCategory: UInt32 = 0x1 << 4

protocol exitDelegate: NSObjectProtocol
{
    func exit()
}

class GameScene: SKScene , SKPhysicsContactDelegate ,restartDelegate
{
    
    enum GameStatus
    {
        case idle           //初始化
        case running        //游戏运行中
        case over           //游戏结束
    }
    var gameStatus: GameStatus = .idle       //表示当前游戏状态的变量，初始值为初始化状态

    var floor1: SKSpriteNode!
    var floor2: SKSpriteNode!
    
    var bird: SKSpriteNode!
    
    lazy var gameOverLabel:SKLabelNode = {                  //懒加载
        let label = SKLabelNode(fontNamed:"Chalkduster")
        label.text="Game Over"
        label.fontSize=58
        //label.fontColor=UIColor.black
        return label
    }()
    
    lazy var newrecord:SKLabelNode = {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text="New Record!"
        label.fontSize = 25
        label.fontColor=UIColor.red
        label.zRotation=CGFloat(-Double.pi/5)
        label.zPosition=1
        return label
    }()
    
    lazy var metersLabel:SKLabelNode = {
        let label = SKLabelNode(text:"meters:0")
        label.verticalAlignmentMode = .top
        label.horizontalAlignmentMode = .center
        label.fontSize=37
        //label.fontColor=UIColor.black
        return label
    }()
    
    lazy var sound = SoundManager()
    
    var meters = 0 {
        didSet {
            metersLabel.text="meters:\(meters)"
        }
    }
    
    let defaultStand = UserDefaults.standard
    
    weak var edelegate:exitDelegate?
    
    //管道宽度在60
    let pipeWidth=CGFloat(60)
    
    var shootingButton:UIButton=UIButton(type: .system)
    
    let bn = 5
    var bulletview = [UIImageView]()
    
    var fire :UIView!
    
    override func didMove(to view: SKView)
    {//didMove()方法会在当前场景被显示到一个view上的时候调用，你可以在里面做一些初始化的工作
        self.backgroundColor=SKColor(red:0/255.0,green:205.0/255.0,blue:205.0/255.0,alpha:1.0)
        /*let background=SKSpriteNode(imageNamed:"bg1")
        background.position=CGPoint(x:self.size.width*0.5,y:self.size.height*0.65)
        background.zPosition=(-1)
        addChild(background)*/
        
        addChild(sound)
        
        fire=FireView(frame:self.frame)
        
        if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Music.rawValue)
        {
            sound.playBackGround()
        }
        
        
        //set scene physics
        self.physicsBody=SKPhysicsBody(edgeLoopFrom:self.frame) //给场景添加一个物理体，这个物理题就是一条沿着场景四周的边，限制了游戏范围，其他物理体就不会跑出这个场景
        self.physicsWorld.contactDelegate=self //物理世界的碰撞检测代理为场景自己，这样如果这个物理世界里面有两个可以碰撞接触的物理体碰到一起了就会通知他的代理
        
        self.physicsWorld.gravity=CGVector(dx:0.0,dy:-3.0)
        
        //set Meter Label
        metersLabel.position=CGPoint(x:self.size.width*0.5,y:self.size.height)
        metersLabel.zPosition=100;
        addChild(metersLabel)
        
        //Set floors
        
        floor1=SKSpriteNode(imageNamed:"floor")
        floor1.yScale=0.5
        floor1.xScale=2.0
        floor1.anchorPoint=CGPoint(x:0,y:0)
        floor1.position=CGPoint(x:0,y:0)
        //设置floor1的物理属性
        floor1.physicsBody=SKPhysicsBody(edgeLoopFrom:CGRect(x:0,y:0,width:floor1.size.width,height:floor1.size.height))
        floor1.physicsBody?.categoryBitMask=floorCategory
        addChild(floor1)
        
        floor2=SKSpriteNode(imageNamed:"floor")
        floor2.xScale=floor1.xScale
        floor2.yScale=floor1.yScale
        floor2.anchorPoint=CGPoint(x:0,y:0)
        floor2.position=CGPoint(x:floor1.size.width,y:0)
        //设置floor2的物理属性
        floor2.physicsBody=SKPhysicsBody(edgeLoopFrom:CGRect(x:0,y:0,width:floor2.size.width,height:floor2.size.height))
        floor2.physicsBody?.categoryBitMask=floorCategory
        addChild(floor2)
        
        //Set bird
        switch defaultStand.string(forKey: UserDefaultKeys.costume)
        {
        case "Butterfly"?:
            bird=SKSpriteNode(imageNamed:"butterfly0")
        case "Helicopter"?:
            bird=SKSpriteNode(imageNamed:"helicopter0")
        default:
            bird=SKSpriteNode(imageNamed:"player1")
        }
        //bird.size=CGSize(width: 50.0, height: 47.0)
        bird.physicsBody=SKPhysicsBody(texture:bird.texture!,size:bird.size)
        bird.physicsBody?.allowsRotation=false //禁止旋转
        bird.physicsBody?.categoryBitMask=birdCategory //设置小鸟物理体标识
        bird.physicsBody?.restitution=0
        bird.physicsBody?.contactTestBitMask = floorCategory | pipeCategory | supplyCategory //设置可以小鸟碰撞检测的物理体
        addChild(bird)
        
        shootingButton.frame=CGRect(x: self.size.width*0.8, y: self.size.height*0.7, width: self.size.width*0.13, height: self.size.width*0.13)
        //shootingButton.backgroundColor=UIColor.black
        shootingButton.setBackgroundImage(UIImage(named:"射击"), for: UIControlState.normal)
        shootingButton.layer.cornerRadius=shootingButton.frame.size.width*0.5
        shootingButton.layer.masksToBounds=true
        self.view?.addSubview(shootingButton)
        shootingButton.addTarget(self, action: #selector(shoot(button:)), for: .touchUpInside)
        
        shuffle()
        
    }
    
    @objc func shoot(button:UIButton)
    {
        if bulletview.count>0 {
            var bp : String
            
            switch defaultStand.string(forKey: UserDefaultKeys.costume)
            {
            case "Butterfly"?:
                bp = "胡萝卜"
            case "Helicopter"?:
                bp = "子弹"
            default:
                bp = "手里剑"
            }
            
            let bulletTexture = SKTexture(imageNamed: bp)
            let bulletSize=CGSize(width: 42, height: 42)
            let bullet = SKSpriteNode(texture: bulletTexture,size:bulletSize)
        
            bullet.physicsBody=SKPhysicsBody(texture:bulletTexture,size:bulletSize)
            bullet.physicsBody?.affectedByGravity=false
            bullet.physicsBody?.allowsRotation=false
            bullet.physicsBody?.categoryBitMask = bulletCategory
            bullet.name="bullet"
            bullet.physicsBody?.contactTestBitMask = pipeCategory
            bullet.position=CGPoint(x:bird.position.x+bird.size.width*0.5+bullet.size.width*0.6,y:bird.position.y)
            addChild(bullet)
            
            if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
            {
                sound.playShoot()
            }
            
            bulletview.last?.removeFromSuperview()
            
            bulletview.removeLast()
            
            print(bulletview.count)
        
            bullet.run(SKAction.move(by: CGVector(dx:self.size.width-bullet.position.x+bullet.size.width*0.5,dy:0), duration: 1),completion: {bullet.removeFromParent()})
        }
    }
    
    func shuffle()
    {
        //游戏初始化处理方法
        gameStatus = .idle
        meters=0
        removeAllPipesNode()
        gameOverLabel.removeFromParent()
        newrecord.removeFromParent()
        
        bird.position=CGPoint(x:self.size.width*0.5,y:self.size.height*0.65)
        bird.physicsBody?.isDynamic=false
        birdStartFly()
        isUserInteractionEnabled=true
        shootingButton.isUserInteractionEnabled=true
        
        var bbnn = 0
        
        var bp : String
        switch defaultStand.string(forKey: UserDefaultKeys.costume)
        {
        case "Butterfly"?:
            bp = "胡萝卜"
        case "Helicopter"?:
            bp = "子弹"
        default:
           bp = "手里剑"
        }
        
        for bv in bulletview
        {
            bv.removeFromSuperview()
        }
        
        bulletview.removeAll()
        
        while bbnn < bn
        {
            let bulleticon = UIImageView(image: UIImage(named: bp))
            bulleticon.frame=CGRect(x: CGFloat(bbnn)*self.size.width*0.06, y: 0, width: self.size.width*0.06, height: self.size.width*0.06)
            bulletview.append(bulleticon)
            self.view?.addSubview(bulleticon)
            bbnn+=1
        }
        print(bulletview.count)
    }
    
    func startGame()
    {
        //游戏开始处理方法
        gameStatus = .running
        bird.physicsBody?.isDynamic=true
        startCreateRandomPipesAction()
        //sound.playBackGround()
        
    }
    
    func gameOver()
    {
        //游戏结束处理方法
        gameStatus = .over
        
        birdStopFly()
        
        //sound.stopBackGround()
        
        stopCreateRandomPipesAction()
        
        //禁止用户点击屏幕
        isUserInteractionEnabled=false
        shootingButton.isUserInteractionEnabled=false
        
        //添加gameOverLabel到场景里
        addChild(gameOverLabel)
        
        gameOverLabel.zPosition = 1
        
        //设置gameOverLabel初始位置在屏幕顶部
        gameOverLabel.position=CGPoint(x:self.size.width*0.5,y:self.size.height)
        //让gameOverLabel通过一个动画action移动到屏幕中间
        gameOverLabel.run(SKAction.move(by: CGVector(dx: 0,dy:-self.size.height*0.4), duration: 0.5), completion: {
            let gameover=GameOver(frame:CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            gameover.rdelegate=self
            self.view?.addSubview(gameover)
        })
        
        //更新rank榜
        switch defaultStand.string(forKey: UserDefaultKeys.difficulty)
        {
        case "crazy"?:
            if meters>defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop1.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop4.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop3.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop2.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop3.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop1.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop2.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.crazy.ctop1.rawValue)
                self.view?.addSubview(fire)
                addChild(newrecord)
                newrecord.position=CGPoint(x:self.size.width*0.8,y:self.size.height*0.7)
                if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
                {
                    sound.playNewRecord()
                }
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop2.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop4.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop3.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop2.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop3.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.crazy.ctop2.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop3.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop4.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop3.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop4.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.crazy.ctop3.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop4.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop4.rawValue),
                                 forKey: UserDefaultKeys.crazy.ctop5.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.crazy.ctop4.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.crazy.ctop5.rawValue)
            {
                defaultStand.set(meters, forKey: UserDefaultKeys.crazy.ctop5.rawValue)
            }
        case "hard"?:
            if meters>defaultStand.integer(forKey: UserDefaultKeys.hard.htop1.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop4.rawValue),
                                 forKey: UserDefaultKeys.hard.htop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop3.rawValue),
                                 forKey: UserDefaultKeys.hard.htop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop2.rawValue),
                                 forKey: UserDefaultKeys.hard.htop3.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop1.rawValue),
                                 forKey: UserDefaultKeys.hard.htop2.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.hard.htop1.rawValue)
                self.view?.addSubview(fire)
                addChild(newrecord)
                newrecord.position=CGPoint(x:self.size.width*0.8,y:self.size.height*0.7)
                if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
                {
                    sound.playNewRecord()
                }
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.hard.htop2.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop4.rawValue),
                                 forKey: UserDefaultKeys.hard.htop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop3.rawValue),
                                 forKey: UserDefaultKeys.hard.htop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop2.rawValue),
                                 forKey: UserDefaultKeys.hard.htop3.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.hard.htop2.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.hard.htop3.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop4.rawValue),
                                 forKey: UserDefaultKeys.hard.htop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop3.rawValue),
                                 forKey: UserDefaultKeys.hard.htop4.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.hard.htop3.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.hard.htop4.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.hard.htop4.rawValue),
                                 forKey: UserDefaultKeys.hard.htop5.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.hard.htop4.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.hard.htop5.rawValue)
            {
                defaultStand.set(meters, forKey: UserDefaultKeys.hard.htop5.rawValue)
            }
        case "difficult"?:
            if meters>defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop1.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop4.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop3.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop2.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop3.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop1.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop2.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.difficult.dtop1.rawValue)
                self.view?.addSubview(fire)
                addChild(newrecord)
                newrecord.position=CGPoint(x:self.size.width*0.8,y:self.size.height*0.7)
                if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
                {
                    sound.playNewRecord()
                }
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop2.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop4.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop3.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop2.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop3.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.difficult.dtop2.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop3.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop4.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop3.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop4.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.difficult.dtop3.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop4.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop4.rawValue),
                                 forKey: UserDefaultKeys.difficult.dtop5.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.difficult.dtop4.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.difficult.dtop5.rawValue)
            {
                defaultStand.set(meters, forKey: UserDefaultKeys.difficult.dtop5.rawValue)
            }
        case "general"?:
            if meters>defaultStand.integer(forKey: UserDefaultKeys.general.gtop1.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop4.rawValue),
                                 forKey: UserDefaultKeys.general.gtop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop3.rawValue),
                                 forKey: UserDefaultKeys.general.gtop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop2.rawValue),
                                 forKey: UserDefaultKeys.general.gtop3.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop1.rawValue),
                                 forKey: UserDefaultKeys.general.gtop2.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.general.gtop1.rawValue)
                self.view?.addSubview(fire)
                addChild(newrecord)
                newrecord.position=CGPoint(x:self.size.width*0.8,y:self.size.height*0.7)
                if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
                {
                    sound.playNewRecord()
                }
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.general.gtop2.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop4.rawValue),
                                 forKey: UserDefaultKeys.general.gtop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop3.rawValue),
                                 forKey: UserDefaultKeys.general.gtop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop2.rawValue),
                                 forKey: UserDefaultKeys.general.gtop3.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.general.gtop2.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.general.gtop3.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop4.rawValue),
                                 forKey: UserDefaultKeys.general.gtop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop3.rawValue),
                                 forKey: UserDefaultKeys.general.gtop4.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.general.gtop3.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.general.gtop4.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.general.gtop4.rawValue),
                                 forKey: UserDefaultKeys.general.gtop5.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.general.gtop4.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.general.gtop5.rawValue)
            {
                defaultStand.set(meters, forKey: UserDefaultKeys.general.gtop5.rawValue)
            }
        default:
            if meters>defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop1.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop4.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop3.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop2.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop3.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop1.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop2.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.ordinary.otop1.rawValue)
                self.view?.addSubview(fire)
                addChild(newrecord)
                newrecord.position=CGPoint(x:self.size.width*0.8,y:self.size.height*0.7)
                if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
                {
                    sound.playNewRecord()
                }
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop2.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop4.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop3.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop4.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop2.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop3.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.ordinary.otop2.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop3.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop4.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop5.rawValue)
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop3.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop4.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.ordinary.otop3.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop4.rawValue)
            {
                defaultStand.set(defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop4.rawValue),
                                 forKey: UserDefaultKeys.ordinary.otop5.rawValue)
                defaultStand.set(meters, forKey: UserDefaultKeys.ordinary.otop4.rawValue)
            }
            else if meters>defaultStand.integer(forKey: UserDefaultKeys.ordinary.otop5.rawValue)
            {
                defaultStand.set(meters, forKey: UserDefaultKeys.ordinary.otop5.rawValue)
            }
        }
        
    }
    
    
    func again()
    {
        shuffle()
        fire.removeFromSuperview()
        sound.playNewRecord()
        sound.stopNewRecord()
        
    }
    
    func clickMenu()
    {
        edelegate?.exit()
    }
    
    //开始飞
    func birdStartFly()
    {
        
        var flyAction:SKAction
        
        switch defaultStand.string(forKey: UserDefaultKeys.costume)
        {
        case "Butterfly"?:
            flyAction = SKAction.animate(with: [SKTexture(imageNamed:"butterfly0"),
                                                SKTexture(imageNamed:"butterfly1"),
                                                SKTexture(imageNamed:"butterfly2"),
                                                SKTexture(imageNamed:"butterfly3"),
                                                SKTexture(imageNamed:"butterfly4"),
                                                SKTexture(imageNamed:"butterfly5"),
                                                SKTexture(imageNamed:"butterfly6"),
                                                SKTexture(imageNamed:"butterfly7"),
                                                SKTexture(imageNamed:"butterfly8"),
                                                SKTexture(imageNamed:"butterfly9"),
                                                SKTexture(imageNamed:"butterfly10")],
                                         timePerFrame: 0.07)
        case "Helicopter"?:
            flyAction = SKAction.animate(with: [SKTexture(imageNamed:"helicopter0"),
                                                SKTexture(imageNamed:"helicopter1"),
                                                SKTexture(imageNamed:"helicopter2"),
                                                SKTexture(imageNamed:"helicopter3")],
                                         timePerFrame: 0.15)
        default:
            flyAction = SKAction.animate(with: [SKTexture(imageNamed:"player1"),
                                                SKTexture(imageNamed:"player2"),
                                                SKTexture(imageNamed:"player3"),
                                                SKTexture(imageNamed:"player2")],
                                             timePerFrame: 0.15)
        }
        bird.run(SKAction.repeatForever(flyAction), withKey: "fly")
    }
    
    //停止飞
    func birdStopFly()
    {
        bird.removeAction(forKey: "fly")
    }
    
    func moveScene()
    {
        //make floor move
        floor1.position=CGPoint(x:floor1.position.x-1,y:floor1.position.y)
        floor2.position=CGPoint(x:floor2.position.x-1,y:floor2.position.y)
        
        //check floor position
        if floor1.position.x < -floor1.size.width
        {
            floor1.position=CGPoint(x:floor2.position.x+floor2.size.width,y:floor1.position.y)
        }
        if floor2.position.x < -floor2.size.width
        {
            floor2.position=CGPoint(x:floor1.position.x+floor1.size.width,y:floor2.position.y)
        }
        
        //循环检查场景的子节点，同时这个子节点的名字要为pipe
        for pipeNode in self.children where pipeNode.name=="pipe"||pipeNode.name=="supply"
        {
            //因为我们要用到水管的size，但是SKNode没有size属性，所以我们要把它转成SKSpriteNode
            if let pipeSprite = pipeNode as? SKSpriteNode
            {
                //将水管左移1
                pipeSprite.position = CGPoint(x:pipeSprite.position.x - 1,y:pipeSprite.position.y)
                if pipeSprite.position.x > bird.position.x - pipeSprite.size.width
                    && pipeSprite.position.x < bird.position.x - pipeSprite.size.width + 1
                    && defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
                    && pipeNode.name == "pipe"
                {
                    sound.playPipe()
                }
                
                //检查水管是否完全超出屏幕左侧了，如果是则将它从场景里移除
                if pipeSprite.position.x < -pipeSprite.size.width*0.5
                {
                    pipeSprite.removeFromParent()
                }
            }
        }
    }
    
    func startCreateRandomPipesAction()
    {
        //创建一个等待的action，等待时间的平均值为5.5秒，变化范围为1秒
        
        let waitAct1=SKAction.wait(forDuration:3)
        let waitAct2=SKAction.wait(forDuration:3)
        
        //创建一个产生随机水管的action，这个action实际上就是调用一下我们上面新添加的那个createRandomPipes()方法
        
        let generatePipeAct=SKAction.run{
            self.createRandomPipes()
        }
        
        let generateBulletAct = SKAction.run{
            self.addSupply()
        }
        
        //让场景开始重复循环执行“等待”->”创建“->“等待”->”创建“……
        //并且给这个循环的动作设置了一个叫做”createPipe“的key来标记它
        run(SKAction.repeatForever(SKAction.sequence([generatePipeAct,waitAct1,generateBulletAct,waitAct2])),withKey:"createPipe")
        
    }
    
    
    
    func stopCreateRandomPipesAction()
    {
        self.removeAction(forKey: "createPipe")
    }
    
    func removeAllPipesNode()
    {
        for pipe in self.children where pipe.name=="pipe"||pipe.name=="supply"
        {
            //循环检查场景的子节点，同时这个子节点的名字要为pipe
            pipe.removeFromParent()
        }
    }
    
    func createRandomPipes()
    {
        //先计算地板顶部到屏幕顶部的总可用高度
        let height = self.size.height-floor1.size.height
        
        //计算上下管道中间的空挡的随机高度，空挡最小高度为2.5倍小鸟高度，最大高度为3.5倍小鸟高度
        var pipeGap:CGFloat = bird.size.height //CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*2.5
        //["crazy","hard","difficult","general","ordinary"]
        
        switch defaultStand.string(forKey: UserDefaultKeys.difficulty)
        {
        case "crazy"?:
            pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*1.5
        case "hard"?:
            pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*2.0
        case "difficult"?:
            pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*2.5
        case "general"?:
            pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*3.0
        case "ordinary"?:
            pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height)))+bird.size.height*3.5
        default:
            pipeGap=height
        }
        
        
        if pipeGap > height
        {
            pipeGap = height
        }
        
        
        //随机计算顶部pipe的随机高度，这个高度肯定要小于（总的可用高度减去空挡的高度）
        let topPipeHeight=CGFloat(arc4random_uniform(UInt32(height-pipeGap)))
        
        //总可用高度减去空挡gap高度，减去顶部水管topPipe高度剩下的就为底部的bottomPipe高度
        let bottomPipeHeight=height-pipeGap-topPipeHeight
        
        //调用添加水管到场景方法
        addPipes(topSize: CGSize(width:pipeWidth,height:topPipeHeight), bottomSize: CGSize(width:pipeWidth,height:bottomPipeHeight))
        
    }
    
    func addSupply() {
        if arc4random_uniform(100)>60
        {
        
            let supplyTexture = SKTexture(imageNamed: "礼物")
            let supplySize=CGSize(width: 42, height: 42)
            let supply = SKSpriteNode(texture: supplyTexture,size:supplySize)
        
            supply.physicsBody=SKPhysicsBody(texture:supplyTexture,size:supplySize)
            supply.physicsBody?.isDynamic=false
            supply.physicsBody?.categoryBitMask = supplyCategory
            supply.name="supply"
            supply.physicsBody?.contactTestBitMask = birdCategory
            supply.physicsBody?.collisionBitMask = 0
            supply.position=CGPoint(x:self.size.width+supply.size.width*0.5,
                                    y:self.size.height*0.25+CGFloat(arc4random_uniform(UInt32(self.size.height/2))))
            addChild(supply)
        }
    }
    
    func addPipes(topSize: CGSize, bottomSize: CGSize)
    {
        //创建上水管
        var top : String
        var bottom : String
        switch defaultStand.string(forKey: UserDefaultKeys.costume)
        {
        case "Butterfly"?:
            top = "lotus_top"
            bottom = "lotus_bottom"
        case "Helicopter"?:
            top = "wood_top"
            bottom = "wood_bottom"
        default:
            top = "topPipe"
            bottom = "bottomPipe"
        }
        let topTexture = SKTexture(imageNamed:top) //利用上水管图片创建一个上水管纹理对象
        let topPipe = SKSpriteNode(texture: topTexture,size: topSize) //利用上水管纹理对象和传入的上水管大小参数创建一个上水管对象
        //配置上水管物理体
        topPipe.physicsBody=SKPhysicsBody(texture:topTexture,size:topSize)
        topPipe.physicsBody?.isDynamic=false
        topPipe.physicsBody?.categoryBitMask = pipeCategory
        topPipe.name = "pipe" //给这个水管取个名字叫Pipe
        topPipe.position=CGPoint(x:self.size.width+topPipe.size.width*0.5,y:self.size.height-topPipe.size.height*0.5) //设置上水管的垂直位置为顶部贴着屏幕顶部，水平位置在屏幕右侧之外
        
        //创建下水管，每一句方法都与创建上水管意义相同
        let bottomTexture = SKTexture(imageNamed:bottom)
        let bottomPipe = SKSpriteNode(texture: bottomTexture,size: bottomSize)
        //配置下水管物理体
        bottomPipe.physicsBody=SKPhysicsBody(texture:bottomTexture,size:bottomSize)
        bottomPipe.physicsBody?.isDynamic=false
        bottomPipe.physicsBody?.categoryBitMask=pipeCategory
        bottomPipe.name="pipe"
        bottomPipe.position=CGPoint(x:self.size.width+bottomPipe.size.width*0.5,
                                    y:self.floor1.size.height+bottomPipe.size.height*0.5) //设置下水管的垂直位置为底部贴着地面的顶部，水平位置在屏幕右侧之外
        
        //将上下水管添加到场景里
        addChild(topPipe)
        addChild(bottomPipe)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {//didBegin()会在当前物理世界有两个物理体碰撞接触了则回调用，这两个碰撞了的物理体的信息都在contact这个参数里面，分别是bodyA和bodyB
        //先检查游戏状态是否在运行中，如果不在运行中则不做操作，直接return
        if gameStatus != .running { return }
        
        //为了方便我们判断碰撞的bodyA和bodyB的categoryBitMask哪个小，小的则将它保存到新建的变量bodyA里，大的则保存到新建的变量bodyB里
        var bodyA:SKPhysicsBody
        var bodyB:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            bodyA=contact.bodyA
            bodyB=contact.bodyB
        }
        else
        {
            bodyB=contact.bodyA
            bodyA=contact.bodyB
        }
        
        //接下来判断bodyA是否为小鸟，bodyB是否为水管或者地面，如果是则游戏结束，直接调用gameOver()方法
        if (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == pipeCategory) ||
            (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == floorCategory)
        {
            //撞击音效
            if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
            {
                sound.playPunch()
            }
            let endAction = SKAction.animate(with: [SKTexture(imageNamed:"end0"),
                                                    SKTexture(imageNamed:"end1"),
                                                    SKTexture(imageNamed:"end2"),
                                                    SKTexture(imageNamed:"end3"),
                                                    SKTexture(imageNamed:"end4"),
                                                    SKTexture(imageNamed:"end5"),
                                                    SKTexture(imageNamed:"end6"),
                                                    SKTexture(imageNamed:"end7"),
                                                    SKTexture(imageNamed:"end8"),
                                                    SKTexture(imageNamed:"end9"),
                                                    SKTexture(imageNamed:"end10"),
                                                    SKTexture(imageNamed:"end11"),
                                                    SKTexture(imageNamed:"end12"),
                                                    SKTexture(imageNamed:"end13"),
                                                    SKTexture(imageNamed:"end14")],
                                             timePerFrame: 0.05)
            let end = SKSpriteNode(imageNamed:"end0")
            end.position=(bodyA.node?.position)!
            addChild(end)
            end.run(endAction, completion:{end.removeFromParent()})
            gameOver()
        }
        
        if (bodyB.categoryBitMask == bulletCategory && bodyA.categoryBitMask == pipeCategory)
        {
            if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
            {
                 sound.playBomb()
            }
           
            let bombAction = SKAction.animate(with: [SKTexture(imageNamed:"0"),
                                                     SKTexture(imageNamed:"1"),
                                                     SKTexture(imageNamed:"2"),
                                                     SKTexture(imageNamed:"3"),
                                                     SKTexture(imageNamed:"4"),
                                                     SKTexture(imageNamed:"5"),
                                                     SKTexture(imageNamed:"6"),
                                                     SKTexture(imageNamed:"7"),
                                                     SKTexture(imageNamed:"8"),
                                                     SKTexture(imageNamed:"9"),
                                                     SKTexture(imageNamed:"10"),
                                                     SKTexture(imageNamed:"11"),
                                                     SKTexture(imageNamed:"12"),
                                                     SKTexture(imageNamed:"13"),
                                                     SKTexture(imageNamed:"14"),
                                                     SKTexture(imageNamed:"15"),
                                                     SKTexture(imageNamed:"16"),
                                                     SKTexture(imageNamed:"17"),
                                                     SKTexture(imageNamed:"18")],
                                              timePerFrame: 0.05)
            let bomb = SKSpriteNode(imageNamed:"0")
            bomb.position=contact.contactPoint
            addChild(bomb)
            bomb.run(bombAction, completion: {bomb.removeFromParent()})
            bodyA.node?.removeFromParent()
            bodyB.node?.removeFromParent()
        }
        
        if (bodyB.categoryBitMask == supplyCategory && bodyA.categoryBitMask == birdCategory)
        {
            bodyB.node?.removeFromParent()
            if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
            {
                sound.playSupply()
            }
            if (bulletview.count<bn)
            {
                var bp : String
                switch defaultStand.string(forKey: UserDefaultKeys.costume)
                {
                case "Butterfly"?:
                    bp = "胡萝卜"
                case "Helicopter"?:
                    bp = "子弹"
                default:
                    bp = "手里剑"
                }
                let bulleticon = UIImageView(image: UIImage(named: bp))
                bulleticon.frame=CGRect(x: CGFloat(bulletview.count)*self.size.width*0.06, y: 0, width: self.size.width*0.06, height: self.size.width*0.06)
                bulletview.append(bulleticon)
                self.view?.addSubview(bulleticon)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {//touchesBegan()是SKScene自带的系统方法，当玩家手指点击到屏幕上的时候回调用
        switch  gameStatus
        {
        case .idle:
            startGame()
        case .running:
            //print("给小鸟一个向上的力")
            if defaultStand.bool(forKey: UserDefaultKeys.systemsetup.Sounds.rawValue)
            {
                sound.playFly()
            }
            bird.physicsBody?.applyImpulse(CGVector(dx:0,dy:(bird.physicsBody?.mass)!*320))
            
        case .over:
            shuffle()
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {//update()方法为SKScene自带的系统方法，在画面每一帧刷新的时候就会调用一次
        // Called before each frame is rendered
        
        if gameStatus == .running
        {
            meters+=1
        }
        
        if gameStatus != .over
        {
            moveScene()
        }
    }
}
