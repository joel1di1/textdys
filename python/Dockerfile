# Use an official Python runtime as a parent image
FROM python:3.11

# Install eSpeak
RUN apt-get update && apt-get install -y espeak

# Install Python dependencies
# (Ensure you include Flask and Phonemizer here)
RUN pip install Flask phonemizer gunicorn

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
# This includes your Python scripts and any other files you need
COPY . /app

# Make port 5000 available to the world outside this container
EXPOSE 5000

ENV FLASK_ENV=production

# Run main.py when the container launches
CMD gunicorn --workers=3 --bind=0.0.0.0:${PORT:-5000} main:app
