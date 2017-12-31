//
//  MenuViewController.swift
//  FlappyBird
//
//  Created by 吴国权 on 2017/11/22.
//  Copyright © 2017年 NJU. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MenuViewController: UIViewController
{

    
    @IBOutlet weak var costume: UIBarButtonItem!
    @IBOutlet weak var rate: UIBarButtonItem!
    
    @IBOutlet weak var bird: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //self.view.backgroundColor=UIColor(red:80.0/255.0,green:192.0/255.0,blue:203.0/255.0,alpha:1.0)
        
        let bgview = UIImageView(image: UIImage(named: "bg1"))
        
        bgview.frame.size=self.view.frame.size
        
        self.view.insertSubview(bgview, at: 0)
        
        
        // navigationbar 全透明
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func exitToMenu(sender:UIStoryboardSegue){
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
