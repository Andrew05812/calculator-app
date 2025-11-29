/**
 * @jest-environment jsdom
 */

const {
    appendToDisplay,
    clearDisplay,
    add,
    subtract,
    multiply,
    calculate,
    memoryAdd,
    memoryClear,
    memoryRecall,
    getState
} = require("../script.js");

document.body.innerHTML = `<input id="display">`;

describe("Тесты работы с памятью", () => {

    beforeEach(() => {
        clearDisplay();
        memoryClear();
    });

    describe("Базовые операции памяти", () => {
        test("M+ добавляет значение в память", () => {
            appendToDisplay("10");
            memoryAdd();
            expect(getState().memory).toBe(10);
        });

        test("MC очищает память", () => {
            appendToDisplay("10");
            memoryAdd();
            memoryClear();
            expect(getState().memory).toBe(0);
        });

        test("MR восстанавливает значение из памяти", () => {
            appendToDisplay("25");
            memoryAdd();
            clearDisplay();
            memoryRecall();
            expect(getState().currentValue).toBe("25");
        });

        test("M+ с несколькими значениями суммирует", () => {
            appendToDisplay("10");
            memoryAdd();
            appendToDisplay("20");
            memoryAdd();
            appendToDisplay("30");
            memoryAdd();
            expect(getState().memory).toBe(60);
        });
    });

    describe("Комплексные сценарии памяти", () => {
        test("память сохраняется после вычислений", () => {
            appendToDisplay("15");
            memoryAdd();
            clearDisplay();
            appendToDisplay("5");
            add();
            appendToDisplay("3");
            calculate();
            expect(getState().memory).toBe(15);
        });

        test("M+ с отрицательными числами", () => {
            appendToDisplay("-10");
            memoryAdd();
            appendToDisplay("20");
            memoryAdd();
            expect(getState().memory).toBe(10);
        });

        test("M+ с десятичными числами", () => {
            appendToDisplay("10.5");
            memoryAdd();
            appendToDisplay("20.3");
            memoryAdd();
            expect(getState().memory).toBeCloseTo(30.8, 5);
        });

        test("MR перезаписывает текущее значение", () => {
            appendToDisplay("100");
            memoryAdd();
            clearDisplay();
            appendToDisplay("999");
            memoryRecall();
            expect(getState().currentValue).toBe("100");
        });

        test("последовательность: M+, вычисление, M+, MR", () => {
            appendToDisplay("10");
            memoryAdd();
            clearDisplay();
            appendToDisplay("5");
            add();
            appendToDisplay("3");
            calculate();
            memoryAdd();
            memoryRecall();
            expect(getState().currentValue).toBe("18");
        });
    });

    describe("Граничные случаи памяти", () => {
        test("M+ с нулем не изменяет память", () => {
            appendToDisplay("10");
            memoryAdd();
            appendToDisplay("0");
            memoryAdd();
            expect(getState().memory).toBe(10);
        });

        test("M+ с пустым значением не изменяет память", () => {
            appendToDisplay("10");
            memoryAdd();
            memoryAdd(); // пустое значение
            expect(getState().memory).toBe(10);
        });

        test("MC после M+ обнуляет память", () => {
            appendToDisplay("100");
            memoryAdd();
            memoryClear();
            memoryRecall();
            expect(getState().currentValue).toBe("0");
        });

        test("память работает с большими числами", () => {
            appendToDisplay("999999");
            memoryAdd();
            appendToDisplay("1");
            memoryAdd();
            expect(getState().memory).toBe(1000000);
        });
    });
});

