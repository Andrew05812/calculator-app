/**
 * @jest-environment jsdom
 */

const {
    appendToDisplay,
    clearDisplay,
    calculateSin,
    calculateCos,
    getState
} = require("../script.js");

document.body.innerHTML = `<input id="display">`;

describe("Тесты тригонометрических функций", () => {

    beforeEach(() => clearDisplay());

    describe("Синус", () => {
        test("sin(0) = 0", () => {
            appendToDisplay("0");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(0, 5);
        });

        test("sin(30) ≈ 0.5", () => {
            appendToDisplay("30");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(0.5, 2);
        });

        test("sin(90) ≈ 1", () => {
            appendToDisplay("90");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(1, 2);
        });

        test("sin(180) ≈ 0", () => {
            appendToDisplay("180");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(0, 2);
        });

        test("sin(270) ≈ -1", () => {
            appendToDisplay("270");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(-1, 2);
        });

        test("sin(45) ≈ 0.707", () => {
            appendToDisplay("45");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(0.707, 2);
        });

        test("sin с отрицательным углом", () => {
            appendToDisplay("-30");
            calculateSin();
            expect(Number(getState().currentValue)).toBeCloseTo(-0.5, 2);
        });

        test("sin не выполняется при пустом значении", () => {
            calculateSin();
            expect(getState().currentValue).toBe("");
        });
    });

    describe("Косинус", () => {
        test("cos(0) = 1", () => {
            appendToDisplay("0");
            calculateCos();
            expect(Number(getState().currentValue)).toBeCloseTo(1, 5);
        });

        test("cos(60) ≈ 0.5", () => {
            appendToDisplay("60");
            calculateCos();
            expect(Number(getState().currentValue)).toBeCloseTo(0.5, 2);
        });

        test("cos(90) ≈ 0", () => {
            appendToDisplay("90");
            calculateCos();
            expect(Number(getState().currentValue)).toBeCloseTo(0, 2);
        });

        test("cos(180) ≈ -1", () => {
            appendToDisplay("180");
            calculateCos();
            expect(Number(getState().currentValue)).toBeCloseTo(-1, 2);
        });

        test("cos(45) ≈ 0.707", () => {
            appendToDisplay("45");
            calculateCos();
            expect(Number(getState().currentValue)).toBeCloseTo(0.707, 2);
        });

        test("cos с отрицательным углом", () => {
            appendToDisplay("-60");
            calculateCos();
            expect(Number(getState().currentValue)).toBeCloseTo(0.5, 2);
        });

        test("cos не выполняется при пустом значении", () => {
            calculateCos();
            expect(getState().currentValue).toBe("");
        });
    });
});

