# Dental Caries Detection App - GKE Deployment

This repository contains the necessary files and steps to deploy the **Dental Caries Detection App** on **Google Kubernetes Engine (GKE)**. The application is containerized using Docker and deployed using Kubernetes.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Dockerize the Application](#dockerize-the-application)
- [Push the Image to Google Container Registry (GCR)](#push-the-image-to-google-container-registry-gcr)
- [Create a GKE Cluster](#create-a-gke-cluster)
- [Kubernetes Deployment YAML](#kubernetes-deployment-yaml)
- [Kubernetes Service YAML](#kubernetes-service-yaml)
- [Deploying to GKE](#deploying-to-gke)
- [Scaling the Application](#scaling-the-application)
- [Cleaning Up Resources](#cleaning-up-resources)

## Prerequisites
Before you begin, make sure you have the following:
1. **Google Cloud Account** with a project set up.
2. **Google Cloud SDK** installed locally.
3. **Docker** installed to build the container image.
4. **kubectl** installed to manage Kubernetes.
5. Enable the following APIs in your Google Cloud project:
    - Kubernetes Engine API
```bash
gcloud services enable container.googleapis.com
```
   - Container Registry API
```bash
gcloud services enable containerregistry.googleapis.com
``` 

### Google Cloud SDK Setup
```bash
gcloud auth login
gcloud config set project [PROJECT_ID]
```

## Dockerize the Application
Create a `Dockerfile` to define the environment for your application. Here is an example `Dockerfile` for the Dental Caries Detection app.

```dockerfile
# Use Python 3.10 slim base image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1

# Upgrade pip and setuptools
RUN pip install --upgrade pip setuptools

# Copy the requirements.txt file and install dependencies
COPY requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . /app

# Expose port 8080 for the application
EXPOSE 8080

# Command to run the application
CMD ["python", "app.py"]
```

## Push the Image to Google Container Registry (GCR)
1. Build the Docker image:
   ```bash
   docker build -t gcr.io/[PROJECT_ID]/caries-detection:latest .
   ```

2. Push the image to GCR:
   ```bash
   docker push gcr.io/[PROJECT_ID]/caries-detection:latest
   ```

## Create a GKE Cluster
Create a GKE cluster where your app will be deployed:

```bash
gcloud container clusters create caries-cluster \
    --zone us-central1-a \
    --num-nodes=3
```

Once the cluster is created, configure `kubectl` to use the new cluster:

```bash
gcloud container clusters get-credentials caries-cluster --zone us-central1-a
```

## Kubernetes Deployment YAML

The `deployment.yaml` file describes the application's deployment in GKE. It defines the number of replicas (pods), the container image, and resource limits.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: caries-detection-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: caries-detection
  template:
    metadata:
      labels:
        app: caries-detection
    spec:
      containers:
      - name: caries-detection
        image: gcr.io/[PROJECT_ID]/caries-detection:latest
        ports:
        - containerPort: 8080
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### Key Components:
- **replicas**: Defines how many instances (pods) of the app will run (in this case, 3).
- **image**: Specifies the Docker image from GCR.
- **resources**: Sets resource limits to prevent a single container from consuming too much CPU or memory.

## Kubernetes Service YAML

The `service.yaml` file defines how the application is exposed externally. In this case, the service is of type `LoadBalancer` which assigns a public IP.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: caries-detection-service
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: caries-detection
```

### Key Components:
- **type: LoadBalancer**: Automatically provisions an external IP to make the service accessible to the internet.
- **port**: The external port exposed to the public.
- **targetPort**: The port where the app is running inside the container (8080).

## Deploying to GKE
Once the Docker image is pushed to GCR and the GKE cluster is ready, you can deploy your app using `kubectl`.

1. **Apply the deployment configuration:**
   ```bash
   kubectl apply -f deployment.yaml
   ```

2. **Apply the service configuration:**
   ```bash
   kubectl apply -f service.yaml
   ```

3. **Check the status of the deployment:**
   ```bash
   kubectl get pods
   ```

4. **Get the external IP of the service:**
   ```bash
   kubectl get services
   ```

You will see an `EXTERNAL-IP` in the output, which is the IP address where your application is accessible.

## Scaling the Application
To scale the application, you can adjust the number of replicas. For example, to scale the app to 5 pods:

```bash
kubectl scale deployment caries-detection-deployment --replicas=5
```

## Cleaning Up Resources
After you are done, clean up resources to avoid incurring costs.

1. **Delete the GKE cluster:**
   ```bash
   gcloud container clusters delete caries-cluster --zone us-central1-a
   ```

2. **Delete the container image:**
   ```bash
   gcloud container images delete gcr.io/[PROJECT_ID]/caries-detection:latest --force-delete-tags
   ```

## Conclusion
This README provides step-by-step instructions for deploying the Dental Caries Detection app on GKE, including details about the YAML files for Kubernetes deployment and service configuration.

