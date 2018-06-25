//
//  SquadTableViewCell.swift
//  Rappucino
//
//  Created by Logan Geefs on 2018-06-22.
//  Copyright © 2018 logangeefs. All rights reserved.
//

import Foundation
import UIKit

class SquadTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var nameLabel: UILabel!
    var lastUpdate: UILabel!
    var dateLabel: UILabel!
    
    var squad: Squad! {
        didSet {
            update()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder aDecoder: NSCoder) not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutUI()
        
    }
    
    func setupUI() {
        
        //self.contentView.backgroundColor = .white
        
        nameLabel = UILabel()
        nameLabel.text = squad.getName()
        self.contentView.addSubview(nameLabel)
        
        lastUpdate = UILabel()
        lastUpdate.text = squad.getLastUpdate().0
        
        dateLabel = UILabel()
        dateLabel.text = squad.getLastUpdate().1
        dateLabel.contentMode = .top
        //dateLabel.font = UIFont(name: fontName, size: Fonts.smaller)
        dateLabel.adjustsFontSizeToFitWidth = true
        self.contentView.addSubview(dateLabel)
        
    }
    
    func layoutUI() {
        
        //var multiplier: CGFloat = 1.0
        
        let width = self.contentView.bounds.width//*multiplier
        let height = self.contentView.bounds.height
        let leftMargin = width*0.1
        let topMargin = height*0.05
        
        nameLabel.frame = CGRect(x: leftMargin, y: topMargin, width: width*0.7, height: height*0.5)
        
        dateLabel.frame = CGRect(x: leftMargin, y: nameLabel.frame.maxY, width: width*0.65, height: height*0.2)
        
        lastUpdate.frame = CGRect(x: self.contentView.bounds.width*0.5, y: 0, width: self.contentView.bounds.width*0.3, height: self.contentView.bounds.height)
        
    }
    
    func update() {
        
        nameLabel.text = squad.getName()
        lastUpdate.text = squad.getLastUpdate().0
        dateLabel.text = squad.getLastUpdate().1
        
    }
    
    fileprivate func convertToDateString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
        
    }
    
    @objc func deleteButtonPressed(sender: UIButton) {
        //leave squad?
        
    }
    
    fileprivate func convertToTimeString(_ duration: Double) -> String {
        
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        
        var zeroPad1 = ""
        var zeroPad2 = ""
        
        if minutes < 10 {
            zeroPad1 = "0"
        }
        if seconds < 10 {
            zeroPad2 = "0"
        }
        
        return "\(zeroPad1)\(minutes):\(zeroPad2)\(seconds)"
        
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        /*if touch.view! is UIButton {
         return false
         } else {
         return true
         }*/
        return true
    }
    
}
