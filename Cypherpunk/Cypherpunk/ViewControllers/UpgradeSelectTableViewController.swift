//
//  UpgradeSelectTableViewController.swift
//  Cypherpunk
//
//  Created by 木村圭佑 on 2016/08/26.
//  Copyright © 2016年 Cypherpunk. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import APIKit

class UpgradeSelectTableViewController: UITableViewController {
    
    @IBOutlet weak var monthlyCellContentView: UIView!
    @IBOutlet weak var monthlyCurrentPlanLabelView: UIView!
    
    @IBOutlet weak var semiannuallyCellContentView: UIView!
    @IBOutlet weak var semiannuallyCurrentPlanLabelView: UIView!

    @IBOutlet weak var annuallyCellContentView: UIView!
    @IBOutlet weak var annuallyBestValueView: TwoColorGradientView!
    @IBOutlet weak var annuallyCurrentPlanLabelView: UIView!

    fileprivate var retrievedProducts: [SKProduct] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let subscriptionType = mainStore.state.accountState.subscriptionType {
            switch subscriptionType {
            case .monthly:
                monthlyCellContentView.alpha = 0.5
                monthlyCellContentView.isUserInteractionEnabled = false
                monthlyCurrentPlanLabelView.isHidden = false
            case .semiannually:
                semiannuallyCellContentView.alpha = 0.5
                semiannuallyCellContentView.isUserInteractionEnabled = false
                semiannuallyCurrentPlanLabelView.isHidden = false
            case .annually:
                annuallyCellContentView.alpha = 0.5
                annuallyCellContentView.isUserInteractionEnabled = false
                annuallyCurrentPlanLabelView.isHidden = false
            default:
                break
            }
        }
        IndicatorView.show()
        SwiftyStoreKit.retrieveProductsInfo([
            SubscriptionType.monthly.subscriptionProductId,
            SubscriptionType.semiannually.subscriptionProductId,
            SubscriptionType.annually.subscriptionProductId
        ]) { result in
            self.retrievedProducts.removeAll()
            
            self.retrievedProducts.append(result.retrievedProducts.filter{return $0.productIdentifier == SubscriptionType.monthly.subscriptionProductId}[0])
            self.retrievedProducts.append(result.retrievedProducts.filter{return $0.productIdentifier == SubscriptionType.semiannually.subscriptionProductId}[0])
            self.retrievedProducts.append(result.retrievedProducts.filter{return $0.productIdentifier == SubscriptionType.annually.subscriptionProductId}[0])
            // dismiss Indicator
            self.tableView.reloadData()
            IndicatorView.dismiss()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upgradeToMonthlySubscriptionAction(_ sender: AnyObject) {
        let priceString = retrievedProducts[0].localizedPrice!
        let alert = UIAlertController(title: "Subscription Terms", message: "Subscribe to Recurring Subscription. This subscription will automatically renew every month for \(priceString)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action in
            SwiftyStoreKit.purchaseProduct(SubscriptionType.monthly.subscriptionProductId, atomically: false) { result in
                switch result {
                case .success(let product):
                    
                    let upgradeRequest = UpgradeRequest(
                        session: mainStore.state.accountState.session!,
                        accountId: mainStore.state.accountState.mailAddress!,
                        planId: SubscriptionType.monthly.planId,
                        receipt: SwiftyStoreKit.localReceiptData!
                    )
                    Session.send(upgradeRequest) {
                        (result) in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                if product.needsFinishTransaction {
                                    SwiftyStoreKit.finishTransaction(product.transaction)
                                }
                                mainStore.dispatch(AccountAction.upgrade(subscription: .monthly, expiredDate: Date()))
                                self.dismiss(animated: true, completion: nil)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .error(let error):
                    print(error)
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func upgradeToSemiannuallySubscriptionAction(_ sender: AnyObject) {
        let priceString = retrievedProducts[1].localizedPrice!
        let alert = UIAlertController(title: "Subscription Terms", message: "Subscribe to Recurring Subscription. This subscription will automatically renew 6 month's for \(priceString)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action in
            SwiftyStoreKit.purchaseProduct(SubscriptionType.semiannually.subscriptionProductId, atomically: false) { result in
                switch result {
                case .success(let product):
                    
                    let upgradeRequest = UpgradeRequest(
                        session: mainStore.state.accountState.session!,
                        accountId: mainStore.state.accountState.mailAddress!,
                        planId: SubscriptionType.semiannually.planId,
                        receipt: SwiftyStoreKit.localReceiptData!
                    )
                    Session.send(upgradeRequest) {
                        (result) in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                if product.needsFinishTransaction {
                                    SwiftyStoreKit.finishTransaction(product.transaction)
                                }
                                mainStore.dispatch(AccountAction.upgrade(subscription: .semiannually, expiredDate: Date()))
                                self.dismiss(animated: true, completion: nil)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .error(let error):
                    print(error)
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func upgradeToAnnuallySubscriptionAction(_ sender: AnyObject) {
        let priceString = retrievedProducts[2].localizedPrice!
        let alert = UIAlertController(title: "Subscription Terms", message: "Subscribe to Recurring Subscription. This subscription will automatically renew every year for \(priceString)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let continueAction = UIAlertAction(title: "Continue", style: .default) { action in
            SwiftyStoreKit.purchaseProduct(SubscriptionType.annually.subscriptionProductId) { result in
                switch result {
                case .success(let product):
                    
                    let upgradeRequest = UpgradeRequest(
                        session: mainStore.state.accountState.session!,
                        accountId: mainStore.state.accountState.mailAddress!,
                        planId: SubscriptionType.annually.planId,
                        receipt: SwiftyStoreKit.localReceiptData!
                    )
                    Session.send(upgradeRequest) {
                        (result) in
                        switch result {
                        case .success:
                            DispatchQueue.main.async {
                                // fetch content from your server, then:
                                if product.needsFinishTransaction {
                                    SwiftyStoreKit.finishTransaction(product.transaction)
                                }
                                mainStore.dispatch(AccountAction.upgrade(subscription: .annually, expiredDate: Date()))
                                self.dismiss(animated: true, completion: nil)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                case .error(let error):
                    print(error)
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showPurchaseSuccessAlert() {
    }
    
}

fileprivate let perMonthValues = [1,6,12]
extension UpgradeSelectTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if retrievedProducts.count == 0 {
            return 0
        }
        
        let accountState = mainStore.state.accountState
        
        if let subscription = accountState.subscriptionType, case .semiannually = subscription {
            return 2
        }
        
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accountState = mainStore.state.accountState
        
        if let subscription = accountState.subscriptionType, case .semiannually = subscription {
            let cell = super.tableView(tableView, cellForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
            if let cell = cell as? UpgradeTableViewCell {
                cell.subscriptionPriceLabel.text = retrievedProducts[indexPath.section + 1].localizedPrice(perMonth: perMonthValues[indexPath.section + 1])
            }
            return cell
        }
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? UpgradeTableViewCell {
            cell.subscriptionPriceLabel.text = retrievedProducts[indexPath.section].localizedPrice(perMonth: perMonthValues[indexPath.section])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let accountState = mainStore.state.accountState
        
        if let subscription = accountState.subscriptionType, case .semiannually = subscription {
            return super.tableView(tableView, heightForRowAt: IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1))
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

fileprivate extension SKProduct {
    func localizedPrice(perMonth: Int) -> String? {
        let nsNumberPerMonth = NSDecimalNumber(value: perMonth)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = self.priceLocale
        numberFormatter.numberStyle = .currency
        let handler = NSDecimalNumberHandler(roundingMode: NSDecimalNumber.RoundingMode.up, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        return numberFormatter.string(from: self.price.dividing(by: nsNumberPerMonth, withBehavior: handler))
    }
}
