//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Антон Ровенко on 21.01.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
    
    var delegate: QuestionFactoryDelegate? {get set}
    func requestNextQuestion()
}
