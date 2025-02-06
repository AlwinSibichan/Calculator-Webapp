# Calculator Web Application

A modern and robust web-based calculator application built with Python Flask and Docker.

![Docker Build and Test](https://github.com/yourusername/calculator-app/workflows/Docker%20Build%20and%20Test/badge.svg)

## Features

- Basic arithmetic operations (Addition, Subtraction, Multiplication, Division, Power)
- RESTful API endpoints
- Docker containerization
- Automated testing
- CI/CD pipeline with Jenkins
- GitHub Actions integration

## Quick Start

### Using Docker

```bash
# Build the image
docker build -t calculator-app .

# Run the container
docker run -d -p 5050:5050 --name calculator-container calculator-app
```

The application will be available at http://localhost:5050

### API Usage

```bash
# Example: Addition
curl -X POST -H "Content-Type: application/json" \
     -d '{"num1": 10, "num2": 5, "operation": "add"}' \
     http://localhost:5050/calculate

# Example: Multiplication
curl -X POST -H "Content-Type: application/json" \
     -d '{"num1": 10, "num2": 5, "operation": "multiply"}' \
     http://localhost:5050/calculate
```

## Development

### Prerequisites

- Python 3.8+
- Docker
- Jenkins (for CI/CD)

### Local Development

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

### Running Tests

```bash
# Run test script
./test_calculator.sh
```

## CI/CD Pipeline

The application uses both Jenkins and GitHub Actions for CI/CD:

### Jenkins Pipeline Stages

1. Checkout Code
2. Build Application
3. Test Application
4. Deploy Application

### GitHub Actions

Automated workflow runs on:
- Push to main branch
- Pull requests to main branch

## API Documentation

### Calculate Endpoint

- **URL**: `/calculate`
- **Method**: `POST`
- **Data Parameters**:
  ```json
  {
    "num1": number,
    "num2": number,
    "operation": string ["add", "subtract", "multiply", "divide", "power"]
  }
  ```
- **Success Response**:
  ```json
  {
    "result": number,
    "operation": string
  }
  ```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 