//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Антон Ровенко on 22.01.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}
