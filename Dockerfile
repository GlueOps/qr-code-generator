# Use an official Python runtime as a parent image
FROM python:3.11.10-alpine@sha256:f089154eb2546de825151b9340a60d39e2ba986ab17aaffca14301b0b961a11c

# Copy the files into the Docker image
COPY . .

# Install dependencies
# RUN pip install --no-cache-dir fastapi uvicorn[standard] gunicorn qrcode[pil]
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8000 available to the world outside this container
EXPOSE 8000

# Run the command to start uvicorn
CMD ["fastapi", "run", "qr-generator.py", "--host", "0.0.0.0", "--port", "8000"]
