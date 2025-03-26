import UIKit

var greeting = "Hello, playground"
//Задача.
//Реализовать логику взаимодействия с банкоматом, работая в плейграунде:
// - запрос баланса по карте и на банковском депозите
// - снятие наличных с карты или банковского депозита
// - пополнение карты и банковского депозита наличными
// - пополнение баланса телефона наличными или с карты.


// Абстракция данных пользователя
protocol UserData {
    var userName: String { get }    // Имя пользователя
    var userCardId: String { get }  // Номер карты
    var userCardPin: Int { get }    // Пин-код
    var userPhone: String { get }   // Номер телефона
    var userCash: Float { get set } // Наличные пользователя
    var userBankDeposit: Float { get set }   // Банковский депозит
    var userPhoneBalance: Float { get set }  // Баланс телефона
    var userCardBalance: Float { get set }   // Баланс карты
}

// Действия, которые пользователь может выбирать в банкомате (имитация кнопок)
enum UserActions {
    case checkCardBalance
    case checkDepositBalance
    case withdrawFromCard
    case withdrawFromDeposit
    case topUpCard
    case topUpDeposit
    case topUpPhone
}

// Виды операций, выбранных пользователем (подтверждение выбора)
enum DescriptionTypesAvailableOperations: String {
    case withdraw = "Снятие наличных"
    case topUp = "Пополнение"
    case balanceInquiry = "Запрос баланса"
}

// Способ оплаты/пополнения наличными, картой или через депозит
enum PaymentMethod {
    case cash
    case card
    case deposit
}

// Тексты ошибок
enum TextErrors: String {
    case insufficientFunds = "Недостаточно средств"
    case invalidUser = "Пользователь не найден"
    case operationFailed = "Ошибка операции"
}

// Протокол по работе с банком
protocol BankApi {
    func showUserCardBalance()
    func showUserDepositBalance()
    func showUserToppedUpMobilePhoneCash(cash: Float)
    func showUserToppedUpMobilePhoneCard(card: Float)
    func showWithdrawalCard(cash: Float)
    func showWithdrawalDeposit(cash: Float)
    func showTopUpCard(cash: Float)
    func showTopUpDeposit(cash: Float)
    func showError(error: TextErrors)

    func checkUserPhone(phone: String) -> Bool
    func checkMaxUserCash(cash: Float) -> Bool
    func checkMaxUserCard(withdraw: Float) -> Bool
    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool

    mutating func topUpPhoneBalanceCash(pay: Float)
    mutating func topUpPhoneBalanceCard(pay: Float)
    mutating func getCashFromDeposit(cash: Float)
    mutating func getCashFromCard(cash: Float)
    mutating func putCashDeposit(topUp: Float)
    mutating func putCashCard(topUp: Float)
}

// Банковская реализация
struct Bank: BankApi, UserData {
    let userName: String
    let userCardId: String
    let userCardPin: Int
    let userPhone: String
    var userCash: Float
    var userBankDeposit: Float
    var userPhoneBalance: Float
    var userCardBalance: Float

    func showUserCardBalance() {
        print("Баланс на карте: \(userCardBalance)₽")
    }

    func showUserDepositBalance() {
        print("Баланс на депозите: \(userBankDeposit)₽")
    }

    func showUserToppedUpMobilePhoneCash(cash: Float) {
        print("Телефон пополнен на \(cash)₽ наличными.")
    }

    func showUserToppedUpMobilePhoneCard(card: Float) {
        print("Телефон пополнен на \(card)₽ с карты.")
    }

    func showWithdrawalCard(cash: Float) {
        print("Снято \(cash)₽ с карты.")
    }

    func showWithdrawalDeposit(cash: Float) {
        print("Снято \(cash)₽ с депозита.")
    }

    func showTopUpCard(cash: Float) {
        print("Карта пополнена на \(cash)₽.")
    }

