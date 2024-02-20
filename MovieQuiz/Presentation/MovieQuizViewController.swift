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
    
    var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresentorImpl(delegate: self)
        showLoadingIndicator()
        presenter.loadData()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideActivityIndicator()
        
        let alertBadNetwork = AlertModel(title: "Ошибка",
                                         message: message,
                                         buttonText: "Попробуйте еще раз") { [weak self] in
            guard let self = self else {return}
            presenter.restartGame()
        }
        
        alertPresenter?.show(alertModel: alertBadNetwork)
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        presenter?.statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(title: "Этот раунд окончен!",
                                    message: presenter.makeResultMessage(),
                                    buttonText: "Сыграть еще раз",
                                    completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 0
        })
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrect: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
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
