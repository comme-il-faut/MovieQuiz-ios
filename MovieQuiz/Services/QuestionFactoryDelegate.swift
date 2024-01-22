//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Антон Ровенко on 21.01.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
