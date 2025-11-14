let currentValue = '';
let previousValue = '';
let operation = null;
let memory = 0;

function appendToDisplay(value) {
    currentValue += value;
    document.getElementById('display').value = currentValue;
}

function clearDisplay() {
    currentValue = '';
    previousValue = '';
    operation = null;
    document.getElementById('display').value = '';
}

// Операция 1: Сложение
function add() {
    if (currentValue === '') return;
    if (previousValue !== '') calculate();
    operation = 'add';
    previousValue = currentValue;
    currentValue = '';
}

// Операция 2: Вычитание
function subtract() {
    if (currentValue === '') return;
    if (previousValue !== '') calculate();
    operation = 'subtract';
    previousValue = currentValue;
    currentValue = '';
}

// Операция 3: Умножение
function multiply() {
    if (currentValue === '') return;
    if (previousValue !== '') calculate();
    operation = 'multiply';
    previousValue = currentValue;
    currentValue = '';
}

// Операция 4: Деление
function divide() {
    if (currentValue === '') return;
    if (previousValue !== '') calculate();
    operation = 'divide';
    previousValue = currentValue;
    currentValue = '';
}
function modulo() {
    if (currentValue === '') return;
    if (previousValue !== '') calculate();
    operation = 'modulo';
    previousValue = currentValue;
    currentValue = '';
}

function calculate() {
    let result;
    const prev = parseFloat(previousValue);
    const current = parseFloat(currentValue);
    
    if (isNaN(prev) || isNaN(current)) return;
    
    switch(operation) {
        case 'add':
            result = prev + current;
            break;
        case 'subtract':
            result = prev - current;
            break;
        case 'multiply':
            result = prev * current;
            break;
        case 'divide':
            if (current === 0) {
                alert('Деление на ноль невозможно!');
                return;
            }
            result = prev / current;
            break;
        case 'modulo':
            result = prev % current;
            break;
        case 'power': 
            result = Math.pow(prev, current); 
            break; 
        default:
            return;
    }
    
    currentValue = result.toString();
    operation = null;
    previousValue = '';
    document.getElementById('display').value = currentValue;
}
// Операция 6: Sin 
function calculateSin() { 
    if (currentValue === '') return; 
    const value = parseFloat(currentValue); 
    // Переводим градусы в радианы 
    const radians = value * (Math.PI / 180); 
    currentValue = Math.sin(radians).toString(); 
    document.getElementById('display').value = currentValue; 
} 
// Операция 7: Cos 
function calculateCos() { 
    if (currentValue === '') return; 
    const value = parseFloat(currentValue); 
    // Переводим градусы в радианы 
    const radians = value * (Math.PI / 180); 
    currentValue = Math.cos(radians).toString(); 
    document.getElementById('display').value = currentValue; 
} 
// Операция 8: Возведение в степень 
function power() { 
    if (currentValue === '') return; 
    if (previousValue !== '') calculate(); 
    operation = 'power'; 
    previousValue = currentValue; 
    currentValue = ''; 
} 
// Операция 9: Квадратный корень 
function calculateSqrt() { 
    if (currentValue === '') return; 
    const value = parseFloat(currentValue); 
    if (value < 0) { 
        alert('Невозможно извлечь корень из отрицательного числа!'); 
        return; 
    } 
    currentValue = Math.sqrt(value).toString(); 
    document.getElementById('display').value = currentValue; 
} 
 
// Операция 10: Округление вниз 
function floorValue() { 
    if (currentValue === '') return; 
    const value = parseFloat(currentValue); 
    currentValue = Math.floor(value).toString(); 
    document.getElementById('display').value = currentValue; 
} 
 
// Операция 11: Округление вверх 
function ceilValue() { 
    if (currentValue === '') return; 
    const value = parseFloat(currentValue); 
    currentValue = Math.ceil(value).toString(); 
    document.getElementById('display').value = currentValue; 
} 
 
// Операция 12: Работа с памятью 
function memoryAdd() { 
    if (currentValue === '') return; 
    memory += parseFloat(currentValue); 


    console.log('В память добавлено:', memory); 
} 
 
function memoryClear() { 
    memory = 0; 
    console.log('Память очищена'); 
} 
 
function memoryRecall() { 
    currentValue = memory.toString(); 
    document.getElementById('display').value = currentValue; 
}
if (typeof module !== 'undefined') { 
    module.exports = { 
        appendToDisplay, 
        clearDisplay, 
        add, 
        subtract, 
        multiply, 
        divide, 
        modulo, 
        calculate, 
        calculateSin, 
        calculateCos, 
        power, 
        calculateSqrt, 
        floorValue, 
        ceilValue, 
        memoryAdd, 
        memoryClear, 
        memoryRecall, 
        getState: () => ({ 
            currentValue, 
            previousValue, 
            operation, 
            memory 
        }) 
    }; 
}