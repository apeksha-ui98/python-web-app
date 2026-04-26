# -----------------------------
# Stage 1: Build dependencies
# -----------------------------
# Use lightweight Python image as build stage
FROM python:3.12-slim AS base

# Set working directory inside container
WORKDIR /app

# Prevent Python from generating .pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Show logs immediately (useful in containers)
ENV PYTHONUNBUFFERED=1

# Copy dependency file first for better Docker layer caching
COPY requirements.txt .

# Install packages into custom folder /install
# This folder will be copied into final runtime image
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Copy application source code
COPY . .

# -----------------------------
# Stage 2: Runtime image
# -----------------------------
# Use clean minimal image for final container
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Reapply environment variables in final stage
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Copy installed Python packages from build stage
COPY --from=base /install /usr/local

# Copy application code and static files
COPY --from=base /app /app

# Container listens on port 8080
EXPOSE 8080

# Start Flask application
CMD ["python", "app.py"]