    func showTopUpDeposit(cash: Float) {
        print("Депозит пополнен на \(cash)₽.")
    }

    func showError(error: TextErrors) {
        print("Ошибка: \(error.rawValue)")
    }

    func checkUserPhone(phone: String) -> Bool {
        return phone == userPhone
    }

    func checkMaxUserCash(cash: Float) -> Bool {
        return userCash >= cash
    }

    func checkMaxUserCard(withdraw: Float) -> Bool {
        return userCardBalance >= withdraw
    }

    func checkCurrentUser(userCardId: String, userCardPin: Int) -> Bool {
        return self.userCardId == userCardId && self.userCardPin == userCardPin
    }

    mutating func topUpPhoneBalanceCash(pay: Float) {
        if checkMaxUserCash(cash: pay) {
            userCash -= pay
            userPhoneBalance += pay
        }
    }

    mutating func topUpPhoneBalanceCard(pay: Float) {
        if checkMaxUserCard(withdraw: pay) {
            userCardBalance -= pay
            userPhoneBalance += pay
        }
    }

    mutating func getCashFromDeposit(cash: Float) {
        if userBankDeposit >= cash {
            userBankDeposit -= cash
            userCash += cash
        }
    }

    mutating func getCashFromCard(cash: Float) {
        if checkMaxUserCard(withdraw: cash) {
            userCardBalance -= cash
            userCash += cash
        }
    }

    mutating func putCashDeposit(topUp: Float) {
        userBankDeposit += topUp
        userCash -= topUp
    }

    mutating func putCashCard(topUp: Float) {
        userCardBalance += topUp
        userCash -= topUp
    }
}

// Банкомат
class ATM {
    private let userCardId: String
    private let userCardPin: Int
    private var someBank: BankApi
    private let action: UserActions
    private let paymentMethod: PaymentMethod?

    init(userCardId: String, userCardPin: Int, someBank: BankApi, action: UserActions, paymentMethod: PaymentMethod? = nil) {
        self.userCardId = userCardId
        self.userCardPin = userCardPin
        self.someBank = someBank
        self.action = action
        self.paymentMethod = paymentMethod

        sendUserDataToBank(userCardId: userCardId, userCardPin: userCardPin, actions: action, payment: paymentMethod)
    }

    public final func sendUserDataToBank(userCardId: String, userCardPin: Int, actions: UserActions, payment: PaymentMethod?) {
        guard someBank.checkCurrentUser(userCardId: userCardId, userCardPin: userCardPin) else {
            someBank.showError(error: .invalidUser)
            return
        }

        switch actions {
        case .checkCardBalance:
            someBank.showUserCardBalance()
        case .checkDepositBalance:
            someBank.showUserDepositBalance()
        case .withdrawFromCard:
            if let payment = payment, payment == .card {
                someBank.getCashFromCard(cash: 500) // Пример: фиксированная сумма
            }
        case .withdrawFromDeposit:
            if let payment = payment, payment == .deposit {
                someBank.getCashFromDeposit(cash: 500)
            }
        case .topUpCard:
            if let payment = payment, payment == .cash {
                someBank.putCashCard(topUp: 1000)
            }
        case .topUpDeposit:
            if let payment = payment, payment == .cash {
                someBank.putCashDeposit(topUp: 1500)
            }
        case .topUpPhone:
            if let payment = payment {
                if payment == .cash {
                    someBank.topUpPhoneBalanceCash(pay: 300)
                } else if payment == .card {
                    someBank.topUpPhoneBalanceCard(pay: 300)
                }
            }
        }
    }
}

// Пример
var bank = Bank(userName: "Александр", userCardId: "1234-5678", userCardPin: 1234, userPhone: "+79999999999", userCash: 1000, userBankDeposit: 5000, userPhoneBalance: 100, userCardBalance: 3000)

let atm = ATM(userCardId: "1234-5678", userCardPin: 1234, someBank: bank, action: .checkCardBalance)
