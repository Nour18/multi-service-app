# Use an official Python 3.12.4 runtime as a parent image
FROM python:3.12.4-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5001 available to the world outside this container
EXPOSE 5001

# Define environment variable for the renamed file
ENV FLASK_APP=processor.py

# Run processor.py when the container launches
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]
