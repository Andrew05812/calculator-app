/**
 * @jest-environment jsdom
 */

const {
    appendToDisplay,
    clearDisplay,
    add,
    subtract,
    multiply,
    divide,
    modulo,
    power,
    calculate,
    getState
} = require("../script.js");

document.body.innerHTML = `<input id="display">`;

describe("Тесты арифметических операций", () => {

    beforeEach(() => clearDisplay());

    describe("Умножение", () => {
        test("3 * 4 = 12", () => {
            appendToDisplay("3");
            multiply();
            appendToDisplay("4");
            calculate();
            expect(getState().currentValue).toBe("12");
        });

        test("0 * 5 = 0", () => {
            appendToDisplay("0");
            multiply();
            appendToDisplay("5");
            calculate();
            expect(getState().currentValue).toBe("0");
        });

        test("-2 * 3 = -6", () => {
            appendToDisplay("-2");
            multiply();
            appendToDisplay("3");
            calculate();
            expect(getState().currentValue).toBe("-6");
        });

        test("2.5 * 4 = 10", () => {
            appendToDisplay("2.5");
            multiply();
            appendToDisplay("4");
            calculate();
            expect(getState().currentValue).toBe("10");
        });
    });

    describe("Деление", () => {
        test("10 / 2 = 5", () => {
            appendToDisplay("10");
            divide();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("15 / 3 = 5", () => {
            appendToDisplay("15");
            divide();
            appendToDisplay("3");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("7 / 2 = 3.5", () => {
            appendToDisplay("7");
            divide();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("3.5");
        });

        test("деление на ноль не выполняется", () => {
            const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
            appendToDisplay("10");
            divide();
            appendToDisplay("0");
            calculate();
            expect(alertSpy).toHaveBeenCalledWith('Деление на ноль невозможно!');
            expect(getState().currentValue).toBe("10");
            alertSpy.mockRestore();
        });

        test("-10 / 2 = -5", () => {
            appendToDisplay("-10");
            divide();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("-5");
        });
    });

    describe("Модуло (остаток от деления)", () => {
        test("10 % 3 = 1", () => {
            appendToDisplay("10");
            modulo();
            appendToDisplay("3");
            calculate();
            expect(getState().currentValue).toBe("1");
        });

        test("15 % 4 = 3", () => {
            appendToDisplay("15");
            modulo();
            appendToDisplay("4");
            calculate();
            expect(getState().currentValue).toBe("3");
        });

        test("8 % 2 = 0", () => {
            appendToDisplay("8");
            modulo();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("0");
        });

        test("-10 % 3 = -1", () => {
            appendToDisplay("-10");
            modulo();
            appendToDisplay("3");
            calculate();
            expect(getState().currentValue).toBe("-1");
        });
    });

    describe("Возведение в степень", () => {
        test("2 ^ 3 = 8", () => {
            appendToDisplay("2");
            power();
            appendToDisplay("3");
            calculate();
            expect(getState().currentValue).toBe("8");
        });

        test("5 ^ 2 = 25", () => {
            appendToDisplay("5");
            power();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("25");
        });

        test("10 ^ 0 = 1", () => {
            appendToDisplay("10");
            power();
            appendToDisplay("0");
            calculate();
            expect(getState().currentValue).toBe("1");
        });

        test("2 ^ -1 = 0.5", () => {
            appendToDisplay("2");
            power();
            appendToDisplay("-1");
            calculate();
            expect(getState().currentValue).toBe("0.5");
        });
    });

    describe("Комбинированные операции", () => {
        test("2 + 3 * 4 = 20 (последовательно)", () => {
            appendToDisplay("2");
            add();
            appendToDisplay("3");
            calculate();
            multiply();
            appendToDisplay("4");
            calculate();
            expect(getState().currentValue).toBe("20");
        });

        test("10 - 3 - 2 = 5", () => {
            appendToDisplay("10");
            subtract();
            appendToDisplay("3");
            calculate();
            subtract();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("4 * 5 / 2 = 10", () => {
            appendToDisplay("4");
            multiply();
            appendToDisplay("5");
            calculate();
            divide();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("10");
        });
    });
});

