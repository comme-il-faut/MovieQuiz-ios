//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Антон Ровенко on 18.02.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactory?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), presenter: self)
        questionFactory?.loadData()
        viewController.hideActivityIndicator()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideActivityIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func loadData() {
        questionFactory?.loadData()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(image: UIImage(data: model.image) ?? UIImage(),
                                 question: model.text,
                                 questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isCorrect: Bool) {
        correctAnswers += 1
    }
    
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
