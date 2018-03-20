//
//  RoundTableViewCell.swift
//  Mastermind
//
//  Created by Sébastien Gaya on 20/03/2018.
//  Copyright © 2018 Sébastien Gaya. All rights reserved.
//

import UIKit

class RoundTableViewCell: UITableViewCell {

    @IBOutlet var userCombinationImageViews: [UIImageView]!
    @IBOutlet weak var placedCounterLabel: UILabel!
    @IBOutlet weak var misplacedCounterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
