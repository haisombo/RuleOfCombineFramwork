//
//  ViewController.swift
//  RuleOfCombineFramwork
//
//  Created by Hai Sombo on 7/8/24.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    // MARK: -  @IBOutlet ----
    @IBOutlet weak var titleLabel       : UILabel!
    // MARK: - Properties
    private let viewModel               = LogInViewModel()
    private var subscriptions           = Set<AnyCancellable>()
    // inject data
    private let input                   : PassthroughSubject<LogInViewModel.Input, Never> = .init()
    private let refreshControl          = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        if viewModel.autoLogin == true {
            self.titleLabel.text = "Login HDEXPANSE SUCCESS With Combine"
        }
        
    }
    
    @IBAction func LoginActionTest(_ sender: Any) {
        
             viewModel.autoLogin        = true
             viewModel.corpGroupCode    = "0001"
             viewModel.password         = "Qwer1234!"
             viewModel.userId           = "next_admin"
        
////             // Trigger the transform method
             let output = viewModel.transform(input: input.eraseToAnyPublisher())
//             // Subscribe to the output and handle the events
             output
                 .receive(on: DispatchQueue.main)
                 .sink(receiveValue: {[weak self] event in
                     switch event {
                     case .fetchUserDidSuccess(let users):
                         print(users)

                     case .fetchUserDidFail(let error):
                        print("")
                     case .fetchUserDidFinish:
                         self?.refreshControl.endRefreshing()
                     }
                 })
                 .store(in: &subscriptions)
             // Send the load event to the input
             input.send(.load)
    }
    
}
