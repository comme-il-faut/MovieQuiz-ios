import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactory?
    var statisticService: StatisticService!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), presenter: self)
        questionFactory?.loadData()
        self.statisticService = StatisticServiceImpl()
        viewController.hideLoadingIndicator()
    }
    
    func getQuestionAmount() -> Int {
        return questionsAmount
    }
    
    func getCorrectAnswers() -> Int {
        return correctAnswers
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
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
        
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    private func proceedToNextQuestionOrResults() {
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
    
    func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let currentGameresultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLines = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccurancyGame = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameresultLine, totalPlaysCountLine, bestGameInfoLines, averageAccurancyGame
        ].joined(separator: "\n")
        return resultMessage
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrect: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            viewController?.isEnabledButtons(activate: true)
        }
    }
}
