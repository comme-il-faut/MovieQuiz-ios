//
//  AlertPresentor.swift
//  MovieQuiz
//
//  Created by Антон Ровенко on 31.01.2024.
//

import UIKit

protocol AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

final class AlertPresentorImpl {
    weak var delegate: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.delegate = delegate
    }
}

extension AlertPresentorImpl: AlertPresenterProtocol {
    func show(alertModel: AlertModel) {
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true)
    }
}
