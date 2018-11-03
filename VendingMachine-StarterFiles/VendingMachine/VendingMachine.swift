//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Rey Matsunaga on 11/2/18.
//  Copyright © 2018 Treehouse Island, Inc. All rights reserved.
//

import Foundation
import UIKit

// List of potential vending selections

enum VendingSelection: String {
    case soda
    case dietSoda
    case chips
    case cookie
    case sandwich
    case wrap
    case candyBar
    case popTart
    case water
    case fruitJuice
    case sportsDrink
    case gum
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue) {
            return image
        } else {
            return UIImage(named: "default")!
        }
    }
}

// Each item has:

protocol VendingItem {
    var price: Double { get }
    var quantity: Int { get set }
    
}

// Vending machines have:

protocol VendingMachine {
    var selection: [VendingSelection] { get }
    var inventory: [VendingSelection: VendingItem] { get set }
    var amountDeposited: Double { get set }
    
    init(inventory: [VendingSelection:VendingItem])
    
    func vend(selection: VendingSelection, quantity: Int) throws
    func deposit(_ amount: Double)
    func item(forSelection selection: VendingSelection) -> VendingItem?
}

struct Item: VendingItem {
    let price: Double
    var quantity: Int
}

// Errors in creating inventory

enum InventoryError: Error {
    case invalidResource
    case conversionFailure
    case invalidSelection
}

class PlistConverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String : AnyObject] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            
            // File is false.
            
            throw InventoryError.invalidResource
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: AnyObject] else {
            
            // data might not convert properly to dictionary
            
            throw InventoryError.conversionFailure
        }
        
        return dictionary
    }
    
}


class InventoryUnarchiver {
    static func vendingInventory(fromDictionary dictionary: [String: AnyObject]) throws -> [VendingSelection: VendingItem] {
        var inventory:[VendingSelection: VendingItem]  = [:]
        
        for (key, value) in dictionary {
            if let itemDictionary = value as? [String: Any],
                let price = itemDictionary["price"] as? Double,
                let quantity = itemDictionary["quantity"] as? Int
            {
                let item = Item(price: price, quantity: quantity)
                
                // Convert item into VendingSelection
                
                guard let selection = VendingSelection(rawValue: key) else {
                    throw InventoryError.invalidSelection
                }
                inventory.updateValue(item, forKey: selection)
            }
        }
        return inventory
    }
    
}

enum VendingMachineError: Error {
    case invalidSelection
    case outOfStock
    case insufficientFunds(required: Double)
}

class FoodVendingMachine: VendingMachine {
    let selection: [VendingSelection] =
        [.soda, .dietSoda, .chips, .cookie, .wrap, .sandwich, .candyBar, .popTart, .water, .fruitJuice, .sportsDrink, .gum]
    
    var inventory: [VendingSelection : VendingItem]
    
    var amountDeposited: Double = 10.0
    
    required init(inventory: [VendingSelection : VendingItem]) {
        self.inventory = inventory
    }
    
    func vend(selection: VendingSelection, quantity: Int) throws {
        guard var item = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        
        guard item.quantity >= quantity else {
            throw VendingMachineError.outOfStock
        }
        
        let totalPrice = item.price * Double(quantity)
        
        if amountDeposited >= totalPrice {
            
            amountDeposited -= totalPrice
            item.quantity -= quantity
            
            inventory.updateValue(item, forKey: selection)
        } else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufficientFunds(required: amountRequired)
        }
    }
    
    func deposit(_ amount: Double) {
        print("I love perry")
    }
    func item(forSelection selection: VendingSelection) -> VendingItem? {
        return inventory[selection]
    }
    
}
