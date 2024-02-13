//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Антон Ровенко on 19.01.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(_ question: QuizQuestion)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

protocol QuestionFactory {
    func requestNextQuestion()
    func loadData()
}

final class QuestionFactoryImpl {
    
    private let moviesLoader: MoviesLoading
    private weak var viewController: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.viewController = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.viewController?.didLoadDataFromServer()
                case .failure(let error):
                    self.viewController?.didFailToLoadData(with: error)
                }
            }
        }
    }
}

extension QuestionFactoryImpl: QuestionFactory {
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                
                let alertFailedLoad = AlertModel(title: "Ошибка",
                                                 message: "Неудачная попытка загрузка изображения",
                                                 buttonText: "Попробуйте еще раз") { [weak self] in
                    guard let self = self else {return}
                    loadData()
                }
                let alertPresenet = AlertPresentorImpl()
                alertPresenet.show(alertModel: alertFailedLoad)
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let questionRating = Int.random(in: 1...10)
            let text = "Рейтинг этого фильма больше чем \(questionRating)?"
            let correctAnswer = rating > Float(questionRating)
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.viewController?.didReceiveNextQuestion(question)
            }
        }
    }
}

//private let questions: [QuizQuestion] = [
//    QuizQuestion(
//        image: "The Godfather",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Dark Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Kill Bill",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Avengers",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Deadpool",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "The Green Knight",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: true),
//    QuizQuestion(
//        image: "Old",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "The Ice Age Adventures of Buck Wild",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "Tesla",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false),
//    QuizQuestion(
//        image: "Vivarium",
//        text: "Рейтинг этого фильма больше чем 6?",
//        correctAnswer: false)
//]
