//
//  ViewController.swift
//  TinkoffCalc
//
//  Created by Ramil on 31.03.2024.
//

import UIKit

class ViewController: UIViewController {
  // MARK: - Properties

  enum CalculationError: Error {
    case divisionByZero
    case overflow
  }

  enum Operation: String {
    case add = "+"
    case subtract = "-"
    case multiply = "X"
    case divide = "/"

    func calculate(_ left: Double, _ right: Double) throws -> Double {
      // Проверка, что оба числа не являются бесконечностью или NaN
      if left.isInfinite || right.isInfinite || left.isNaN || right.isNaN {
        throw CalculationError.overflow
      }
      var result = 0.0

      switch self {
      case .add:
        result = left + right
      case .subtract:
        result = left - right
      case .multiply:
        result = left * right
      case .divide:
        if right == 0 {
          throw CalculationError.divisionByZero
        }
        result = left / right
      }
      // Проверка, что результат не является бесконечностью или NaN
      if result.isInfinite || result.isNaN {
        throw CalculationError.overflow
      }
      // Проверка, что результат не выходит за допустимый диапазон для Double
      let maxDouble = Double.greatestFiniteMagnitude
      let minDouble = -maxDouble
      if result > maxDouble || result < minDouble {
        throw CalculationError.overflow
      }
      return result
    }
  }

  enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
  }

  lazy var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.usesGroupingSeparator = false
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ru_Ru")

    return formatter
  }()

  var calculationHistory: [CalculationHistoryItem] = []

  // MARK: - IBOutlets

  @IBOutlet var label: UILabel!

  // MARK: - IBActions

  @IBAction func clearButtonPressed() {
    calculationHistory.removeAll()
    resetLabelText()
  }

  @IBAction func calculateButtonPressed() {
    guard
      let lebelText = label.text,
      let lebelNumber = numberFormatter.number(from: lebelText)?.doubleValue
    else {
      return
    }

    calculationHistory.append(.number(lebelNumber))
    do {
      let result = try calculate()
      label.text = numberFormatter.string(from: NSNumber(value: result))
    } catch {
      label.text = "Error"
    }
    print(Double.greatestFiniteMagnitude)
    calculationHistory.removeAll()
  }

  @IBAction func buttonPressed(_ sender: UIButton) {
    guard let buttonText = sender.titleLabel?.text else { return }
    if buttonText == ",", label.text?.contains(",") == true { return }

    if label.text == "0" {
      label.text = buttonText
    } else {
      label.text?.append(buttonText)
    }
  }

  @IBAction func operationButtonPressed(_ sender: UIButton) {
    guard
      let buttonText = sender.titleLabel?.text,
      let operation = Operation(rawValue: buttonText)
    else {
      return
    }

    guard
      let lebelText = label.text,
      let lebelNumber = numberFormatter.number(from: lebelText)?.doubleValue
    else {
      return
    }

    calculationHistory.append(.number(lebelNumber))
    calculationHistory.append(.operation(operation))

    resetLabelText()
  }

  // MARK: - LifeCycle

  override func viewDidLoad() {
    super.viewDidLoad()
    resetLabelText()
  }

  // MARK: - Methods

  func resetLabelText() {
    label.text = "0"
  }

  func calculate() throws -> Double {
    guard case .number(let firstNumber) = calculationHistory.first else { return 0 }
    var currentResult = firstNumber
    for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
      guard case .operation(let operation) = calculationHistory[index],
            case .number(let secondNumber) = calculationHistory[index + 1]
      else { break }
      currentResult = try operation.calculate(currentResult, secondNumber)
    }

    return currentResult
  }
}
