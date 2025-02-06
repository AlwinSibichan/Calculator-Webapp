# Use Python 3.8 slim image
FROM python:3.8-slim

# Set working directory
WORKDIR /app

# Install Flask and all required dependencies
RUN pip install --no-cache-dir --progress-bar off \
    flask==2.0.1 \
    Werkzeug==2.0.1 \
    Jinja2==3.0.1 \
    itsdangerous==2.0.1 \
    click==8.0.1 \
    gunicorn==20.1.0

# Copy the application
COPY . .

# Create templates directory if it doesn't exist
RUN mkdir -p templates

# Expose port 5050
EXPOSE 5050

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PORT=5050
ENV PYTHONUNBUFFERED=1

# Run the application with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5050", "app:app"] 