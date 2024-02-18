import UIKit

final class MovieQuizViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryImpl?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresentorImpl(delegate: self)
        questionFactory = QuestionFactoryImpl(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImpl()
        presenter.viewController = self
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let alertBadNetwork = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText: "Попробуйте еще раз") { [weak self] in
            guard let self = self else {return}
            questionFactory?.loadData()
        }
        
        alertPresenter?.show(alertModel: alertBadNetwork)
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: makeResultMessage(),
                                    buttonText: "Сыграть еще раз",
                                    completion: { [weak self] in
            guard let self = self else {
                return
            }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            questionFactory?.requestNextQuestion()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 0
        }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    private func makeResultMessage() -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("error message")
            return ""
        }
        
        let currentGameresultLine = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLines = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccurancyGame = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let resultMessage = [
            currentGameresultLine, totalPlaysCountLine, bestGameInfoLines, averageAccurancyGame
        ].joined(separator: "\n")
        return resultMessage
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        noButton.isEnabled = false
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        yesButton.isEnabled = false
        presenter.yesButtonClicked()
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(_ question: QuizQuestion) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
        activityIndicator.stopAnimating()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
