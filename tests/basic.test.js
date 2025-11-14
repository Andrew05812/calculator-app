/** 
 * @jest-environment jsdom 
 */ 
 
const { 
    appendToDisplay, 
    clearDisplay, 
    add, 
    calculate, 
    getState 
} = require("../script.js"); 
 
document.body.innerHTML = `<input id="display">`; 
 
describe("Базовые тесты калькулятора", () => { 
 
    beforeEach(() => clearDisplay()); 
 
    test("appendToDisplay работает", () => { 
        appendToDisplay("7"); 
        expect(getState().currentValue).toBe("7"); 
    }); 
 
    test("clearDisplay очищает значения", () => { 
        appendToDisplay("123"); 
        clearDisplay(); 
        expect(getState().currentValue).toBe(""); 
    }); 
    test("5 + 3 = 8", () => { 
        appendToDisplay("5"); 
        add(); 
        appendToDisplay("3"); 
        calculate(); 
        expect(getState().currentValue).toBe("8"); 
    }); 
});