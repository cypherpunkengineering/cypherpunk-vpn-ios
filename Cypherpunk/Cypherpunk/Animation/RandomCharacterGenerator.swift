//
//  RandomCharacterGenerator.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/12.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import Foundation

private let characterSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+`-=[]\\{}|;':<>?,.\"\'"
struct RandomCharacterGenerator {
    
    static func generate() -> Character {
        let index = characterSet.characters.index(characterSet.startIndex, offsetBy: Int(arc4random_uniform(UInt32(characterSet.unicodeScalars.count - 1))))
        return characterSet[index]
    }
}
