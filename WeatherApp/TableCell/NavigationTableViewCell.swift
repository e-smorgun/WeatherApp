//
//  NavigationTableViewCell.swift
//  WeatherApp
//
//  Created by Evgeny on 14.07.22.
//

import UIKit

class NavigationTableViewCell: UITableViewCell {
    
    @IBOutlet var cityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
