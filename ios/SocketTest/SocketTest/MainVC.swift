//
//  MainVC.swift
//  SocketTest
//
//  Created by fsociety.1 on 12/25/18.
//  Copyright © 2018 fsociety.1. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ChatVC
        vc.username = nameTF.text!
        
    }
    
    @IBAction func next(_ sender: Any) {
        if nameTF.text! != "" {
            self.performSegue(withIdentifier: "showChat", sender: self)
        }
    }
    
}
