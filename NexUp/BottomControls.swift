//
//  BottomControls.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/19/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation
import UIKit

class BottomControls: UITabBar {
    var timer = Timer()
    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var artistButton: UIButton!
    @IBAction func artistAction(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArtistVC") { present(vc, animated: true, completion: nil) }
        else { print("Error Initalizing ArtistVC") }
    }
    
    @IBOutlet weak var accountButton: UIButton!
    @IBAction func accountAction(_ sender: Any) {
        if let npvc = self.view.superview {
            self.performSegue(withIdentifier: "ToUserAccount", sender: npvc)
        }
    }
 
    @IBOutlet weak var circleButton: ButtonClass!
    @IBAction func circleAction(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC") { present(vc, animated: true, completion: nil) }
        else { print("Error Initalizing UserAccountVC") }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.circleButton.setImage(#imageLiteral(resourceName: "nexup"), for: .normal)
        self.progress.progress = 0.0
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    func updateUserInterface() {
        if let item = audio.player.currentItem { self.progress.progress = Float(item.currentTime().seconds / item.duration.seconds) }
        if let data = audio.metadata { if let image = data["Image"] as? UIImage { self.circleButton.setImage(image, for: .normal) } }
    }
}
