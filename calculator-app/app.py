from flask import Flask, render_template, request, jsonify
import os

# Create Flask application instance
app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/calculate', methods=['POST'])
def calculate():
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
            
        if 'num1' not in data or 'num2' not in data:
            return jsonify({'error': 'Missing numbers for calculation'}), 400
            
        if 'operation' not in data:
            return jsonify({'error': 'No operation specified'}), 400
            
        num1 = float(data['num1'])
        num2 = float(data['num2'])
        operation = data['operation']

        # Validate operation type
        valid_operations = ['add', 'subtract', 'multiply', 'divide', 'power']
        if operation not in valid_operations:
            return jsonify({'error': f'Invalid operation. Must be one of: {", ".join(valid_operations)}'}), 400

        result = None
        if operation == 'add':
            result = num1 + num2
        elif operation == 'subtract':
            result = num1 - num2
        elif operation == 'multiply':
            result = num1 * num2
        elif operation == 'divide':
            if num2 == 0:
                return jsonify({'error': 'Division by zero is not allowed'}), 400
            result = num1 / num2
        elif operation == 'power':
            result = num1 ** num2
        
        # Round result to 6 decimal places to avoid floating point issues
        result = round(result, 6)
        return jsonify({'result': result, 'operation': operation})
    except ValueError as e:
        return jsonify({'error': 'Invalid number format'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5050))
    app.run(debug=False, host='0.0.0.0', port=port) 