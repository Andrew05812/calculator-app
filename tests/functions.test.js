/**
 * @jest-environment jsdom
 */

const {
    appendToDisplay,
    clearDisplay,
    subtract,
    multiply,
    divide,
    modulo,
    calculate,
    calculateSin,
    calculateCos,
    calculateSqrt,
    floorValue,
    ceilValue,
    memoryAdd,
    memoryClear,
    memoryRecall,
    getState
} = require("../script.js");

document.body.innerHTML = `<input id="display">`;

describe("Продвинутые функции калькулятора", () => {

    beforeEach(() => {
        clearDisplay();
        memoryClear();
    });

    test("10 - 4 = 6", () => {
        appendToDisplay("10");
        subtract();
        appendToDisplay("4");
        calculate();
        expect(getState().currentValue).toBe("6");
    });

    test("sin(90) ≈ 1", () => {
        appendToDisplay("90");
        calculateSin();
        expect(Number(getState().currentValue)).toBeCloseTo(1);
    });

    test("√25 = 5", () => {
        appendToDisplay("25");
        calculateSqrt();
        expect(getState().currentValue).toBe("5");
    });

    test("floor(7.8) = 7", () => {
        appendToDisplay("7.8");
        floorValue();
        expect(getState().currentValue).toBe("7");
    });

    test("память (M+ и MR)", () => {
        appendToDisplay("15");
        memoryAdd();
        memoryRecall();
        expect(getState().currentValue).toBe("15");
    });

});