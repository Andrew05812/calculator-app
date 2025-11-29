/**
 * @jest-environment jsdom
 */

const {
    appendToDisplay,
    clearDisplay,
    calculateSqrt,
    floorValue,
    ceilValue,
    getState
} = require("../script.js");

document.body.innerHTML = `<input id="display">`;

describe("Тесты математических функций", () => {

    beforeEach(() => clearDisplay());

    describe("Квадратный корень", () => {
        test("√0 = 0", () => {
            appendToDisplay("0");
            calculateSqrt();
            expect(getState().currentValue).toBe("0");
        });

        test("√1 = 1", () => {
            appendToDisplay("1");
            calculateSqrt();
            expect(getState().currentValue).toBe("1");
        });

        test("√4 = 2", () => {
            appendToDisplay("4");
            calculateSqrt();
            expect(getState().currentValue).toBe("2");
        });

        test("√9 = 3", () => {
            appendToDisplay("9");
            calculateSqrt();
            expect(getState().currentValue).toBe("3");
        });

        test("√16 = 4", () => {
            appendToDisplay("16");
            calculateSqrt();
            expect(getState().currentValue).toBe("4");
        });

        test("√25 = 5", () => {
            appendToDisplay("25");
            calculateSqrt();
            expect(getState().currentValue).toBe("5");
        });

        test("√2 ≈ 1.414", () => {
            appendToDisplay("2");
            calculateSqrt();
            expect(Number(getState().currentValue)).toBeCloseTo(1.414, 2);
        });

        test("√100 = 10", () => {
            appendToDisplay("100");
            calculateSqrt();
            expect(getState().currentValue).toBe("10");
        });

        test("√144 = 12", () => {
            appendToDisplay("144");
            calculateSqrt();
            expect(getState().currentValue).toBe("12");
        });

        test("√2.25 = 1.5", () => {
            appendToDisplay("2.25");
            calculateSqrt();
            expect(getState().currentValue).toBe("1.5");
        });

        test("корень из отрицательного числа не вычисляется", () => {
            const alertSpy = jest.spyOn(window, 'alert').mockImplementation(() => {});
            appendToDisplay("-4");
            calculateSqrt();
            expect(alertSpy).toHaveBeenCalledWith('Невозможно извлечь корень из отрицательного числа!');
            expect(getState().currentValue).toBe("-4");
            alertSpy.mockRestore();
        });

        test("sqrt не выполняется при пустом значении", () => {
            calculateSqrt();
            expect(getState().currentValue).toBe("");
        });
    });

    describe("Округление вниз (floor)", () => {
        test("floor(7.8) = 7", () => {
            appendToDisplay("7.8");
            floorValue();
            expect(getState().currentValue).toBe("7");
        });

        test("floor(7.2) = 7", () => {
            appendToDisplay("7.2");
            floorValue();
            expect(getState().currentValue).toBe("7");
        });

        test("floor(7.0) = 7", () => {
            appendToDisplay("7.0");
            floorValue();
            expect(getState().currentValue).toBe("7");
        });

        test("floor(-7.8) = -8", () => {
            appendToDisplay("-7.8");
            floorValue();
            expect(getState().currentValue).toBe("-8");
        });

        test("floor(0.5) = 0", () => {
            appendToDisplay("0.5");
            floorValue();
            expect(getState().currentValue).toBe("0");
        });

        test("floor(100.99) = 100", () => {
            appendToDisplay("100.99");
            floorValue();
            expect(getState().currentValue).toBe("100");
        });

        test("floor не выполняется при пустом значении", () => {
            floorValue();
            expect(getState().currentValue).toBe("");
        });
    });

    describe("Округление вверх (ceil)", () => {
        test("ceil(7.2) = 8", () => {
            appendToDisplay("7.2");
            ceilValue();
            expect(getState().currentValue).toBe("8");
        });

        test("ceil(7.8) = 8", () => {
            appendToDisplay("7.8");
            ceilValue();
            expect(getState().currentValue).toBe("8");
        });

        test("ceil(7.0) = 7", () => {
            appendToDisplay("7.0");
            ceilValue();
            expect(getState().currentValue).toBe("7");
        });

        test("ceil(-7.2) = -7", () => {
            appendToDisplay("-7.2");
            ceilValue();
            expect(getState().currentValue).toBe("-7");
        });

        test("ceil(0.1) = 1", () => {
            appendToDisplay("0.1");
            ceilValue();
            expect(getState().currentValue).toBe("1");
        });

        test("ceil(100.01) = 101", () => {
            appendToDisplay("100.01");
            ceilValue();
            expect(getState().currentValue).toBe("101");
        });

        test("ceil не выполняется при пустом значении", () => {
            ceilValue();
            expect(getState().currentValue).toBe("");
        });
    });
});

