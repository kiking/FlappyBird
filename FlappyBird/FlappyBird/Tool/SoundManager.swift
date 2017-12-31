//
//  SoundManager.swift
//  FlappyBird
//
//  Created by 吴国权 on 2017/12/11.
//  Copyright © 2017年 NJU. All rights reserved.
//

import SpriteKit

import SpriteKit
//引入多媒体框架
import AVFoundation

class SoundManager :SKNode
{
    //申明一个播放器
    var bgMusicPlayer = AVAudioPlayer()
    
    var nrMusicPlayer = AVAudioPlayer()
    
    //扇动翅膀的音效
    let flyAct = SKAction.playSoundFileNamed("wing.wav", waitForCompletion: false)
    
    let punchAct = SKAction.playSoundFileNamed("punch.mp3", waitForCompletion: false)
    
    let pipeAct = SKAction.playSoundFileNamed("pipe.mp3", waitForCompletion: false)
    
    let shootAct = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
    
    let bombAct = SKAction.playSoundFileNamed("bomb.mp3", waitForCompletion: false)
    
    let supplyAct = SKAction.playSoundFileNamed("point.wav", waitForCompletion: false)
    
    //播放背景音乐的音效
    func playBackGround()
    {
        //print("开始播放背景音乐!")
        //获取bg.mp3文件地址
        var bgMusicURL : URL
        switch UserDefaults.standard.string(forKey: UserDefaultKeys.costume)
        {
        case "Butterfly"?:
            bgMusicURL =  Bundle.main.url(forResource: "梁祝", withExtension: "mp3")!
        case "Helicopter"?:
            bgMusicURL =  Bundle.main.url(forResource: "Please Don't Go", withExtension: "mp3")!
        default:
            bgMusicURL =  Bundle.main.url(forResource: "Always", withExtension: "mp3")!
        }
        //根据背景音乐地址生成播放器
        try! bgMusicPlayer = AVAudioPlayer (contentsOf: bgMusicURL)
        //设置为循环播放(
        bgMusicPlayer.numberOfLoops = -1
        //准备播放音乐
        bgMusicPlayer.prepareToPlay()
        //播放音乐
        bgMusicPlayer.play()
    }
    
    func playNewRecord()
    {
        let nrURL=Bundle.main.url(forResource: "newrecord", withExtension: "mp3")!
        
        try! nrMusicPlayer = AVAudioPlayer (contentsOf: nrURL)
     
        nrMusicPlayer.numberOfLoops = -1
        
        nrMusicPlayer.prepareToPlay()
        
        nrMusicPlayer.play()
    }
    
    func stopBackGround()
    {
        //print("停止播放背景音乐！")
        bgMusicPlayer.stop()
    }
    
    func stopNewRecord()
    {
        nrMusicPlayer.stop()
    }
    
    //播放点击音效动作的方法
    func playFly()
    {
        //print("播放音效!")
        self.run(flyAct)
    }
    
    func playPunch()
    {
        //撞击音效
        self.run(punchAct)
    }
    
    func playPipe()
    {
        //通过
        self.run(pipeAct)
    }
    
    func playShoot()
    {
        //射出子弹
        self.run(shootAct)
    }
    
    func playBomb()
    {
        //子弹和pipe同归于尽
        self.run(bombAct)
    }
    
    func playSupply()
    {
        self.run(supplyAct)
    }
    
}

