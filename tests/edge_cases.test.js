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
    calculate,
    getState
} = require("../script.js");

document.body.innerHTML = `<input id="display">`;

describe("Тесты граничных случаев и ошибок", () => {

    beforeEach(() => clearDisplay());

    describe("Работа с пустыми значениями", () => {
        test("операции не выполняются при пустом текущем значении", () => {
            add();
            expect(getState().operation).toBe(null);
            expect(getState().previousValue).toBe("");
        });

        test("calculate не выполняется без операции", () => {
            appendToDisplay("5");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("calculate не выполняется без предыдущего значения", () => {
            appendToDisplay("5");
            add();
            clearDisplay();
            appendToDisplay("3");
            calculate();
            // Операция должна быть установлена, но calculate не выполнится
            expect(getState().operation).toBe("add");
        });
    });

    describe("Работа с нулем", () => {
        test("0 + 5 = 5", () => {
            appendToDisplay("0");
            add();
            appendToDisplay("5");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("5 - 0 = 5", () => {
            appendToDisplay("5");
            subtract();
            appendToDisplay("0");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("0 * 100 = 0", () => {
            appendToDisplay("0");
            multiply();
            appendToDisplay("100");
            calculate();
            expect(getState().currentValue).toBe("0");
        });
    });

    describe("Работа с отрицательными числами", () => {
        test("-5 + 3 = -2", () => {
            appendToDisplay("-5");
            add();
            appendToDisplay("3");
            calculate();
            expect(getState().currentValue).toBe("-2");
        });

        test("5 - 10 = -5", () => {
            appendToDisplay("5");
            subtract();
            appendToDisplay("10");
            calculate();
            expect(getState().currentValue).toBe("-5");
        });

        test("-3 * -4 = 12", () => {
            appendToDisplay("-3");
            multiply();
            appendToDisplay("-4");
            calculate();
            expect(getState().currentValue).toBe("12");
        });

        test("-10 / 2 = -5", () => {
            appendToDisplay("-10");
            divide();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("-5");
        });
    });

    describe("Работа с десятичными числами", () => {
        test("0.1 + 0.2 ≈ 0.3", () => {
            appendToDisplay("0.1");
            add();
            appendToDisplay("0.2");
            calculate();
            expect(Number(getState().currentValue)).toBeCloseTo(0.3, 10);
        });

        test("2.5 * 2 = 5", () => {
            appendToDisplay("2.5");
            multiply();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("5");
        });

        test("10.5 / 2 = 5.25", () => {
            appendToDisplay("10.5");
            divide();
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("5.25");
        });

        test("3.14159 * 2 ≈ 6.28318", () => {
            appendToDisplay("3.14159");
            multiply();
            appendToDisplay("2");
            calculate();
            expect(Number(getState().currentValue)).toBeCloseTo(6.28318, 5);
        });
    });

    describe("Работа с большими числами", () => {
        test("1000000 + 2000000 = 3000000", () => {
            appendToDisplay("1000000");
            add();
            appendToDisplay("2000000");
            calculate();
            expect(getState().currentValue).toBe("3000000");
        });

        test("999999 * 1 = 999999", () => {
            appendToDisplay("999999");
            multiply();
            appendToDisplay("1");
            calculate();
            expect(getState().currentValue).toBe("999999");
        });
    });

    describe("Множественные операции", () => {
        test("последовательные операции без calculate", () => {
            appendToDisplay("5");
            add();
            appendToDisplay("3");
            add(); // должно выполнить предыдущее вычисление
            appendToDisplay("2");
            calculate();
            expect(getState().currentValue).toBe("10");
        });

        test("clearDisplay сбрасывает все состояния", () => {
            appendToDisplay("10");
            add();
            appendToDisplay("5");
            clearDisplay();
            expect(getState().currentValue).toBe("");
            expect(getState().previousValue).toBe("");
            expect(getState().operation).toBe(null);
        });
    });

    describe("Обработка некорректных данных", () => {
        test("calculate с NaN не выполняется", () => {
            // Симулируем ситуацию с некорректными данными
            appendToDisplay("abc");
            add();
            appendToDisplay("5");
            // parseFloat("abc") вернет NaN, calculate не выполнится
            calculate();
            expect(getState().currentValue).toBe("5");
        });
    });
});

