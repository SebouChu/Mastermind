//
//  HistoryTableViewCell.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 26/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet var combinationImageViews: [UIImageView]!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
