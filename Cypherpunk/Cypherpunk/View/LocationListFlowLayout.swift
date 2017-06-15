//
//  LocationLIstFlowLayout.swift
//  Cypherpunk
//
//  Created by Julie Ann Sakuda on 6/14/17.
//  Copyright © 2017 Cypherpunk. All rights reserved.
//

import UIKit

class LocationListFlowLayout: UICollectionViewFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: collectionView.bounds.width, height: 60)
        return size
    }
}
