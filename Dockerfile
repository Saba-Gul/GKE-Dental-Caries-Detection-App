# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies required by OpenCV and other libraries
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    && rm -rf /var/lib/apt/lists/*  # Clean up apt cache

# Upgrade pip and setuptools to avoid dependency issues
RUN pip install --upgrade pip setuptools

# Copy requirements.txt first
COPY requirements.txt /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code incrementally
COPY app/ /app
COPY data/ /app/data

# Expose the port defined by the PORT environment variable
EXPOSE 8080

# Define environment variable for Gradio app
ENV GRADIO_SERVER_NAME="0.0.0.0"

# Set the PORT environment variable to 8080 (default for Cloud Run)
ENV PORT=8080

# Run the application and ensure it binds to the correct port
CMD ["python", "-u", "gradio-app.py", "--server-name", "0.0.0.0", "--server-port", "8080"]


# For deployment to GCP
# gcloud auth configure-docker   
# docker build -t gcr.io/pacific-diode-435602-h0/caries-detection-app .  
# docker push gcr.io/pacific-diode-435602-h0/caries-detection-app     
# gcloud run deploy caries-detection-app --image gcr.io/pacific-diode-435602-h0/caries-detection-app --platform managed --region us-central1 --allow-unauthenticated
