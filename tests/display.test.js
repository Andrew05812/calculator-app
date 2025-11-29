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

describe("Тесты отображения и ввода", () => {

    beforeEach(() => clearDisplay());

    describe("appendToDisplay", () => {
        test("добавление одной цифры", () => {
            appendToDisplay("5");
            expect(getState().currentValue).toBe("5");
            expect(document.getElementById('display').value).toBe("5");
        });

        test("добавление нескольких цифр", () => {
            appendToDisplay("1");
            appendToDisplay("2");
            appendToDisplay("3");
            expect(getState().currentValue).toBe("123");
            expect(document.getElementById('display').value).toBe("123");
        });

        test("добавление десятичной точки", () => {
            appendToDisplay("3");
            appendToDisplay(".");
            appendToDisplay("1");
            appendToDisplay("4");
            expect(getState().currentValue).toBe("3.14");
            expect(document.getElementById('display').value).toBe("3.14");
        });

        test("добавление отрицательного числа", () => {
            appendToDisplay("-");
            appendToDisplay("5");
            expect(getState().currentValue).toBe("-5");
            expect(document.getElementById('display').value).toBe("-5");
        });

        test("последовательное добавление после вычисления", () => {
            appendToDisplay("5");
            add();
            appendToDisplay("3");
            calculate();
            appendToDisplay("2");
            expect(getState().currentValue).toBe("82");
        });
    });

    describe("clearDisplay", () => {
        test("очистка пустого дисплея", () => {
            clearDisplay();
            expect(getState().currentValue).toBe("");
            expect(document.getElementById('display').value).toBe("");
        });

        test("очистка после ввода", () => {
            appendToDisplay("12345");
            clearDisplay();
            expect(getState().currentValue).toBe("");
            expect(document.getElementById('display').value).toBe("");
        });

        test("очистка после вычисления", () => {
            appendToDisplay("10");
            add();
            appendToDisplay("5");
            calculate();
            clearDisplay();
            expect(getState().currentValue).toBe("");
            expect(getState().previousValue).toBe("");
            expect(getState().operation).toBe(null);
        });

        test("очистка сбрасывает операцию", () => {
            appendToDisplay("5");
            add();
            clearDisplay();
            expect(getState().operation).toBe(null);
        });
    });

    describe("Обновление дисплея при операциях", () => {
        test("дисплей обновляется после calculate", () => {
            appendToDisplay("10");
            add();
            appendToDisplay("5");
            calculate();
            expect(document.getElementById('display').value).toBe("15");
        });

        test("дисплей очищается при выборе операции", () => {
            appendToDisplay("10");
            add();
            expect(getState().currentValue).toBe("");
            // Дисплей должен показывать пустое значение для нового ввода
        });
    });

    describe("Длинные числа", () => {
        test("ввод длинного числа", () => {
            const longNumber = "123456789012345";
            for (let char of longNumber) {
                appendToDisplay(char);
            }
            expect(getState().currentValue).toBe(longNumber);
        });

        test("результат длинного вычисления", () => {
            appendToDisplay("999999");
            multiply();
            appendToDisplay("999999");
            calculate();
            expect(getState().currentValue).toBe("999998000001");
        });
    });

    describe("Специальные символы", () => {
        test("ввод только точки", () => {
            appendToDisplay(".");
            expect(getState().currentValue).toBe(".");
        });

        test("ввод точки после числа", () => {
            appendToDisplay("5");
            appendToDisplay(".");
            expect(getState().currentValue).toBe("5.");
        });

        test("ввод нескольких точек (как строка)", () => {
            appendToDisplay("5");
            appendToDisplay(".");
            appendToDisplay(".");
            appendToDisplay("3");
            expect(getState().currentValue).toBe("5..3");
        });
    });
});

