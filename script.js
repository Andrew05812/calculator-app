let currentValue = '';
let previousValue = '';
let operation = null;

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
        default:
            return;
    }
    
    currentValue = result.toString();
    operation = null;
    previousValue = '';
    document.getElementById('display').value = currentValue;
}