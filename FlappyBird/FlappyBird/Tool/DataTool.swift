//
//  DataTool.swift
//  FlappyBird
//
//  Created by 吴国权 on 2017/12/9.
//  Copyright © 2017年 NJU. All rights reserved.
//

import Foundation

struct UserDefaultKeys
{
    
    enum crazy: String
    {
        case ctop1
        case ctop2
        case ctop3
        case ctop4
        case ctop5
    }
    
    enum hard: String
    {
        case htop1
        case htop2
        case htop3
        case htop4
        case htop5
    }
    
    enum difficult: String
    {
        case dtop1
        case dtop2
        case dtop3
        case dtop4
        case dtop5
    }
    
    enum general: String
    {
        case gtop1
        case gtop2
        case gtop3
        case gtop4
        case gtop5
    }
    
    enum ordinary: String
    {
        case otop1
        case otop2
        case otop3
        case otop4
        case otop5
    }
    
    enum systemsetup:String
    {
        case Music
        case Sounds
    }
    
    //["crazy","hard","difficult","general","ordinary"]
    static let difficulty="difficulty"
    
    static let costume="costume"
    
    static let everLaunched="everLaunched"
    
    
}

