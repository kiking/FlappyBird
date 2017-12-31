//
//  GameOver.swift
//  FlappyBird
//
//  Created by 吴国权 on 2017/12/3.
//  Copyright © 2017年 NJU. All rights reserved.
//

import UIKit

protocol restartDelegate:NSObjectProtocol
{
    func again()
    func clickMenu()
}

@objcMembers
class GameOver: UIView
{
    
    weak var rdelegate:restartDelegate?
    
    
    var menuButton :UIButton=UIButton(type: .system)
    var restartButton:UIButton=UIButton(type: .system)
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupSubViews()
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clickMenu(button:UIButton)
    {
        rdelegate?.clickMenu()
    }
    
    func clickRestart(button:UIButton)
    {
        rdelegate?.again()
        self.removeFromSuperview()
    }
    
    func setupSubViews()
    {
        //self.backgroundColor=UIColor.orange
        menuButton.setBackgroundImage(UIImage(named:"menu"), for: UIControlState.normal)
        menuButton.frame=CGRect(x: self.frame.size.width*0.32, y:self.frame.size.height*0.5,
                                width: self.frame.size.width*0.12, height: self.frame.size.height*0.12)
        self.addSubview(menuButton)
        restartButton.setBackgroundImage(UIImage(named:"restart"), for: UIControlState.normal)
        restartButton.frame=CGRect(x:self.frame.size.width*0.56,y:self.frame.size.height*0.5,
                                   width:self.frame.size.width*0.12,height:self.frame.size.height*0.12)
        self.addSubview(restartButton)
        menuButton.addTarget(self, action: #selector(clickMenu(button:)), for: .touchUpInside)
        restartButton.addTarget(self, action: #selector(clickRestart(button:)), for: .touchUpInside)
    }
    
    
}
