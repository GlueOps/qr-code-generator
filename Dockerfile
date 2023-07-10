# Use an official Python runtime as a parent image
FROM python:3.11.4-bullseye

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["uvicorn", "qr-generator:app", "--host", "0.0.0.0", "--port", "8000"]
